import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../model/person.dart';

class EditPage extends StatefulWidget {
  final Isar isar;
  final Person person; // 編集対象のPersonオブジェクト

  const EditPage({super.key, required this.isar, required this.person});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController nameController;
  late TextEditingController answerController;
  late TextEditingController explanationController;

  @override
  void initState() {
    super.initState();
    // 初期値を設定
    nameController = TextEditingController(text: widget.person.name);
    answerController = TextEditingController(text: widget.person.answer);
    explanationController =
        TextEditingController(text: widget.person.explanation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('編集')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  maxLines: null, // 改行可能にする
                  decoration: const InputDecoration(
                    labelText: '問題', // ラベルを追加
                    hintText: '問題文を入力', // ヒントテキストを設定
                    border: OutlineInputBorder(), // 外枠を追加
                  ),
                ),
                const SizedBox(height: 16), // テキストフィールド同士の隙間を広げる
                TextField(
                  controller: answerController,
                  maxLines: null, // 改行可能にする
                  decoration: const InputDecoration(
                    labelText: '解答', // ラベルを追加
                    hintText: '答えを入力', // ヒントテキストを設定
                    border: OutlineInputBorder(), // 外枠を追加
                  ),
                ),
                const SizedBox(height: 16), // テキストフィールド同士の隙間を広げる
                TextField(
                  controller: explanationController,
                  maxLines: null, // 改行可能にする
                  decoration: const InputDecoration(
                    labelText: '解説', // ラベルを追加
                    hintText: '解説を入力', // ヒントテキストを設定
                    border: OutlineInputBorder(), // 外枠を追加
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 編集した値を保存
                    widget.person
                      ..name = nameController.text
                      ..answer = answerController.text
                      ..explanation = explanationController.text;
                    await widget.isar.writeTxn(() async {
                      await widget.isar.persons.put(widget.person);
                    });
                    Navigator.pop(context); // 編集画面を閉じて前の画面に戻る
                  },
                  child: const Text('保存'),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    // コントローラーを破棄する
    nameController.dispose();
    answerController.dispose();
    explanationController.dispose();
    super.dispose();
  }
}
