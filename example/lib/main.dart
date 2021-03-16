// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:aliplayer/aliplayer.dart';

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: _App(),
    ),
  );
}

class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: const ValueKey<String>('home_page'),
        body: TabBarView(
          children: <Widget>[
            _BumbleBeeRemoteVideo(),
            _ButterFlyAssetVideo(),
            _ButterFlyAssetVideoInList(),
          ],
        ),
      ),
    );
  }
}

class _ButterFlyAssetVideoInList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _ExampleCard(title: "Item a"),
        _ExampleCard(title: "Item b"),
        _ExampleCard(title: "Item c"),
        _ExampleCard(title: "Item d"),
        _ExampleCard(title: "Item e"),
        _ExampleCard(title: "Item f"),
        _ExampleCard(title: "Item g"),
        Card(
            child: Column(children: <Widget>[
          Column(
            children: <Widget>[
              const ListTile(
                leading: Icon(Icons.cake),
                title: Text("Video video"),
              ),
              Stack(
                  alignment: FractionalOffset.bottomRight +
                      const FractionalOffset(-0.1, -0.1),
                  children: <Widget>[
                    _ButterFlyAssetVideo(),
                    Image.asset('assets/flutter-mark-square-64.png'),
                  ]),
            ],
          ),
        ])),
        _ExampleCard(title: "Item h"),
        _ExampleCard(title: "Item i"),
        _ExampleCard(title: "Item j"),
        _ExampleCard(title: "Item k"),
        _ExampleCard(title: "Item l"),
      ],
    );
  }
}

/// A filler card to show the video in a list of scrolling contents.
class _ExampleCard extends StatelessWidget {
  const _ExampleCard({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.airline_seat_flat_angled),
            title: Text(title),
          ),
          ButtonBar(
            children: <Widget>[
              FlatButton(
                child: const Text('BUY TICKETS'),
                onPressed: () {
                  /* ... */
                },
              ),
              FlatButton(
                child: const Text('SELL TICKETS'),
                onPressed: () {
                  /* ... */
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ButterFlyAssetVideo extends StatefulWidget {
  @override
  _ButterFlyAssetVideoState createState() => _ButterFlyAssetVideoState();
}

class _ButterFlyAssetVideoState extends State<_ButterFlyAssetVideo> {
  AliPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AliPlayerController();

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLoop(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 20.0),
          ),
          const Text('With assets mp4'),
          Container(
            padding: const EdgeInsets.all(20),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  AliPlayer(_controller),
                  _PlayPauseOverlay(controller: _controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BumbleBeeRemoteVideo extends StatefulWidget {
  @override
  _BumbleBeeRemoteVideoState createState() => _BumbleBeeRemoteVideoState();
}

class _BumbleBeeRemoteVideoState extends State<_BumbleBeeRemoteVideo> {
  AliPlayerController _controller;
  bool _isPlay = false;

  @override
  void initState() {
    super.initState();
    UrlSource urlSource = UrlSource();
    urlSource.uri = 'https://alivc-demo-cms.alicdn.com/video/videoAD.mp4';
    urlSource.title = '测试';
    _controller = AliPlayerController(dataSource: urlSource, actions: [
      IconButton(icon: Icon(Icons.shop), color: Colors.white, onPressed: () {})
    ]);

    _controller.addListener(() {
      print(_controller.position);
    });
    _controller.setLoop(true);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverPersistentHeader(
            pinned: _isPlay,
            delegate: _SliverDelegate(
              child: Stack(
                children: [
                  AliPlayer(
                    _controller,
                  ),
                  // _PlayPauseOverlay(controller: _controller),
                ],
              ),
              maxHeight: MediaQuery.of(context).size.width / 16 * 9,
              minHeight: MediaQuery.of(context).size.width / 16 * 9,
            ),
          )
        ];
      },
      body: ListView.builder(
        itemBuilder: (context, index) {
          if (index == 0) {
            return FlatButton(
                onPressed: () {
                  // VidSts vidSts = VidSts();
                  // vidSts.accessKeyId = "accessKeyId";
                  // vidSts.accessKeySecret = "accessKeySecret";
                  // vidSts.region = "region";
                  // vidSts.vid = "vid";
                  //
                  // vidSts.securityToken = "securityToken";
                  // VidPlayerConfigGen configGen = VidPlayerConfigGen();
                  // configGen.configMap["PreviewTime"] = 10;
                  // vidSts.playConfig = configGen;

                  // print(jsonEncode(vidSts.toJson()));
                  _controller.setDataSource(UrlSource()
                    ..uri =
                        "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4");
                },
                child: Text("下一个"));
          }
          return GestureDetector(
            child: Text("TESTSTTSTTSTTSTSTTS$index"),
            onTap: () {
              setState(() {
                _isPlay = !_isPlay;
              });
              print(_isPlay);
            },
          );
        },
        itemCount: 1000,
      ),
    );
    // return SingleChildScrollView(
    //   child: Column(
    //     children: <Widget>[
    //       Container(padding: const EdgeInsets.only(top: 20.0)),
    //       const Text('With remote mp4'),
    //       Container(
    //         padding: const EdgeInsets.all(20),
    //         child: AspectRatio(
    //           aspectRatio: _controller.value.aspectRatio,
    //           child: Stack(
    //             alignment: Alignment.bottomCenter,
    //             children: <Widget>[
    //               AliPlayer(_controller),
    //               //ClosedCaption(text: _controller.value.caption.text),
    //               _PlayPauseOverlay(controller: _controller),
    //               VideoProgressIndicator(_controller, allowScrubbing: true),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final AliPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}

class _PlayerVideoAndPopPage extends StatefulWidget {
  @override
  _PlayerVideoAndPopPageState createState() => _PlayerVideoAndPopPageState();
}

class _PlayerVideoAndPopPageState extends State<_PlayerVideoAndPopPage> {
  AliPlayerController _videoPlayerController;
  bool startedPlaying = false;

  @override
  void initState() {
    super.initState();

    UrlSource urlSource = UrlSource();
    urlSource.uri = 'https://alivc-demo-cms.alicdn.com/video/videoAD.mp4';
    urlSource.title = '测试';
    _videoPlayerController = AliPlayerController(dataSource: urlSource);
    _videoPlayerController.addListener(() {
      if (startedPlaying && !_videoPlayerController.value.isPlaying) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<bool> started() async {
    await _videoPlayerController.initialize();
    await _videoPlayerController.play();
    startedPlaying = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      child: Center(
        child: FutureBuilder<bool>(
          future: started(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.data == true) {
              return AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: AliPlayer(_videoPlayerController),
              );
            } else {
              return const Text('waiting for video to load');
            }
          },
        ),
      ),
    );
  }
}

class _SliverDelegate extends SliverPersistentHeaderDelegate {
  _SliverDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight; //最小高度
  final double maxHeight; //最大高度
  final Widget child; //孩子

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override //是否需要重建
  bool shouldRebuild(_SliverDelegate oldDelegate) {
    print(oldDelegate.child);
    print(child);
    return false;
  }
}
