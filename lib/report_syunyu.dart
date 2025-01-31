import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // intlパッケージのインポート

class ReportShunyu extends StatefulWidget {
  const ReportShunyu({super.key});

  @override
  _ReportShunyuState createState() => _ReportShunyuState();
}

class _ReportShunyuState extends State<ReportShunyu> {
  late Future<Map<String, double>> categorySumsFuture;

  @override
  void initState() {
    super.initState();
    categorySumsFuture = fetchIncomeData(); // Firestoreからデータを取得
  }

  // Firestoreから収入データを取得し、カテゴリごとの合計を計算
  Future<Map<String, double>> fetchIncomeData() async {
    final snapshot = await FirebaseFirestore.instance.collection('income').get();
    Map<String, double> categorySums = {};

    for (var doc in snapshot.docs) {
      final category = doc['category']; // カテゴリ名
      final amount = doc['amount']; // 収入金額

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
      case '給与':
        return const Color.fromARGB(255, 151, 219, 154);
      case '臨時収入':
        return Colors.amber;
      case '投資':
        return const Color.fromARGB(255, 115, 177, 227);
      case '贈り物':
        return const Color.fromARGB(255, 255, 116, 106);
      case 'その他':
        return const Color.fromARGB(255, 205, 118, 220);
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
        title: const Text('収入のレポート'),
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
          final totalSum = _calculateTotalSum(categorySums); // 合計金額を計算

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center, // 中央揃え
                  children: [
                    AspectRatio(
                      aspectRatio: 1.3,
                      child: PieChart(
                        PieChartData(
                          sections: pieChartSections,
                          centerSpaceRadius: 60, // 中心の空白を指定
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
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // フォントサイズを指定
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






