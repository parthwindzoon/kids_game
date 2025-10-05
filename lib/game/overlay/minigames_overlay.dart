// lib/game/overlay/minigames_overlay.dart

import 'package:flutter/material.dart';
import 'package:kids_game/game/my_game.dart';

class MiniGamesOverlay extends StatefulWidget {
  final TiledGame game;

  const MiniGamesOverlay({super.key, required this.game});

  @override
  State<MiniGamesOverlay> createState() => _MiniGamesOverlayState();
}

class _MiniGamesOverlayState extends State<MiniGamesOverlay>
    with TickerProviderStateMixin {
  late AnimationController _titleAnimationController;
  late Animation<double> _titleAnimation;
  late PageController _pageController;

  // Animation controller for floating text effect
  late AnimationController _floatingAnimationController;
  late Animation<double> _floatingAnimation;

  final Map<String, List<MiniGame>> buildingMiniGames = {
    'School': [
      MiniGame('Learn Alphabets', 'Alphabet Learning.png', false),
      MiniGame('Learn Numbers', 'Number Learning.png', false),
      MiniGame('Simple Math', 'Simple Math.png', false),
    ],
    'Library': [
      MiniGame('Number Memory', 'Number Memory.png', false),
      MiniGame('Counting Fun', 'Counting fun.png', false),
      MiniGame('Pattern Recognition', 'Pattern Recognition.png', false),
    ],
    'Garden': [
      MiniGame('Shape Shorting', 'Shape Shorting.png', false),
    ],
    'Art Studio': [
      MiniGame('Color Filling', 'Color Filling.png', false),
      MiniGame('Color Matching', 'Color matching.png', false),
    ],
    'Zoo': [
      MiniGame('Learn Animals', 'Learn Animals.png', false),
      MiniGame('Animal Quiz', 'Animal Quiz.png', false),
      MiniGame('Animal Sounds', 'Animals with Sounds.png', false),
    ],
  };

  @override
  void initState() {
    super.initState();
    // Increased viewportFraction to 0.85 to show just a hint of adjacent games
    _pageController = PageController(viewportFraction: 0.85);

    _titleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _titleAnimation = CurvedAnimation(
      parent: _titleAnimationController,
      curve: Curves.easeOut,
    );

    // Floating animation for game names
    _floatingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOut,
    ));

    _titleAnimationController.forward();
  }

  @override
  void dispose() {
    _titleAnimationController.dispose();
    _floatingAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<MiniGame> _getMiniGames() {
    final buildingName = widget.game.currentBuildingName ?? 'School';
    return buildingMiniGames[buildingName] ?? [];
  }

  void _handleBackButton() {
    // Remove the overlay and go back to the building popup
    widget.game.overlays.remove('minigames_overlay');
    // Optionally, show the building popup again
    // widget.game.overlays.add('building_popup');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;
    final buildingName = widget.game.currentBuildingName ?? 'Building';
    final miniGames = _getMiniGames();

    return WillPopScope(
      onWillPop: () async {
        _handleBackButton();
        return false;
      },
      child: Container(
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
              // Decorative clouds
              _buildDecorativeClouds(isTablet),

              // Back Button (top-left)
              Positioned(
                top: isTablet ? 20 : 10,
                left: isTablet ? 20 : 10,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleBackButton,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 15,
                        vertical: isTablet ? 10 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: Colors.grey.shade700,
                            size: isTablet ? 24 : 18,
                          ),
                          SizedBox(width: isTablet ? 8 : 5),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 18 : 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Title (animated from top)
              AnimatedBuilder(
                animation: _titleAnimation,
                builder: (context, child) {
                  final clampedValue = _titleAnimation.value.clamp(0.0, 1.0);
                  return Positioned(
                    top: isTablet ? 80 : 60,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: clampedValue,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          -50 * (1 - clampedValue),
                        ),
                        child: Center(
                          child: Text(
                            buildingName,
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 56 : 42,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFA500),
                              shadows: [
                                Shadow(
                                  offset: const Offset(3, 3),
                                  blurRadius: 5,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Horizontal Carousel
              Center(
                child: SizedBox(
                  height: isTablet ? 450 : 380,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: miniGames.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (_pageController.position.haveDimensions) {
                            value = _pageController.page! - index;
                            // Reduce scaling effect for adjacent items
                            value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
                          }
                          return Center(
                            child: Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: _buildMiniGameCircle(
                          miniGames[index],
                          isTablet,
                          index,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeClouds(bool isTablet) {
    return Stack(
      children: [
        // Top-left clouds
        Positioned(
          top: 80,
          left: -20,
          child: Opacity(
            opacity: 0.7,
            child: Image.asset(
              'assets/images/home/background.png',
              width: isTablet ? 120 : 80,
              height: isTablet ? 80 : 60,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Top-right clouds
        Positioned(
          top: 100,
          right: -20,
          child: Opacity(
            opacity: 0.7,
            child: Image.asset(
              'assets/images/home/background.png',
              width: isTablet ? 140 : 100,
              height: isTablet ? 100 : 70,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniGameCircle(MiniGame miniGame, bool isTablet, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 150)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: clampedValue,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          print('Selected: ${miniGame.name}');
          widget.game.overlays.remove('minigames_overlay');
          // TODO: Navigate to the mini game
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Game Name
            AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingAnimation.value),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 15,
                      vertical: isTablet ? 12 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA500).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      miniGame.name,
                      style: TextStyle(
                        fontFamily: 'AkayaKanadaka',
                        fontSize: isTablet ? 24 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: const Offset(2, 2),
                            blurRadius: 3,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: isTablet ? 20 : 15),

            // Game Circle
            SizedBox(
              width: isTablet ? 240 : 180,
              height: isTablet ? 240 : 180,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Outer glow circle
                  Container(
                    width: isTablet ? 240 : 180,
                    height: isTablet ? 240 : 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00BCD4),
                        width: isTablet ? 6 : 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),

                  // Inner circle with image
                  Container(
                    width: isTablet ? 210 : 160,
                    height: isTablet ? 210 : 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/minigames/${miniGame.imageName}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.blue.shade200,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: isTablet ? 60 : 45,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Decorative elements
                  _buildDecorativeElements(miniGame, isTablet),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeElements(MiniGame miniGame, bool isTablet) {
    return Stack(
      children: [
        // Top flower
        Positioned(
          top: isTablet ? -10 : -5,
          right: isTablet ? 20 : 15,
          child: Text(
            '🌸',
            style: TextStyle(fontSize: isTablet ? 28 : 20),
          ),
        ),
        // Bottom flower
        Positioned(
          bottom: isTablet ? 10 : 8,
          left: isTablet ? 15 : 10,
          child: Text(
            '🌺',
            style: TextStyle(fontSize: isTablet ? 24 : 18),
          ),
        ),
      ],
    );
  }
}

class MiniGame {
  final String name;
  final String imageName;
  final bool isLocked;

  MiniGame(this.name, this.imageName, this.isLocked);
}