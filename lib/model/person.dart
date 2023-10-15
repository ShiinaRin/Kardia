import 'package:isar/isar.dart'; // 1. isarパッケージをインポート
import 'QuestionList.dart';
part 'person.g.dart'; // ファイル名.g.dartと書く

@collection
class Person {
  Id id = Isar.autoIncrement; // id = nullでも自動インクリメントされます。
  String? name; //問題
  String? answer; //答え
  String? explanation; //解答解説
  late DateTime createdAt;
  late DateTime updatedAt;
  int? correctCount;
  int? atemptCount;
  String? lastAnswerStatus;
  late DateTime lastAnswerDate;
  late int questionListId;
  final questionlists = IsarLinks<QuestionList>();
}

//動かなかったらFlutter buildのやつやっとき。