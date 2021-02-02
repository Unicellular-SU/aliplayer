import 'dart:io';

import 'package:flutter/material.dart';

import 'ali_player_controller.dart';
import 'ali_player_ui_panel.dart';

class AliPlayer extends StatefulWidget {
  AliPlayer(this.controller);

  final AliPlayerController controller;

  @override
  _AliPlayerState createState() => _AliPlayerState();
}

class _AliPlayerState extends State<AliPlayer> {
  _AliPlayerState() {
    _listener = () {
      final int newTextureId = widget.controller.textureId;
      if (newTextureId != _textureId) {
        setState(() {
          _textureId = newTextureId;
        });
      }
    };
  }

  VoidCallback _listener;
  int _textureId;

  @override
  void initState() {
    super.initState();
    _textureId = widget.controller.textureId;
    widget.controller.addListener(_listener);
  }

  @override
  void didUpdateWidget(AliPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller.removeListener(_listener);
    _textureId = widget.controller.textureId;
    widget.controller.addListener(_listener);
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(_listener);
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = widget.controller.fullScreen
        ? MediaQuery.of(context).size.height /
            widget.controller.height *
            widget.controller.width
        : MediaQuery.of(context).size.width;

    if (Platform.isIOS && widget.controller.fullScreen) {
      width = MediaQuery.of(context).size.width;
    }
    double height;
    if (widget.controller.fullScreen) {
      height = MediaQuery.of(context).size.height;
    } else {
      if (widget.controller.height == null) {
        height = width / 16 * 9;
      } else {
        height = width / widget.controller.width * widget.controller.height;
      }
    }
    double aspectRatio = widget.controller.height != null
        ? widget.controller.width / widget.controller.height
        : 16 / 9;
    return _textureId == null
        ? SizedBox(
            width: width,
            height: height,
            child: Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )),
          )
        : Container(
            width: width,
            height: height,
            color: Colors.black,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                    aspectRatio: aspectRatio,
                    child: Texture(textureId: _textureId)),
                UIPanel(
                  player: widget.controller,
                  viewSize: Size(width, height),
                )
              ],
            ),
          );
  }
}
