enum AVPEventType {
  ///准备完成事件0
  AVPEventPrepareDone,

  ///自动启播事件1
  AVPEventAutoPlayStart,

  ///首帧显示事件2
  AVPEventFirstRenderedStart,

  ///播放完成事件3
  AVPEventCompletion,

  ///缓冲开始事件4
  AVPEventLoadingStart,

  ///缓冲完成事件5
  AVPEventLoadingEnd,

  ///跳转完成事件6
  AVPEventSeekEnd,

  ///循环播放开始事件7
  AVPEventLoopingStart,

  ///轨道切换成功8
  AVPEventTrackChangeSuccess,

  ///轨道切换失败9
  AVPEventTrackChangeFail,

  ///Player Created 10
  AVPEventCreated,

  /// 软解失败11
  AVPEventRawFail,
}
enum AVPStatus {
  ///空转，闲时，静态
  AVPStatusIdle,

  /// 初始化完成
  AVPStatusInitialized,

  /// 准备完成
  AVPStatusPrepared,

  /// 正在播放
  AVPStatusStarted,

  /// 播放暂停
  AVPStatusPaused,

  /// 播放停止
  AVPStatusStopped,

  /// 播放完成
  AVPStatusCompletion,

  /// 播放错误
  AVPStatusError
}

enum AVPScreenStatus { FULLSCREEN, NORMAL }

enum AVPScalingMode {
  SCALE_TO_FILL,
  SCALE_ASPECT_FIT,
  SCALE_ASPECT_FILL,
}

/// 缓冲进度
class LoadProcess {
  final int percent;
  final double kbps;

  LoadProcess(this.percent, this.kbps);
}

/// 当前播放进度更新
class PlayerPosition {
  int position;

  PlayerPosition(this.position);
}

class BufferPosition {
  int position;

  BufferPosition(this.position);
}

/// 错误信息
class AVPError {
  int errorCode;
  String msg;

  AVPError({this.errorCode, this.msg});
}
