import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/components/empty_flex.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/kanji.dart';
import 'package:kanji_memory_hint/kanji-list/example.dart';
import 'package:kanji_memory_hint/kanji-list/parameter.dart';
import 'package:kanji_memory_hint/kanji-list/view_layout.dart';
import 'package:kanji_memory_hint/theme.dart';

class KanjiView extends StatelessWidget {
  late List<Kanji> kanjis;
  late int index;

  KanjiView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var param = ModalRoute.of(context)!.settings.arguments as KanjiViewParam;
    kanjis = param.kanjis;
    index = param.index;
    
    return KanjiLayout(
      topic: kanjis[0].chapter, 
      child: PageView.builder(
        controller: PageController(
          initialPage: index,
          viewportFraction: 0.8
        ),
        itemCount: kanjis.length,
        itemBuilder: (context, index) {
          return _KanjiContainer(kanji: kanjis[index]);
        }
      ),
    );
  }
}

class _KanjiContainer extends StatelessWidget {
  final Kanji kanji;

  const _KanjiContainer({Key? key, required this.kanji}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        width: size.width*0.8,
        height: size.height*0.7,
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1
          ),
          color: AppColors.primary
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1
            )
          ),
          child: _KanjiWidget(kanji: kanji,)
        ),
      )
    );
  }
}

class _KanjiWidget extends StatelessWidget {
  final Kanji kanji;
  static const String _fontStyle = 'MsMincho';

  const _KanjiWidget({Key? key, required this.kanji}) : super(key: key);
  
  Widget _header(BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: 16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  kanji.rune, 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: _fontStyle,
                    fontSize: 76
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(),
              ),
              //kunyomi onyomi
              Expanded(
                flex: 8,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //kunyomi
                      Flexible(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(flex: 1, child: const Text("くん・よみ", style: TextStyle(fontWeight: FontWeight.bold),),),
                            // Text(kanji.kunyomi.join("／"))
                            Expanded(flex: 1, child: Text(kanji.kunyomi))
                          ]
                        )
                      ),
                      // EmptyFlex(flex: 1),
                      // SizedBox(height: 50,),
                      // onyomi
                      Flexible(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(flex: 1, child: const Text("おん・よみ", style: TextStyle(fontWeight: FontWeight.bold)),),
                            // Text(kanji.onyomi.join("／"))
                            Expanded(flex: 1, child:Text(kanji.onyomi))
                          ],
                        )
                      )
                    ],
                  ),
                )
              )
            ]
          )
        ),
        EmptyFlex(flex: 1)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    kanji.examples.sort((a, b) {
      if(a.hasImage == b.hasImage) {
        return 0;
      } else if(a.hasImage){
        return -1;
      } else {
        return 1;
      }
    });
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10
      ),
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              // decoration: BoxDecoration(
              //     border: Border.all(width: 1)
              //   ),
              child: _header(context),
            )
          ),
          Expanded(
          flex: 3,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                // decoration: BoxDecoration(
                //   border: Border.all(width: 1)
                // ),
                width: constraints.maxWidth,
                child: Image.asset(
                  STROKE_ORDER_FOLDER+kanji.strokeOrder,
                  fit: BoxFit.contain,
                ),
              );
            }
          )
        ),
          EmptyFlex(flex: 1),
          Expanded(
            flex: 15,
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 3/6,
              crossAxisSpacing: 5,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              // physics: const NeverScrollableScrollPhysics(),
              children: 
              kanji.examples.map((example) => ExampleContainer(example: example, kanji: kanji,)).toList()
            )
          )
        ],
      )
    );

  }
}