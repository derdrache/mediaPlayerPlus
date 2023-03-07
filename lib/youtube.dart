import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
//import 'package:flutter_background/flutter_background.dart';

/*
final androidConfig = FlutterBackgroundAndroidConfig(
  notificationTitle: "flutter_background example app",
  notificationText: "Background notification for keeping the example app running in the background",
  notificationImportance: AndroidNotificationImportance.Default,
  notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'), // Default is ic_launcher from folder mipmap
);

 */


Future<void> downloadVideo(String videoLink, selectedVideoQuality, {onlySound = false}) async {
  //await FlutterBackground.initialize(androidConfig: androidConfig);
  //await FlutterBackground.enableBackgroundExecution();
  var mediaBox = Hive.box('mediaBox');

  final yt = YoutubeExplode();
  var video = await yt.videos.get(videoLink);
  var videoId = video.id;
  var videoTitle = video.title;
  var videoDuration = video.duration;
  var videoImage = video.thumbnails.lowResUrl;
  videoTitle = videoTitle.replaceAll("/", " ");
  videoTitle = videoTitle.replaceAll("|", " ");
  yt.close();

  Directory directory  = await getApplicationDocumentsDirectory();
  var path = directory.path;
  var outputPath = "$path/youtube/$videoTitle.mp4";
  final yt2 = YoutubeExplode();
  final manifest = await yt2.videos.streamsClient.getManifest(videoId);
  var soundonly = manifest.audioOnly.first;
  var videoQuality = {
    "low": manifest.video.first,
    "med": manifest.video[1],
    "high": manifest.video[2]
  };
  yt2.close();
  var downloadUrl = onlySound ? soundonly.url : videoQuality[selectedVideoQuality]!.url;
  final output = File(outputPath);

  final taskId = await FlutterDownloader.enqueue(
    url: downloadUrl.toString(),
    headers: {}, // optional: header send with url (auth token etc)
    savedDir: output.path,
    showNotification: true, // show download progress in status bar (for Android)
    openFileFromNotification: true, // click on notification to open downloaded file (for Android)
  );

/*
  final httpClient = HttpClient();
  final request = await httpClient.getUrl(downloadUrl);
  final response = await request.close();

  mediaBox.put(videoTitle,{
    "status": "start",
    "duration": videoDuration?.inMilliseconds,
    "image": videoImage
  });



  await response.pipe(output.openWrite()).whenComplete(() {
    httpClient.close();
    var videoData = mediaBox.get(videoTitle);
    videoData["status"] = "done";
    print('Video Downloaded Successfully');
  });

 */

}


