import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/buttons/select_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/menu_screens/chapter_select.dart';
import 'package:kanji_memory_hint/menu_screens/menu.dart';
import 'package:kanji_memory_hint/route_param.dart';

class ModeSelect extends StatelessWidget {
  const ModeSelect({Key? key}) : super(key: key);

  static const route = '/mode-select';
  static const List<int> chapters = [1,2,3,4,5,6,7,8]; 


  
  @override
  Widget build(BuildContext context) {

    PracticeGameArguments param = ModalRoute.of(context)!.settings.arguments as PracticeGameArguments;

    Widget screen = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SelectButton(
              onTap: () {
                param.mode = GAME_MODE.imageMeaning;
                Navigator.pushReplacementNamed(context, ChapterSelect.route, arguments: param);
              },
              title: "Image Meaning",
              description: "Match the Kanji with the image based on its appropriate meaning",
            ),
            SizedBox(height: 100),
            SelectButton(
              onTap: () {
                param.mode = GAME_MODE.reading;
                Navigator.pushReplacementNamed(context, ChapterSelect.route, arguments: param);
              },
              title: "Reading",
              description: "Choose the correct answer based on its spelling",
            ),
          ]
        );
    return Menu(title: "Select Mode", japanese: "in japanese", child: screen);
  }
}