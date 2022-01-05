import 'package:flutter/cupertino.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/multiple-choice/game.dart';
import 'package:kanji_memory_hint/quiz/next_button.dart';

class MultipleChoiceQuizGame extends StatefulWidget {
  const MultipleChoiceQuizGame({Key? key, required this.mode, required this.questionSets, required this.onSubmit, this.quizOver = false}) : super(key: key);

  final GAME_MODE mode;
  final List<QuizQuestionSet> questionSets;
  final Function(int correct, int wrong, List<List<int>> correctKanjis) onSubmit;
  final bool quizOver;

  @override
  State<StatefulWidget> createState() => _MultipleChoiceGameState();
}

class _MultipleChoiceGameState extends State<MultipleChoiceQuizGame> {
    int correct = 0;
    int wrong = 0;
    int solved = 0;
    List<int> correctIndexes = [];

    bool initialRerender = true;
    late int totalQuestion = widget.questionSets.length; 

  void _handleOnSelectQuiz(bool isCorrect, int index, bool? wasCorrect) {
      setState(() {
        if(wasCorrect == true) {
          correct--;
          correctIndexes.remove(index);
        } else if(wasCorrect == false) {
          wrong--;
        }

        if(isCorrect){
          correct++;
          correctIndexes.add(index);
        } else {
          wrong++;
        }

        if(wasCorrect == null) {
          solved++;
        }
      });
  }

  Widget _buildMultipleChoiceRound(BuildContext context, int index, QuizQuestionSet set) {
    final unanswered = totalQuestion - solved;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1
        )
      ),
      child: Column(
        children: [
          Expanded(
            flex: 15,
            child: MultipleChoiceRound(
              mode: widget.mode,
              question: set.question,
              options: set.options,
              index: index,
              onSelect: _handleOnSelectQuiz,
              quiz: true,
              isOver: widget.quizOver,
            ),
          ),
          Expanded(
            flex: 1,
            child: NextQuizRoundButton(
              onTap: () {
                var correctKanjis = correctIndexes.map((index) => widget.questionSets[index].fromKanji).toList();
                widget.onSubmit(correct, wrong+unanswered, correctKanjis);
              }, 
              visible: !widget.quizOver && solved == totalQuestion
            )
          )
        ]
      )
    );
  }

  Widget _build(BuildContext context, List<QuizQuestionSet> items) {
    return Column(
      children: [
        Flexible(
          flex: 9,
          child: PageView.builder(
              // store this controller in a State to save the carousel scroll position
            pageSnapping: true,
            controller: PageController(
              viewportFraction: 1,
              initialPage: 0,
              keepPage: false,
            ),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildMultipleChoiceRound(context, index, items[index]);
            },
          ),
        ),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if(widget.quizOver && initialRerender) {
        final unanswered = totalQuestion - solved;
        var correctKanjis = correctIndexes.map((index) => widget.questionSets[index].fromKanji).toList();
        widget.onSubmit(correct, wrong+unanswered, correctKanjis);
        // setState(() {
          initialRerender = false;
        // });
      }
    });
    return _build(context, widget.questionSets);
  }
}