import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'views/dashboard_view.dart';
import 'views/timeline_view.dart';
import 'views/drop_anchor_view.dart';
import 'views/profile_view.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const AnchorsApp(),
    ),
  );
}

class AnchorsApp extends StatelessWidget {
  const AnchorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anchors - 锚点',
      theme: AppTheme.warmTheme,
      home: const MainScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        // 这里不要加 const
        backgroundColor: AppTheme.backgroundWarm, 
        selectedItemColor: AppTheme.accentWarmOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '主页'),
          BottomNavigationBarItem(icon: Icon(Icons.timeline), label: '时间轴'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: '投掷'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '角色'),
        ],
      ),
    );
  }
}