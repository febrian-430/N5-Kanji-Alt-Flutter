import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/loading_screen.dart';
import 'package:kanji_memory_hint/components/result_button.dart';
import 'package:kanji_memory_hint/components/submit_button.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/game_components/question_widget.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/multiple-choice/repo.dart';
import 'package:kanji_memory_hint/route_param.dart';

typedef OnOptionSelectCallback = Function(Option option);
typedef RoundOverCallback = Function(bool isCorrect, int index, bool? wasCorrect); 



class MultipleChoiceGame extends StatefulWidget {
  MultipleChoiceGame({Key? key, required this.mode, required this.chapter}) : super(key: key);

  static const route = '/game/multiple-choice';
  static const name ='Multiple Choice';

  final GAME_MODE mode;
  final int chapter;
  final Stopwatch stopwatch = Stopwatch();

  Future<List<QuestionSet>> _getQuestionSet(int chapter, GAME_MODE mode) async {
     return multipleChoiceQuestionSet(15, chapter, mode, false);
  }

  @override
  State<StatefulWidget> createState() => _MultipleChoiceGameState();
}


class _MultipleChoiceGameState extends State<MultipleChoiceGame> {
  int score = 0;
  int wrong = 0;

  var _questionSet;
  int solved = 0;

  List<int> correctlySolved = [];

  late int numOfQuestions;

  bool gameOver = false;

  @override
  void initState() {
    super.initState();
      _questionSet = widget._getQuestionSet(widget.chapter, widget.mode); 
  }

  void _handleOnSelect(bool isCorrect, int index, bool? wasCorrect) {
    setState(() {
      print("WASCORRECT IS: " + wasCorrect.toString());

      if(wasCorrect == null) {
        solved++;
      }

      if(isCorrect) {
        correctlySolved.add(index);
      } else {
        wrong++;
      }

    });
  }

  Widget _buildRound(BuildContext context, int itemIndex, List<QuestionSet> data) {
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MultipleChoiceRound(
            question: data[itemIndex].question, 
            options: data[itemIndex].options, 
            mode: widget.mode, 
            index: itemIndex, 
            onSelect:  _handleOnSelect,
            isOver: gameOver, 
            // || (!widget.quiz && correctlySolved.contains(itemIndex)), quiz test purposes
            quiz: true,
          ),
          ResultButton(
            visible: gameOver && solved == numOfQuestions, 
            param: ResultParam(wrongCount: wrong, decreaseFactor: 100, stopwatch: widget.stopwatch)
          ),
          SubmitButton(
            visible: !gameOver && solved == numOfQuestions, 
            onTap: () {
              setState(() {
                gameOver = true;
                widget.stopwatch.stop();
              });
            },
          ),
      ],) 

      
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.stopwatch.start();

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _questionSet,
          builder: (context, AsyncSnapshot<List<QuestionSet>> snapshot) {
            if(snapshot.hasData) {
              numOfQuestions = snapshot.data!.length;

              return PageView.builder(
                // store this controller in a State to save the carousel scroll position
                controller: PageController(
                  viewportFraction: 1,
                ),
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int itemIndex) {
                  return _buildRound(context, itemIndex, snapshot.data!);
                },
              );
            } else {
              return LoadingScreen();
            }
          }
        )
      )
    );
  }
}

class MultipleChoiceRound extends StatefulWidget  {
  const MultipleChoiceRound({Key? key, required this.question, required this.options, required this.mode, required this.onSelect, this.quiz = false, this.isOver = false, required this.index}) : super(key: key);

  final int index;

  final Question question;
  final List<Option> options;
  final GAME_MODE mode;
  final RoundOverCallback onSelect;

  final bool quiz;
  final bool isOver;

  @override
  State<StatefulWidget> createState() => _MultipleChoiceRoundState();
}

class _MultipleChoiceRoundState extends State<MultipleChoiceRound> with AutomaticKeepAliveClientMixin<MultipleChoiceRound> {
  Option? selected;

  void _handleSelect(Option opt) {
    Option? prev = selected;
    
    setState(() {
      selected = opt;
    });

    bool? wasCorrect;
    if(prev != null) {
      wasCorrect = prev.key == widget.question.key;
    }

    widget.onSelect(opt.key == widget.question.key, widget.index, wasCorrect);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Container( 
      child: Center(
        child: Column(
          children: [
            QuestionWidget(mode: widget.mode, questionStr: widget.question.value),
            Center(child: Text((widget.question.key.toString())),),
            Column(
                children: widget.options.map((Option opt) {
                  return widget.quiz ?  
                  _QuizOption(
                    option: opt, 
                    isSelected: selected?.key == opt.key, 
                    disabled: widget.isOver, 
                    correctKey: widget.question.key.toString(), 
                    onSelect: (option) {
                      _handleSelect(opt);
                    }, 
                    isOver: widget.isOver
                  )
                  :
                  _PracticeOption(
                    option: opt, 
                    isSelected: selected?.key == opt.key, 
                    disabled: widget.isOver, 
                    correctKey: widget.question.key.toString(), 
                    onSelect: (option) {
                      _handleSelect(opt);
                    }
                  );
                }).toList(),
            )
          ],
        ),
      ),

      
    );
  }
}



class _QuizOption extends StatelessWidget {
  const _QuizOption({Key? key, required this.option, required this.isSelected, required this.disabled, required this.correctKey, required this.onSelect, required this.isOver}): super(key: key);

  final Option option;
  final bool isSelected;
  final bool disabled;

  final bool isOver;

  final String correctKey;
  final OnOptionSelectCallback onSelect;

  Color _inProgress() {
    if(isSelected) {
      return Colors.grey;
    }
    return Colors.white;
  }

  Color _afterQuizOver() {
    if(correctKey == option.key) {
      return Colors.green;
    } else if (isSelected) {
      return Colors.red;
    } else {
      return Colors.white;
    }
  }

  Color _getBackgroundColor(BuildContext buildContext) {
    // if((disabled || isSelected) && correctKey == option.key) {
    //   return Colors.green;
    // } else if(isSelected) {
    //   return Colors.red;
    // } 
    
    // return Colors.white;

    if(isOver) {
      return _afterQuizOver();
    }
    return _inProgress();
  }

  TextStyle? _getTextStyle(BuildContext buildContext) {
    if(isSelected) {
      return const TextStyle(
      color: Colors.white
    );
    }
    return const TextStyle(
      color: Colors.black
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => disabled ? null : onSelect(option),
      child: Container(
        color: _getBackgroundColor(context),
        child: Center(
          child: Text(option.value + '\t' + option.key.toString(), style: _getTextStyle(context),),),
        width: 180,
        height: 60
      ),
      
    );
  }
}

class _PracticeOption extends StatelessWidget {
  const _PracticeOption({Key? key, required this.option, required this.isSelected, required this.disabled, required this.correctKey, required this.onSelect}): super(key: key);

  final Option option;
  final bool isSelected;
  final bool disabled;

  final String correctKey;
  final OnOptionSelectCallback onSelect;

  Color _getBackgroundColor(BuildContext buildContext) {
    if(isSelected && correctKey == option.key) {
      return Colors.green;
    } else if(isSelected) {
      return Colors.red;
    }
    
    return Colors.white;
  }

  TextStyle? _getTextStyle(BuildContext buildContext) {
    if(isSelected) {
      return const TextStyle(
        color: Colors.white
      );
    }
    return const TextStyle(
      color: Colors.black
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => disabled ? null : onSelect(option),
      child: Container(
        color: _getBackgroundColor(context),
        child: Center(
          child: Text(option.value + '\t' + option.key.toString(), style: _getTextStyle(context),),),
        width: 180,
        height: 60
      ),
      
    );
  }
}