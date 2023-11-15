import 'package:isar/isar.dart'; // 1. isarパッケージをインポート

part 'QuestionList.g.dart'; // ファイル名.g.dartと書く

@collection
class QuestionList {
  Id id = Isar.autoIncrement; // リストのID
  late String title = "タイムライン！"; // リストのタイトル
  late String gaiyo = "";
  late DateTime createdAt; // リストの作成日時
  late DateTime updatedAt; // リストの最終更新日時
}
//動かなかったらFlutter buildのやつやっとき。