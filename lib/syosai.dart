import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
//import 'add.dart';

class SyosaiScreen extends StatefulWidget {
  final DateTime selectedDate;

  const SyosaiScreen({super.key, required this.selectedDate});

  @override
  _SyosaiScreenState createState() => _SyosaiScreenState();
}

class _SyosaiScreenState extends State<SyosaiScreen> {
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy/MM/dd').format(widget.selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('$formattedDate の詳細'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildTransactionList('expenses', '支出')),
          Divider(),
          Expanded(child: _buildTransactionList('income', '収入')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ボタンが押されたときの処理
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionList(String collection, String title) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection(collection)
          .where('date', isEqualTo: Timestamp.fromDate(widget.selectedDate))
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('エラー: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('データがありません'));
        }

        final transactions = snapshot.data!.docs;

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final amount = transaction['amount'];
            final description = transaction['description'];

            return ListTile(
              title: Text(description),
              trailing: Text('${NumberFormat('#,###').format(amount)}円'),
            );
          },
        );
      },
    );
  }
}