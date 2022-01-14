import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/dialogs/confirmation_dialog.dart';
import 'package:kanji_memory_hint/components/dialogs/kana_dialog.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/images.dart';
import 'package:kanji_memory_hint/theme.dart';

class PauseDialog extends StatelessWidget {
  
  final Function() onContinue;
  final Function() onRestart;
  final bool withKanaChart;

  const PauseDialog({Key? key, required this.onContinue, required this.onRestart, this.withKanaChart = true}) : super(key: key);

  Widget showKanaDialog(BuildContext context) {
    return KanaDialog();
  }

  Widget _buildPracticePause(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return  GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      children: [
        _DialogButton(
            icon: AppIcons.resume, 
            onPressed: () {
              onContinue();
              Navigator.pop(context);
            },
          ),

        _DialogButton(
          icon: AppIcons.retry, 
          onPressed: () {
            Navigator.pop(context);
            onRestart();
          },
          ),
        _DialogButton(
          icon: AppIcons.kana, 
          onPressed: (){
            showDialog(context: context, builder: showKanaDialog);
          }),
        _QuitButton(
            icon: AppIcons.home, 
            onPressed: (){
              // Navigator.of(context).pushNamedAndRemoveUntil(newRouteName, (route) => false)
              Navigator.of(context).popUntil(ModalRoute.withName('/'));
            }
          )
        ],
    );
  }

  Widget _buildQuizPause(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.all(5),
                child: _DialogButton(
                icon: AppIcons.resume, 
                onPressed: () {
                  onContinue();
                  Navigator.pop(context);
                },
              ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: _DialogButton(
                icon: AppIcons.retry, 
                onPressed: () {
                  Navigator.pop(context);
                  onRestart();
                },
              ),)
            ],
          ),
        ),
        Flexible(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: _QuitButton(
              icon: AppIcons.exit, 
              onPressed: (){
                Navigator.of(context).popUntil(ModalRoute.withName('/start-select'));
              }
            )
          )
        )
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        onContinue();
        return true;
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          shape: const BeveledRectangleBorder(
              side: BorderSide(color: Colors.black, width: 1)
          ),
          child: Container(
            height: size.height * 0.42,
            width: size.width * 0.42,
            padding: EdgeInsets.all(6),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1
                )
              ),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 3, 
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
                    child: Text("Paused",
                      style: Theme.of(context).textTheme.headline6!,  
                    )
                  )
                ),
                Flexible(
                  flex: 8,
                  child: withKanaChart ? 
                    SizedBox(
                      width: size.width*0.5,
                      child:
                        _buildPracticePause(context) 
                    ) 
                    :
                    SizedBox(
                      width: size.width*0.52,
                      child: _buildQuizPause(context) 
                    )
                )
              ]
              )
            ),
          )
        )
      )
    );
  }
}

class _DialogButton extends  StatelessWidget {
  
  final String icon;
  final Function() onPressed;

  const _DialogButton({Key? key, required this.icon, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
      width: size.width*0.4,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1
        )
      ),
        child: TextButton(
          onPressed: onPressed,
          child: Container(
            alignment: Alignment.center,
            child: Image.asset(
              icon,
              height: 50,
              width: 50,
            )
          )
          )
        )
    );
  }
}

class _QuitButton extends  StatelessWidget {
  
  final String icon;
  final Function() onPressed;

  const _QuitButton({Key? key, required this.icon, required this.onPressed}) : super(key: key);

  Widget buildConfirmationDialog(BuildContext context) {
    return ConfirmationDialog(
      onConfirm: (){
        Navigator.of(context, rootNavigator: true).pop(true);
      },
      onCancel: (){
        Navigator.of(context, rootNavigator: true).pop(false);
      },
    );
  }

  Future<bool> showConfirmationDialog(BuildContext context) async {
    bool exit;
    exit = await showDialog(
      context: context, 
      builder: buildConfirmationDialog
    ) ?? false;
    return exit;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
      width: size.width*0.4,
  
      decoration: BoxDecoration(
        border: Border.all(
          width: 2
        )
      ),
      child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: AppColors.wrong
          ),
          onPressed: () async {
            bool exit = await showConfirmationDialog(context);
            if(exit) {
              onPressed();
            }
          },
          child: Container(
            alignment: Alignment.center,
            child: Image.asset(
              icon,
              height: 50,
              width: 50,
            )
          )
        )
      )
    );
  }
}