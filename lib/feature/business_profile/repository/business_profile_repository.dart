import '../model/business_profile_model.dart';

class BusinessProfileRepository {
  BusinessProfileModel load() {
    return const BusinessProfileModel(
      name: 'Nexa Studio',
      info: 'Design-first business page with contact and promotion actions.',
      analyticsPlaceholder: 'Reach, profile visits, CTA taps, and audience growth.',
    );
  }
}
