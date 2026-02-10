
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  final int _bannerCount = 3;

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
    _startAutoScroll();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (!_bannerController.hasClients) {
        _startAutoScroll();
        return;
      }
      final current = _bannerController.page?.round() ?? 1;
      final next = current + 1;
      _bannerController
          .animateToPage(
            next,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOut,
          )
          .whenComplete(_startAutoScroll);
    });
  }

  Widget _featureTile({
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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

          // ---------- Banner carousel ----------
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _bannerController,
              itemCount: _bannerCount + 2,
              onPageChanged: (index) {
                if (index == 0) {
                  _bannerController.jumpToPage(_bannerCount);
                  _bannerIndex = _bannerCount - 1;
                  return;
                }
                if (index == _bannerCount + 1) {
                  _bannerController.jumpToPage(1);
                  _bannerIndex = 0;
                  return;
                }
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
                final colors = [
                  Colors.brown.shade700,
                  Colors.orange.shade600,
                  Colors.teal.shade600,
                ];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors[bannerIndex % colors.length],
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // ---------- Category label ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
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

                // Default to "All" once
                selectedCategoryId ??= 'all';

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

