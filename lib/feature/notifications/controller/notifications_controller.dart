import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../app_route/route_names.dart';
import '../../../core/data/models/load_state_model.dart';
import '../../../core/data/models/notification_model.dart';
import '../../../core/data/service/analytics_service.dart';
import '../../../core/data/service/deep_link_service.dart';
import '../../../core/socket/socket_event.dart';
import '../../../core/socket/socket_handler.dart';
import '../../../core/socket/socket_service.dart';
import '../model/notification_payload_model.dart';
import '../repository/notifications_repository.dart';

enum NotificationFilter { all, social, commerce, security }

class NotificationsController extends ChangeNotifier {
  NotificationsController({
    NotificationsRepository? repository,
    DeepLinkService? deepLinkService,
    AnalyticsService? analytics,
    SocketService? socketService,
  }) : _repository = repository ?? NotificationsRepository(),
       _deepLinkService = deepLinkService ?? DeepLinkService(),
       _analytics = analytics ?? AnalyticsService(),
       _socketService = socketService ?? SocketService.instance;

  final NotificationsRepository _repository;
  final DeepLinkService _deepLinkService;
  final AnalyticsService _analytics;
  final SocketService _socketService;
  StreamSubscription<SocketEnvelope>? _notificationSubscription;

  LoadStateModel state = const LoadStateModel();
  List<NotificationModel> notifications = <NotificationModel>[];
  NotificationFilter activeFilter = NotificationFilter.all;
  final Set<String> _readIds = <String>{};

  List<NotificationModel> get visibleNotifications {
    switch (activeFilter) {
      case NotificationFilter.all:
        return notifications;
      case NotificationFilter.social:
        return notifications
            .where((n) => n.payload.type == NotificationType.social)
            .toList();
      case NotificationFilter.commerce:
        return notifications
            .where((n) => n.payload.type == NotificationType.commerce)
            .toList();
      case NotificationFilter.security:
        return notifications
            .where((n) => n.payload.type == NotificationType.security)
            .toList();
    }
  }

  bool isUnread(NotificationModel item) =>
      item.unread && !_readIds.contains(item.id);
  int get unreadCount =>
      notifications.where((NotificationModel n) => isUnread(n)).length;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();
    try {
      notifications = await _repository.fetchNotifications();
      await _ensureSocketSubscription();
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        isEmpty: notifications.isEmpty,
      );
      notifyListeners();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Unable to load notifications',
      );
      notifyListeners();
    }
  }

  Future<void> _ensureSocketSubscription() async {
    if (_notificationSubscription != null) {
      return;
    }
    await _socketService.connect();
    _notificationSubscription = _socketService.notificationEvents.listen(
      _handleSocketNotification,
    );
  }

  void _handleSocketNotification(SocketEnvelope envelope) {
    if (envelope.event != SocketEvent.notificationCreated &&
        envelope.event != SocketEvent.notificationUpdated) {
      return;
    }
    final NotificationModel incoming = NotificationModel.fromApiJson(
      envelope.data,
    );
    if (incoming.id.isEmpty) {
      return;
    }
    notifications = <NotificationModel>[
      incoming,
      ...notifications.where(
        (NotificationModel item) => item.id != incoming.id,
      ),
    ];
    state = state.copyWith(
      isEmpty: notifications.isEmpty,
      isSuccess: notifications.isNotEmpty,
      hasError: false,
      errorMessage: null,
    );
    notifyListeners();
  }

  Future<void> setFilter(NotificationFilter filter) async {
    activeFilter = filter;
    await _analytics.logEvent(
      'notification_filter',
      params: <String, dynamic>{'filter': filter.name},
    );
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    final List<String> unreadIds = notifications
        .where(isUnread)
        .map((NotificationModel item) => item.id)
        .where((String id) => id.trim().isNotEmpty)
        .toList(growable: false);
    if (unreadIds.isEmpty) {
      return;
    }
    _readIds.addAll(unreadIds);
    notifyListeners();
    await _repository.markAllRead(unreadIds);
  }

  Future<void> markRead(NotificationModel item) async {
    if (!isUnread(item)) {
      return;
    }
    _readIds.add(item.id);
    notifyListeners();
    await _repository.markRead(item.id);
  }

  Future<void> removeNotification(String notificationId) async {
    final previousNotifications = notifications;
    notifications = notifications
        .where((item) => item.id != notificationId)
        .toList();
    notifyListeners();
    try {
      await _repository.deleteNotification(notificationId);
    } catch (error) {
      notifications = previousNotifications;
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Unable to delete notification',
      );
      notifyListeners();
    }
  }

  Future<String?> handleTap(NotificationModel item) async {
    await markRead(item);
    await _analytics.logEvent(
      'notification_tap',
      params: <String, dynamic>{
        'notificationId': item.id,
        'title': item.title,
        'type': item.payload.type.name,
      },
    );
    return _openPayload(item.payload);
  }

  Future<String?> openPushPayload(Map<String, dynamic> payload) async {
    final NotificationPayloadModel normalized =
        NotificationPayloadModel.fromMap(payload);

    await _analytics.logEvent(
      'push_notification_open',
      params: <String, dynamic>{
        'type': normalized.type.name,
        'route': normalized.routeName,
        if (normalized.entityId != null) 'entityId': normalized.entityId,
      },
    );

    return _openPayload(normalized);
  }

  Future<String?> _openPayload(NotificationPayloadModel payload) async {
    final String? resolvedRoute = await _deepLinkService.open(
      payload.routeName,
    );
    final _NotificationNavigationTarget? target = _resolveNavigationTarget(
      payload,
      resolvedRoute: resolvedRoute,
    );
    if (target == null) {
      return resolvedRoute;
    }

    await AppGet.toNamed(
      target.routeName,
      parameters: target.parameters,
      arguments: target.arguments,
    );
    return target.routeName;
  }

  _NotificationNavigationTarget? _resolveNavigationTarget(
    NotificationPayloadModel payload, {
    String? resolvedRoute,
  }) {
    final Map<String, dynamic> metadata = payload.metadata;
    final String rawRoute = (resolvedRoute ?? payload.routeName).trim();
    final Uri? uri = Uri.tryParse(rawRoute);
    final String route = _normalizeRoutePath(uri?.path ?? rawRoute);
    final Map<String, String> queryParameters = uri?.queryParameters ?? {};
    final String entityType = _firstString(<Object?>[
      metadata['entityType'],
      metadata['targetType'],
      metadata['targetEntityType'],
      metadata['section'],
      metadata['kind'],
    ]).toLowerCase();
    final String entityId = _firstString(<Object?>[
      payload.entityId,
      queryParameters['id'],
      metadata['entityId'],
      metadata['targetId'],
      metadata['targetEntityId'],
      metadata['id'],
    ]);
    final Map<String, dynamic> arguments = <String, dynamic>{
      ...metadata,
      if (payload.entityId != null) 'entityId': payload.entityId,
      if (entityId.isNotEmpty) 'targetId': entityId,
    };

    final String postId = _firstString(<Object?>[
      queryParameters['postId'],
      queryParameters['id'],
      metadata['postId'],
      if (_looksLikeType(entityType, <String>['post', 'comment'])) entityId,
    ]);
    if (route == RouteNames.postDetail ||
        route.startsWith('/post/') ||
        route.startsWith('/posts/') ||
        postId.isNotEmpty) {
      final String id = postId.isNotEmpty ? postId : entityId;
      if (id.isNotEmpty) {
        return _NotificationNavigationTarget(
          routeName: RouteNames.postDetail,
          parameters: <String, String>{'id': id},
          arguments: arguments,
        );
      }
    }

    final String userId = _firstString(<Object?>[
      queryParameters['userId'],
      queryParameters['id'],
      metadata['userId'],
      metadata['profileId'],
      metadata['actorId'],
      if (_looksLikeType(entityType, <String>['user', 'profile', 'account']))
        entityId,
    ]);
    if (route == RouteNames.userProfile ||
        route.startsWith('/user/') ||
        route.startsWith('/users/') ||
        route.startsWith('/profile/') ||
        route.startsWith('/profiles/') ||
        userId.isNotEmpty &&
            _looksLikeType(entityType, <String>['user', 'profile'])) {
      if (userId.isNotEmpty) {
        return _NotificationNavigationTarget(
          routeName: RouteNames.userProfile,
          parameters: <String, String>{'id': userId},
          arguments: arguments,
        );
      }
    }

    if (route == RouteNames.reels ||
        route.startsWith('/reel/') ||
        route.startsWith('/reels/') ||
        _looksLikeType(entityType, <String>['reel'])) {
      return _NotificationNavigationTarget(
        routeName: RouteNames.shell,
        arguments: <String, dynamic>{...arguments, 'tabIndex': 1},
      );
    }

    final String callSessionId = _firstString(<Object?>[
      queryParameters['sessionId'],
      queryParameters['callSessionId'],
      metadata['sessionId'],
      metadata['callSessionId'],
      _routeTail(route, <String>['/calls/sessions/', '/call/sessions/']),
      if (_looksLikeType(entityType, <String>['call'])) entityId,
    ]);
    if (route == RouteNames.calls ||
        route.startsWith('/calls/') ||
        route.startsWith('/call/') ||
        _looksLikeType(entityType, <String>['call'])) {
      if (callSessionId.isNotEmpty) {
        return _NotificationNavigationTarget(
          routeName: RouteNames.calls,
          arguments: <String, dynamic>{
            ...arguments,
            'sessionId': callSessionId,
            'callSessionId': callSessionId,
            'mode': _firstString(<Object?>[
              queryParameters['mode'],
              metadata['mode'],
              metadata['callMode'],
            ]),
          },
        );
      }
      return _NotificationNavigationTarget(
        routeName: RouteNames.calls,
        arguments: arguments,
      );
    }

    if (route == RouteNames.chat ||
        route == RouteNames.chatDetail ||
        route.startsWith('/chat/') ||
        route.startsWith('/threads/') ||
        _looksLikeType(entityType, <String>['chat', 'message', 'thread'])) {
      final String threadId = _firstString(<Object?>[
        queryParameters['threadId'],
        queryParameters['chatId'],
        metadata['threadId'],
        metadata['chatId'],
        metadata['conversationId'],
        _routeTail(route, <String>['/chat/threads/', '/threads/']),
        if (_looksLikeType(entityType, <String>['chat', 'message', 'thread']))
          entityId,
      ]);
      if (threadId.isNotEmpty) {
        return _NotificationNavigationTarget(
          routeName: RouteNames.chatDetail,
          parameters: <String, String>{'threadId': threadId},
          arguments: <String, dynamic>{
            ...arguments,
            'threadId': threadId,
            'messageId': _firstString(<Object?>[
              queryParameters['messageId'],
              metadata['messageId'],
            ]),
          },
        );
      }
      return _NotificationNavigationTarget(
        routeName: RouteNames.shell,
        arguments: <String, dynamic>{...arguments, 'tabIndex': 3},
      );
    }

    if (route == RouteNames.marketplace ||
        route == RouteNames.marketplaceDetail ||
        route.startsWith('/marketplace/') ||
        _looksLikeType(entityType, <String>[
          'marketplace',
          'product',
          'listing',
        ])) {
      return _NotificationNavigationTarget(
        routeName: RouteNames.marketplace,
        arguments: arguments,
      );
    }

    if (route == RouteNames.jobsNetworking ||
        route == RouteNames.jobsDetail ||
        route.startsWith('/jobs/') ||
        _looksLikeType(entityType, <String>['job', 'application'])) {
      return _NotificationNavigationTarget(
        routeName: RouteNames.jobsNetworking,
        arguments: arguments,
      );
    }

    if (route == RouteNames.events ||
        route == RouteNames.eventsDetail ||
        route.startsWith('/events/') ||
        _looksLikeType(entityType, <String>['event'])) {
      return _NotificationNavigationTarget(
        routeName: RouteNames.events,
        arguments: arguments,
      );
    }

    if (route == RouteNames.communities ||
        route.startsWith('/communities/') ||
        route.startsWith('/community/') ||
        _looksLikeType(entityType, <String>['community', 'group'])) {
      return _NotificationNavigationTarget(
        routeName: RouteNames.communities,
        arguments: arguments,
      );
    }

    if (route == RouteNames.pages ||
        route.startsWith('/pages/') ||
        route.startsWith('/page/') ||
        _looksLikeType(entityType, <String>['page'])) {
      return _NotificationNavigationTarget(
        routeName: RouteNames.pages,
        arguments: arguments,
      );
    }

    if (route == RouteNames.notificationsSettings ||
        route == RouteNames.pushNotificationPreferences) {
      return _NotificationNavigationTarget(
        routeName: RouteNames.pushNotificationPreferences,
        arguments: arguments,
      );
    }

    if (route.isEmpty || route == RouteNames.splash) {
      return null;
    }

    return _NotificationNavigationTarget(
      routeName: route,
      parameters: queryParameters.isEmpty ? null : queryParameters,
      arguments: arguments,
    );
  }

  String _routeTail(String route, List<String> prefixes) {
    for (final String prefix in prefixes) {
      if (!route.startsWith(prefix)) {
        continue;
      }
      final String tail = route.substring(prefix.length).trim();
      final String firstSegment = tail.split('/').first.trim();
      if (firstSegment.isNotEmpty) {
        return Uri.decodeComponent(firstSegment);
      }
    }
    return '';
  }

  String _normalizeRoutePath(String route) {
    final String normalized = route.trim();
    if (normalized.isEmpty || normalized == '/') {
      return RouteNames.splash;
    }
    return normalized.startsWith('/') ? normalized : '/$normalized';
  }

  bool _looksLikeType(String value, List<String> candidates) {
    if (value.isEmpty) {
      return false;
    }
    return candidates.any(value.contains);
  }

  String _firstString(List<Object?> values) {
    for (final Object? value in values) {
      final String text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text != 'null') {
        return text;
      }
    }
    return '';
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
    super.dispose();
  }
}

class _NotificationNavigationTarget {
  const _NotificationNavigationTarget({
    required this.routeName,
    this.parameters,
    this.arguments,
  });

  final String routeName;
  final Map<String, String>? parameters;
  final Object? arguments;
}
