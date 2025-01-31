import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // intlパッケージのインポート

class ReportSisyutu extends StatefulWidget {
  const ReportSisyutu({super.key});

  @override
  _ReportSisyutuState createState() => _ReportSisyutuState();
}

class _ReportSisyutuState extends State<ReportSisyutu> {
  late Future<Map<String, double>> categorySumsFuture;

  @override
  void initState() {
    super.initState();
    categorySumsFuture = fetchExpenseData(); // Firestoreからデータを取得
  }

  // Firestoreから支出データを取得し、カテゴリごとの合計を計算
  Future<Map<String, double>> fetchExpenseData() async {
    final snapshot = await FirebaseFirestore.instance.collection('expenses').get();
    Map<String, double> categorySums = {};

    for (var doc in snapshot.docs) {
      final category = doc['category']; // カテゴリ名
      final amount = doc['amount']; // 支出金額

      // Firestoreから取得したデータをdouble型に変換
      final amountAsDouble = (amount is int) ? amount.toDouble() : amount;

      if (categorySums.containsKey(category)) {
        categorySums[category] = categorySums[category]! + amountAsDouble;
      } else {
        categorySums[category] = amountAsDouble;
      }
    }

    return categorySums;
  }

  // カテゴリに対応する色を返す関数
  Color _getCategoryColor(String category) {
    switch (category) {
      case '食費':
        return const Color.fromARGB(255, 132, 191, 249);
      case '日用品':
        return const Color.fromARGB(255, 151, 219, 154);
      case '交通費':
        return const Color.fromARGB(255, 255, 116, 106);
      case '衣服':
        return const Color.fromARGB(255, 255, 181, 70);
      case '交際費':
        return const Color.fromARGB(255, 255, 168, 197);
      case '医療費':
        return const Color.fromARGB(255, 228, 162, 238);
      case '趣味':
        return const Color.fromARGB(255, 161, 213, 255);
      default:
        return Colors.grey;
    }
  }

  // 円グラフのセクションデータを生成する関数
  List<PieChartSectionData> _generatePieChartSections(Map<String, double> categorySums) {
    return categorySums.entries.map((entry) {
      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value,
        title: entry.key, // セクション内の文字を非表示
        radius: 80,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  // 合計金額を計算する関数
  double _calculateTotalSum(Map<String, double> categorySums) {
    return categorySums.values.fold(0, (sum, value) => sum + value);
  }

  // 金額をコンマ区切りでフォーマットする関数
  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###'); // コンマ区切りの形式
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('支出のレポート'),
        backgroundColor: const Color.fromARGB(255, 236, 235, 232),
      ),
      body: FutureBuilder<Map<String, double>>(
        future: categorySumsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('エラー: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('データがありません'));
          }

          final categorySums = snapshot.data!;
          final pieChartSections = _generatePieChartSections(categorySums);
          final totalSum = _calculateTotalSum(categorySums);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.3,
                      child: PieChart(
                        PieChartData(
                          sections: pieChartSections,
                          centerSpaceRadius: 60,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '合計',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${_formatCurrency(totalSum)}円', // コンマ区切りで表示
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: categorySums.length,
                    itemBuilder: (context, index) {
                      final category = categorySums.keys.elementAt(index);
                      final total = categorySums[category]!;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getCategoryColor(category),
                        ),
                        title: Text(category),
                        trailing: Text(
                          '${_formatCurrency(total)}円', // コンマ区切りで表示
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}









