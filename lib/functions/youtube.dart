import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:al_downloader/al_downloader.dart';

import 'notification.dart';

Future<void> downloadVideo(String videoLink, selectedVideoQuality, {onlySound = false}) async {
  final mediaBox = Hive.box('mediaBox');
  var dirs = await getExternalStorageDirectories();
  dirs = dirs!;
  var speicherPfad = mediaBox.get("speicherPfad") ?? "Interner Speicher";
  var selectedDirectory = speicherPfad == "Interner Speicher" ? dirs[0].path : dirs[1].path;
  String savePath = "$selectedDirectory/youtube/";
  Map youtubeVideoData = await getYoutubeVideoInformation(videoLink);
  var youtubeManifest = youtubeVideoData["manifest"];
  String youtubeTitle = youtubeVideoData["title"];
  String youtubeImage = youtubeVideoData["image"];
  Duration youtubeDuration = youtubeVideoData["duration"];
  final soundonly = youtubeManifest.audioOnly.first;
  Map videoQuality = {
    "low": youtubeManifest.video.first,
    "med": youtubeManifest.video[1],
    "high": youtubeManifest.video[2]
  };
  File("$savePath$youtubeTitle.mp4");
  final downloadUrl = onlySound ? soundonly.url : videoQuality[selectedVideoQuality]!.url;
  int downloadId = mediaBox.get("downloadId")??0+1;

  mediaBox.put(youtubeTitle,{
    "status": "start",
    "url": downloadUrl.toString(),
    "downloadStatus": "0",
    "duration": youtubeDuration.inMilliseconds,
    "image": youtubeImage,
    "id": downloadId
  });

  mediaBox.put("downloadId", downloadId);
  await Permission.storage.request();

  downloadManager(downloadUrl, youtubeTitle, savePath, downloadId);

}

getYoutubeVideoInformation(youtubeUrl) async {
  final yt = YoutubeExplode();
  final video = await yt.videos.get(youtubeUrl);
  final videoId = video.id;
  String videoTitle = video.title;
  Duration? videoDuration = video.duration;
  String videoImage = video.thumbnails.lowResUrl;
  int maxTitleLength = 35;

  videoTitle = videoTitle.replaceAll("/", " ");
  videoTitle = videoTitle.replaceAll("|", " ");
  if(videoTitle.length > maxTitleLength){
    videoTitle = videoTitle.substring(0,maxTitleLength);
  }

  final manifest = await yt.videos.streamsClient.getManifest(videoId);
  yt.close();

  return{
    "title" : videoTitle,
    "duration": videoDuration,
    "image": videoImage,
    "manifest": manifest
  };
}

downloadManager(downloadUrl, videoTitle, path, downloadId){
  final mediaBox = Hive.box('mediaBox');

  ALDownloader.download(downloadUrl.toString(), directoryPath: path, fileName: "$videoTitle.mp4",
    downloaderHandlerInterface: ALDownloaderHandlerInterface(progressHandler: (progress){
      var hiveVideoData = mediaBox.get(videoTitle);
      hiveVideoData["downloadStatus"] = (progress*100).round().toString();
      mediaBox.put(videoTitle, hiveVideoData);
      NotificationService().createNotification((progress*100).round(), downloadId, videoTitle);
    }, succeededHandler: () {
      var hiveVideoData = mediaBox.get(videoTitle);
      hiveVideoData["status"] = "done";
      hiveVideoData["downloadStatus"] = "100";
      mediaBox.put(videoTitle, hiveVideoData);
      debugPrint('ALDownloader | download succeeded\n');
    }, failedHandler: () {
      mediaBox.get(videoTitle)["status"] = "error";
      ALDownloader.remove(downloadUrl.toString());
      debugPrint('ALDownloader | download failed\n');
    }, pausedHandler: () {
      mediaBox.get(videoTitle)["status"] = "pause?";
      debugPrint('ALDownloader | download paused}\n');
    }),
  );
}


