import 'package:flutter/material.dart';

import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/marketplace_category_model.dart';
import '../model/marketplace_chat_model.dart';
import '../model/marketplace_order_model.dart';
import '../model/product_model.dart';
import '../model/seller_model.dart';
import '../service/marketplace_service.dart';

class MarketplaceSeedData {
  const MarketplaceSeedData({
    required this.products,
    required this.sellers,
    required this.categories,
    required this.savedItemIds,
    required this.followedSellerIds,
    required this.savedSearches,
    required this.recentSearches,
    required this.trendingSearches,
    required this.notifications,
    required this.blockedKeywords,
    required this.chatMessages,
    required this.offerHistory,
    required this.orders,
  });

  final List<ProductModel> products;
  final List<SellerModel> sellers;
  final List<MarketplaceCategoryModel> categories;
  final List<String> savedItemIds;
  final List<String> followedSellerIds;
  final List<String> savedSearches;
  final List<String> recentSearches;
  final List<String> trendingSearches;
  final List<String> notifications;
  final List<String> blockedKeywords;
  final List<MarketplaceChatMessage> chatMessages;
  final List<MarketplaceOfferEvent> offerHistory;
  final List<MarketplaceOrderModel> orders;
}

class MarketplaceRepository {
  MarketplaceRepository({MarketplaceService? service})
    : _service = service ?? MarketplaceService();

  final MarketplaceService _service;

  Future<MarketplaceSeedData> loadMarketplace() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final sellers = <SellerModel>[
      SellerModel(
        id: 'seller-1',
        name: 'Ava Rahman',
        avatar:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=600&q=80',
        bio:
            'Verified creator seller sharing premium camera, home, and studio gear.',
        joinDate: DateTime(2021, 3, 2),
        rating: 4.9,
        responseRate: 96,
        responseTime: 'within 12 mins',
        followers: 18340,
        following: 224,
        isVerified: true,
        sellerType: SellerType.verified,
        activeListings: 18,
        completedOrders: 316,
        reviews: const <SellerReview>[
          SellerReview(
            buyerName: 'Mila',
            rating: 5,
            comment: 'Exactly as described and delivery was fast.',
            dateLabel: '2 days ago',
          ),
          SellerReview(
            buyerName: 'Noah',
            rating: 4.8,
            comment: 'Great communication and fair negotiation.',
            dateLabel: '1 week ago',
          ),
        ],
        storeName: 'Ava Select',
        strikeStatus: 'No warnings',
      ),
      SellerModel(
        id: 'seller-2',
        name: 'Urban Home Lab',
        avatar:
            'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=600&q=80',
        bio: 'Boutique shop for premium home furniture and office upgrades.',
        joinDate: DateTime(2020, 7, 15),
        rating: 4.7,
        responseRate: 92,
        responseTime: 'within 25 mins',
        followers: 9300,
        following: 120,
        isVerified: true,
        sellerType: SellerType.shop,
        activeListings: 42,
        completedOrders: 802,
        reviews: const <SellerReview>[
          SellerReview(
            buyerName: 'Nadia',
            rating: 4.5,
            comment: 'Furniture arrived well packed.',
            dateLabel: '5 days ago',
          ),
        ],
        storeName: 'Urban Home Lab',
        strikeStatus: 'No warnings',
      ),
      SellerModel(
        id: 'seller-3',
        name: 'Rafi Hasan',
        avatar:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80',
        bio: 'Individual seller with gaming, tech, and lifestyle picks.',
        joinDate: DateTime(2022, 11, 8),
        rating: 4.6,
        responseRate: 88,
        responseTime: 'within 40 mins',
        followers: 3100,
        following: 89,
        isVerified: false,
        sellerType: SellerType.individual,
        activeListings: 7,
        completedOrders: 64,
        reviews: const <SellerReview>[
          SellerReview(
            buyerName: 'Samir',
            rating: 4.7,
            comment: 'Smooth pickup and honest condition.',
            dateLabel: '3 days ago',
          ),
        ],
        storeName: 'Rafi Deals',
        strikeStatus: '1 policy reminder',
      ),
    ];

    final products = <ProductModel>[
      ProductModel(
        id: 'item-1',
        title: 'Sony A7 IV Creator Bundle',
        description:
            'Mirrorless body with 24-70mm lens, cage, spare battery, and creator grip. Perfect for feed, reels, and live selling content.',
        price: 1890,
        category: 'Electronics',
        subcategory: 'Cameras',
        condition: ProductCondition.likeNew,
        location: 'Gulshan, Dhaka',
        distanceLabel: '2.1 km away',
        timePosted: DateTime.now().subtract(const Duration(hours: 4)),
        images: const <String>[
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1516724562728-afc824a36e84?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1495707902641-75cac588d2e9?auto=format&fit=crop&w=1200&q=80',
        ],
        sellerId: 'seller-1',
        sellerName: 'Ava Rahman',
        sellerType: SellerType.verified,
        isNegotiable: true,
        deliveryOptions: const <DeliveryOption>[
          DeliveryOption.pickup,
          DeliveryOption.shipping,
        ],
        attributes: const <String, String>{
          'Brand': 'Sony',
          'Color': 'Black',
          'Warranty': '3 months seller warranty',
          'SKU': 'CAM-AV4-001',
          'Variant': 'Body + Lens Bundle',
        },
        tags: const <String>['camera', 'creator', 'video', 'mirrorless'],
        brand: 'Sony',
        quantity: 2,
        isFeatured: true,
        isTrending: true,
        isRecommended: true,
        isRecentlyViewed: true,
        hasPriceDrop: true,
        isAuction: false,
        rating: 4.9,
        reviewCount: 28,
        reviews: const <ProductReview>[
          ProductReview(
            author: 'Tania',
            rating: 5,
            comment: 'Clean condition and amazing seller support.',
            dateLabel: '1 day ago',
          ),
          ProductReview(
            author: 'Leo',
            rating: 4.8,
            comment: 'Ready for shooting right out of the box.',
            dateLabel: '1 week ago',
          ),
        ],
        listingStatus: ListingStatus.active,
        views: 1480,
        watchers: 210,
        chats: 38,
        isHiddenByModeration: false,
        reviewStatus: 'Approved',
      ),
      ProductModel(
        id: 'item-2',
        title: 'Cloud Lounge Accent Chair',
        description:
            'Soft boucle accent chair with oak legs. Works beautifully in living rooms, studio corners, or creator lounges.',
        price: 320,
        category: 'Home & Furniture',
        subcategory: 'Living Room',
        condition: ProductCondition.newItem,
        location: 'Dhanmondi, Dhaka',
        distanceLabel: '5.4 km away',
        timePosted: DateTime.now().subtract(const Duration(hours: 10)),
        images: const <String>[
          'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1484101403633-562f891dc89a?auto=format&fit=crop&w=1200&q=80',
        ],
        sellerId: 'seller-2',
        sellerName: 'Urban Home Lab',
        sellerType: SellerType.shop,
        isNegotiable: false,
        deliveryOptions: const <DeliveryOption>[
          DeliveryOption.delivery,
          DeliveryOption.shipping,
        ],
        attributes: const <String, String>{
          'Brand': 'Urban Home Lab',
          'Color': 'Cream',
          'Size': 'Single seat',
          'Warranty': '12 months',
          'SKU': 'FUR-CHR-204',
        },
        tags: const <String>['chair', 'furniture', 'home', 'premium'],
        brand: 'Urban Home Lab',
        quantity: 9,
        isFeatured: true,
        isTrending: false,
        isRecommended: true,
        isRecentlyViewed: false,
        hasPriceDrop: false,
        isAuction: false,
        rating: 4.7,
        reviewCount: 19,
        reviews: const <ProductReview>[
          ProductReview(
            author: 'Sadia',
            rating: 4.7,
            comment: 'Looks premium and feels sturdy.',
            dateLabel: '3 days ago',
          ),
        ],
        listingStatus: ListingStatus.active,
        views: 860,
        watchers: 74,
        chats: 19,
        isHiddenByModeration: false,
        reviewStatus: 'Approved',
      ),
      ProductModel(
        id: 'item-3',
        title: 'Nintendo Switch OLED Set',
        description:
            'Switch OLED with dock, travel case, and two games included. Great family or gifting bundle.',
        price: 290,
        category: 'Electronics',
        subcategory: 'Gaming',
        condition: ProductCondition.good,
        location: 'Banani, Dhaka',
        distanceLabel: '3.0 km away',
        timePosted: DateTime.now().subtract(const Duration(days: 1)),
        images: const <String>[
          'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?auto=format&fit=crop&w=1200&q=80',
        ],
        sellerId: 'seller-3',
        sellerName: 'Rafi Hasan',
        sellerType: SellerType.individual,
        isNegotiable: true,
        deliveryOptions: const <DeliveryOption>[
          DeliveryOption.pickup,
          DeliveryOption.delivery,
        ],
        attributes: const <String, String>{
          'Brand': 'Nintendo',
          'Color': 'White',
          'Warranty': 'No warranty',
          'Variant': '128 GB bundle',
        },
        tags: const <String>['switch', 'gaming', 'console'],
        brand: 'Nintendo',
        quantity: 1,
        isFeatured: false,
        isTrending: true,
        isRecommended: true,
        isRecentlyViewed: true,
        hasPriceDrop: false,
        isAuction: false,
        rating: 4.6,
        reviewCount: 12,
        reviews: const <ProductReview>[
          ProductReview(
            author: 'Rita',
            rating: 4.5,
            comment: 'Good deal and easy meetup.',
            dateLabel: '2 weeks ago',
          ),
        ],
        listingStatus: ListingStatus.active,
        views: 630,
        watchers: 65,
        chats: 12,
        isHiddenByModeration: false,
        reviewStatus: 'Approved',
      ),
      ProductModel(
        id: 'item-4',
        title: 'Pilates Starter Reformer',
        description:
            'Compact home reformer with adjustable resistance and cushioned carriage. Includes beginner guide.',
        price: 540,
        category: 'Sports & Outdoors',
        subcategory: 'Fitness',
        condition: ProductCondition.newItem,
        location: 'Bashundhara, Dhaka',
        distanceLabel: '7.2 km away',
        timePosted: DateTime.now().subtract(const Duration(hours: 2)),
        images: const <String>[
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&w=1200&q=80',
        ],
        sellerId: 'seller-2',
        sellerName: 'Urban Home Lab',
        sellerType: SellerType.shop,
        isNegotiable: false,
        deliveryOptions: const <DeliveryOption>[DeliveryOption.delivery],
        attributes: const <String, String>{
          'Brand': 'Core Studio',
          'Color': 'Sand',
          'Warranty': '6 months',
          'SKU': 'FIT-PLT-908',
        },
        tags: const <String>['fitness', 'pilates', 'home gym'],
        brand: 'Core Studio',
        quantity: 4,
        isFeatured: false,
        isTrending: true,
        isRecommended: true,
        isRecentlyViewed: false,
        hasPriceDrop: true,
        isAuction: false,
        rating: 4.8,
        reviewCount: 8,
        reviews: const <ProductReview>[
          ProductReview(
            author: 'Mim',
            rating: 4.9,
            comment: 'Perfect for apartment workouts.',
            dateLabel: '4 days ago',
          ),
        ],
        listingStatus: ListingStatus.pending,
        views: 402,
        watchers: 42,
        chats: 9,
        isHiddenByModeration: false,
        reviewStatus: 'Pending QA',
      ),
      ProductModel(
        id: 'item-5',
        title: 'Minimalist Work Desk',
        description:
            'Walnut workstation with cable tray and matte steel frame. Designed for remote work or study setups.',
        price: 210,
        category: 'Home & Furniture',
        subcategory: 'Office',
        condition: ProductCondition.good,
        location: 'Mirpur, Dhaka',
        distanceLabel: '8.8 km away',
        timePosted: DateTime.now().subtract(const Duration(days: 3)),
        images: const <String>[
          'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1200&q=80',
        ],
        sellerId: 'seller-3',
        sellerName: 'Rafi Hasan',
        sellerType: SellerType.individual,
        isNegotiable: true,
        deliveryOptions: const <DeliveryOption>[
          DeliveryOption.pickup,
          DeliveryOption.delivery,
        ],
        attributes: const <String, String>{
          'Brand': 'Habitat',
          'Color': 'Walnut',
          'Size': '120 cm',
          'Warranty': 'No warranty',
        },
        tags: const <String>['desk', 'workspace', 'furniture'],
        brand: 'Habitat',
        quantity: 1,
        isFeatured: false,
        isTrending: false,
        isRecommended: true,
        isRecentlyViewed: true,
        hasPriceDrop: false,
        isAuction: false,
        rating: 4.4,
        reviewCount: 5,
        reviews: const <ProductReview>[
          ProductReview(
            author: 'Shafin',
            rating: 4.3,
            comment: 'Solid desk and easy pickup.',
            dateLabel: '2 months ago',
          ),
        ],
        listingStatus: ListingStatus.sold,
        views: 1220,
        watchers: 110,
        chats: 26,
        isHiddenByModeration: false,
        reviewStatus: 'Approved',
      ),
      ProductModel(
        id: 'item-6',
        title: 'Vintage Film Camera Collection',
        description:
            'Auction listing for a curated set of restored film cameras with straps and original leather cases.',
        price: 720,
        category: 'Electronics',
        subcategory: 'Vintage Cameras',
        condition: ProductCondition.refurbished,
        location: 'Old Dhaka',
        distanceLabel: '11 km away',
        timePosted: DateTime.now().subtract(const Duration(days: 2)),
        images: const <String>[
          'https://images.unsplash.com/photo-1510127034890-ba27508e9f1c?auto=format&fit=crop&w=1200&q=80',
        ],
        sellerId: 'seller-1',
        sellerName: 'Ava Rahman',
        sellerType: SellerType.verified,
        isNegotiable: false,
        deliveryOptions: const <DeliveryOption>[
          DeliveryOption.shipping,
          DeliveryOption.pickup,
        ],
        attributes: const <String, String>{
          'Brand': 'Mixed collection',
          'Color': 'Black / Silver',
          'Warranty': 'Inspection on pickup',
          'Variant': 'Auction listing',
        },
        tags: const <String>['vintage', 'auction', 'camera'],
        brand: 'Collector Series',
        quantity: 1,
        isFeatured: true,
        isTrending: false,
        isRecommended: false,
        isRecentlyViewed: false,
        hasPriceDrop: false,
        isAuction: true,
        rating: 4.9,
        reviewCount: 11,
        reviews: const <ProductReview>[
          ProductReview(
            author: 'Karim',
            rating: 5,
            comment: 'Collector-grade condition.',
            dateLabel: '6 days ago',
          ),
        ],
        listingStatus: ListingStatus.expired,
        views: 500,
        watchers: 52,
        chats: 6,
        isHiddenByModeration: false,
        reviewStatus: 'Approved',
      ),
      ProductModel(
        id: 'item-7',
        title: 'Organic Skincare Gift Box',
        description:
            'Curated beauty set with cleanser, serum, and sleeping mask in reusable packaging.',
        price: 48,
        category: 'Beauty & Personal Care',
        subcategory: 'Skincare',
        condition: ProductCondition.newItem,
        location: 'Uttara, Dhaka',
        distanceLabel: '14 km away',
        timePosted: DateTime.now().subtract(const Duration(hours: 8)),
        images: const <String>[
          'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=1200&q=80',
        ],
        sellerId: 'seller-2',
        sellerName: 'Urban Home Lab',
        sellerType: SellerType.shop,
        isNegotiable: false,
        deliveryOptions: const <DeliveryOption>[DeliveryOption.shipping],
        attributes: const <String, String>{
          'Brand': 'Atelier Skin',
          'Color': 'Natural',
          'Warranty': 'Sealed item guarantee',
        },
        tags: const <String>['beauty', 'gift', 'skincare'],
        brand: 'Atelier Skin',
        quantity: 12,
        isFeatured: false,
        isTrending: true,
        isRecommended: false,
        isRecentlyViewed: false,
        hasPriceDrop: true,
        isAuction: false,
        rating: 4.8,
        reviewCount: 24,
        reviews: const <ProductReview>[
          ProductReview(
            author: 'Pia',
            rating: 4.8,
            comment: 'Packaging felt premium and authentic.',
            dateLabel: '4 days ago',
          ),
        ],
        listingStatus: ListingStatus.draft,
        views: 0,
        watchers: 0,
        chats: 0,
        isHiddenByModeration: false,
        reviewStatus: 'Draft',
      ),
      ProductModel(
        id: 'item-8',
        title: 'Freelance UI Audit Package',
        description:
            'Digital product with recorded audit, annotated Figma feedback, and conversion-focused suggestions.',
        price: 120,
        category: 'Digital Products',
        subcategory: 'Design Services',
        condition: ProductCondition.newItem,
        location: 'Remote',
        distanceLabel: 'Online',
        timePosted: DateTime.now().subtract(const Duration(hours: 14)),
        images: const <String>[
          'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=1200&q=80',
        ],
        sellerId: 'seller-1',
        sellerName: 'Ava Rahman',
        sellerType: SellerType.verified,
        isNegotiable: true,
        deliveryOptions: const <DeliveryOption>[DeliveryOption.shipping],
        attributes: const <String, String>{
          'Brand': 'Ava Select',
          'Warranty': 'Revision window 7 days',
          'Variant': 'Recorded audit + notes',
        },
        tags: const <String>['digital', 'design', 'audit'],
        brand: 'Ava Select',
        quantity: 20,
        isFeatured: false,
        isTrending: true,
        isRecommended: true,
        isRecentlyViewed: false,
        hasPriceDrop: false,
        isAuction: false,
        rating: 5,
        reviewCount: 6,
        reviews: const <ProductReview>[
          ProductReview(
            author: 'Arian',
            rating: 5,
            comment: 'Very actionable insights.',
            dateLabel: '6 hours ago',
          ),
        ],
        listingStatus: ListingStatus.active,
        views: 210,
        watchers: 18,
        chats: 7,
        isHiddenByModeration: true,
        reviewStatus: 'Auto-hidden for keyword review',
      ),
    ];

    final MarketplaceSeedData? remoteData = await _loadRemoteMarketplace();

    return MarketplaceSeedData(
      products: remoteData?.products ?? products,
      sellers: remoteData?.sellers ?? sellers,
      categories: remoteData?.categories ?? const <MarketplaceCategoryModel>[
        MarketplaceCategoryModel(
          name: 'Vehicles',
          icon: Icons.directions_car_outlined,
          subcategories: <String>['Cars', 'Motorcycles', 'Spare Parts'],
        ),
        MarketplaceCategoryModel(
          name: 'Property',
          icon: Icons.apartment_outlined,
          subcategories: <String>['Rent', 'Sale', 'Commercial'],
        ),
        MarketplaceCategoryModel(
          name: 'Electronics',
          icon: Icons.devices_other_outlined,
          subcategories: <String>['Phones', 'Cameras', 'Gaming'],
          isFollowed: true,
        ),
        MarketplaceCategoryModel(
          name: 'Fashion',
          icon: Icons.checkroom_outlined,
          subcategories: <String>['Menswear', 'Womenswear', 'Shoes'],
        ),
        MarketplaceCategoryModel(
          name: 'Home & Furniture',
          icon: Icons.weekend_outlined,
          subcategories: <String>['Bedroom', 'Office', 'Living Room'],
          isFollowed: true,
        ),
        MarketplaceCategoryModel(
          name: 'Beauty & Personal Care',
          icon: Icons.spa_outlined,
          subcategories: <String>['Skincare', 'Haircare', 'Makeup'],
        ),
        MarketplaceCategoryModel(
          name: 'Sports & Outdoors',
          icon: Icons.sports_basketball_outlined,
          subcategories: <String>['Fitness', 'Cycling', 'Outdoor Gear'],
        ),
        MarketplaceCategoryModel(
          name: 'Books & Education',
          icon: Icons.menu_book_outlined,
          subcategories: <String>['Textbooks', 'Courses', 'Stationery'],
        ),
        MarketplaceCategoryModel(
          name: 'Toys & Kids',
          icon: Icons.toys_outlined,
          subcategories: <String>['Baby Gear', 'Learning Toys', 'Games'],
        ),
        MarketplaceCategoryModel(
          name: 'Jobs',
          icon: Icons.work_outline,
          subcategories: <String>['Remote', 'Part-time', 'Full-time'],
        ),
        MarketplaceCategoryModel(
          name: 'Services',
          icon: Icons.design_services_outlined,
          subcategories: <String>['Cleaning', 'Repair', 'Freelance'],
        ),
        MarketplaceCategoryModel(
          name: 'Pets',
          icon: Icons.pets_outlined,
          subcategories: <String>['Accessories', 'Food', 'Care'],
        ),
        MarketplaceCategoryModel(
          name: 'Food',
          icon: Icons.lunch_dining_outlined,
          subcategories: <String>['Meal Kits', 'Desserts', 'Organic'],
        ),
        MarketplaceCategoryModel(
          name: 'Events & Tickets',
          icon: Icons.confirmation_number_outlined,
          subcategories: <String>['Concerts', 'Workshops', 'Sports'],
        ),
        MarketplaceCategoryModel(
          name: 'Digital Products',
          icon: Icons.cloud_download_outlined,
          subcategories: <String>['Templates', 'Courses', 'Design Services'],
        ),
        MarketplaceCategoryModel(
          name: 'Others',
          icon: Icons.more_horiz_rounded,
          subcategories: <String>['Collectibles', 'Bundles', 'Seasonal'],
        ),
      ],
      savedItemIds: remoteData?.savedItemIds ?? const <String>['item-1', 'item-2', 'item-4'],
      followedSellerIds: remoteData?.followedSellerIds ?? const <String>['seller-1', 'seller-2'],
      savedSearches: const <String>[
        'sony camera',
        'ergonomic desk',
        'verified skincare',
      ],
      recentSearches: remoteData?.recentSearches ?? const <String>[
        'gaming console',
        'remote digital products',
        'delivery available chair',
      ],
      trendingSearches: remoteData?.trendingSearches ?? const <String>[
        'creator camera',
        'home office desk',
        'pilates reformer',
        'switch oled',
      ],
      notifications: remoteData?.notifications ?? const <String>[
        'Price dropped 8% on Sony A7 IV Creator Bundle',
        'Urban Home Lab replied to your delivery question',
        'Your draft listing passed keyword review',
      ],
      blockedKeywords: remoteData?.blockedKeywords ?? const <String>[
        'weapons',
        'counterfeit',
        'adult-only',
        'stolen',
      ],
      chatMessages: remoteData?.chatMessages ?? <MarketplaceChatMessage>[
        MarketplaceChatMessage(
          id: 'chat-1',
          senderName: 'Ava Rahman',
          text: 'Hi, yes, the bundle is still available.',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          productTitle: 'Sony A7 IV Creator Bundle',
        ),
        MarketplaceChatMessage(
          id: 'chat-2',
          senderName: 'You',
          text: 'Can you do shipping tomorrow?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        MarketplaceChatMessage(
          id: 'chat-3',
          senderName: 'Ava Rahman',
          text: 'I can ship tomorrow morning. Feel free to send an offer.',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
      offerHistory: remoteData?.offerHistory ?? <MarketplaceOfferEvent>[
        MarketplaceOfferEvent(
          actor: 'You',
          action: 'Offered',
          amount: 1760,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        MarketplaceOfferEvent(
          actor: 'Ava Rahman',
          action: 'Countered',
          amount: 1810,
          timestamp: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 20),
          ),
        ),
      ],
      orders: remoteData?.orders ?? <MarketplaceOrderModel>[
        MarketplaceOrderModel(
          id: 'ord-1',
          productId: 'item-2',
          productTitle: 'Cloud Lounge Accent Chair',
          amount: 320,
          status: MarketplaceOrderStatus.pending,
          address: 'House 14, Road 7, Dhanmondi, Dhaka',
          deliveryMethod: 'Home delivery',
          paymentMethod: 'Cash on delivery',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        MarketplaceOrderModel(
          id: 'ord-2',
          productId: 'item-5',
          productTitle: 'Minimalist Work Desk',
          amount: 210,
          status: MarketplaceOrderStatus.delivered,
          address: 'Sector 10, Uttara, Dhaka',
          deliveryMethod: 'Pickup arranged',
          paymentMethod: 'Wallet',
          createdAt: DateTime.now().subtract(const Duration(days: 6)),
        ),
      ],
    );
  }

  Future<MarketplaceSeedData?> _loadRemoteMarketplace() async {
    for (final String key in <String>['marketplace', 'products']) {
      try {
        final ServiceResponseModel<Map<String, dynamic>> response =
            await _service.getEndpoint(key);
        if (!response.isSuccess || response.data['success'] == false) {
          continue;
        }

        final List<Map<String, dynamic>> productItems =
            ApiPayloadReader.readMapList(
              response.data,
              preferredKeys: const <String>['products', 'items'],
            );
        if (productItems.isEmpty) {
          continue;
        }

        final List<ProductModel> products = productItems
            .map(ProductModel.fromApiJson)
            .where((ProductModel item) => item.id.isNotEmpty)
            .toList(growable: false);
        if (products.isEmpty) {
          continue;
        }

        final List<SellerModel> sellers = _deriveSellers(products);
        final List<MarketplaceCategoryModel> categories =
            _deriveCategories(products);

        return MarketplaceSeedData(
          products: products,
          sellers: sellers,
          categories: categories,
          savedItemIds: ApiPayloadReader.readStringList(
            response.data['savedItemIds'],
          ),
          followedSellerIds: ApiPayloadReader.readStringList(
            response.data['followedSellerIds'],
          ),
          savedSearches: ApiPayloadReader.readStringList(
            response.data['savedSearches'],
          ),
          recentSearches: ApiPayloadReader.readStringList(
            response.data['recentSearches'],
          ),
          trendingSearches: ApiPayloadReader.readStringList(
            response.data['trendingSearches'],
          ),
          notifications: ApiPayloadReader.readStringList(
            response.data['notifications'],
          ),
          blockedKeywords: ApiPayloadReader.readStringList(
            response.data['blockedKeywords'],
          ),
          chatMessages: const <MarketplaceChatMessage>[],
          offerHistory: const <MarketplaceOfferEvent>[],
          orders: const <MarketplaceOrderModel>[],
        );
      } catch (_) {}
    }

    return null;
  }

  List<SellerModel> _deriveSellers(List<ProductModel> products) {
    final Map<String, SellerModel> sellersById = <String, SellerModel>{};
    for (final ProductModel product in products) {
      if (product.sellerId.isEmpty) {
        continue;
      }
      sellersById.putIfAbsent(
        product.sellerId,
        () => SellerModel(
          id: product.sellerId,
          name: product.sellerName,
          avatar: '',
          bio: 'Marketplace seller on OptiZenqor.',
          joinDate: DateTime.now(),
          rating: product.rating,
          responseRate: 90,
          responseTime: 'within 1 day',
          followers: 0,
          following: 0,
          isVerified: product.sellerType == SellerType.verified,
          sellerType: product.sellerType,
          activeListings: products
              .where((ProductModel item) => item.sellerId == product.sellerId)
              .length,
          completedOrders: 0,
          reviews: product.reviews
              .map(
                (ProductReview item) => SellerReview(
                  buyerName: item.author,
                  rating: item.rating,
                  comment: item.comment,
                  dateLabel: item.dateLabel,
                ),
              )
              .toList(growable: false),
          storeName: product.sellerName,
          strikeStatus: 'No warnings',
        ),
      );
    }
    return sellersById.values.toList(growable: false);
  }

  List<MarketplaceCategoryModel> _deriveCategories(List<ProductModel> products) {
    final Map<String, Set<String>> categoryMap = <String, Set<String>>{};
    for (final ProductModel product in products) {
      categoryMap.putIfAbsent(product.category, () => <String>{});
      if (product.subcategory.isNotEmpty) {
        categoryMap[product.category]!.add(product.subcategory);
      }
    }

    return categoryMap.entries
        .map(
          (MapEntry<String, Set<String>> entry) => MarketplaceCategoryModel(
            name: entry.key,
            icon: _iconForCategory(entry.key),
            subcategories: entry.value.toList(growable: false),
          ),
        )
        .toList(growable: false);
  }

  IconData _iconForCategory(String category) {
    switch (category.trim().toLowerCase()) {
      case 'electronics':
        return Icons.devices_other_outlined;
      case 'home & furniture':
        return Icons.weekend_outlined;
      case 'beauty & personal care':
        return Icons.spa_outlined;
      case 'sports & outdoors':
        return Icons.sports_basketball_outlined;
      case 'digital products':
        return Icons.cloud_download_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
