import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex; // Add this property
  final Function(int) onItemTapped; // Add this property

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex, // Make them required
    required this.onItemTapped,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  // Remove _selectedIndex here, as it's now passed from the parent
  // Remove _onItemTapped here, as it's now received from the parent

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.black,
      elevation: 0,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home Item
          GestureDetector(
            onTap: () => widget.onItemTapped(0), // Use widget.onItemTapped
            child: _buildNavItem(
              icon: Icons.home_filled,
              label: 'Home',
              index: 0,
            ),
          ),
          // Search Item
          GestureDetector(
            onTap: () => widget.onItemTapped(1), // Use widget.onItemTapped
            child: _buildNavItem(
              icon: Icons.search,
              label: '',
              index: 1,
            ),
          ),
          // Add Item
          // GestureDetector(
          //   onTap: () => widget.onItemTapped(2), // Use widget.onItemTapped
          //   child: _buildNavItem(
          //     icon: Icons.add_circle_outline,
          //     label: '',
          //     index: 2,
          //   ),
          // ),
          // Books Item
          GestureDetector(
            onTap: () => widget.onItemTapped(2), // Use widget.onItemTapped
            child: _buildNavItem(
              icon: Icons.library_music,
              label: '',
              index: 2,
            ),
          ),
          // Profile Item
          GestureDetector(
            onTap: () => widget.onItemTapped(3), // Use widget.onItemTapped
            child: _buildNavItem(
              icon: Icons.person_outline,
              label: '',
              index: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    // Use widget.selectedIndex here
    final bool isSelected = widget.selectedIndex == index;
    final Color iconColor = Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16.0 : 8.0, vertical: 8.0),
      decoration: isSelected
          ? BoxDecoration(
        color: Colors.lightGreenAccent[400],
        borderRadius: BorderRadius.circular(30.0),
      )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.black : iconColor,
            size: 24,
          ),
          if (isSelected && label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}