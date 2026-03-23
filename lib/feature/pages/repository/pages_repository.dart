import '../model/page_model.dart';

class PagesRepository {
  List<PageModel> load() => const <PageModel>[
        PageModel(id: 'page_1', name: 'OptiZenqor Official', about: 'Official social updates.', posts: <String>['Roadmap Q2', 'Creator Spotlight']),
      ];
}
