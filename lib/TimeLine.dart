import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:kardia_anki/model/QuestionList.dart';
import 'package:kardia_anki/model/person.dart';

class TimelineScreen extends StatefulWidget {
  final Isar isar;
  final QuestionList? questionList; // nullable型として宣言

  TimelineScreen({required this.isar, required this.questionList});

  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
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
        .lastAnswerDateGreaterThan(DateTime.now().subtract(Duration(days: 14)))
        .or()
        .createdAtGreaterThan(DateTime.now().subtract(Duration(days: 1)))
        .or()
        .importantEqualTo(1)
        .and()
        .correctCountLessThan(6)
        .findAll();
    setState(() {
      persons = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
              widget.questionList?.title ?? 'タイトルがありません'), // nullチェックを行ってから使用
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
                leading: _buildIconForStatus(
                    person.lastAnswerStatus, person.important),
                title: Text("問題:${person.name ?? "値が入ってません"}"),
                subtitle: Text(
                  '正解率: ${person.correctCount ?? 0}/${person.atemptCount ?? 0}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        person.important == 1 ? Icons.star : Icons.star_border,
                        color: Colors.yellow,
                      ),
                      onPressed: () async {
                        // ボタンがタップされた時の処理
                        person.important = person.important == 1 ? 0 : 1;
                        await widget.isar.writeTxn(() async {
                          await widget.isar.persons.put(person);
                        });
                        setState(() {});
                      },
                    ),
                  ],
                ),
              );
            }));
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
        title: Text('解答・解説'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '問題:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.question.name ?? '問題がありません',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '答え:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.question.answer ?? '答えがありません',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '解説:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.question.explanation ?? '解説がありません',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _handleAnswer(true);
                  },
                  child: Text('正解', style: TextStyle(fontSize: 16)),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _handleAnswer(false);
                  },
                  child: Text('不正解', style: TextStyle(fontSize: 16)),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                ),
              ],
            ),
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
