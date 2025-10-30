// lib/game/overlay/companion_selection_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/screens/home/home_controller.dart';
import '../../controllers/companion_controller.dart';

class CompanionSelectionOverlay extends StatelessWidget {
  const CompanionSelectionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompanionController>();
    final homeController = Get.find<HomeController>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return WillPopScope(
      onWillPop: () async {
        homeController.closeCompanionSelection();
        return false;
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/home/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Main Content
                  Center(
                    child: Container(
                      width: size.width * 0.85,
                      height: size.height * 0.70,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/images/change_character/white_bg.png'),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 60 : 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Show unlocked companions in scrollable row
                              Expanded(
                                child: _buildUnlockedCompanionRow(
                                  controller,
                                  isTablet,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Title at the top
                  Positioned(
                    top: isTablet ? 100 : 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Select Companion',
                        style: TextStyle(
                          fontFamily: 'AkayaKanadaka',
                          fontSize: isTablet ? 48 : 36,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF6B35),
                          shadows: [
                            Shadow(
                              offset: const Offset(2, 2),
                              blurRadius: 5,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Back Button (top-left)
                  Positioned(
                    top: isTablet ? 20 : 10,
                    left: isTablet ? 20 : 10,
                    child: GestureDetector(
                      onTap: () {
                        homeController.closeCompanionSelection();
                      },
                      child: Image.asset(
                        'assets/images/back_btn.png',
                        width: isTablet ? 80 : 60,
                        height: isTablet ? 80 : 60,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockedCompanionRow(
      CompanionController controller,
      bool isTablet,
      ) {
    // Filter only unlocked companions
    final unlockedCompanions = controller.companions
        .where((companion) => controller.isCompanionUnlocked(companion.id))
        .toList();

    if (unlockedCompanions.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: isTablet ? 80 : 60,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: isTablet ? 20 : 15),
          Text(
            'No companions unlocked yet!',
            style: TextStyle(
              fontFamily: 'AkayaKanadaka',
              fontSize: isTablet ? 24 : 18,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: isTablet ? 10 : 8),
          Text(
            'Visit the Pet Shop building on the map\nto unlock new companions!',
            style: TextStyle(
              fontFamily: 'AkayaKanadaka',
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    // Scrollable horizontal row of companions
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: unlockedCompanions
            .map((companion) => Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 15 : 10),
          child: _buildCompanionOption(companion, controller, isTablet),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildCompanionOption(
      CompanionData companion,
      CompanionController controller,
      bool isTablet,
      ) {
    final optionSize = isTablet ? 180.0 : 140.0;

    return Obx(() {
      final isSelected = controller.selectedCompanion.value == companion.id;

      return GestureDetector(
        onTap: () {
          print('🐾 Selected companion: ${companion.name}');
          controller.selectCompanion(companion.id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: optionSize,
          height: optionSize + 50, // Extra height for name
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
              width: isSelected ? 4 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF4CAF50).withOpacity(0.4)
                    : Colors.black.withOpacity(0.1),
                blurRadius: isSelected ? 15 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Main companion area
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(isTablet ? 15 : 10),
                      child: Image.asset(
                        companion.displayImagePath,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Color(companion.color).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.pets,
                              size: isTablet ? 70 : 50,
                              color: Color(companion.color),
                            ),
                          );
                        },
                      ),
                    ),

                    // Selection indicator
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: isTablet ? 18 : 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Companion name
              Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  companion.name,
                  style: TextStyle(
                    fontFamily: 'AkayaKanadaka',
                    fontSize: isTablet ? 18 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}