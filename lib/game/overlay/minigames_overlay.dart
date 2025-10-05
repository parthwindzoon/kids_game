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
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _titleAnimation;
  late PageController _pageController;

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
    _pageController = PageController(viewportFraction: 0.6);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _titleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<MiniGame> _getMiniGames() {
    final buildingName = widget.game.currentBuildingName ?? 'School';
    return buildingMiniGames[buildingName] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;
    final buildingName = widget.game.currentBuildingName ?? 'Building';
    final miniGames = _getMiniGames();

    return Container(
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
              child: GestureDetector(
                onTap: () {
                  widget.game.overlays.remove('minigames_overlay');
                },
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
                  child: Text(
                    'For parents',
                    style: TextStyle(
                      fontFamily: 'AkayaKanadaka',
                      fontSize: isTablet ? 18 : 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),

            // Unlock All Button (top-right)
            Positioned(
              top: isTablet ? 20 : 10,
              right: isTablet ? 20 : 10,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 15,
                  vertical: isTablet ? 10 : 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF7CB342),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Unlock all',
                  style: TextStyle(
                    fontFamily: 'AkayaKanadaka',
                    fontSize: isTablet ? 18 : 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Title (animated from top)
            AnimatedBuilder(
              animation: _titleAnimation,
              builder: (context, child) {
                return Positioned(
                  top: isTablet ? 80 : 60,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: _titleAnimation.value,
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        -50 * (1 - _titleAnimation.value),
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
                height: isTablet ? 450 : 350,
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
                          value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                        }
                        return Center(
                          child: SizedBox(
                            height: Curves.easeInOut.transform(value) *
                                (isTablet ? 400 : 300),
                            width: Curves.easeInOut.transform(value) *
                                (isTablet ? 400 : 300),
                            child: child,
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

            // Bottom decorative text
            if (!isTablet)
              Positioned(
                bottom: 10,
                left: 20,
                child: Text(
                  'Restore Purchases',
                  style: TextStyle(
                    fontFamily: 'AkayaKanadaka',
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
          ],
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
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          if (!miniGame.isLocked) {
            print('Selected: ${miniGame.name}');
            widget.game.overlays.remove('minigames_overlay');
            // TODO: Navigate to the mini game
          }
        },
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Outer glow circle
              Container(
                width: isTablet ? 380 : 280,
                height: isTablet ? 380 : 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00BCD4),
                    width: isTablet ? 8 : 6,
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
                width: isTablet ? 340 : 250,
                height: isTablet ? 340 : 250,
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
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/minigames/${miniGame.imageName}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.blue.shade200,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: isTablet ? 80 : 60,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      // Lock overlay
                      if (miniGame.isLocked)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lock,
                                size: isTablet ? 60 : 40,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Decorative elements (flowers, animals, etc.)
              _buildDecorativeElements(miniGame, isTablet),
            ],
          ),
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
          right: isTablet ? 40 : 30,
          child: Text(
            '🌸',
            style: TextStyle(fontSize: isTablet ? 32 : 24),
          ),
        ),
        // Bottom flower
        Positioned(
          bottom: isTablet ? 20 : 15,
          left: isTablet ? 30 : 20,
          child: Text(
            '🌺',
            style: TextStyle(fontSize: isTablet ? 28 : 20),
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