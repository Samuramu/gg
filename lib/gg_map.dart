import 'package:flutter/material.dart';
import 'package:flutter_json_list/MapLevelModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'gg_game.dart';
import 'gg_level_avatar.dart';
import 'package:localstorage/localstorage.dart';

class GgMap extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<GgMap> {
  final String url =
      "http://ggapps.net/gateway/dbquery.php?bundle=$appBundlePrefix.de&language=en&gender=f&variator=0.36&level=map";

  List<MapLevelModel> myAllData = [];

  LocalStorage storage;
  int unlockedLevel;

  @override
  void initState() {
    super.initState();
    loadStorage();
  }

  void loadStorage() {
    storage = new LocalStorage('user_data');
    storage.ready.then((_) => useStorage());
  }

  void useStorage() {
    unlockedLevel = storage.getItem('level_unlocked');

    if (unlockedLevel == null) {
      print("map level not stored: $unlockedLevel");
      storage.setItem('level_unlocked', 1);
      unlockedLevel = 1;
    } else {
      print("Unlocked level: $unlockedLevel");
      // for testing:
      //resetUnlockedLevel();
    }
    loadData();
  }

  void resetUnlockedLevel() {
    storage.setItem('level_unlocked', 1);
  }

  void updateLevelMap(int levelNum) {
    print('updateLevelMap$levelNum');
    setState(() {
      unlockedLevel = levelNum;
    });
  }

  loadData() async {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var responseBody = response.body;
      print('Got map json');
      //
      int n = 0;
      do {
        var levelData = json.decode(responseBody)['$n'];
        if (levelData['level_name'] != null) {
          myAllData.add(new MapLevelModel(
            levelId: levelData["level_id"],
            levelName: levelData["level_name"],
            levelSeq: levelData["level_seq"],
            gameType: levelData["game_type"],
            isLockLevel: levelData["is_lock_level"],
            isAssessment: levelData["is_assessment"],
            isRelevancy: levelData["is_relevancy"],
            isMajor: levelData["is_major"],
            relevancyGroup: levelData["relevancyGroup"],
            color: levelData["color"],
          ));
        }
        n++;
      } while (json.decode(response.body)['$n'] != null);
      setState(() {
        //unlockedLevel =
      });
      //myAllData.forEach((someData) => print("Name : ${someData.levelName}"));
    } else {
      print('Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    return myAllData.length == 0
        ? Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
            physics: BouncingScrollPhysics(),
            reverse: true,
            scrollDirection: Axis.vertical,
            itemCount: myAllData.length,
            itemBuilder: (_, index) {
              return Container(
                color: hexToColor(myAllData[index].color),
                child: Builder(
                  builder: (context) => FlatButton(
                        onPressed: () {
                          int level = int.parse(myAllData[index].levelSeq);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GgGame(
                                      levelNumber: level,
                                      updateLevelProgressCallback:
                                          updateLevelMap,
                                    )),
                          );
                        },
                        child: Container(
                          padding: new EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              StarRating(
                                size: 20.0,
                                rating: 0,
                                color: Colors.yellow,
                                borderColor: Colors.white54,
                                starCount: 3,
                                onRatingChanged: (rating) => setState(
                                      () {},
                                    ),
                              ),
                              Hero(
                                  tag: 'levelAvatar$index',
                                  child: GgLevelAvatar(
                                    levelSeq: myAllData[index].levelSeq,
                                    index: index,
                                    isLocked: unlockedLevel < index + 1
                                        ? true
                                        : false,
                                  )),
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 3.0)),
                              Text('${myAllData[index].levelName}',
                                  style: kTextStyleLevelName),
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 3.0)),
                            ],
                          ),
                        ),
                      ),
                ),
              );
            });
  }

  Color hexToColor(String code) {
    return Color(
        int.parse(code.substring(0, code.length), radix: 16) + 0xFF000000);
  }
}
