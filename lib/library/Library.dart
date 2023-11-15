import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import 'package:kardia_anki/library/MakeQuestionView/editQuestion.dart';
import 'package:kardia_anki/main.dart';
import 'package:kardia_anki/model/QuestionList.dart';
import 'package:kardia_anki/model/person.dart';

class LibraryScreen extends StatefulWidget {
  final Isar isar;

  LibraryScreen({required this.isar});

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late List<QuestionList> questionLists = [];

  @override
  void initState() {
    super.initState();
    loadQuestionLists();
  }

  Future<void> loadQuestionLists() async {
    questionLists = await widget.isar.questionLists.where().findAll();
    setState(() {}); // 状態を更新してUIを再描画
  }

  void _onListTileTap(QuestionList questionList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonListScreen(
          isar: widget.isar,
          questionList: questionList,
        ),
      ),
    );
  }

  void _addQuestionList(String title, gaiyo) async {
    final newQuestionList = QuestionList()
      ..title = title
      ..gaiyo = gaiyo
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await widget.isar.writeTxn(() async {
      await widget.isar.questionLists.put(newQuestionList);
    });
    loadQuestionLists();
  }

  Future<void> _deleteQuestionList(QuestionList questionList) async {
    await widget.isar.writeTxn(() async {
      await widget.isar.questionLists.delete(questionList.id);
    });
    loadQuestionLists();
  }

  void _editQuestionList(QuestionList questionList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditQuestionListScreen(
          isar: widget.isar,
          questionList: questionList,
          onQuestionListUpdated: () {
            loadQuestionLists(); // フォルダーが編集されたらリストを再読み込み
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('フォルダー'),
      ),
      body: ListView.builder(
        itemCount: questionLists.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            elevation: 4,
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
              title: Text(questionLists[index].title),
              //subtitle: Text('ここに何かしらの値を表示: '), // 例: フォルダー内の問題数を表示
              onTap: () => _onListTileTap(questionLists[index]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editQuestionList(questionLists[index]),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('フォルダーを削除'),
                            content: Text(
                                'まじで ${questionLists[index].title} を消しますか?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('キャンセル'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('消す'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _deleteQuestionList(questionLists[index]);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddQuestionListScreen(
                onAddPressed: (title, gaiyo) {
                  _addQuestionList(title, gaiyo);
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddQuestionListScreen extends StatefulWidget {
  final Function(String, String) onAddPressed;

  AddQuestionListScreen({required this.onAddPressed});

  @override
  _AddQuestionListScreenState createState() => _AddQuestionListScreenState();
}

class _AddQuestionListScreenState extends State<AddQuestionListScreen> {
  late String _newTitle;
  late String _newGaiyo;

  @override
  void initState() {
    super.initState();
    _newTitle = '';
    _newGaiyo = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('フォルダーを追加'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                _newTitle = value;
              },
              decoration: InputDecoration(labelText: 'タイトル'),
            ),
            TextField(
              onChanged: (value) {
                _newGaiyo = value;
              },
              decoration: InputDecoration(labelText: '概要'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onAddPressed(_newTitle, _newGaiyo);
                Navigator.pop(context); // スクリーンを閉じる
              },
              child: Text('追加'),
            ),
          ],
        ),
      ),
    );
  }
}

// 追加したスクリーン
class EditQuestionListScreen extends StatefulWidget {
  final Isar isar;
  final QuestionList questionList;
  final Function onQuestionListUpdated;

  EditQuestionListScreen({
    required this.isar,
    required this.questionList,
    required this.onQuestionListUpdated,
  });

  @override
  _EditQuestionListScreenState createState() => _EditQuestionListScreenState();
}

class _EditQuestionListScreenState extends State<EditQuestionListScreen> {
  late TextEditingController _titleController;
  late TextEditingController _gaiyoController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.questionList.title);
    _gaiyoController = TextEditingController(text: widget.questionList.gaiyo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('フォルダーを編集'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'フォルダーのタイトル'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _gaiyoController,
              decoration:
                  InputDecoration(labelText: 'フォルダーの概要'), // 概要のテキストフィールド
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                widget.questionList.title = _titleController.text;
                widget.questionList.gaiyo = _gaiyoController.text; // 概要の値を更新
                widget.questionList.updatedAt = DateTime.now();

                await widget.isar.writeTxn(() async {
                  await widget.isar.questionLists.put(widget.questionList);
                });

                widget.onQuestionListUpdated(); // 親スクリーンに変更を通知
                Navigator.pop(context); // スクリーンを閉じる
              },
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}

class PersonListScreen extends StatefulWidget {
  final Isar isar;
  final QuestionList questionList;

  PersonListScreen({required this.isar, required this.questionList});

  @override
  _PersonListScreenState createState() => _PersonListScreenState();
}

class _PersonListScreenState extends State<PersonListScreen> {
  late List<Person> persons = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await widget.isar.persons
        .where()
        .filter()
        .questionListIdEqualTo(widget.questionList.id)
        .findAll();
    setState(() {
      persons = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.questionList.title),
      ),
      body: ListView.builder(
        itemCount: persons.length,
        itemBuilder: (context, index) {
          final person = persons[index];
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionDetailScreen(
                    isar: widget.isar,
                    question: person,
                  ),
                ),
              ).then((_) {
                // 編集画面から戻ってきたらデータを再読み込み
                loadData();
              });
            },
            //leading:
            //_buildIconForStatus(person.lastAnswerStatus, person.important),
            title: Text("${person.name ?? "値が入ってません"}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // 編集画面に遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditPage(isar: widget.isar, person: person),
                      ),
                    ).then((_) {
                      // 編集画面から戻ってきたらデータを再読み込み
                      loadData();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    // ここでデータベースから削除しています
                    await widget.isar.writeTxn(() async {
                      await widget.isar.persons.delete(person.id);
                    });
                    await loadData();
                  },
                ),

                // 新しいボタンを追加
                //IconButton(
                //icon: Icon(
                //person.important == 1 ? Icons.star : Icons.star_border,
                //color: const Color.fromARGB(255, 170, 170, 170),
                //),
                //onPressed: () async {
                // ボタンがタップされた時の処理
                //person.important = person.important == 1 ? 0 : 1;
                //await widget.isar.writeTxn(() async {
                //await widget.isar.persons.put(person);
                //});
                //setState(() {});
                //},
                //),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPage(
                isar: widget.isar,
                questionListId: widget.questionList.id,
              ),
            ),
          ).then((_) {
            // 画面から戻ってきたらデータを再読み込み
            loadData();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Icon _buildIconForStatus(String? status, int? important) {
    if (status == '正解') {
      return Icon(Icons.check, color: Colors.green);
    } else if (status == '不正解') {
      return Icon(Icons.close, color: Colors.red);
    } else {
      if (important == 1) {
        return Icon(Icons.help, color: Colors.yellow);
      } else {
        return Icon(Icons.help, color: Colors.grey);
      }
    }
  }
}

class QuestionDetailScreen extends StatefulWidget {
  final Isar isar;
  final Person question;

  QuestionDetailScreen({required this.isar, required this.question});

  @override
  _QuestionDetailScreenState createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('詳細'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '大問:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.question.name ?? '問題がありません',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '小問:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.question.answer ?? '答えがありません',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '解答・解説:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.question.explanation ?? '解説がありません',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 40),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     ElevatedButton(
            //       onPressed: () {
            //         _handleAnswer(true);
            //       },
            //       child: Text('正解', style: TextStyle(fontSize: 16)),
            //       style: ButtonStyle(
            //         backgroundColor: MaterialStateProperty.all(Colors.green),
            //       ),
            //     ),
            //     ElevatedButton(
            //       onPressed: () {
            //         _handleAnswer(false);
            //       },
            //       child: Text('不正解', style: TextStyle(fontSize: 16)),
            //       style: ButtonStyle(
            //         backgroundColor: MaterialStateProperty.all(Colors.red),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  void _handleAnswer(bool isCorrect) {
    widget.question.atemptCount = (widget.question.atemptCount ?? 0) + 1;
    widget.question.correctCount =
        (widget.question.correctCount ?? 0) + (isCorrect ? 1 : 0);
    widget.question.lastAnswerStatus = isCorrect ? '正解' : '不正解';
    widget.question.lastAnswerDate = DateTime.now();

    widget.isar.writeTxn(() {
      return widget.isar.persons.put(widget.question);
    });

    Navigator.pop(context);
  }
}
