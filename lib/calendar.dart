import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'bottomNV.dart'; // BottomNavBarをインポート
import 'syosai.dart'; // SyosaiScreenをインポート

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentDate = DateTime.now();
  int _selectedIndex = 2;
  List<Map<String, dynamic>> expenseDates = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenseDates();
  }

  // Firestoreから支出データを取得し、支出がある日をリストに追加
  Future<void> _fetchExpenseDates() async {
    final expenseSnapshot = await FirebaseFirestore.instance.collection('expenses').get();
    List<Map<String, dynamic>> dates = [];
    for (var doc in expenseSnapshot.docs) {
      final date = DateTime.parse(doc['date']);
      final amount = doc['amount']; // 金額を取得
      dates.add({'date': date, 'amount': amount});
    }
    setState(() {
      expenseDates = dates;
    });
  }

  // 支出のある日に合計金額を表示するための設定
  List<Widget> _getMarkers(DateTime day) {
    double totalExpensesForDay = 0;

    // その日の支出金額を合計
    for (var expense in expenseDates) {
      if (isSameDay(expense['date'], day)) {
        totalExpensesForDay += expense['amount']; // 支出金額を合計
      }
    }

    // 合計支出金額がある場合
    if (totalExpensesForDay > 0) {
      return [
        Align(
          alignment: Alignment(0, 1.3), // 中央から少し下に配置
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 248, 131, 123), // 赤い背景
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '¥${totalExpensesForDay.toStringAsFixed(0)}', // 支出金額を表示
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ];
    }
    return [];
  }

  // 日付が選択された時にSyosaiScreenに遷移
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _currentDate = focusedDay;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SyosaiScreen(selectedDate: selectedDay),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<Map<String, double>> _calculateTotals() async {
    double totalExpenses = 0;
    double totalIncome = 0;

    final expenseSnapshot = await FirebaseFirestore.instance.collection('expenses').get();
    for (var doc in expenseSnapshot.docs) {
      totalExpenses += doc['amount'];
    }

    final incomeSnapshot = await FirebaseFirestore.instance.collection('income').get();
    for (var doc in incomeSnapshot.docs) {
      totalIncome += doc['amount'];
    }

    return {
      'totalExpenses': totalExpenses,
      'totalIncome': totalIncome,
      'balance': totalIncome - totalExpenses,
    };
  }

  Stream<QuerySnapshot> _getIncome() {
    return FirebaseFirestore.instance.collection('income').snapshots();
  }

  Stream<QuerySnapshot> _getExpenses() {
    return FirebaseFirestore.instance.collection('expenses').snapshots();
  }

  Future<void> _deleteIncome(String documentId) async {
    await FirebaseFirestore.instance.collection('income').doc(documentId).delete();
  }

  Future<void> _deleteExpense(String documentId) async {
    await FirebaseFirestore.instance.collection('expenses').doc(documentId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カレンダー'),
        backgroundColor: const Color.fromARGB(255, 236, 235, 232),
      ),
      body: FutureBuilder<Map<String, double>>(
        future: _calculateTotals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('データがありません'));
          }

          final totals = snapshot.data!;
          final totalExpenses = totals['totalExpenses']!;
          final totalIncome = totals['totalIncome']!;
          final balance = totals['balance']!;

          return Column(
            children: [
              // カレンダーウィジェット
              TableCalendar(
                focusedDay: _currentDate,
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                calendarFormat: CalendarFormat.month,
                onDaySelected: _onDaySelected, // 修正点: 関数を渡す
                selectedDayPredicate: (day) {
                  return isSameDay(_currentDate, day);
                },
                // 支出がある日にマーカーを設定
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    return Stack(
                      children: _getMarkers(day), // マーカーをスタックで配置
                    );
                  },
                ),
              ),
              // 月の切り替えボタンと収支合計のカード
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    title: const Text('収支合計'),
                    subtitle: Text(
                      '収入: ¥${totalIncome.toStringAsFixed(0)}\n'
                      '支出: ¥${totalExpenses.toStringAsFixed(0)}\n'
                      '収支: ¥${balance.toStringAsFixed(0)}',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    // 収入の表示部分
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _getIncome(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('収入データがありません'));
                          }

                          final income = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: income.length,
                            itemBuilder: (context, index) {
                              final incomeItem = income[index];
                              final date = DateTime.parse(incomeItem['date']);
                              final amount = incomeItem['amount'];
                              final category = incomeItem['category'];
                              final memo = incomeItem['memo'];
                              final documentId = incomeItem.id;

                              return Card(
                                margin: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Text('$category - ¥$amount'),
                                  subtitle: Text(memo ?? 'メモなし'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(DateFormat('yyyy/MM/dd').format(date)),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('削除確認'),
                                              content: const Text('この収入データを削除しますか？'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('キャンセル'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await _deleteIncome(documentId);
                                                    if (mounted) {
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  child: const Text('削除'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    // 支出の表示部分
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _getExpenses(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('支出データがありません'));
                          }

                          final expenses = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: expenses.length,
                            itemBuilder: (context, index) {
                              final expenseItem = expenses[index];
                              final date = DateTime.parse(expenseItem['date']);
                              final amount = expenseItem['amount'];
                              final category = expenseItem['category'];
                              final memo = expenseItem['memo'];
                              final documentId = expenseItem.id;

                              return Card(
                                margin: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Text('$category - ¥$amount'),
                                  subtitle: Text(memo ?? 'メモなし'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(DateFormat('yyyy/MM/dd').format(date)),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('削除確認'),
                                              content: const Text('この支出データを削除しますか？'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('キャンセル'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await _deleteExpense(documentId);
                                                    if (mounted) {
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  child: const Text('削除'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}









