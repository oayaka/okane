import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'bottomNV.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double budget = 100000; // Example budget value

  // Function to calculate totals for income and expense
  Future<Map<String, double>> _calculateTotals() async {
    double totalExpenses = 0.0;
    double totalIncome = 0.0;

    // Fetch expenses from Firestore
    final expenseSnapshot = await _firestore.collection('expenses').get();
    for (var expense in expenseSnapshot.docs) {
      totalExpenses += expense['amount'].toDouble();
    }

    // Fetch income from Firestore
    final incomeSnapshot = await _firestore.collection('income').get();
    for (var income in incomeSnapshot.docs) {
      totalIncome += income['amount'].toDouble();
    }

    return {
      'totalExpenses': totalExpenses,
      'totalIncome': totalIncome,
      'balance': totalIncome - totalExpenses,
    };
  }

  // カンマ区切りのフォーマット関数
  String formatWithCommas(double value) {
    final formatter = NumberFormat.decimalPattern('ja_JP');
    return formatter.format(value);
  }

  String getFormattedDate() {
    DateTime now = DateTime.now();
    String weekday = DateFormat('EEEE').format(now);

    String kanjiWeekday;
    switch (weekday) {
      case 'Monday':
        kanjiWeekday = '月';
        break;
      case 'Tuesday':
        kanjiWeekday = '火';
        break;
      case 'Wednesday':
        kanjiWeekday = '水';
        break;
      case 'Thursday':
        kanjiWeekday = '木';
        break;
      case 'Friday':
        kanjiWeekday = '金';
        break;
      case 'Saturday':
        kanjiWeekday = '土';
        break;
      case 'Sunday':
        kanjiWeekday = '日';
        break;
      default:
        kanjiWeekday = '';
    }

    return '${DateFormat(' y年M月d日').format(now)}($kanjiWeekday)';
  }

  double getExpenseProgress(double expense) {
    return expense / budget;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ダイアログで予算を変更するための関数
  void _showBudgetDialog() {
    TextEditingController budgetController = TextEditingController(text: budget.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('予算を変更'),
          content: TextField(
            controller: budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '新しい予算'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  budget = double.tryParse(budgetController.text) ?? budget;
                });
                Navigator.of(context).pop();
              },
              child: const Text('変更'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 236, 235, 232),
        title: const Text('HOME'),
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
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    getFormattedDate(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              const Padding(
                padding: EdgeInsets.all(3.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '   最近のお金の動き',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // 収支情報のカード
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '今月の収支',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('収入'),
                          Text('￥${formatWithCommas(totalIncome)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('支出'),
                          Text('￥${formatWithCommas(totalExpenses)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('収支'),
                          Text(
                            '￥${formatWithCommas(balance)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // 予算の進捗カード
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '予算の進捗',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: _showBudgetDialog, // ダイアログを表示
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: getExpenseProgress(totalExpenses),
                        backgroundColor: Colors.grey[300],
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '支出：${(getExpenseProgress(totalExpenses) * 100).toStringAsFixed(1)}%使用',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('今月の予算'),
                          Text('￥${formatWithCommas(budget)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('支出合計'),
                          Text(
                            '￥${formatWithCommas(totalExpenses)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // 予算の残り
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('残り予算'),
                          Text(
                            '￥${formatWithCommas(budget - totalExpenses)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
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












// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'bottomNV.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Function to calculate totals for income and expense
//   Future<Map<String, double>> _calculateTotals() async {
//     double totalExpenses = 0.0;
//     double totalIncome = 0.0;

//     // Fetch expenses from Firestore
//     final expenseSnapshot = await _firestore.collection('expenses').get();
//     for (var expense in expenseSnapshot.docs) {
//       totalExpenses += expense['amount'].toDouble();
//     }

//     // Fetch income from Firestore
//     final incomeSnapshot = await _firestore.collection('income').get();
//     for (var income in incomeSnapshot.docs) {
//       totalIncome += income['amount'].toDouble();
//     }

//     return {
//       'totalExpenses': totalExpenses,
//       'totalIncome': totalIncome,
//       'balance': totalIncome - totalExpenses,
//     };
//   }

//   // カンマ区切りのフォーマット関数
//   String formatWithCommas(double value) {
//     final formatter = NumberFormat.decimalPattern('ja_JP');
//     return formatter.format(value);
//   }

//   String getFormattedDate() {
//     DateTime now = DateTime.now();
//     String weekday = DateFormat('EEEE').format(now);

//     String kanjiWeekday;
//     switch (weekday) {
//       case 'Monday':
//         kanjiWeekday = '月';
//         break;
//       case 'Tuesday':
//         kanjiWeekday = '火';
//         break;
//       case 'Wednesday':
//         kanjiWeekday = '水';
//         break;
//       case 'Thursday':
//         kanjiWeekday = '木';
//         break;
//       case 'Friday':
//         kanjiWeekday = '金';
//         break;
//       case 'Saturday':
//         kanjiWeekday = '土';
//         break;
//       case 'Sunday':
//         kanjiWeekday = '日';
//         break;
//       default:
//         kanjiWeekday = '';
//     }

//     return '${DateFormat(' y年M月d日').format(now)}($kanjiWeekday)';
//   }

//   double budget = 100000; // Example budget value

//   double getExpenseProgress(double expense) {
//     return expense / budget;
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 236, 235, 232),
//         title: const Text('HOME'),
//       ),
//       body: FutureBuilder<Map<String, double>>(
//         future: _calculateTotals(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData) {
//             return const Center(child: Text('データがありません'));
//           }

//           final totals = snapshot.data!;
//           final totalExpenses = totals['totalExpenses']!;
//           final totalIncome = totals['totalIncome']!;
//           final balance = totals['balance']!;

//           return Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(6.0),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     getFormattedDate(),
//                     style: const TextStyle(fontSize: 18),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 5),
//               const Padding(
//                 padding: EdgeInsets.all(3.0),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     '   最近のお金の動き',
//                     style: TextStyle(fontSize: 24),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               // 収支情報のカード
//               Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 elevation: 5,
//                 color: Colors.white,
//                 margin: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         '今月の収支',
//                         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text('収入'),
//                           Text('￥${formatWithCommas(totalIncome)}', style: const TextStyle(fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text('支出'),
//                           Text('￥${formatWithCommas(totalExpenses)}', style: const TextStyle(fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                       const Divider(),
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text('収支'),
//                           Text(
//                             '￥${formatWithCommas(balance)}',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 24,
//                               color: Colors.red,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               // 予算の進捗カード
//               Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 elevation: 5,
//                 color: Colors.white,
//                 margin: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         '予算の進捗',
//                         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 10),
//                       LinearProgressIndicator(
//                         value: getExpenseProgress(totalExpenses),
//                         backgroundColor: Colors.grey[300],
//                         color: Colors.blue,
//                       ),
//                       const SizedBox(height: 5),
//                       Text(
//                         '支出：${(getExpenseProgress(totalExpenses) * 100).toStringAsFixed(1)}%使用',
//                         style: const TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                       const SizedBox(height: 15),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text('今月の予算'),
//                           Text('￥${formatWithCommas(budget)}', style: const TextStyle(fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text('支出合計'),
//                           Text(
//                             '￥${formatWithCommas(totalExpenses)}',
//                             style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       // 予算の残り
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text('残り予算'),
//                           Text(
//                             '￥${formatWithCommas(budget - totalExpenses)}',
//                             style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//       bottomNavigationBar: BottomNavBar(
//         selectedIndex: _selectedIndex,
//         onItemTapped: _onItemTapped,
//       ),
//     );
//   }
// }


