import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';


Future<void> downloadVideo(String videoLink) async {
  final yt = YoutubeExplode();
  var video = await yt.videos.get(videoLink);
  var videoId = video.id;
  var videoTitle = video.title;
  videoTitle = videoTitle.replaceAll("/", " ");
  videoTitle = videoTitle.replaceAll("|", " ");
  yt.close();

  Directory directory  = await getApplicationDocumentsDirectory();
  var path = directory.path;
  var outputPath = "$path/youtube/$videoTitle.mp4";
  final yt2 = YoutubeExplode();
  final manifest = await yt2.videos.streamsClient.getManifest(videoId);
  final streamInfo = manifest.videoOnly.first;
  final httpClient = HttpClient();
  final request = await httpClient.getUrl(streamInfo.url);
  final response = await request.close();
  final output = File(outputPath);
  await response.pipe(output.openWrite()).whenComplete(() {
    httpClient.close();
    print('Video Downloaded Successfully');
  });
  yt2.close();
}


