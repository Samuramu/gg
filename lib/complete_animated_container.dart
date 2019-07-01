import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:animator/animator.dart';

class CorrectCounterItem extends StatelessWidget {
  CorrectCounterItem({
    this.currentStatement,
    this.totalStatements,
    this.index,
  });
  final int index;
  final int currentStatement;
  final int totalStatements;

  @override
  Widget build(BuildContext context) {
    //double opc = currentStatement / totalStatements * 1000;
    return currentStatement != index + 1 ?
    Container (
      alignment: Alignment.center,
      color: currentStatement < index + 1 ? Colors.white12 : Colors.white54,
      child: Text(
      currentStatement < index+1 ? '' : (index+1).toString(),
          style: kTextStyleStatementNumber,
        ),
      )
        : Animator(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration (milliseconds: 500),
      resetAnimationOnRebuild: false,
      builder: (anim) => Opacity(
        opacity: anim.value,
        child: Container (
          alignment: Alignment.center,
          color: Colors.white54,
          child: Text(
            (index+1).toString(),
            style: kTextStyleStatementNumber,
          ),
        ),
      ),
    );
  }
}
