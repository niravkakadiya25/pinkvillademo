import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as https;
import 'package:pinkvillademo/utils/const.dart';
import 'package:pinkvillademo/utils/response.dart';

class VideoProviders {
  https.Client httpClient = https.Client();

  Future<https.Response> getVideos(page) async {
    var url = '$baseUrl/page/$page';
    var responseJson;
    print(Uri.parse(url));

    final response = await httpClient.get(Uri.parse(url)).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException('Something went wrong');
      },
    );
    responseJson = responses(response);

    return responseJson;
  }
}
