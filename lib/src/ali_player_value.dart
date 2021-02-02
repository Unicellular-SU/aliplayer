import 'package:flutter/cupertino.dart';

class AliPlayerValue {
  AliPlayerValue({
    @required this.duration,
    this.size = Size.zero,
    this.position = const Duration(),
    this.isPlaying = false,
    this.isLoop = false,
    this.isLoading = false,
    this.volume = 1.0,
    this.fullScreen = false,
    this.errorDescription,
  });

  AliPlayerValue.uninitialized() : this(duration: null);

  AliPlayerValue.erroneous(String errorDescription)
      : this(duration: null, errorDescription: errorDescription);

  final Duration duration;

  final Duration position;

  final bool isPlaying;

  final bool isLoop;

  final bool isLoading;

  final double volume;

  final bool fullScreen;

  final String errorDescription;

  final Size size;

  bool get initialized => duration != null;

  bool get hasError => errorDescription != null;

  double get aspectRatio {
    if (size == null || size.width == 0 || size.height == 0) {
      return 1.0;
    }
    final double aspectRatio = size.width / size.height;
    if (aspectRatio <= 0) {
      return 1.0;
    }
    return aspectRatio;
  }

  AliPlayerValue copyWith({
    Duration duration,
    Size size,
    Duration position,
    bool isPlaying,
    bool isLoop,
    bool isLoading,
    double volume,
    bool fullScreen,
    String errorDescription,
  }) {
    return AliPlayerValue(
      duration: duration ?? this.duration,
      size: size ?? this.size,
      position: position ?? this.position,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoop: isLoop ?? this.isLoop,
      isLoading: isLoading ?? this.isLoading,
      volume: volume ?? this.volume,
      fullScreen: fullScreen ?? this.fullScreen,
      errorDescription: errorDescription ?? this.errorDescription,
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'duration: $duration, '
        'size: $size, '
        'position: $position, '
        'isPlaying: $isPlaying, '
        'isLoop: $isLoop, '
        'isLoading: $isLoading'
        'volume: $volume, '
        'fullScreen: $fullScreen, '
        'errorDescription: $errorDescription)';
  }
}
