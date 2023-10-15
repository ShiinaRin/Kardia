import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../model/QuestionList.dart';

class MakeQuestionListPage extends StatefulWidget {
  final Isar isar;
  final QuestionList questionList;

  const MakeQuestionListPage({
    required this.isar,
    required this.questionList,
  });

  @override
  _MakeQuestionListPageState createState() => _MakeQuestionListPageState();
}

class _MakeQuestionListPageState extends State<MakeQuestionListPage> {
  TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新しい問題リストを作成')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('問題リストのタイトル:'),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: '問題リストのタイトルを入力してください',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final newTitle = QuestionList() // 新しい問題リストを作成
                  ..title = titleController.text
                  ..createdAt = DateTime.now()
                  ..updatedAt = DateTime.now();

                if (newTitle.title.isNotEmpty) {
                  await widget.isar.writeTxn(() async {
                    await widget.isar.questionLists.put(newTitle);
                  });
                  Navigator.pop(context);
                } else {
                  // タイトルが空の場合のエラーメッセージを表示するなどの処理を追加できます
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('タイトルがないと…かわいそうだよ！'), // ここにエラーメッセージを表示したい文字列を入力
                    ),
                  );
                }
              },
              child: const Text('問題リストを作成'),
            ),
          ],
        ),
      ),
    );
  }
}
