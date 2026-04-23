import '../../../core/constants/storage_keys.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service/local_storage_service.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/page_model.dart';
import '../service/pages_service.dart';

class PagesRepository {
  PagesRepository({
    PagesService? service,
    LocalStorageService? storage,
  }) : _service = service ?? PagesService(),
       _storage = storage ?? LocalStorageService();

  final PagesService _service;
  final LocalStorageService _storage;

  Future<List<PageModel>> load() async {
    final List<PageModel>? remotePages = await _loadFromApi();
    if (remotePages != null) {
      return remotePages;
    }
    return _fallbackPages;
  }

  Future<String> currentUserId() async {
    final Map<String, dynamic>? authSession = await _storage.readJson(
      StorageKeys.authSession,
    );
    final Object? user = authSession?['user'];
    if (user is Map<String, dynamic>) {
      return ApiPayloadReader.readString(user['id']);
    }
    if (user is Map) {
      return ApiPayloadReader.readString(user['id']);
    }
    return 'u1';
  }

  static const List<PageModel> _fallbackPages = <PageModel>[
        PageModel(
          id: 'page_1',
          name: 'OptiZenqor Official',
          about:
              'Official product updates, launches, and community announcements from OptiZenqor.',
          posts: <String>[
            'Roadmap Q2 is live with creator tools improvements.',
            'Creator Spotlight: Maya Quinn shared her launch workflow.',
            'New moderation features are rolling out to public pages.',
          ],
          category: 'Technology',
          actionButtonLabel: 'View Page',
          reviewSummary: '4.9 rating from creators and brand partners.',
          visitorPostsSummary: 'Visitor posts are curated before publishing.',
          followersInsight: 'Reach increased 18% this week after product launch.',
          avatarUrl:
              'https://images.unsplash.com/photo-1551434678-e076c223a692?w=500',
          coverUrl:
              'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=1200',
          followersCount: 284000,
          likesCount: 191000,
          verified: true,
          ownerId: 'u2',
          location: 'Global',
          contactLabel: 'Message',
          highlights: <String>['Announcements', 'Creators', 'Product'],
        ),
        PageModel(
          id: 'page_2',
          name: 'OptiZenqor Creators',
          about:
              'Creator education, launch recaps, workshops, and partnership opportunities.',
          posts: <String>[
            'Weekly creator prompt board is now open.',
            'Live workshop replay: brand storytelling that converts.',
            'Submission form for April creator showcase is available.',
          ],
          category: 'Creator',
          actionButtonLabel: 'Follow',
          reviewSummary: 'Creators rate the page highly for practical guidance.',
          visitorPostsSummary:
              'Follower shoutouts and collaboration requests appear here.',
          followersInsight: 'Follower saves are up 24% on educational posts.',
          avatarUrl:
              'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=500',
          coverUrl:
              'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200',
          followersCount: 98200,
          likesCount: 75300,
          verified: true,
          ownerId: 'u1',
          location: 'Dhaka, Bangladesh',
          contactLabel: 'Message',
          highlights: <String>['Workshops', 'Guides', 'Collabs'],
        ),
        PageModel(
          id: 'page_3',
          name: 'Nexa Studio',
          about:
              'Design system notes, campaign breakdowns, and digital product launches from Nexa Studio.',
          posts: <String>[
            'Design sprint notes from this week are now published.',
            'Template drop for landing page hero sections is live.',
          ],
          category: 'Business',
          following: true,
          actionButtonLabel: 'Follow',
          reviewSummary: 'Praised for polished campaign references and templates.',
          visitorPostsSummary:
              'Followers can tag their launches for possible feature posts.',
          followersInsight: 'Page followers are most active around template launches.',
          avatarUrl:
              'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=500',
          coverUrl:
              'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=1200',
          followersCount: 15400,
          likesCount: 11800,
          verified: true,
          ownerId: 'u2',
          location: 'Remote Team',
          contactLabel: 'Message',
          highlights: <String>['Design', 'Templates', 'Campaigns'],
        ),
        PageModel(
          id: 'page_4',
          name: 'Luna Crafts Shop',
          about:
              'Handmade decor drops, studio updates, and new collection reveals from Luna Crafts.',
          posts: <String>[
            'Weekend lamp collection is back in stock.',
            'Studio behind-the-scenes story set is saved in highlights.',
          ],
          category: 'Shopping',
          following: true,
          actionButtonLabel: 'Follow',
          reviewSummary: 'Customers highlight quality packaging and quick support.',
          visitorPostsSummary:
              'Customer photos and delivery feedback are featured weekly.',
          followersInsight: 'Product launch posts drive the strongest engagement.',
          avatarUrl:
              'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=500',
          coverUrl:
              'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?w=1200',
          followersCount: 21400,
          likesCount: 16200,
          verified: true,
          ownerId: 'u4',
          location: 'Dhaka, Bangladesh',
          contactLabel: 'Shop Now',
          highlights: <String>['New Drops', 'Behind the Scenes', 'Reviews'],
        ),
        PageModel(
          id: 'page_5',
          name: 'Arif Talent Hub',
          about:
              'Hiring updates, recruiter notes, and networking opportunities for product and growth teams.',
          posts: <String>[
            'Open product roles for May are now pinned.',
            'Interview prep checklist for shortlisted candidates.',
          ],
          category: 'Careers',
          actionButtonLabel: 'Follow',
          reviewSummary: 'Candidates appreciate the clear hiring updates.',
          visitorPostsSummary:
              'Questions from candidates are answered in weekly roundups.',
          followersInsight:
              'Remote-role updates generate the highest profile visits.',
          avatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500',
          coverUrl:
              'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=1200',
          followersCount: 12600,
          likesCount: 8600,
          verified: false,
          ownerId: 'u5',
          location: 'Global Remote',
          contactLabel: 'Contact',
          highlights: <String>['Jobs', 'Hiring', 'Guides'],
        ),
      ];

  Future<List<PageModel>?> _loadFromApi() async {
    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _service.getEndpoint('pages');
      if (!response.isSuccess || response.data['success'] == false) {
        return null;
      }
      final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
        response.data,
        preferredKeys: const <String>['pages', 'items'],
      );
      if (items.isNotEmpty) {
        return items
            .map(PageModel.fromApiJson)
            .where((PageModel item) => item.id.isNotEmpty)
            .toList(growable: false);
      }
    } catch (_) {}
    return null;
  }
}
