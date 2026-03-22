import 'package:flutter/foundation.dart';

import '../../../core/common_models/load_state_model.dart';
import '../../../core/common_models/notification_model.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/deep_link_service.dart';
import '../../../route/route_names.dart';
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
        return notifications.where((n) => _isSocial(n.title)).toList();
      case NotificationFilter.commerce:
        return notifications.where((n) => _isCommerce(n.title)).toList();
      case NotificationFilter.security:
        return notifications.where((n) => _isSecurity(n.title)).toList();
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
    });
    final route = _routeFromNotification(item);
    if (route != null) {
      await _deepLinkService.open(route);
    }
    return route;
  }

  bool _isSocial(String title) =>
      title.toLowerCase().contains('like') || title.toLowerCase().contains('comment');

  bool _isCommerce(String title) =>
      title.toLowerCase().contains('order') || title.toLowerCase().contains('shop');

  bool _isSecurity(String title) =>
      title.toLowerCase().contains('security') || title.toLowerCase().contains('login');

  String? _routeFromNotification(NotificationModel item) {
    if (_isSocial(item.title)) {
      return RouteNames.postDetail;
    }
    if (_isCommerce(item.title)) {
      return RouteNames.marketplace;
    }
    if (_isSecurity(item.title)) {
      return RouteNames.advancedPrivacyControls;
    }
    return null;
  }
}
