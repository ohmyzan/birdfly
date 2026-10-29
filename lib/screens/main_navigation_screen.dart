import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'catalog_screen.dart';
import 'identification_screen.dart';
import 'journal_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  static _MainNavigationScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainNavigationScreenState>();

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final GlobalKey<JournalScreenState> _journalKey =
      GlobalKey<JournalScreenState>();

  void setTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 3) {
      // Otomatis memperbarui daftar jurnal saat tab Observasi dibuka
      _journalKey.currentState?.refreshJournals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const CatalogScreen(),
      const IdentificationScreen(),
      JournalScreen(key: _journalKey),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, Icons.home, 'Beranda', 0),
            _buildNavItem(Icons.explore_outlined, Icons.explore, 'Katalog', 1),
            const SizedBox(width: 48),
            _buildNavItem(
              Icons.menu_book_outlined,
              Icons.menu_book,
              'Observasi',
              3,
            ),
            _buildNavItem(Icons.person_outline, Icons.person, 'Profil', 4),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setTab(2),
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(
    IconData unselectedIcon,
    IconData selectedIcon,
    String label,
    int index,
  ) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? selectedIcon : unselectedIcon,
            color: isSelected ? const Color(0xFF1B5E20) : Colors.grey,
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF1B5E20) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
