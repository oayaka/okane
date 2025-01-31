import 'package:flutter/material.dart';
import 'home.dart'; // home.dartをインポート

// パスワード画面
class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  String _inputPassword = '';
  final String _correctPassword = '1234';

  void _onNumberPressed(String number) {
    setState(() {
      if (_inputPassword.length < 4) {
        _inputPassword += number;
      }
      if (_inputPassword.length == 4) {
        _checkPassword();
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (_inputPassword.isNotEmpty) {
        _inputPassword = _inputPassword.substring(0, _inputPassword.length - 1);
      }
    });
  }

  void _checkPassword() {
    if (_inputPassword == _correctPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('エラー'),
          content: const Text('パスコードが間違っています。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _inputPassword = '';
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildNumberButton(String number) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 70, // ボタンの高さを揃える
          child: ElevatedButton(
            onPressed: () => _onNumberPressed(number),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 209, 171, 151), // ボタンの背景色
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              number,
              style: const TextStyle(fontSize: 28, color: Colors.white), // フォントサイズと色
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 70, // ボタンの高さを揃える
          child: ElevatedButton(
            onPressed: _onDeletePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 164, 141, 134), // 消去ボタンの背景色
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Icon(
              Icons.backspace, // 消去アイコン
              size: 28, // アイコンサイズ
              color: Colors.white, // アイコンの色
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordDisplay() {
    List<Widget> passwordDigits = List.generate(4, (index) {
      return Container(
        width: 70,
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 238, 238, 238), // 背景色
          borderRadius: BorderRadius.circular(16), // 角を丸くする
          border: Border.all(color: const Color.fromARGB(255, 217, 217, 217)), // 枠線
        ),
        alignment: Alignment.center,
        child: Text(
          index < _inputPassword.length ? _inputPassword[index] : '', // 入力された数字を表示
          style: const TextStyle(fontSize: 24, color: Colors.black), // フォントサイズと色
        ),
      );
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: passwordDigits,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('パスコードを入力'),
        backgroundColor: const Color.fromARGB(255, 209, 171, 151), // アプリバーの背景色
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          _buildPasswordDisplay(),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    _buildNumberButton('1'),
                    _buildNumberButton('2'),
                    _buildNumberButton('3'),
                  ],
                ),
                Row(
                  children: [
                    _buildNumberButton('4'),
                    _buildNumberButton('5'),
                    _buildNumberButton('6'),
                  ],
                ),
                Row(
                  children: [
                    _buildNumberButton('7'),
                    _buildNumberButton('8'),
                    _buildNumberButton('9'),
                  ],
                ),
                Row(
                  children: [
                    const Spacer(), // 0ボタンの左側にスペースを追加
                    _buildNumberButton('0'), // 0ボタン
                    _buildDeleteButton(), // 消去ボタン
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


