import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/order_mode.dart';
import 'menu_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));

    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _goToMenu(OrderMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MenuScreen(
          orderMode: mode,
          tableId: mode == OrderMode.dineIn ? 'T01' : null, // temp until QR
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final isTablet = w >= 700;

    const bg = Color(0xFFF6F3F6);
    final contentMaxWidth = isTablet ? 560.0 : w;
    final tileGap = isTablet ? 22.0 : 14.0;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // ----------- Background plates (ONE screen) -----------
            IgnorePointer(
              child: Stack(
                children: [
                  // STEAK: top-left
                  Positioned(
                    left: -w * 0.30,
                    top: -h * 0.08,
                    width: w * 0.92,
                    child: Image.asset(
                      'assets/images/steak_start_screen-removebg-preview.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  // SALAD: top-right
                  Positioned(
                    right: -w * 0.18,
                    top: -h * 0.01,
                    width: w * 0.55,
                    child: Opacity(
                      opacity: 0.95,
                      child: Image.asset(
                        'assets/images/salad_start_screen-removebg-preview.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // DESSERT: bottom-left
                  Positioned(
                    left: -w * 0.20,
                    bottom: -h * 0.02,
                    width: w * 0.55,
                    child: Opacity(
                      opacity: 0.95,
                      child: Image.asset(
                        'assets/images/dessert_start_screen-removebg-preview.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // BURGER: bottom-right (smaller + lower)
                  Positioned(
                    right: -w * 0.20,
                    bottom: -h * 0.12,
                    width: w * 0.78, // smaller than before
                    child: Image.asset(
                      'assets/images/burger_start_screen.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

           
            // ----------- Center content (slightly LOWER) -----------
            Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: Offset(0, isTablet ? 30 : 24), // push content down
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 28 : 18,
                      vertical: isTablet ? 22 : 18,
                    ),
                    child: FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // LOGO above the title
                            Image.asset(
                              'assets/images/Logo Grill Empire.png',
                              height: isTablet ? 200 : 150,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 20),

                            Text(
                              'Grill Empire',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 26 : 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Welcome to Grill Empire — Where Fire Rules',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 18: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: _SquareTile(
                                      title: 'Dine-In',
                                      subtitle: 'Order for table',
                                      icon: Icons.restaurant,
                                      onTap: () => _goToMenu(OrderMode.dineIn),
                                    ),
                                  ),
                                ),
                                SizedBox(width: tileGap),
                                Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: _SquareTile(
                                      title: 'Takeaway',
                                      subtitle: 'Order to pick up',
                                      icon: Icons.shopping_bag,
                                      onTap: () => _goToMenu(OrderMode.takeaway),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SquareTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SquareTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 10),
                color: Colors.black.withOpacity(0.08),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 46, color: Colors.black87),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
