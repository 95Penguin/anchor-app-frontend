// ==================== main.dart ====================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anchors/providers/app_provider.dart';
import 'package:anchors/views/dashboard_view.dart';
import 'package:anchors/views/timeline_view.dart';
import 'package:anchors/views/drop_anchor_view.dart';
import 'package:anchors/views/profile_view.dart';
import 'package:anchors/utils/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const AnchorsApp(),
    ),
  );
}

class AnchorsApp extends StatelessWidget {
  const AnchorsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anchors - 锚点',
      theme: AppTheme.darkTheme,
      home: const MainScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardView(),
    TimelineView(),
    DropAnchorView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.accentGreen.withOpacity(0.2), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.backgroundDark,
          selectedItemColor: AppTheme.accentGreen,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '主页'),
            BottomNavigationBarItem(icon: Icon(Icons.timeline), label: '时间轴'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: '投掷'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '角色'),
          ],
        ),
      ),
    );
  }
}