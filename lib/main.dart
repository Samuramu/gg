import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
import 'package:localstorage/localstorage.dart';
import 'gg_map.dart';

void main() => runApp(new GgApp());

class GgApp extends StatefulWidget {
  @override
  _GgAppState createState() => _GgAppState();
}

class _GgAppState extends State<GgApp> {
  final String url =
      "http://ggapps.net/gateway/dbquery.php?bundle=$appBundlePrefix.de&language=en&gender=f&variator=0.36";

  var appData = {};
  LocalStorage storage;
  var initialData = {
    'language': 'en',
    'num_launches': 0,
    'levels_complete': 0,
  };
  //TODO write and load app state - persistent. begin with level number, then stars, time etc.

  @override
  void initState() {
    super.initState();
    loadStorage();
    //loadData();
  }

  void loadStorage()  {
    storage = new LocalStorage('user_data');
    storage.ready.then((_) => useStorage());
  }

  void useStorage() {
    var numLaunches = storage.getItem('num_launches');

    if (numLaunches == null) {
      print("launches not stored: $numLaunches");
      storage.setItem('num_launches', 1);
    } else {
      print("launches stored: $numLaunches");
      numLaunches++;
      storage.setItem('num_launches', numLaunches);
    }
    loadData();
  }

  loadData() async {
    print ("load data");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var responseBody = response.body;
      print('Got master json');
      int n = 1;
      appData = json.decode(responseBody)['$n'];
      if (appData['bundle_id'] != null) {
        print(appData['bundle_id']);
      }
      setState(() {});
    } else {
      print('Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: appData['bundle_id'] == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : GgMap(),
      ),
    );
  }
}

Color hexToColor(String code) {
  return Color(
      int.parse(code.substring(0, code.length), radix: 16) + 0xFF000000);
}
