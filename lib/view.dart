import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'model/person.dart';
import 'library/edit_page.dart'; // 編集画面への遷移用のページをインポート

class ViewPage extends StatefulWidget {
  final Isar isar;

  ViewPage({required this.isar});

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  List<Person> persons = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await widget.isar.persons.where().findAll();
    setState(() {
      persons = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('データを編集')),
      body: ListView.builder(
        itemCount: persons.length,
        itemBuilder: (context, index) {
          final person = persons[index];
          return ListTile(
            title: Text("問題:${person.name ?? "値が入ってません"}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("解答: ${person.answer ?? "未設定"}"),
                Text("解説: ${person.explanation ?? "未設定"}"),
              ],
            ),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
