import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/navigation_service.dart';

class DynamicBottomNavBar extends StatefulWidget {
  final String currentRoute;
  final List<BottomNavItem> navItems;

  const DynamicBottomNavBar({
    Key? key,
    required this.currentRoute,
    this.navItems = NavigationConfig.mainNavItems,
  }) : super(key: key);

  @override
  State<DynamicBottomNavBar> createState() => _DynamicBottomNavBarState();
}

class _DynamicBottomNavBarState extends State<DynamicBottomNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _iconAnimations;
  late AnimationController _bubbleController;
  late Animation<double> _bubbleAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  int get currentIndex {
    return widget.navItems.indexWhere((item) => item.route == widget.currentRoute);
  }

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Initialize animation controllers for each tab
    _animationControllers = List.generate(
      widget.navItems.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );

    // Icon bounce animations
    _iconAnimations = _animationControllers
        .map(
          (controller) => Tween<double>(
            begin: 1.0,
            end: 1.2,
          ).animate(
            CurvedAnimation(
              parent: controller,
              curve: Curves.elasticOut,
            ),
          ),
        )
        .toList();

    // Bubble animation controller
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bubbleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _bubbleController,
        curve: Curves.elasticOut,
      ),
    );

    // Slide animation for the entire bottom nav
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start animations
    if (currentIndex >= 0) {
      _animationControllers[currentIndex].forward();
      _bubbleController.forward();
    }
    _slideController.forward();
  }

  @override
  void didUpdateWidget(DynamicBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIndex = oldWidget.navItems.indexWhere((item) => item.route == oldWidget.currentRoute);
    final newIndex = currentIndex;
    
    if (oldIndex != newIndex && oldIndex >= 0 && newIndex >= 0) {
      // Reset previous animation
      _animationControllers[oldIndex].reverse();
      // Start new animation
      _animationControllers[newIndex].forward();
      
      // Restart bubble animation
      _bubbleController.reset();
      _bubbleController.forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    _bubbleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!NavigationConfig.shouldShowBottomNav(widget.currentRoute)) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF2E7D8A),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D8A).withOpacity(0.3),
              offset: const Offset(0, 8),
              blurRadius: 30,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 15,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Container(
            height: 80,
            child: Stack(
              children: [
                // Animated background bubble
                if (currentIndex >= 0)
                  AnimatedBuilder(
                    animation: _bubbleAnimation,
                    builder: (context, child) {
                      return Positioned(
                        left: (MediaQuery.of(context).size.width - 64) / widget.navItems.length * currentIndex + 
                              ((MediaQuery.of(context).size.width - 64) / widget.navItems.length - 56) / 2,
                        top: 12,
                        child: Transform.scale(
                          scale: _bubbleAnimation.value,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                
                // Navigation items
                Row(
                  children: widget.navItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = index == currentIndex;

                    return Expanded(
                      child: _buildNavItem(item, index, isSelected),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BottomNavItem item, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => _handleNavTap(item, index),
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.transparent,
                  ],
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with animations
            AnimatedBuilder(
              animation: _iconAnimations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: isSelected ? _iconAnimations[index].value : 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      isSelected && item.activeIcon != null ? item.activeIcon! : item.icon,
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                      size: isSelected ? 26 : 22,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 4),
            
            // Label with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(
                0,
                isSelected ? 0 : 3,
                0,
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                  fontSize: isSelected ? 12 : 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: isSelected ? 0.5 : 0,
                ),
                child: Text(item.label),
              ),
            ),
            
            // Active indicator dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(top: 2),
              width: isSelected ? 4 : 0,
              height: isSelected ? 4 : 0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavTap(BottomNavItem item, int index) {
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Don't navigate if already on the same route
    if (item.route == widget.currentRoute) {
      return;
    }

    // Navigate to the selected route
    NavigationService.navigateTo(item.route);
  }
}
