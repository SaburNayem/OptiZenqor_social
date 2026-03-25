import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/data/models/load_state_model.dart';
import '../../../core/data/models/notification_model.dart';
import '../../../core/data/service/analytics_service.dart';
import '../../../core/data/service/deep_link_service.dart';
import '../model/notification_payload_model.dart';
import '../repository/notifications_repository.dart';

enum NotificationFilter { all, social, commerce, security }

class NotificationsController extends ChangeNotifier {
  NotificationsController({
    NotificationsRepository? repository,
    DeepLinkService? deepLinkService,
    AnalyticsService? analytics,
  })  : _repository = repository ?? NotificationsRepository(),
        _deepLinkService = deepLinkService ?? DeepLinkService(),
        _analytics = analytics ?? AnalyticsService();

  final NotificationsRepository _repository;
  final DeepLinkService _deepLinkService;
  final AnalyticsService _analytics;

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

  bool isUnread(NotificationModel item) => item.unread && !_readIds.contains(item.id);
  int get unreadCount =>
      notifications.where((NotificationModel n) => isUnread(n)).length;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();
    try {
      notifications = await _repository.fetchNotifications();
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

  Future<void> setFilter(NotificationFilter filter) async {
    activeFilter = filter;
    await _analytics.logEvent('notification_filter', params: <String, dynamic>{
      'filter': filter.name,
    });
    notifyListeners();
  }

  Future<String?> handleTap(NotificationModel item) async {
    _readIds.add(item.id);
    notifyListeners();
    await _analytics.logEvent('notification_tap', params: <String, dynamic>{
      'notificationId': item.id,
      'title': item.title,
      'type': item.payload.type.name,
    });
    final route = item.payload.routeName;
    final resolvedRoute = await _deepLinkService.open(route);
    if (resolvedRoute != null && resolvedRoute.isNotEmpty) {
      final uri = Uri.tryParse(resolvedRoute);
      if (uri != null && uri.queryParameters.isNotEmpty) {
        await Get.toNamed(uri.path, parameters: uri.queryParameters);
      } else {
        await Get.toNamed(resolvedRoute, arguments: item.payload.metadata);
      }
    }
    return resolvedRoute;
  }
}
