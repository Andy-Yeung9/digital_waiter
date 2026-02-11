
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
  int _bannerIndex = 0;
  int _bannerPage = 1;
  final int _bannerCount = 3;
  int _bottomIndex = 0;
  Timer? _bannerTimer;

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

  @override
  void initState() {
    super.initState();
    selectedCategoryId = 'all';
    _startAutoScroll();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
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
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
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
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _bottomBar(),
      body: SafeArea(
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
            height: 142,
            child: PageView.builder(
              controller: _bannerController,
              clipBehavior: Clip.none,
              itemCount: _bannerCount + 2,
              onPageChanged: (index) {
                if (index == 0) {
                  _bannerPage = _bannerCount;
                  _bannerController.jumpToPage(_bannerCount);
                  _bannerIndex = _bannerCount - 1;
                  return;
                }
                if (index == _bannerCount + 1) {
                  _bannerPage = 1;
                  _bannerController.jumpToPage(1);
                  _bannerIndex = 0;
                  return;
                }
                _bannerPage = index;
                _bannerIndex = index - 1;
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
                  {'label': 'All', 'asset': ''},
                  {'label': 'Steak', 'asset': 'assets/icons/steak.png'},
                  {'label': 'Burger', 'asset': 'assets/icons/burger.png'},
                  {'label': 'Fries', 'asset': 'assets/icons/french-fries.png'},
                  {'label': 'Desserts', 'asset': 'assets/icons/dessert.png'},
                  {'label': 'Drinks', 'asset': 'assets/icons/soft-drink.png'},
                ];

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: iconItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = iconItems[index];
                    final label = item['label']!;
                    final asset = item['asset']!;

                    final isAll = label == 'All';
                    final match =
                        isAll ? null : _matchCategoryByLabel(categories, label);
                    final selectedId = isAll ? 'all' : (match?.id ?? '__none__');
                    final isSelected = selectedCategoryId == selectedId;

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
                              label,
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
                height: 300,
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

          const Divider(height: 1),

          // ---------- Items (hidden for now) ----------
          const SizedBox.shrink(),
        ],
      ),
      ),
    );
  }
}
