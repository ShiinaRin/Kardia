import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../model/person.dart'; // 問題モデルをインポート
import '../model/QuestionList.dart';

class EditQuestionListPage extends StatefulWidget {
  final Isar isar;
  final QuestionList questionList;
  final String title;

  EditQuestionListPage(
      {super.key,
      required this.isar,
      required this.questionList,
      required this.title});
  @override
  _EditQuestionListPageState createState() => _EditQuestionListPageState();
}

class _EditQuestionListPageState extends State<EditQuestionListPage> {
  late TextEditingController _titleController;
  late TextEditingController _searchController;
  List<Person> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.questionList.title);
    _searchController = TextEditingController();
  }

  Future<void> _searchQuestions() async {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      final results = await widget.isar.persons
          .where()
          .filter()
          .nameContains(query) // nameフィールドが部分一致するか確認
          .or()
          .answerContains(query) // answerフィールドが部分一致するか確認
          .or()
          .explanationContains(query) // explanationフィールドが部分一致するか確認
          .findAll();
      setState(() {
        _searchResults = results;
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  Future<void> _addQuestionToQuestionList(Person question) async {
    final currentTime = DateTime.now();
    question
      ..createdAt = currentTime
      ..updatedAt = currentTime
      ..lastAnswerDate = currentTime;

    try {
      // QuestionListのIsarLinksにPersonを関連付けて更新
      widget.questionList.persons.add(question);

      // 問題リストを保存 (問題リストに関連する問題は自動的に保存されます)
      await widget.isar.writeTxn(() async {
        await widget.isar.questionLists.put(widget.questionList);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('問題を追加しました')),
      );
    } catch (e) {
      // エラーハンドリング（必要に応じてエラーメッセージを表示するなど）
      print('エラーが発生しました: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('問題リストを編集')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '問題リストのタイトル'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(labelText: '問題を検索'),
              onChanged: (query) {
                _searchQuestions();
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final question = _searchResults[index];
                  return ListTile(
                    title: Text(question.name ?? 'タイトルなし'),
                    subtitle: Text(question.answer ?? '内容なし'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final selectedQuestion = _searchResults[index];
                        await _addQuestionToQuestionList(selectedQuestion);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
