import 'package:isar/isar.dart'; // 1. isarパッケージをインポート
import 'person.dart';

part 'QuestionList.g.dart'; // ファイル名.g.dartと書く

@collection
class QuestionList {
  Id id = Isar.autoIncrement; // リストのID
  late String title; // リストのタイトル
  late DateTime createdAt; // リストの作成日時
  late DateTime updatedAt; // リストの最終更新日時
  @Backlink(to: "questionlists")
  final persons = IsarLinks<Person>();
}
//動かなかったらFlutter buildのやつやっとき。