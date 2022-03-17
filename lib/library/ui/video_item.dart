import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pinkvillademo/Model/VideoListModel.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../config/video_item_config.dart';

class VideoItemWidget<V extends VideoListModel> extends StatefulWidget {
  final int pageIndex;
  final int currentPageIndex;
  final bool isPaused;

  /// Video ended callback
  ///
  final void Function()? videoEnded;

  final VideoItemConfig config;

  /// Video Information: like count, like, more, name song, ....
  ///
  final V videoInfo;

//  /// Video network url
//  ///
//  final String url;

  /// Video Info Customizable
  ///
  final Widget? customVideoInfoWidget;

  const VideoItemWidget(
      {

      /// video information
      required this.videoInfo,

      /// video config
      this.config = const VideoItemConfig(
          loop: true,
          itemLoadingWidget: CircularProgressIndicator(),
          autoPlayNextVideo: true),
      required this.pageIndex,
      required this.currentPageIndex,
      required this.isPaused,
      this.customVideoInfoWidget,
      this.videoEnded});

  @override
  State<StatefulWidget> createState() => _VideoItemWidgetState<V>();
}

class _VideoItemWidgetState<V extends VideoListModel>
    extends State<VideoItemWidget<V>> {
  late VideoPlayerController? _videoPlayerController;
  bool initialized = false;
  bool actualDisposed = false;
  bool isEnded = false;

  ///
  ///
  @override
  void initState() {
    super.initState();
    _initVideoController();
  }

  ///
  ///
  @override
  Widget build(BuildContext context) {
    bool isLandscape = false;
    _pauseAndPlayVideo();
    if (initialized && _videoPlayerController!.value.isInitialized) {
      isLandscape = _videoPlayerController!.value.size.width >
          _videoPlayerController!.value.size.height;
    }

    return Center(
      child: Stack(
        children: [
          initialized
              ? isLandscape
                  ? _renderLandscapeVideo()
                  : _renderPortraitVideo()
              : Container(),
          _renderVideoInfo(),
        ],
      ),
    );
  }

  ///
  ///
  @override
  void dispose() {
    if (initialized && _videoPlayerController != null) {
      _videoPlayerController!.removeListener(_videoListener);
      _videoPlayerController!.dispose();
      _videoPlayerController = null;
    }

    actualDisposed = true;
    super.dispose();
  }

  /// Video initialization
  ///
  void _initVideoController() {
    if (widget.videoInfo == null) return;
    // Init video from network url
    _videoPlayerController =
        VideoPlayerController.network(widget.videoInfo.vimeo!.first.url!);
    _videoPlayerController!.addListener(_videoListener);
    _videoPlayerController!.initialize().then((_) {
      setState(() {
        _videoPlayerController!.setLooping(widget.config.loop);
        initialized = true;
      });
    });
  }

  /// Video controller listener
  ///
  void _videoListener() {
    if (!initialized) return;

    if (_videoPlayerController?.value.position != null &&
        _videoPlayerController?.value.duration != null) {
      /// check if video has ended
      ///
      if (_videoPlayerController!.value.position >=
          _videoPlayerController!.value.duration) {
        if (widget.config.autoPlayNextVideo &&
            widget.videoEnded != null &&
            !isEnded) {
          isEnded = true;
          widget.videoEnded!();
        }
      }
    }
  }

  void _pauseAndPlayVideo() {
    if (initialized && _videoPlayerController != null) {
      if (widget.pageIndex == widget.currentPageIndex &&
          !widget.isPaused &&
          initialized) {
        _videoPlayerController?.play().then((value) {});
      } else {
        _videoPlayerController?.pause().then((value) {});
      }
    }
  }

  Widget _renderLandscapeVideo() {
    if (!initialized) return Container();
    if (_videoPlayerController == null) return Container();
    return Center(
      child: AspectRatio(
        child: VisibilityDetector(
            child: VideoPlayer(_videoPlayerController!),
            onVisibilityChanged: _handleVisibilityDetector,
            key: Key('key_${widget.currentPageIndex}')),
        aspectRatio: _videoPlayerController!.value.aspectRatio,
      ),
    );
  }

  Widget _renderPortraitVideo() {
    if (!initialized) return Container();
    if (_videoPlayerController == null) return Container();

    var tmp = MediaQuery.of(context).size;

    var screenH = max(tmp.height, tmp.width);
    var screenW = min(tmp.height, tmp.width);
    tmp = _videoPlayerController!.value.size;

    var previewH = max(tmp.height, tmp.width);
    var previewW = min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return Center(
      child: OverflowBox(
        child: VisibilityDetector(
            onVisibilityChanged: _handleVisibilityDetector,
            key: Key('key_${widget.currentPageIndex}'),
            child: VideoPlayer(_videoPlayerController!)),
        maxHeight: screenRatio > previewRatio
            ? screenH
            : screenW / previewW * previewH,
        maxWidth: screenRatio > previewRatio
            ? screenH / previewH * previewW
            : screenW,
      ),
    );
  }

  Widget _renderVideoInfo() {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Container(height: h, child: widget.customVideoInfoWidget);
  }

  void _handleVisibilityDetector(VisibilityInfo info) {
    if (info.visibleFraction == 0) {
      if (!actualDisposed &&
          widget.pageIndex == widget.currentPageIndex &&
          !widget.isPaused &&
          initialized) {
        if (_videoPlayerController != null) {
          _videoPlayerController?.pause().then((value) {});
        }
      }
    } else {
      _videoPlayerController?.play().then((value) {});
    }
  }
}
