
import 'package:flutter/material.dart';
import 'bottomNV.dart'; // BottomNavBarをインポート
import 'home.dart'; // HomeScreenをインポート
import 'add.dart'; // AddScreenをインポート
import 'calendar.dart'; // CalendarScreenをインポート
import 'report_sisyutu.dart'; // ReportSisyutuをインポート
import 'report_syunyu.dart'; // ReportShunyuをインポート

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final int _selectedIndex = 3; // 初期選択を「レポート」に設定

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AddScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => CalendarScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      // すでにレポート画面が選択されている場合は何もしない
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // タブの数
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 236, 235, 232),
          centerTitle: true,
          title: const Text('レポート'), // タイトルを設定
          bottom: const TabBar(
            tabs: [
              Tab(text: '支出'),
              Tab(text: '収入'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ReportSisyutu(), // 支出タブに円グラフ表示
            ReportShunyu(),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}








