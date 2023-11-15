import 'package:isar/isar.dart'; // 1. isarパッケージをインポート
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
  //final questionlists = IsarLinks<QuestionList>();
  int? important;

    // 14日経過しているかを判定するメソッド
  bool isLastAnswerDateExpired() {
    final daysDifference = DateTime.now().difference(lastAnswerDate).inDays;
    return daysDifference >= 14;
  }

  // createdAtから1日以上経過していて、かつlastAnswerDate＝createdAtのものを判定するメソッド
  bool isCreatedAtAndLastAnswerDateEqual() {
    final daysDifference = lastAnswerDate.difference(createdAt).inDays;
    return daysDifference >= 1;
  }
  
}

//動かなかったらFlutter buildのやつやっとき。