import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/example.dart';
import 'package:kanji_memory_hint/database/game_provider.dart';
import 'package:kanji_memory_hint/database/kanji.dart';
import 'package:kanji_memory_hint/database/quests.dart';
import 'package:kanji_memory_hint/database/user_point.dart';
import 'package:kanji_memory_hint/quests/practice_quest.dart';
import 'package:kanji_memory_hint/quests/quiz_quest.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class SQLRepo {
  static Database? db;
  static late final UserPointProvider userPoints;
  static late final QuestProvider quests;
  static late final KanjiProvider kanjis;
  static late final ExampleProvider examples;
  static late final GameQuestionProvider gameQuestions;

  static Future drop() async {
    var path = await getDatabasesPath();
    var dbPath = join(path, "kantan_test.db");
    await deleteDatabase(dbPath);
  }

  static Future open() async {
    if(MIGRATE) {
      await drop();
    }

    var path = await getDatabasesPath();
    var dbPath = join(path, 'kantan_test.db');
    db ??= await openDatabase(dbPath, version: 1,
      onCreate: (Database db, int version) async {
        await UserPointProvider.migrate(db);
        await QuestProvider.migrate(db);
        await KanjiProvider.migrate(db);
        await ExampleProvider.migrate(db);
      }
    );

    userPoints = UserPointProvider(db!);
    quests = QuestProvider(db!);
    kanjis = KanjiProvider(db!);
    examples = ExampleProvider(db!);
    gameQuestions = GameQuestionProvider(kanjis, examples);

    PracticeQuestHandler.supplyQuests();
    QuizQuestHandler.supplyQuests();
    if(MIGRATE){
      kanjis.seed();
      examples.seed();
    }
  }
}