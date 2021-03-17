import 'dart:async';
import 'dart:convert' as convert;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:screen/screen.dart';

import '../aliplayer.dart';
import 'ali_player_interface.dart';
import 'ali_player_value.dart';
import 'event/event.dart';
import 'event/event_bus.dart';
import 'inner_view.dart';

final MethodChannel _channel = const MethodChannel('aliplayer');

class AliPlayerController extends ValueNotifier<AliPlayerValue> {
  AliPlayerController(
      {this.dataSource, this.canFullScreen = true, this.actions})
      : super(AliPlayerValue(duration: null));

  int _textureId;

  /// 创建EventBus
  EventBus eventBus = EventBus();

  final DataSource dataSource;
  final bool canFullScreen;
  final List<Widget> actions;

  bool _isDisposed = false;
  Completer<void> _creatingCompleter;
  StreamSubscription<dynamic> _eventSubscription;
  _VideoAppLifeCycleObserver _lifeCycleObserver;

  AVPStatus currentStatus;

  int width;
  int height;

  bool fullScreen = false;

  bool isLive = false;

  /// 视频总时长
  Duration duration;
  Duration position;
  List tracks = [];

  bool get initialized => duration != null;

  bool get isPlaying => currentStatus == AVPStatus.AVPStatusStarted;

  Stream<AVPEventType> get onPlayEvent => eventBus.on<AVPEventType>();

  Stream<AVPStatus> get onStatusEvent => eventBus.on<AVPStatus>().transform(
          StreamTransformer.fromHandlers(handleData: (AVPStatus value, sink) {
        switch (value) {
          case AVPStatus.AVPStatusInitialized:
          case AVPStatus.AVPStatusPrepared:
          case AVPStatus.AVPStatusStarted:
            screenKeepOn(true);
            break;
          case AVPStatus.AVPStatusIdle:
          case AVPStatus.AVPStatusPaused:
          case AVPStatus.AVPStatusStopped:
          case AVPStatus.AVPStatusCompletion:
          case AVPStatus.AVPStatusError:
            screenKeepOn(false);
            break;
        }
        sink.add(value);
      }));

  Stream<LoadProcess> get onLoadProcess => eventBus.on<LoadProcess>();

  Stream<int> get onPositionUpdate => eventBus
          .on<PlayerPosition>()
          .transform(StreamTransformer.fromHandlers(handleData: (value, sink) {
        sink.add(value.position);
        position = Duration(milliseconds: value.position);
      }));

  Stream<int> get onBufferPositionUpdate => eventBus
          .on<BufferPosition>()
          .transform(StreamTransformer.fromHandlers(handleData: (value, sink) {
        sink.add(value.position);
      }));

  Stream<AVPError> get onError => eventBus.on<AVPError>();

  Stream<AVPScreenStatus> get onFullScreenChange =>
      eventBus.on<AVPScreenStatus>();

  StreamSubscription<DeviceOrientation> onDeviceOrientation;

  int get textureId => _textureId;

  int qualityIndex = 0;

  // static DeviceOrientation _currentOrientation;

  Future<void> initialize() async {
    _lifeCycleObserver = _VideoAppLifeCycleObserver(this);
    _lifeCycleObserver.initialize();
    _creatingCompleter = Completer<void>();

    String type = dataSource.runtimeType.toString();
    _textureId = await _channel.invokeMethod('player_create',
        {'type': type, 'source': convert.json.encode(dataSource)});

    _creatingCompleter.complete(null);
    final Completer<void> initializingCompleter = Completer<void>();

    void eventListener(dynamic event) {
      if (_isDisposed) {
        return;
      }

      final Map<dynamic, dynamic> map = event;
      switch (map['event']) {
        case 'error':
          eventBus.fire(
              AVPError(errorCode: event["errorCode"], msg: event["errorMsg"]));
          break;
        // 准备完成
        case 'prepared':
          width = map['width'];
          height = map['height'];
          //获取清晰度
          getTrack().then((value) => {tracks = value});
          duration = new Duration(milliseconds: event['duration']);
          eventBus.fire(AVPEventType.AVPEventPrepareDone);
          value = value.copyWith(duration: duration);
          break;
        case 'playEvent':
          eventBus.fire(AVPEventType.values[map['value']]);
          break;
        case 'stateChanged':
          print("Flutter stateChanged${map['value']}");
          currentStatus = AVPStatus.values[map['value']];
          eventBus.fire(AVPStatus.values[map['value']]);
          break;
        // 当前进度
        case 'currentPosition':
          eventBus.fire(PlayerPosition(event['value']));
          break;
        // 预加载进度
        case 'bufferedPosition':
          eventBus.fire(BufferPosition(event['value']));
          break;
        // 缓冲进度
        case 'loadingProgress':
          eventBus.fire(LoadProcess(event['percent'], event['netSpeed']));
          break;
        case 'videoSizeChanged':
          height = map['height'];
          width = map['width'];
          break;
      }
    }

    void errorListener(Object obj) {
      final PlatformException e = obj;
      value = AliPlayerValue.erroneous(e.message);
      if (!initializingCompleter.isCompleted) {
        initializingCompleter.completeError(obj);
      }
    }

    _eventSubscription = EventChannel('aliplayer/videoEvents$textureId')
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);

    // onDeviceOrientation = OrientationPlugin.onOrientationChange.listen((event) {
    //   _currentOrientation = event;
    // });

    prepare();
    return initializingCompleter.future;
  }

  Future<void> prepare() async {
    await _channel.invokeMethod('player_prepare', {"textureId": textureId});
  }

  @override
  Future<void> dispose() async {
    if (_creatingCompleter != null) {
      await _creatingCompleter.future;
      if (!_isDisposed) {
        _isDisposed = true;
        await _eventSubscription?.cancel();
        await onDeviceOrientation?.cancel();
        await _channel.invokeMethod('player_dispose', {"textureId": textureId});
      }
      _lifeCycleObserver.dispose();
    }
    _isDisposed = true;
    super.dispose();
  }

  Future<void> play() async {
    await _applyPlayPause();
  }

  Future<void> setLoop(bool isLoop) async {
    value = value.copyWith(isLoop: isLoop);
    await _applyLooping();
  }

  Future<void> pause() async {
    await _applyPlayPause();
  }

  Future<void> setDataSource(DataSource dataSource) async {
    if (_isDisposed) {
      return;
    }
    String type = dataSource.runtimeType.toString();
    await _channel.invokeMethod("player_set_source", {
      "textureId": textureId,
      'type': type,
      'source': convert.json.encode(dataSource)
    });
  }

  void setLive(bool isLive) {
    this.isLive = isLive;
    notifyListeners();
  }

  Future<void> _applyLooping() async {
    if (!initialized || _isDisposed) {
      return;
    }
    await _channel.invokeMethod(
        "player_set_loop", {"textureId": textureId, "isLoop": value.isLoop});
  }

  Future<void> _applyPlayPause() async {
    if (!initialized || _isDisposed) {
      return;
    }
    if (!isPlaying) {
      await _channel.invokeMethod("player_start", {"textureId": textureId});
    } else {
      await _channel.invokeMethod("player_pause", {"textureId": textureId});
    }
  }

  Future<void> seekTo(Duration position) async {
    if (_isDisposed) {
      return;
    }
    if (position > duration) {
      position = duration;
    } else if (position < const Duration()) {
      position = const Duration();
    }
    await _channel.invokeMethod("player_seek_to",
        {"textureId": textureId, "position": position.inMilliseconds});
  }

  Future<List> getTrack() {
    if (_isDisposed) {
      return Future.value([]);
    }
    return _channel?.invokeMethod("player_get_track", {"textureId": textureId});
  }

  Future<void> setTrack(int index) {
    if (_isDisposed) {
      return null;
    }
    return _channel?.invokeMethod(
        "player_set_track", {"textureId": textureId, "index": index});
  }

  Future<void> setSpeed(double speed) {
    if (_isDisposed) {
      return null;
    }
    return _channel?.invokeMethod(
        "player_set_speed", {"textureId": textureId, "speed": speed});
  }

  void enterFullScreen(context) {
    fullScreen = true;
    _pushFullScreenWidget(context);
    eventBus.fire(AVPScreenStatus.FULLSCREEN);
  }

  void exitFullScreen(context) async {
    // if (Platform.isIOS) {
    //   if (MediaQuery.of(context).orientation == Orientation.portrait) {
    //     await setOrientationLandscape();
    //   } else if (MediaQuery.of(context).orientation == Orientation.landscape) {
    //     await setOrientationPortrait();
    //   }
    // } else {
    //   print('退出全屏');
    //   Navigator.of(context).pop();
    // }
    Navigator.of(context).pop();
    fullScreen = false;
    eventBus.fire(AVPScreenStatus.NORMAL);
  }

  Future<dynamic> _pushFullScreenWidget(BuildContext context) async {
    final TransitionRoute<Null> route = PageRouteBuilder<Null>(
      settings: RouteSettings(),
      pageBuilder: _fullScreenRoutePageBuilder,
    );

    await SystemChrome.setEnabledSystemUIOverlays([]);
    await setOrientationLandscape();
    await Navigator.of(context).push(route);
    await setOrientationPortrait();
    await SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

  static Future<bool> setOrientationPortrait() async {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Future.value(true);
  }

  static Future<bool> setOrientationLandscape() async {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    // if (_currentOrientation == DeviceOrientation.landscapeRight) {
    //   SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
    // } else if (_currentOrientation == DeviceOrientation.landscapeLeft) {
    //   SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    // } else {
    //   SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
    // }
    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    return Future.value(true);
  }

  Widget _fullScreenRoutePageBuilder(BuildContext context,
      Animation<double> animation, Animation<double> secondaryAnimation) {
    return defaultRoutePageBuilder(context, animation, this);
  }

  void screenKeepOn(bool on) async {
    bool isKeepOn = await Screen.isKeptOn;
    if (!on && isKeepOn) {
      Screen.keepOn(false);
    } else if (on && !isKeepOn) {
      Screen.keepOn(true);
    }
  }
}

class _VideoAppLifeCycleObserver extends Object with WidgetsBindingObserver {
  _VideoAppLifeCycleObserver(this._controller);

  bool _wasPlayingBeforePause = false;
  final AliPlayerController _controller;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _wasPlayingBeforePause = _controller.value.isPlaying;
        _controller.pause();
        break;
      case AppLifecycleState.resumed:
        if (_wasPlayingBeforePause) {
          _controller.play();
        }
        break;
      default:
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
