import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pinkvillademo/library/config/screen_config.dart';
import 'package:pinkvillademo/library/config/video_item_config.dart';
import 'package:pinkvillademo/library/ui/built_in/custome_button.dart';
import 'package:pinkvillademo/utils/const.dart';
import 'Model/VideoListModel.dart';
import 'library/api/api.dart';
import 'library/ui/video_newfeed_screen.dart';
import 'providers/video-provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
          )),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

List<VideoListModel>? videos = [];

int page = 0;

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = true;

  @override
  initState() {
    getVideos(page);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container()
        : Scaffold(
            body: VideoNewFeedScreen(
              keepPage: true,
              config: VideoItemConfig(
                  autoPlayNextVideo: true,
                  itemLoadingWidget: Container(),
                  loop: false),
              customVideoInfoWidget: (context, VideoListModel v) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                v.postDateStr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400),
                              ),
                              Container(
                                margin: EdgeInsets.only(bottom: 10),
                                child: _likeMoreWidget(),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            v.title,
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              api: YourApi(),
            ),
          );
  }

  Widget _likeMoreWidget() {
    return Container(
      alignment: Alignment.centerRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          CustomButton(
            isFav: true,
            onClicked: (bool d) {
              return Future.value(!d);
            },
          ),
          const SizedBox(height: 15),
          CustomButton(
            isComment: true,
            onClicked: (bool d) {
              return Future.value(!d);
            },
          ),
          const SizedBox(height: 15),
          CustomButton(
            isShare: true,
            onClicked: (bool d) {
              return Future.value(!d);
            },
          ),
        ],
      ),
    );
  }

  getVideos(page) {
    videos?.clear();
    setState(() {
      isLoading = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        VideoProviders().getVideos(page).then((Response response) async {
          List list = json.decode(response.body);

          if (response.statusCode == 200) {
            for (var value in list) {
              videos?.add(VideoListModel.fromJson(value));
            }

            setState(() {
              isLoading = false;
            });
            if (kDebugMode) {
              print(videos.toString());
            }
          } else {
            setState(() {
              isLoading = false;
            });

            buildErrorDialog(context, '', 'Something went wrong');
          }
        }).catchError((onError) {
          setState(() {
            isLoading = false;
          });

          if (kDebugMode) {
            print(onError.toString());
          }
          buildErrorDialog(context, 'Error', 'Something went wrong');
        });
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', 'Internet Required');
      }
    });
  }
}

class YourApi implements VideoNewFeedApi {
  @override
  Future<List<VideoListModel>> getListVideo() {
    return Future.value(videos);
  }

  List<VideoListModel> loadMoreVideos = [];

  bool isLoadMoreRunning = false;

  @override
  Future<List<VideoListModel>> loadMore(List<VideoListModel> currentList) {
    print('page;' + page.toString());
    if (isLoadMoreRunning == false && page < 3) {
      print('loadMores');
      checkInternet().then((internet) async {
        isLoadMoreRunning = true;
        page = page + 1;
        VideoProviders().getVideos(page).then((Response response) async {
          List list = json.decode(response.body);
          if (response.statusCode == 200) {
            loadMoreVideos.clear();
            for (var value in list) {
              loadMoreVideos.add(VideoListModel.fromJson(value));
            }
            isLoadMoreRunning = false;
            if (kDebugMode) {
              print(loadMoreVideos.toString());
            }
          } else {
            isLoadMoreRunning = false;
          }
        }).catchError((onError) {
          isLoadMoreRunning = false;

          if (kDebugMode) {
            print(onError.toString());
          }
        });
      });
    }
    return Future.value(loadMoreVideos);
  }
}
