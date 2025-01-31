import 'package:flutter/material.dart';
import 'package:okane_1018/%20report.dart';
import 'home.dart'; // HomeScreenをインポート
import 'add.dart';  // AddScreenをインポート
import 'calendar.dart'; // CalendarScreenをインポート
//import 'report.dart'; // ReportScreenをインポート

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'ホーム',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: '記録',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: '履歴',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pie_chart),
          label: 'レポート',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: const Color.fromARGB(255, 255, 122, 211),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 0) {
          // ホームボタンを押した時の画面遷移（アニメーションなし）
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
              transitionDuration: Duration.zero,  // アニメーションの時間をゼロに設定
              reverseTransitionDuration: Duration.zero, // 逆方向のアニメーションもゼロに
            ),
          );
        } else if (index == 1) {
          // 入力ボタンを押した時の画面遷移（アニメーションなし）
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const AddScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 2) {
          // カレンダーボタンを押した時の画面遷移（アニメーションなし）
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>  CalendarScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 3) {
          // レポートボタンを押した時の画面遷移（アニメーションなし）
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const ReportScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else {
          onItemTapped(index);
        }
      },
    );
  }
}



