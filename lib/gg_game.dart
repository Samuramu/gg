import 'package:flutter/material.dart';
import 'constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'statement_model.dart';
import 'gg_level_avatar.dart';
import 'complete_animated_container.dart';


class GgGame extends StatefulWidget {
  GgGame ({this.levelNumber,this.updateLevelProgressCallback});

  final int levelNumber;
  final Function updateLevelProgressCallback;



  @override
  _GgGameState createState() => _GgGameState();
}

class _GgGameState extends State<GgGame> {
  ScrollController _controller;
  //
  String message = '';
  int currentStatement = 0;
  int totalStatements = 0;
  String currentStatementText;
  bool currentPos;
  double heightAdjustment = 120;
  bool gameOn = false;
  int unlockedLevel;
  String url;
  bool isVisible = true;
  LocalStorage storage;
  List<StatementModel> levelStatementsData = [];
  ScrollPhysics scrollPhysics = BouncingScrollPhysics();


  @override
  void initState() {

    super.initState();
    url = "http://ggapps.net/gateway/dbquery.php?bundle=com.samuramu.gg.de&language=en&gender=f&variator=0.36&statements=yes&level=";
    loadStorage();
    //

  }
  void loadStorage()  {
    storage = new LocalStorage('user_data');
    storage.ready.then((_) => useStorage());
  }
  void useStorage() {
    unlockedLevel = storage.getItem('level_unlocked');

    if (unlockedLevel == null) {
      print("game: level not stored: $unlockedLevel");
      storage.setItem('level_unlocked', 1);
      unlockedLevel = 1;
    }
    loadData();
  }
  void updateLevelMap() {
    if (unlockedLevel < widget.levelNumber) {
      print ('updating new unlocked level') ;
      storage.setItem('level_unlocked', widget.levelNumber);
    }
    if (widget.updateLevelProgressCallback != null) {
      print ('callback found');
      widget.updateLevelProgressCallback(widget.levelNumber);
    }
  }

  loadData() async {
    String num = widget.levelNumber.toString();
    String theURL = "$url$num";
    print(theURL);
    int countStatements;
    var response = await http.get(theURL);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      //print("Got statements json: $responseBody['statements']");
      for (var levelData in responseBody['statements']) {
        //var levelData = responseBody['statements'][n];
        if (levelData['theme'] != null) {
          //print (levelData["stmt"]);

          levelStatementsData.add(StatementModel(
            theme: levelData["theme"],
            negpos: levelData["negpos"],
            stmt: levelData["stmt"],
          ));
          //countStatements ++;
        }
      }
      setState(() {
        totalStatements = countStatements;
        gameOn = true;
      });
    } else {
      print('Something went wrong');
    }
  }

  void finishGame() {
    updateLevelMap();
    gameOn = false;
    Navigator.pop(context);
  }

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      if (levelStatementsData[currentStatement].negpos.toLowerCase() == "neg") {
        setState(() {
          isVisible = false;
          //message = "reached the top";
          //print(message);
          currentStatement ++;
          if (currentStatement > levelStatementsData.length - 1) {
            finishGame();
          } else {
            String next = getStatement();
            currentStatementText = next;
            updateScroll(context);
          }
        });
      }
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      if (levelStatementsData[currentStatement].negpos.toLowerCase() == "pos") {
        setState(() {
          isVisible = false;
          //message = "reached the bottom";
          //print(message);
          currentStatement ++;
          if (currentStatement > levelStatementsData.length - 1) {
            finishGame();
          } else {
            String next = getStatement();
            currentStatementText = next;
            updateScroll(context);
          }
        });
      }
    }
  }

  void updateScroll(context) {

    print ('Update scroll');
    double moveBy = (currentPos ? MediaQuery.of(context).size.height * .5 + heightAdjustment / 2 : MediaQuery.of(context).size.height * .5 - heightAdjustment / 2);
    //_controller.animateTo(moveBy, duration: Duration(milliseconds: 100), curve: Curves.easeInOut );
    _controller.jumpTo(moveBy);
    //_controller.addListener(_scrollListener);
    //_controller.
  }
  String getStatement() {

    return levelStatementsData[currentStatement].stmt;
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    super.dispose();
  }
  List<Widget> _createChildren() {
    return List<Widget>.generate(levelStatementsData.length, (int index) {
      return Expanded(
        child: CorrectCounterItem(
          index: index,
          currentStatement: currentStatement,
          totalStatements: levelStatementsData.length,
        )
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    //
    String heroTag = "levelAvatar" + widget.levelNumber.toString();
    return Scaffold(
      body: levelStatementsData.length == 0 || gameOn == false
          ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              Hero(
                  tag: heroTag,
                  child: GgLevelAvatar(
                    index: widget.levelNumber,
                    levelSeq: widget.levelNumber.toString() ,
                    isLocked: false,
                  )
              ),
            ],
        ),
      )
          : showStatementsUI(context),
    );
  }
  Widget showStatementsUI(context) {
    currentStatementText = levelStatementsData[currentStatement].stmt;
    currentPos = levelStatementsData[currentStatement].negpos.toLowerCase() == "pos";
    double baseHeight = MediaQuery.of(context).size.height;
    _controller = ScrollController();
    scrollPhysics = BouncingScrollPhysics();//ClampingScrollPhysics();
    _controller.addListener(_scrollListener);

    Future.delayed (Duration(milliseconds: 1), (){
      updateScroll(context);
      if (!isVisible) {
        setState(() {
          isVisible = true;
        });
      }
    });
    return Container(
      color: Colors.teal,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: Container (
              height: 50.0,
              //color: Colors.orange,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _createChildren(),
                ),
              ),
            ),
          ListView(
            controller: _controller,
            physics: scrollPhysics,
            children: <Widget>[
              SizedBox(
                height: currentPos? baseHeight : baseHeight - heightAdjustment,
              ),
              Visibility(
                visible: isVisible,
                child: Card(
                  margin: EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        currentStatementText != null ? currentStatementText : '[null]',
                        style: kTextStyleStatementCard,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: currentPos? baseHeight - heightAdjustment : baseHeight,
              ),
            ],
          ),

        ],
      ),
    );
  }
}
