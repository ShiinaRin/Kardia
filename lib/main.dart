import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:kardia_anki/TimeLine.dart';
import 'package:kardia_anki/library/Library.dart';

import "model/person.dart";
import "model/QuestionList.dart";
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  // Isarの初期化
  WidgetsFlutterBinding.ensureInitialized();
  // アプリのドキュメントディレクトリを取得
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [PersonSchema, QuestionListSchema],
    directory: dir.path,
  );

  runApp(
    MyApp(isar: isar),
  );
}

class MyApp extends StatelessWidget {
  final Isar isar;

  MyApp({required this.isar});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kardia Anki',
      theme: ThemeData(
        textTheme: GoogleFonts.bizUDPGothicTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 29, 80, 162),
          //brightness: Brightness.dark, // 追記
        ),
        useMaterial3: true,
      ),
      home: SideNavigation(isar: isar),
    );
  }
}

class SideNavigation extends StatefulWidget {
  final Isar isar; // コンストラクタで受け取ったisarを使用する

  SideNavigation({required this.isar});

  @override
  _SideNavigationState createState() => _SideNavigationState();
}

class _SideNavigationState extends State<SideNavigation> {
  var selectedIndex = 0;

  // initState内でwidget.isarを使用する
  @override
  void initState() {
    super.initState();
    isar = widget.isar;
  }

  late Isar isar; // late修飾子を削除
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = LibraryScreen(
          isar: isar,
        );
        break;
      case 1:
        page = TimelineScreen(
          isar: isar,
          questionList: QuestionList(),
        );
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.library_add_check),
                    label: Text('Library'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.edit_note),
                    label: Text('復習ホーム'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page, // ← Here.
              ),
            ),
          ],
        ),
      );
    });
  }
}

class AddPage extends StatefulWidget {
  const AddPage({
    Key? key,
    required this.isar,
    required this.questionListId, // questionListId パラメータを追加
  }) : super(key: key);

  final Isar isar;
  final int questionListId;

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final nameController = TextEditingController();
  final answerController = TextEditingController();
  final explanationController = TextEditingController();
  final _nameFocusNode = FocusNode(); // 名前フィールドのFocusNodeを作成

  @override
  void dispose() {
    nameController.dispose();
    answerController.dispose();
    explanationController.dispose();
    _nameFocusNode.dispose(); // FocusNodeの破棄
    super.dispose();
  }

  Future<void> _savePerson() async {
    final person = Person()
      ..name = nameController.text
      ..answer = answerController.text
      ..explanation = explanationController.text
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..lastAnswerDate = DateTime.now()
      ..questionListId = widget.questionListId; // 選択されたQuestionListのIDを保持

    nameController.clear();
    answerController.clear();
    explanationController.clear();
    await widget.isar.writeTxn(() async {
      await widget.isar.persons.put(person);
    });
    _nameFocusNode.requestFocus(); // 名前フィールドにフォーカスを設定
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('問題追加'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              focusNode: _nameFocusNode, // 名前フィールドにFocusNodeを設定
              maxLines: null,
              decoration: const InputDecoration(
                labelText: '問題',
                hintText: '問題文を入力',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: answerController,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: '解答',
                hintText: '答えを入力',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: explanationController,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: '解説',
                hintText: '解説を入力',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePerson, // ボタンが押されたときに _savePerson メソッドを呼び出す
              child: const Text('保存'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
