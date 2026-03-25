class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, dynamic>? params}) async {
    // Placeholder for Firebase Analytics / Segment / Mixpanel integration.
    name;
    params;
  }

  Future<void> onboardingCompleted() => logEvent('onboarding_complete');
  Future<void> signupCompleted() => logEvent('signup_complete');
  Future<void> firstPostCreated() => logEvent('first_post');
  Future<void> followAction() => logEvent('follow_action');
  Future<void> profileViewed() => logEvent('profile_view');
  Future<void> messageOpened() => logEvent('message_open');
  Future<void> premiumClicked() => logEvent('premium_click');
}
