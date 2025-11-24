import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:katahari/constant/app_colors.dart';

import '../config/routes.dart';

class BottomNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigationShell({super.key, required this.navigationShell});

  void _onItemTapped(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final currentIndex = navigationShell.currentIndex;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        final currentLocation = GoRouterState.of(context).uri.path;

        if (currentLocation == AppRoutes.journal) {
          Navigator.of(context).pop();
        } else {
          if (GoRouter.of(context).canPop()) {
            GoRouter.of(context).pop();
          } else {
            context.go(AppRoutes.journal);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,

        body: Stack(
          children: [
            /// ---- PAGE CONTENT ----
            navigationShell,

            /// ---- FLOATING NAV BAR ----
            Positioned(
              left: screenWidth * 0.04,
              right: screenWidth * 0.04,
              bottom: screenHeight * 0.02,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.015,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFAED0F5),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.08),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(context, 0, Icons.list_alt_rounded, currentIndex),
                    _buildNavItem(context, 1, Icons.book_rounded, currentIndex),
                    _buildNavItem(context, 2, Icons.person_rounded, currentIndex),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context,
      int index,
      IconData icon,
      int currentIndex,
      ) {
    final bool isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(isActive ? 12 : 6),
        decoration: isActive
            ? BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 3),
            )
          ],
        )
            : null,
        child: Icon(
          icon,
          size: 28,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
