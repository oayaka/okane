import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'bottomNV.dart'; // BottomNavBarをインポート
import 'home.dart';
import 'addSyunyu.dart';  // addSyunyu.dart をインポート

//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Firestore インスタンス
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  int _selectedIndex = 1; // 初期選択を「入力」に設定
  DateTime _selectedDate = DateTime.now(); // デフォルトで今日の日付を設定
  final TextEditingController _memoController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _showCalculator = false; // 電卓の表示状態
  String _amount = ''; // 支出額の値

  // カテゴリのリストと選択されたカテゴリ
  final List<String> _categories = [
    '食費',
    '日用品',
    '交通費',
    '衣服',
    '交際費',
    '医療費',
    '趣味',
    'その他'
  ];
  String? _selectedCategory;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else if (index == 1) {
      return;
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _onCalculatorButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _amount = ''; // Cでリセット
      } else if (value == 'OK') {
        _amountController.text = _amount; // OKで入力確定
        _showCalculator = false;
      } else {
        _amount += value; // 数字を追加
      }

      // 数字のフォーマット（カンマ区切り）
      _amount = NumberFormat('#,###').format(
        int.tryParse(_amount.replaceAll(',', '')) ?? 0,
      );
    });
  }

  Widget _buildCalculatorButton(String value) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _onCalculatorButtonPressed(value),
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // 四角くする
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(value, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  Future<void> _saveData() async {
    if (_amountController.text.isNotEmpty && _selectedCategory != null) {
      try {
        await _firestore.collection('expenses').add({
          'date': _selectedDate.toIso8601String(), // 日付（ISO 形式）
          'memo': _memoController.text, // メモ
          'amount':
              int.parse(_amountController.text.replaceAll(',', '')), // 支出（数値）
          'category': _selectedCategory, // カテゴリ
          'createdAt': FieldValue.serverTimestamp(), // サーバータイムスタンプ
        });
        // 保存完了メッセージ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('データを保存しました！')),
        );

        // 入力フィールドをクリア
        setState(() {
          _memoController.clear();
          _amountController.clear();
          _selectedCategory = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('全てのフィールドを入力してください。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // タブ数
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 236, 235, 232),
          centerTitle: true,
          title: const Text(''),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(48.0),
            child: TabBar(
              indicatorColor: Color.fromARGB(255, 245, 168, 194),
              tabs: [
                Tab(child: Text('支出', style: TextStyle(color: Colors.black))),
                Tab(child: Text('収入', style: TextStyle(color: Colors.black))),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text("日付", style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => _changeDate(-1),
                      ),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Text(
                          DateFormat('yyyy/MM/dd').format(_selectedDate),
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => _changeDate(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("メモ", style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _memoController,
                          decoration: const InputDecoration(
                            hintText: "未入力",
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("支出", style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _showCalculator = !_showCalculator;
                            });
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 40),
                          minimumSize: const Size(300, 60),
                        ),
                        child: Text(
                          _amount.isEmpty ? "" : _amount,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '円',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("カテゴリ", style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _selectedCategory,
                        hint: const Text("選択してください"),
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_showCalculator)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildCalculatorButton('7'),
                            _buildCalculatorButton('8'),
                            _buildCalculatorButton('9'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildCalculatorButton('4'),
                            _buildCalculatorButton('5'),
                            _buildCalculatorButton('6'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildCalculatorButton('1'),
                            _buildCalculatorButton('2'),
                            _buildCalculatorButton('3'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildCalculatorButton('C'),
                            _buildCalculatorButton('0'),
                            _buildCalculatorButton('OK'),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _saveData,
                    child: const Text('保存'),
                  ),
                ],
              ),
            ),
            const AddSyunyuScreen(),
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





