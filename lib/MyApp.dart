import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dictionary/newclass.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String _url = "https://owlbot.info/api/v4/dictionary/";
  String _token = "30263faa5ef0fdd31dd87f6c3b150dd671605553";
  TextEditingController _controller = TextEditingController();
  StreamController _streamController;
  Stream _stream;
  bool _status = true;
  var _connectionStatus = "Enter the search word";
  var _connectivity;
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectivity = Connectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        if (result == ConnectivityResult.wifi) {
          _connectionStatus = "Enter the search word";
        } else if (result == ConnectivityResult.mobile) {
          _connectionStatus = "Enter the search word";
        } else if (result == ConnectivityResult.none) {
          _connectionStatus = result.toString();
        }
      });
    });

    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MyApp();
      }));
    }
  }

  Timer _timer;
  _search() async {
    if (_controller.text == null || _controller.text.length == 0) {
      _streamController.add(null);
      return;
    }
    _streamController.add("waiting");

    Response response = await get(_url + _controller.text.trim(),
        headers: {"Authorization": "Token " + _token});
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      _streamController.add(jsonResponse);
    } else if (response.statusCode == 404) {
      setState(() {
        _status = false;
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
    _streamController.close();
    WidgetsBinding.instance.removeObserver(this);
  }

  showExit() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Confirm",
              style: TextStyle(color: Colors.pink),
            ),
            content: Text("Do you want to Exit"),
            actions: <Widget>[
              FlatButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Yes"),
                onPressed: () {
                  SystemNavigator.pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return showExit();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          title: Text("Meaning of Word"),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(78.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 12.0, bottom: 12.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.0)),
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 28.0),
                          hintText: "Enter the word",
                          border: InputBorder.none),
                      onChanged: (val) {
                        if (_timer?.isActive ?? false) _timer.cancel();
                        _timer = Timer(const Duration(seconds: 1), () {
                          _status = true;
                          _search();
                        });
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    size: 24,
                    color: Colors.white,
                  ),
                  onPressed: () => _search(),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          margin: EdgeInsets.all(8.0),
          child: StreamBuilder(
            stream: _stream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(
                  child: Center(
                    child: Text(_connectionStatus),
                  ),
                );
              }
              if (snapshot.data == "waiting") {
                return Center(
                  child: _status == false
                      ? Center(child: Text("Not Found"))
                      : CircularProgressIndicator(),
                );
              }
              var val = _controller.text.toString();
              return ListView.builder(
                itemCount: snapshot.data["definitions"].length == null
                    ? 0
                    : snapshot.data["definitions"].length,
                itemBuilder: (BuildContext context, dynamic index) {
                  return ListBody(
                    children: <Widget>[
                      SizedBox(
                        height: 2,
                      ),
                      Card(
                        elevation: 10,
                        color: Colors.pinkAccent,
                        child: Column(
                          children: <Widget>[
                            Container(
                              color: Colors.pinkAccent[100],
                              padding: EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: snapshot.data["definitions"][index]
                                            ["image_url"] ==
                                        null
                                    ? null
                                    : Hero(
                                        tag: "$val",
                                        child: Container(
                                            child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return newclass(
                                                  snapshot.data["definitions"]
                                                      [index]["image_url"],
                                                  _controller.text);
                                            }));
                                          },
                                          child: CircleAvatar(
                                            backgroundColor: Colors.pinkAccent,
                                            backgroundImage: NetworkImage(
                                                snapshot.data["definitions"]
                                                    [index]["image_url"]),
                                            radius: 30,
                                          ),
                                        )),
                                      ),
                                title: snapshot.data["definitions"][index]
                                            ["type"] ==
                                        null
                                    ? null
                                    : Text(
                                        _controller.text.trim().toString() +
                                            "{" +
                                            snapshot.data["definitions"][index]
                                                ["type"] +
                                            "}",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  color: Colors.pinkAccent,
                                  child: snapshot.data["definitions"][index]
                                              ["definition"] ==
                                          null
                                      ? null
                                      : Text(
                                          "${snapshot.data["definitions"][index]["definition"]}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
