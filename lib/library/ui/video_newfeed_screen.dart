import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinkvillademo/Model/VideoListModel.dart';
import 'package:pinkvillademo/library/ui/video_item.dart';
import 'package:pinkvillademo/main.dart';

import '../api/api.dart';
import '../config/screen_config.dart';
import '../config/video_item_config.dart';

class VideoNewFeedScreen<V extends VideoListModel> extends StatefulWidget {
  /// Is case you want to keep the screen
  ///
  final bool keepPage;

  ///
  /// Screen config
  final ScreenConfig screenConfig;

  ///
  /// Video Item config
  final VideoItemConfig config;

  final VideoNewFeedApi<V> api;

  /// Video ended callback
  ///
  final void Function()? videoEnded;

  /// Video Info Customizable
  ///
  final Widget Function(BuildContext context, V v)? customVideoInfoWidget;

  const VideoNewFeedScreen({
    this.keepPage = false,
    this.screenConfig = const ScreenConfig(
      backgroundColor: Colors.black,
      loadingWidget: CircularProgressIndicator(),
    ),

    /// video config
    this.config = const VideoItemConfig(
        loop: true,
        itemLoadingWidget: CircularProgressIndicator(),
        autoPlayNextVideo: true),
    this.customVideoInfoWidget,
    this.videoEnded,
    required this.api,
  });

  @override
  State<StatefulWidget> createState() => _VideoNewFeedScreenState<V>();
}

class _VideoNewFeedScreenState<V extends VideoListModel>
    extends State<VideoNewFeedScreen<V>> {
  /// PageController
  ///
  late PageController _pageController;

  /// Current page is on screen
  ///
  int _currentPage = 0;

  /// Page is on turning or off, use to check how much percent the next video will render and play
  ///
  bool _isOnPageTurning = false;

  final _listVideoStream = StreamController<List<V>>();

  /// Temp to update list video data
  ///
  List<V> temps = [];

  void setList(List<V> items) {
    if (!_listVideoStream.isClosed) {
      _listVideoStream.sink.add(items);
    }
  }

  void _notifyDataChanged() => setList(temps);

  /// Check to play next video when user scroll
  /// If the next video appear about 30% (0.7) the next video will play
  ///
  void _scrollListener() {
    if (_isOnPageTurning &&
        _pageController.page == _pageController.page!.roundToDouble()) {
      setState(() {
        _currentPage = _pageController.page!.toInt();
        _isOnPageTurning = false;
      });
    } else if (!_isOnPageTurning &&
        _currentPage.toDouble() != _pageController.page) {
      if ((_currentPage.toDouble() - _pageController.page!).abs() > 0.7) {
        setState(() {
          _isOnPageTurning = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(keepPage: widget.keepPage);
    _pageController.addListener(_scrollListener);
    _getListVideo();
  }

  void _getListVideo() {
    widget.api.getListVideo().then((value) {
      temps.addAll(value);
      _notifyDataChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.screenConfig.backgroundColor,
      body: _renderVideoPageView(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _listVideoStream.close();
    super.dispose();
  }

  /// Page View
  ///
  ///
  bool loadMore = false;

  Widget _renderVideoPageView() {
    return StreamBuilder<List<VideoListModel>>(
        stream: _listVideoStream.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: widget.screenConfig.emptyWidget ??
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [Text("No result.")],
                    ));
          }

          return PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            allowImplicitScrolling: true,
            pageSnapping: true,
            itemCount: snapshot.data!.length,
            onPageChanged: (page) {},
            itemBuilder: (context, index) {
              if (index == ((snapshot.data?.length ?? 0) - 5)) {
                if (!loadMore) {
                  loadMore = true;
                  widget.api.loadMore(snapshot.data!).then((value) {
                    temps.addAll(value);
                    _notifyDataChanged();
                    loadMore = false;
                  });
                }
              }
              return GestureDetector(
                onTap: () {
                  if (_isOnPageTurning) {
                    _isOnPageTurning = false;
                  } else {
                    _isOnPageTurning = true;
                  }
                  setState(() {});
                },
                child: VideoItemWidget(
                  videoInfo: snapshot.data![index],
                  pageIndex: index,
                  currentPageIndex: _currentPage,
                  isPaused: _isOnPageTurning,
                  config: widget.config,
                  videoEnded: widget.videoEnded,
                  customVideoInfoWidget: widget.customVideoInfoWidget != null
                      ? widget.customVideoInfoWidget!(context, temps[index])
                      : null,
                ),
              );
            },
          );
        });
  }
}
