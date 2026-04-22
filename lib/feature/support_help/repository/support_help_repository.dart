import '../model/faq_item_model.dart';

class SupportHelpRepository {
  List<FaqItemModel> loadFaqs() => const <FaqItemModel>[
        FaqItemModel(
          question: 'How do I recover my account?',
          answer: 'Go to the login screen and choose Forgot Password to start recovery.',
        ),
        FaqItemModel(
          question: 'How do I report abuse?',
          answer: 'Use the report action from the post or profile menu and submit the details.',
        ),
        FaqItemModel(
          question: 'How can I manage notifications?',
          answer: 'Open settings or notification preferences to update alert categories.',
        ),
      ];
}
