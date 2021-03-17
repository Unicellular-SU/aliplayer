import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:screen/screen.dart';
import 'package:volume_control/volume_control.dart';

import '../aliplayer.dart';
import 'ali_player_slider.dart';
import 'event/event.dart';

class UIPanel extends StatefulWidget {
  final AliPlayerController player;
  final BuildContext buildContext;
  final Size viewSize;
  final Rect texturePos;
  final List sources;

  const UIPanel(
      {@required this.player,
      this.buildContext,
      this.viewSize,
      this.texturePos,
      this.sources});

  @override
  UIPanelPanelState createState() => UIPanelPanelState();
}

class UIPanelPanelState extends State<UIPanel> {
  AliPlayerController get controller => widget.player;
  Duration _duration = Duration();
  Duration _currentPos = Duration();
  Duration _fastPos = Duration();
  int _buffered = 0;

  bool get isLive =>
      controller.isLive ||
      _duration?.inMilliseconds == null ||
      _duration?.inMilliseconds == 0;

  // Duration _bufferPos = Duration();
  bool _playing = false;
  bool _prepared = false;
  bool _showFastbox = false;

  double _seekPos = -1.0;

  StreamSubscription _stateEvent;
  StreamSubscription _positionEvent;
  StreamSubscription _playerEvent;
  StreamSubscription _bufferPositionUpdate;
  StreamSubscription _processListen;
  List<Widget> _actions;
  Timer _hideTimer;
  bool _hideStuff = true;
  bool _speedShow = false;
  bool _qualityShow = false;
  bool _showSound = false;
  double _speed = 1;
  List _tracks = [];
  double _volume = 0;
  double _brightness = 0;
  int _processPercent = 0;
  int _changeState;
  Map quality = {
    "OD": "原画",
    "FD": "流畅",
    "LD": "标清",
    "SD": "高清",
    "HD": "超清",
    "2K": "2K",
    "4K": "4K",
    "video": "默认视频",
    "audio": "默认音频"
  };
  final barHeight = 40.0;
  static const AliSliderColors sliderColors = AliSliderColors(
      cursorColor: Color(0xffffffff),
      playedColor: Color(0xffFF5800),
      baselineColor: Color.fromRGBO(255, 255, 255, 0.5),
      bufferedColor: Color.fromRGBO(255, 255, 255, 0.8));

  @override
  void initState() {
    super.initState();
    VolumeControl.volume.then((value) {
      setState(() {
        _volume = value;
      });
    });
    _currentPos = new Duration(milliseconds: 0);
    _playing = controller.currentStatus == AVPStatus.AVPStatusStarted;
    _duration = controller?.duration ?? Duration();
    _tracks = controller.tracks;
    _actions = controller.actions;
    if (controller.currentStatus != null) {
      _prepared =
          controller.currentStatus.index >= AVPStatus.AVPStatusPrepared.index;
    }

    _processListen = controller.onLoadProcess.listen((event) {
      setState(() {
        _processPercent = event.percent;
      });
    });

    _positionEvent = controller.onPositionUpdate.listen((position) {
      setState(() {
        _currentPos = Duration(milliseconds: position); //position;
      });
    });
    _stateEvent = controller.onStatusEvent.listen((event) {
      setState(() {
        _playing = event == AVPStatus.AVPStatusStarted;
        _prepared =
            controller.currentStatus.index >= AVPStatus.AVPStatusPrepared.index;
      });
    });
    _bufferPositionUpdate = controller.onBufferPositionUpdate.listen((buffer) {
      setState(() {
        _buffered = buffer;
      });
    });
    _playerEvent = controller.onPlayEvent.listen((event) {
      switch (event) {
        case AVPEventType.AVPEventPrepareDone:
          setState(() {
            _duration = controller.duration ?? Duration();
            _tracks = controller.tracks;
          });
          // Future.delayed(Duration(milliseconds: 400), () {
          //   setState(() {
          //     _tracks = player.tracks;
          //   });
          // });
          break;
        case AVPEventType.AVPEventLoadingStart:
          setState(() {
            _prepared = false;
            _processPercent = 0;
          });
          break;
        case AVPEventType.AVPEventLoadingEnd:
          _prepared = true;
          break;
        default:
      }
    });
  }

  void _playOrPause() {
    if (_playing == true) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _positionEvent?.cancel();
    _stateEvent?.cancel();
    _playerEvent?.cancel();
    _hideTimer?.cancel();
    _processListen?.cancel();
    _bufferPositionUpdate?.cancel();
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void _cancelAndRestartTimer() {
    if (_hideStuff == true) {
      _hideTimer?.cancel();
      _startHideTimer();
    }
    setState(() {
      _hideStuff = !_hideStuff;
    });
  }

  AnimatedOpacity _buildBottomBar(BuildContext context) {
    double duration = _duration?.inMilliseconds?.toDouble() ?? 0;
    double currentValue =
        _seekPos > 0 ? _seekPos : _currentPos.inMilliseconds.toDouble();
    currentValue = min(currentValue, duration);
    currentValue = max(currentValue, 0);
    return AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 0.8,
      duration: Duration(milliseconds: 400),
      child: Container(
        height: barHeight +
            (controller.fullScreen
                ? MediaQuery.of(context).padding.bottom + 20
                : 0),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Color(0xFF000000).withOpacity(0.0),
          Color(0xFF000000).withOpacity(0.7),
        ], begin: FractionalOffset(0, 0), end: FractionalOffset(0, 0.9))),
        child: DefaultTextStyle(
          style: TextStyle(color: Colors.white),
          child: Row(
            children: <Widget>[
              IconButton(
                  icon: ImageIcon(
                    !_playing
                        ? AssetImage('images/play.png', package: "aliplayer")
                        : AssetImage('images/pause.png', package: "aliplayer"),
                    color: Colors.white,
                    size: 25,
                  ),
                  onPressed: () {
                    _playing ? controller.pause() : controller.play();
                  }),
              isLive
                  ? Padding(
                      padding: EdgeInsets.only(right: 5.0, left: 5),
                      child: Text(
                        'LIVE',
                        style: TextStyle(
                            fontSize: controller.fullScreen ? 16 : 14,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.only(right: 5.0, left: 5),
                      child: Text(
                        '${_duration2String(_currentPos)}',
                        style: TextStyle(
                            fontSize: controller.fullScreen ? 14 : 12.0),
                      ),
                    ),

              isLive
                  ? Expanded(
                      child: Center(),
                    )
                  : Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 0, left: 8),
                        child: AliSlider(
                          colors: sliderColors,
                          value: currentValue,
                          cacheValue: _buffered.toDouble(),
                          min: 0.0,
                          max: duration ?? 0,
                          onChanged: (v) {
                            setState(() {
                              _seekPos = v;
                            });
                          },
                          onChangeEnd: (v) {
                            setState(() {
                              controller
                                  .seekTo(Duration(milliseconds: v.toInt()));
                              _currentPos =
                                  Duration(milliseconds: _seekPos.toInt());
                              _seekPos = -1;
                            });
                          },
                        ),
                      ),
                    ),

              // duration / position
              isLive
                  ? Container(child: const Text(""))
                  : Padding(
                      padding: EdgeInsets.only(right: 5.0, left: 5),
                      child: Text(
                        '${_duration2String(_duration)}',
                        style: TextStyle(
                          fontSize: controller.fullScreen ? 14 : 12.0,
                        ),
                      ),
                    ),
              controller.fullScreen &&
                      _duration?.inMilliseconds != null &&
                      _duration?.inMilliseconds != 0
                  ? FlatButton(
                      textColor: Colors.white,
                      onPressed: () {
                        this._speedShow = true;
                      },
                      child: Container(
                        child: Text(
                          _speed == 1 ? '倍速' : '${_speed}X',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    )
                  : Center(),
              controller.fullScreen &&
                      _duration?.inMilliseconds != null &&
                      _duration?.inMilliseconds != 0
                  ? FlatButton(
                      textColor: Colors.white,
                      onPressed: () {
                        this._qualityShow = true;
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 5, right: 5),
                        child: Text('清晰度'),
                      ),
                    )
                  : Center(),
              if (controller.canFullScreen)
                IconButton(
                  icon: ImageIcon(
                    controller.fullScreen
                        ? AssetImage('images/exitFullscreen.png',
                            package: "aliplayer")
                        : AssetImage('images/fullscreen.png',
                            package: "aliplayer"),
                    size: 40,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  color: Colors.white,
                  onPressed: () {
                    widget.player.fullScreen
                        ? controller.exitFullScreen(context)
                        : controller.enterFullScreen(context);
                  },
                )
              //
            ],
          ),
        ),
      ),
    );
  }

  Widget _speedPanel(List<Widget> data) {
    return Offstage(
      offstage: isLive || !_speedShow,
      child: Stack(children: [
        GestureDetector(
          onTap: () {
            this._speedShow = false;
          },
          child: Container(
            color: Colors.transparent,
          ),
        ),
        AnimatedPositioned(
          top: 0,
          right: _speedShow ? 0 : -200,
          duration: Duration(milliseconds: 300),
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(10),
            color: Colors.black.withOpacity(0.8),
            alignment: Alignment.bottomLeft,
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [...data]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _qualityPanel(List<Widget> data) {
    return Offstage(
      offstage: isLive || !_qualityShow,
      child: Stack(children: [
        GestureDetector(
          onTap: () {
            this._qualityShow = false;
          },
          child: Container(
            color: Colors.transparent,
          ),
        ),
        AnimatedPositioned(
          top: 0,
          right: _qualityShow ? 0 : -200,
          duration: Duration(milliseconds: 300),
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(10),
            color: Colors.black.withOpacity(0.8),
            alignment: Alignment.bottomLeft,
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [...data]),
            ),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
          height: widget.viewSize.height,
          child: Stack(children: [
            GestureDetector(
              onDoubleTap: () {
                this._playOrPause();
              },
              onVerticalDragStart: controller.fullScreen
                  ? (DragStartDetails detail) async {
                      if (detail.localPosition.dx <
                          MediaQuery.of(context).size.width / 2) {
                        _brightness = await Screen.brightness;
                        _changeState = 1;
                      } else {
                        _changeState = 0;
                        _volume = await VolumeControl.volume;
                      }
                    }
                  : null,
              onVerticalDragEnd: (_) {
                setState(() {
                  _showSound = false;
                });
              },
              onVerticalDragUpdate: controller.fullScreen
                  ? (DragUpdateDetails detail) {
                      setState(() {
                        _showSound = true;
                      });
                      if (_changeState == 1) {
                        double brightness =
                            _brightness - (detail.delta.dy / 100);
                        if (brightness < 0.01) {
                          _brightness = 0.01;
                        } else if (brightness > 1) {
                          _brightness = 1.0;
                        } else {
                          _brightness = brightness;
                        }
                        Screen.setBrightness(_brightness);
                      } else {
                        double volume = _volume - (detail.delta.dy / 100);
                        if (volume < 0) {
                          _volume = 0;
                        } else if (volume > 1) {
                          _volume = 1.0;
                        } else {
                          _volume = volume;
                        }
                        VolumeControl.setVolume(_volume);
                      }
                    }
                  : null,
              onHorizontalDragStart: (_) {
                if (isLive) return;
                _fastPos = _currentPos;
                setState(() {
                  _showFastbox = true;
                });
              },
              onHorizontalDragUpdate: (DragUpdateDetails detail) {
                if (isLive) return;
                setState(() {
                  int res =
                      _fastPos.inMilliseconds + detail.delta.dx.toInt() * 1000;
                  if (res <= 0) {
                    _fastPos = Duration(milliseconds: 0);
                  } else if (res < _duration?.inMilliseconds ?? 0) {
                    _fastPos = Duration(milliseconds: res);
                  }
                });
              },
              onHorizontalDragEnd: (_) {
                if (isLive) return;
                controller.seekTo(_fastPos);
                setState(() {
                  _showFastbox = false;
                });
              },
              onTap: _cancelAndRestartTimer,
              child: AbsorbPointer(
                absorbing: _hideStuff,
                child: Column(
                  children: <Widget>[
                    AnimatedOpacity(
                      opacity: _hideStuff ? 0 : 0.8,
                      duration: Duration(milliseconds: 400),
                      child: Container(
                          height: controller.fullScreen ? 50 : barHeight,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                Color(0xFF000000).withOpacity(0.5),
                                Color(0xFF000000).withOpacity(0.0),
                              ],
                                  begin: FractionalOffset(0, 0),
                                  end: FractionalOffset(0, 1))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: IconButton(
                                  alignment: Alignment.topLeft,
                                  icon: ImageIcon(AssetImage('images/back.png',
                                      package: "aliplayer")),
                                  color: Colors.white,
                                  iconSize: 20,
                                  onPressed: () {
                                    if (controller.fullScreen == true) {
                                      controller.exitFullScreen(context);
                                    } else {
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  },
                                ),
                              ),
                              Row(
                                children: _actions ?? [],
                              ),
                            ],
                          )),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _cancelAndRestartTimer();
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Center(
                              child: _prepared
                                  ? Container()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Colors.white)),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            _processPercent.toString() + '%',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        )
                                      ],
                                    )),
                        ),
                      ),
                    ),
                    _buildBottomBar(context),
                  ],
                ),
              ),
            ),
            _fastBox(),
            _soundAndBrignt()
          ])),
      _speedPanel(_speedContainer()),
      _qualityPanel(_qualityContainer())
    ]);
  }

  // 快进快退显示
  _fastBox() {
    int boxWidth = controller.fullScreen ? 160 : 100;
    double boxHeight = controller.fullScreen ? 40 : 30;
    return Positioned(
      top: widget.viewSize.height / 2 - 20,
      left: MediaQuery.of(context).size.width / 2 - boxWidth / 2,
      width: boxWidth.toDouble(),
      height: boxHeight,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _showFastbox ? 1 : 0,
          duration: Duration(milliseconds: 200),
          child: Container(
            width: 120,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.7),
                borderRadius: BorderRadius.all(Radius.circular(4))),
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: DefaultTextStyle(
                style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
                child: Row(children: [
                  Text('${_duration2String(_fastPos)}'),
                  Text(' / '),
                  Text('${_duration2String(_duration)}'),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _soundAndBrignt() {
    return Positioned(
      top: widget.viewSize.height / 2 - 20,
      left: MediaQuery.of(context).size.width / 2 - 80,
      width: 160,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _showSound ? 1 : 0,
          duration: Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.7),
                borderRadius: BorderRadius.all(Radius.circular(4))),
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: Row(children: [
                ImageIcon(
                  AssetImage(
                      _changeState == 1
                          ? 'images/brightness.png'
                          : 'images/sound.png',
                      package: "aliplayer"),
                  color: Color.fromRGBO(255, 255, 255, 0.8),
                  size: 40,
                ),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Stack(children: [
                    Container(
                        height: 4,
                        width: 160,
                        color: Color.fromRGBO(255, 255, 255, 0.8)),
                    Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                            height: 4,
                            width: 160 *
                                (_changeState == 1 ? _brightness : _volume),
                            color: Color(0xffFF5800)))
                  ]),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }

  _qualityContainer() {
    List<Widget> widgets = [];
    for (var i = 0; i < _tracks.length; i++) {
      widgets.add(Expanded(
        flex: 1,
        child: FlatButton(
          onPressed: () {
            controller.setTrack(i);
            setState(() {
              this.controller.qualityIndex = i;
              this._hideStuff = true;
              this._qualityShow = false;
            });
          },
          child: Container(
            alignment: Alignment.center,
            child: Text('${quality[_tracks[i]]}',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: this.controller.qualityIndex == i
                        ? Theme.of(context).accentColor
                        : Colors.white)),
          ),
        ),
      ));
    }
    return widgets;
  }

  List<Widget> _speedContainer() {
    List<double> list = [2, 1.25, 1, 0.75];
    List<Widget> widgets = [];
    list.forEach((speed) {
      widgets.add(Expanded(
        flex: 1,
        child: FlatButton(
          onPressed: () async {
            controller.setSpeed(speed);
            setState(() {
              this._speed = speed;
              this._hideStuff = true;
              this._speedShow = false;
            });
          },
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(5),
            child: Text('${speed}X',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: _speed == speed
                        ? Theme.of(context).accentColor
                        : Colors.white)),
          ),
        ),
      ));
    });
    return widgets;
  }
}

String _duration2String(Duration duration) {
  if (duration == null || duration.inMilliseconds < 0) return "-: negtive";

  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  int inHours = duration.inHours;
  return inHours > 0
      ? "$inHours:$twoDigitMinutes:$twoDigitSeconds"
      : "$twoDigitMinutes:$twoDigitSeconds";
}
