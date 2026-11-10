import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/circular_sos_button.dart';
import 'tabs/home_tab.dart';
import 'tabs/reminders_tab.dart';
import 'tabs/insights_tab.dart';
import 'tabs/family_tab.dart';
import 'tabs/more_tab.dart';

class SeniorDashboardScreen extends StatefulWidget {
  final int initialTab;

  const SeniorDashboardScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<SeniorDashboardScreen> createState() => _SeniorDashboardScreenState();
}

class _SeniorDashboardScreenState extends State<SeniorDashboardScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeTab(onNavigateTab: _onTabTapped),
      const RemindersTab(),
      const InsightsTab(),
      const FamilyTab(),
      const MoreTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient Tint
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEAF5FF),
                  Color(0xFFFFFEF7),
                  Color(0xFFF0F7FF),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _selectedIndex,
                children: pages,
              ),
            ),
          ),

          // REQUIREMENT 7: Consistent circular floating SOS button across tabs!
          // Positioned above the bottom navigation bar without overlapping content
          Positioned(
            right: 18,
            bottom: 88,
            child: const CircularSOSButton(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    const items = [
      (Icons.home_rounded, 'Home'),
      (Icons.calendar_month_rounded, 'Reminders'),
      (Icons.bar_chart_rounded, 'Insights'),
      (Icons.people_rounded, 'My Family'),
      (Icons.grid_view_rounded, 'More'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Color(0x180E2B54),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = _selectedIndex == index;
              final item = items[index];
              final color = isSelected ? AppColors.primaryBlue : const Color(0xFF8192AB);

              return Expanded(
                child: InkWell(
                  onTap: () => _onTabTapped(index),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSelected ? 12 : 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryLight : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item.$1,
                            color: color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

