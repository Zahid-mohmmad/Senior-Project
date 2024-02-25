import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uober/homeScreen/home_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late PageController pageController;
  int selectedIndex = 0;

  void onPageChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: selectedIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: const [
          HomeScreen(),
          // EarningsScreen(),
          // ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: selectedIndex == 0 ? Colors.amber : Colors.black,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Hexagon(
              child: Stack(
                children: [
                  const Icon(
                    Icons.wallet,
                    color: Colors.black,
                    size: 50,
                  ),
                  Positioned(
                    top: -20,
                    left: 3,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            label: "Wallet",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: selectedIndex == 2 ? Colors.orange : Colors.black,
            ),
            label: "Profile",
          ),
        ],
        currentIndex: selectedIndex,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.black,
        showSelectedLabels: true,
        selectedLabelStyle: GoogleFonts.poppins(),
        unselectedLabelStyle: GoogleFonts.poppins(),
        onTap: (index) {
          setState(() {
            selectedIndex = index;
            pageController.animateToPage(
              selectedIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
      ),
    );
  }
}

class Hexagon extends StatelessWidget {
  final Widget child;

  const Hexagon({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 116,
      child: CustomPaint(
        painter: _HexagonPainter(),
        child: Center(child: child),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.amber;
    final path = Path();

    final radius = size.width / 2;

    path.moveTo(radius, 0);
    path.lineTo(size.width, size.height / 4);
    path.lineTo(size.width, size.height * 3 / 4);
    path.lineTo(radius, size.height);
    path.lineTo(0, size.height * 3 / 4);
    path.lineTo(0, size.height / 4);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
