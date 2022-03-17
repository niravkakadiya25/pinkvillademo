import 'package:pinkvillademo/Model/VideoListModel.dart';


abstract class VideoNewFeedApi<V extends VideoListModel> {
  Future<List<V>> getListVideo();

  Future<List<V>> loadMore(List<VideoListModel> currentList);
}
