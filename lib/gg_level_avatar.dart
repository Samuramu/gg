import 'package:flutter/material.dart';
import 'constants.dart';

class GgLevelAvatar extends StatelessWidget {
  const GgLevelAvatar({
    Key key,
    @required this.levelSeq,
    @required this.index,
    this.isLocked
  }) : super(key: key);

  final String levelSeq;
  final int index;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      minRadius: 26.0,
      child: CircleAvatar(
        minRadius: 22.0,
        backgroundColor: isLocked ? Colors.teal : Colors.orange,
        //foregroundColor: Colors.black,
        child: Text(
          levelSeq,
          style: kTextStyleLevelNumber,
        ),
      ),
    );
  }
}