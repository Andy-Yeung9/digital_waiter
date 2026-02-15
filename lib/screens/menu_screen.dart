
import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/order_mode.dart';

class MenuScreen extends StatefulWidget {
  final OrderMode orderMode;
  final String? tableId;

  const MenuScreen({
    super.key,
    required this.orderMode,
    required this.tableId,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String? selectedCategoryId;
  final PageController _bannerController =
      PageController(viewportFraction: 0.9, initialPage: 1);
  final PageController _steakCardController =
      PageController(viewportFraction: 0.74, initialPage: 1);
  final PageController _burgerCardController =
      PageController(viewportFraction: 0.74, initialPage: 1);
  int _bannerPage = 1;
  final int _bannerCount = 3;
  int _steakCardPage = 1;
  final int _steakCardCount = 12;
  int _burgerCardPage = 1;
  final int _burgerCardCount = 5;
  int _bottomIndex = 0;
  Timer? _bannerTimer;
  Timer? _steakCardTimer;
  Timer? _burgerCardTimer;
  static const double _bottomBarHeight = 64;
  static const double _bottomBarBottomPadding = 12;

  QueryDocumentSnapshot<Object?>? _matchCategoryByLabel(
    List<QueryDocumentSnapshot<Object?>> categories,
    String label,
  ) {
    final target = label.toLowerCase();
    for (final doc in categories) {
      final data = doc.data() as Map<String, dynamic>;
      final nameTranslations =
          (data['nameTranslations'] ?? {}) as Map<String, dynamic>;
      final name = (nameTranslations['en'] ?? '').toString().toLowerCase();
      if (name.contains(target)) {
        return doc;
      }
    }
    return null;
  }

  String _translationKeyForLocale(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    if (localeCode == 'zh') return 'man';
    if (localeCode == 'en' ||
        localeCode == 'fr' ||
        localeCode == 'hi' ||
        localeCode == 'ur' ||
        localeCode == 'man') {
      return localeCode;
    }
    return 'en';
  }

  String _categoryDisplayName(
    BuildContext context,
    QueryDocumentSnapshot<Object?>? doc, {
    required String fallback,
  }) {
    if (doc == null) return fallback;
    final data = doc.data() as Map<String, dynamic>;
    final names = (data['nameTranslations'] ?? {}) as Map<String, dynamic>;
    final key = _translationKeyForLocale(context);
    final localized = (names[key] ?? '').toString().trim();
    if (localized.isNotEmpty) return localized;
    final english = (names['en'] ?? '').toString().trim();
    if (english.isNotEmpty) return english;
    return fallback;
  }

  @override
  void initState() {
    super.initState();
    selectedCategoryId = 'all';
    _startAutoScroll();
    _startSteakCardsAutoScroll();
    _startBurgerCardsAutoScroll();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _steakCardTimer?.cancel();
    _burgerCardTimer?.cancel();
    _bannerController.dispose();
    _steakCardController.dispose();
    _burgerCardController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_bannerController.hasClients) return;
      final next = _bannerPage + 1;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    });
  }

  void _startBurgerCardsAutoScroll() {
    _burgerCardTimer?.cancel();
    _burgerCardTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_burgerCardController.hasClients) return;
      final next = _burgerCardPage + 1;
      _burgerCardController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    });
  }

  void _startSteakCardsAutoScroll() {
    _steakCardTimer?.cancel();
    _steakCardTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_steakCardController.hasClients) return;
      final next = _steakCardPage + 1;
      _steakCardController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _featureTile({
    String? imagePath,
    Color? backgroundColor,
    required String title,
    required String subtitle,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imagePath != null)
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
            )
          else
            Container(color: backgroundColor ?? Colors.grey.shade400),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _promoBanner({
    required Color gradientStartColor,
    required Color gradientEndColor,
    required String title,
    required String headline,
    required String cta,
    required String imagePath,
    double textLeft = 20,
    double imageRight = -58,
    double imageTop = -34,
    double imageBottom = -34,
    double imageWidth = 290,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [gradientStartColor, gradientEndColor],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: textLeft,
            top: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.black.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  headline,
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                    height: 0.95,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cta,
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: imageRight,
            bottom: imageBottom,
            top: imageTop,
            child: SizedBox(
              width: imageWidth,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    final items = [
      {'label': 'Home', 'icon': Icons.home_outlined},
      {'label': 'Cart', 'icon': Icons.shopping_cart_outlined},
      {'label': 'Order', 'icon': Icons.checklist},
      {'label': 'Assistant', 'icon': Icons.smart_toy_outlined},
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, _bottomBarBottomPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              height: _bottomBarHeight,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = _bottomIndex == index;
                  return InkWell(
                    onTap: () => setState(() => _bottomIndex = index),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.orange.shade500
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            Text(
                              item['label'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final bannerHeight = (screenWidth * 0.33).clamp(132.0, 170.0);
        final featureHeight = (screenWidth * 0.72).clamp(260.0, 360.0);
        final bottomSafe = MediaQuery.of(context).padding.bottom;
        final bottomInset = _bottomBarHeight +
            _bottomBarBottomPadding +
            bottomSafe +
            24;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: Column(
                    children: [
          // ---------- Top row: back + actions ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios_new),
                  tooltip: 'Back',
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.language),
                  tooltip: 'Language',
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.checklist),
                  tooltip: 'Checklist',
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_cart_outlined),
                  tooltip: 'Cart',
                ),
              ],
            ),
          ),

          // ---------- Second row: search + filter ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Search here...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Text('Filter'),
                      SizedBox(width: 6),
                      Icon(Icons.tune),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ---------- Banner carousel ----------
          SizedBox(
            height: bannerHeight,
            child: PageView.builder(
              controller: _bannerController,
              clipBehavior: Clip.none,
              itemCount: _bannerCount + 2,
              onPageChanged: (index) {
                if (index == 0) {
                  _bannerPage = _bannerCount;
                  _bannerController.jumpToPage(_bannerCount);
                  return;
                }
                if (index == _bannerCount + 1) {
                  _bannerPage = 1;
                  _bannerController.jumpToPage(1);
                  return;
                }
                _bannerPage = index;
              },
              itemBuilder: (context, index) {
                int bannerIndex;
                if (index == 0) {
                  bannerIndex = _bannerCount - 1;
                } else if (index == _bannerCount + 1) {
                  bannerIndex = 0;
                } else {
                  bannerIndex = index - 1;
                }
                final banners = [
                  {
                    'startColor': const Color(0xFFB9DD91),
                    'endColor': const Color(0xFFE7EEAF),
                    'title': 'Juicy Deal Drop',
                    'headline': '10% Off',
                    'cta': 'Order Now',
                    'image': 'assets/images/Home_Page_Banner/Burger_Explosion.png',
                    'textLeft': 20.0,
                    'imgRight': -60.0,
                    'imgTop': -30.0,
                    'imgBottom': -30.0,
                    'imgWidth': 290.0,
                  },
                  {
                    'startColor': const Color(0xFFF6B5C9),
                    'endColor': const Color(0xFFEFD0DD),
                    'title': 'Cocktail Rush',
                    'headline': 'Buy 1 Get 1',
                    'cta': 'Grab Now',
                    'image':
                        'assets/images/Home_Page_Banner/Cocktail_Explosion.png',
                    'textLeft': 28.0,
                    'imgRight': -108.0,
                    'imgTop': -30.0,
                    'imgBottom': -10.0,
                    'imgWidth': 350.0,
                  },
                  {
                    'startColor': const Color(0xFFBFD3C1),
                    'endColor': const Color(0xFFE9F0EA),
                    'title': 'Seasoned Steak',
                    'headline': '20% Off',
                    'cta': 'Try Today',
                    'image':
                        'assets/images/Home_Page_Banner/Seasoning_Steak.png',
                    'textLeft': 28.0,
                    'imgRight': -130.0,
                    'imgTop': -24.0,
                    'imgBottom': -15.0,
                    'imgWidth': 400.0,
                  },
                ];
                final data = banners[bannerIndex % banners.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _promoBanner(
                    gradientStartColor: data['startColor'] as Color,
                    gradientEndColor: data['endColor'] as Color,
                    title: data['title'] as String,
                    headline: data['headline'] as String,
                    cta: data['cta'] as String,
                    imagePath: data['image'] as String,
                    textLeft: data['textLeft'] as double,
                    imageRight: data['imgRight'] as double,
                    imageTop: data['imgTop'] as double,
                    imageBottom: data['imgBottom'] as double,
                    imageWidth: data['imgWidth'] as double,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // ---------- Category label ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
            child: Row(
              children: const [
                Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ---------- Category chips ----------
          SizedBox(
            height: 96,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('MenuCategories')
                  .where('isActive', isEqualTo: true)
                  .orderBy('sortOrder')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading categories'));
                }

                final categories = snapshot.data?.docs ?? [];

                final iconItems = [
                  {'query': 'All', 'fallback': 'All', 'asset': ''},
                  {
                    'query': 'Steak',
                    'fallback': 'Steak',
                    'asset': 'assets/icons/steak.png',
                  },
                  {
                    'query': 'Burgers',
                    'fallback': 'Burgers',
                    'asset': 'assets/icons/burger.png',
                  },
                  {
                    'query': 'Fries',
                    'fallback': 'Fries',
                    'asset': 'assets/icons/french-fries.png',
                  },
                  {
                    'query': 'Desserts',
                    'fallback': 'Desserts',
                    'asset': 'assets/icons/dessert.png',
                  },
                  {
                    'query': 'Drinks',
                    'fallback': 'Drinks',
                    'asset': 'assets/icons/soft-drink.png',
                  },
                ];

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: iconItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = iconItems[index];
                    final queryLabel = item['query']!;
                    final fallbackLabel = item['fallback']!;
                    final asset = item['asset']!;

                    final isAll = queryLabel == 'All';
                    final match =
                        isAll ? null : _matchCategoryByLabel(categories, queryLabel);
                    final selectedId = isAll ? 'all' : (match?.id ?? '__none__');
                    final isSelected = selectedCategoryId == selectedId;
                    final displayLabel = isAll
                        ? fallbackLabel
                        : _categoryDisplayName(
                            context,
                            match,
                            fallback: fallbackLabel,
                          );

                    return GestureDetector(
                      onTap: () {
                        if (!isAll && match == null) return;
                        setState(() => selectedCategoryId = selectedId);
                      },
                      child: SizedBox(
                        width: 70,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.orange.shade400
                                    : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(9),
                                child: isAll
                                    ? Icon(
                                        Icons.grid_view_rounded,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                      )
                                    : Image.asset(
                                        asset,
                                        color: isSelected ? Colors.white : null,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              displayLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ---------- Feature tiles (All) ----------
          if (selectedCategoryId == 'all')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: SizedBox(
                height: featureHeight,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _featureTile(
                              imagePath:
                                  'assets/images/Home_Page_Banner/best deal.jpg',
                              title: 'Deal of the Moment',
                              subtitle: 'Best Deal Picks',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            flex: 2,
                            child: _featureTile(
                              imagePath:
                                  'assets/images/Home_Page_Banner/dessert.jpg',
                              title: 'Sweet Cravings',
                              subtitle: 'Dessert Delights',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _featureTile(
                              imagePath:
                                  'assets/images/Home_Page_Banner/Steak.jpg',
                              title: 'Sizzling Steak',
                              subtitle: 'Fire-Grilled Flavor',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            flex: 3,
                            child: _featureTile(
                              imagePath:
                                  'assets/images/Home_Page_Banner/burger.jpg',
                              title: 'Burger Bliss',
                              subtitle: 'Juicy & Loaded',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('MenuCategories')
                .where('isActive', isEqualTo: true)
                .orderBy('sortOrder')
                .snapshots(),
            builder: (context, snapshot) {
              final categories = snapshot.data?.docs ?? [];
              final steakDoc = _matchCategoryByLabel(categories, 'Steak');
              final steakTitle = _categoryDisplayName(
                context,
                steakDoc,
                fallback: 'Steak',
              );

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Row(
                  children: [
                    Text(
                      steakTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'See More>>',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(
            height: 242,
            child: PageView.builder(
              controller: _steakCardController,
              clipBehavior: Clip.none,
              itemCount: _steakCardCount + 2,
              onPageChanged: (index) {
                if (index == 0) {
                  _steakCardPage = _steakCardCount;
                  _steakCardController.jumpToPage(_steakCardCount);
                  return;
                }
                if (index == _steakCardCount + 1) {
                  _steakCardPage = 1;
                  _steakCardController.jumpToPage(1);
                  return;
                }
                _steakCardPage = index;
              },
              itemBuilder: (context, index) {
                int itemIndex;
                if (index == 0) {
                  itemIndex = _steakCardCount - 1;
                } else if (index == _steakCardCount + 1) {
                  itemIndex = 0;
                } else {
                  itemIndex = index - 1;
                }

                final steakCards = [
                  {
                    'title': 'BBQ Chicken Steak',
                    'description':
                        'Chargrilled chicken steak,\nsmoky BBQ glaze,\nserved juicy hot.',
                    'price': 'Rs 540',
                    'imageScale': 1.00,
                    'imageUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-steaks%2FBBQ_chicken-removebg-preview.png?alt=media',
                  },
                  {
                    'title': 'Chicken Breast Steak',
                    'description':
                        'Lean grilled chicken breast,\nlight herb seasoning,\nclean savory finish.',
                    'price': 'Rs 560',
                    'imageScale': 1.00,
                    'imageDx': 0.0,
                    'imageDy': 0.0,
                    'imageUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-steaks%2FSteak_Chicken_Breast-removebg-preview.png?alt=media',
          
                  },
                  {
                    'title': 'Peri Peri \nChicken Steak',
                    'description':
                        'Spicy peri peri chicken,\nbold grilled heat,\nzesty finish.',
                    'price': 'Rs 570',
                    'imageScale': 0.98,
                    'imageUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-steaks%2FPeri_Peri-removebg-preview.png?alt=media',
                    'imageBackupUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-steaks%2FPeri_Peri.png?alt=media',
                  },
                  {
                    'title': 'Chicken Supreme Steak',
                    'description':
                        'Signature chicken steak,\ncreamy mushroom sauce,\nhouse favorite.',
                    'price': 'Rs 610',
                    'imageScale': 1.00,
                    'imageUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-steaks%2Fchicken_supreme-removebg-preview.png?alt=media',
                  },
                  {
                    'title': 'Teriyaki\nChicken Steak',
                    'description':
                        'Teriyaki glazed chicken,\nsweet-savory balance,\ngrilled to finish.',
                    'price': 'Rs 590',
                    'imageScale': 0.95,
                    'imageUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-steaks%2Fchicken_teriyaki_steak-removebg-preview.png?alt=media',
                  },
                  {
                    'title': 'Filet Mignon',
                    'description':
                        'Premium tenderloin cut,\nbuttery texture,\npan-seared finish.',
                    'price': 'Rs 800',
                    'imageScale': 1.10,
                    'imageUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-steaks%2FFillet_Mignon-removebg-preview.png?alt=media',
                    'imageBackupUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-steaks%2FFillet_Mignon.png?alt=media',
                  },
                  {
                    'title': 'New York Strip Steak',
                    'description':
                        'Classic strip cut,\nrich beef flavor,\ncrisp seared edge.',
                    'price': 'Rs 780',
                    'imageScale': 1.00,
                    'imageUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-steaks%2FNY_strip-removebg-preview.png?alt=media',
                    'imageBackupUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-steaks%2FNY_strip.png?alt=media',
                  },
                  {
                    'title': 'T-Bone Steak',
                    'description':
                        'Bone-in classic cut,\nrich marbling,\ndeep grilled flavor.',
                    'price': 'Rs 790',
                    'imageScale': 0.92,
                    'imageUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-steaks%2FTbone_steak-removebg-preview.png?alt=media',
                  },
                  {
                    'title': 'Ribeye Steak',
                    'description':
                        'Well-marbled ribeye,\nintense meaty flavor,\nperfectly grilled.',
                    'price': 'Rs 800',
                    'imageScale': 1.05,
                    'imageUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-steaks%2Fribeye_steak-removebg-preview.png?alt=media',
                  },
                  {
                    'title': 'Sirloin Steak',
                    'description':
                        'Balanced sirloin cut,\nmeaty bite,\npepper-herb finish.',
                    'price': 'Rs 740',
                    'imageScale': 1.00,
                    'imageUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-steaks%2Fsirloin_steak-removebg-preview.png?alt=media',
                  },
                  {
                    'title': 'Shawarma Spiced Steak',
                    'description':
                        'Shawarma-spiced steak,\ngrilled and aromatic,\nserved with garlic notes.',
                    'price': 'Rs 600',
                    'imageScale': 0.92,
                    'imageUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-steaks%2Fshawarma_steak-removebg-preview.png?alt=media',
                  },
                  {
                    'title': 'Salmon Fillet Steak',
                    'description':
                        'Pan-seared salmon,\nlemon herb butter,\nflaky and tender.',
                    'price': 'Rs 760',
                    'imageScale': 1.02,
                    'imageUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-steaks%2FSalmon_fillet-removebg-preview.png?alt=media',
                    'imageBackupUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-steaks%2FSalmon_fillet.png?alt=media',
                  },
                 
                ];

                final card = steakCards[itemIndex % steakCards.length];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
                  child: _showcaseCard(
                    title: card['title'] as String,
                    description: card['description'] as String,
                    price: card['price'] as String,
                    imageUrl: card['imageUrl'] as String,
                    imageBackupUrl: card['imageBackupUrl'] as String?,
                    imageBackupUrl2: card['imageBackupUrl2'] as String?,
                    imageScale: (card['imageScale'] as num).toDouble(),
                    imageDx: (card['imageDx'] as num?)?.toDouble() ?? 0,
                    imageDy: (card['imageDy'] as num?)?.toDouble() ?? 0,
                    cardStartColor: const Color(0xFFEAD3B5),
                    cardEndColor: const Color(0xFFDCE6DA),
                    titleColor: Colors.black87,
                    descriptionColor: Colors.black54,
                  ),
                );
              },
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('MenuCategories')
                .where('isActive', isEqualTo: true)
                .orderBy('sortOrder')
                .snapshots(),
            builder: (context, snapshot) {
              final categories = snapshot.data?.docs ?? [];
              final burgersDoc = _matchCategoryByLabel(categories, 'Burgers');
              final burgersTitle = _categoryDisplayName(
                context,
                burgersDoc,
                fallback: 'Burgers',
              );

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Row(
                  children: [
                    Text(
                      burgersTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'See More>>',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(
            height: 242,
            child: PageView.builder(
              controller: _burgerCardController,
              clipBehavior: Clip.none,
              itemCount: _burgerCardCount + 2,
              onPageChanged: (index) {
                if (index == 0) {
                  _burgerCardPage = _burgerCardCount;
                  _burgerCardController.jumpToPage(_burgerCardCount);
                  return;
                }
                if (index == _burgerCardCount + 1) {
                  _burgerCardPage = 1;
                  _burgerCardController.jumpToPage(1);
                  return;
                }
                _burgerCardPage = index;
              },
              itemBuilder: (context, index) {
                int itemIndex;
                if (index == 0) {
                  itemIndex = _burgerCardCount - 1;
                } else if (index == _burgerCardCount + 1) {
                  itemIndex = 0;
                } else {
                  itemIndex = index - 1;
                }

                final burgerCards = [
                  {
                    'title': 'Chicken Breast Burger',
                    'description':
                        'Fresh grilled chicken,\ncrisp lettuce,\nand house sauce.',
                    'price': 'Rs 250',
                    'imageScale': 1.00,
                    'imageUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-burgers%2Fchicken_breast-removebg-preview.png?alt=media',
                  },
                  {
                    'title': 'Beef Burger',
                    'description':
                        'Juicy beef patty,\ncheddar, lettuce,\nand signature sauce.',
                    'price': 'Rs 350',
                    'imageScale': 0.88,
                    'imageUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-burgers%2FBeef_Burger.png?alt=media',
                  },
                  {
                    'title': 'Beyond Meat Burger',
                    'description':
                        'Plant-based patty,\nfresh veggies,\nand smoky dressing.',
                    'price': 'Rs 300',
                    'imageScale': 1.00,
                    'imageUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-burgers%2Fburger_veg-removebg-preview.png?alt=media',
                  },
                  {
                    'title': 'Teriyaki Chicken',
                    'description':
                        'Teriyaki glazed thigh,\ncrunchy slaw,\nand sesame mayo.',
                    'price': 'Rs 320',
                    'imageScale': 1.14,
                    'imageUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-burgers%2FChicken_Teriyaki-removebg-preview.png?alt=media',
                  },
                  {
                    'title': 'Catfish Fillet',
                    'description':
                        'Crispy fish fillet,\nlettuce, pickles,\nand tartar sauce.',
                    'price': 'Rs 300',
                    'imageScale': 1.00,
                    'imageUrl':
                        'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-burgers%2Ffillet_burger-removebg-preview.png?alt=media',
                  },
                ];

                final card = burgerCards[itemIndex % burgerCards.length];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
                  child: _showcaseCard(
                    title: card['title'] as String,
                    description: card['description'] as String,
                    price: card['price'] as String,
                    imageUrl: card['imageUrl'] as String,
                    imageScale: (card['imageScale'] as num).toDouble(),
                    cardStartColor: const Color(0xFFE9EFE6),
                    cardEndColor: const Color(0xFFF2C28F),
                    titleColor: Colors.black87,
                    descriptionColor: Colors.black54,
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // ---------- Items (hidden for now) ----------
          const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        _bottomBarBottomPadding + _bottomBarHeight - 8,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _bottomBar(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _showcaseCard({
    required String title,
    required String description,
    required String price,
    required String imageUrl,
    String? imageBackupUrl,
    String? imageBackupUrl2,
    double imageScale = 1.0,
    double imageDx = 0,
    double imageDy = 0,
    Color cardStartColor = const Color(0xFFFFF2D9),
    Color cardEndColor = const Color(0xFFFFE3B3),
    Color titleColor = Colors.black87,
    Color descriptionColor = Colors.black54,
  }) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardStartColor,
            cardEndColor,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -42,
            top: -44,
            child: Container(
              width: 168,
              height: 168,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Transform.translate(
                  offset: Offset(imageDx, imageDy),
                  child: Transform.scale(
                    scale: imageScale,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        if (imageBackupUrl == null || imageBackupUrl.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Image.network(
                          imageBackupUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            if (imageBackupUrl2 == null ||
                                imageBackupUrl2.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Image.network(
                              imageBackupUrl2,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox.shrink(),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 106, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: descriptionColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                price,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
