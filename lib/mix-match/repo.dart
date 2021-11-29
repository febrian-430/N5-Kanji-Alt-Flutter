import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/repository/repo.dart';
import 'package:kanji_memory_hint/map_indexed.dart';


Future<List<Question>> makeOptions(int n, int chapter, GAME_MODE mode) {
  if(mode == GAME_MODE.imageMeaning) {
    return _makeImageMeaningOptions(n, chapter);
  }
  return _makeReadingOptions(n, chapter);
}

Future<List<Question>> _makeImageMeaningOptions(int n, int chapter) async {
    var kanjis = await ByChapter(chapter);
    kanjis.shuffle();

    var candidates = kanjis.take(n);

    List<Question> imageOptions = candidates.mapIndexed((kanji, index) {
      return Question(id: index, value: kanji.image, key: kanji.id, isImage: true);
    }).toList();

    var last = imageOptions.length;

    List<Question> runeOptions = candidates.mapIndexed((kanji, index) {
      return Question(id: index+last, value: kanji.rune, key: kanji.id);
    }).toList();

    final List<Question> options = [...imageOptions, ...runeOptions];
    options.shuffle();

    return options;
}

Future<List<Question>> _makeReadingOptions(int n, int chapter) async {
    var kanjis = await ByChapter(chapter);
    kanjis.shuffle();

    var candidates = kanjis.take(n);

    List<Question> runeOptions = candidates.mapIndexed((kanji, index) {
      return Question(id: index, value: kanji.rune, key: kanji.id);
    }).toList();

    var last = runeOptions.length;

    List<Question> spellingOptions = candidates.mapIndexed((kanji, index) {
      return Question(id: index+last, value: kanji.spelling, key: kanji.id);
    }).toList();

    final List<Question> options = [...runeOptions, ...spellingOptions];
    options.shuffle();

    return options;
}