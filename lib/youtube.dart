import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:al_downloader/al_downloader.dart';

import 'notification.dart';


Future<void> downloadVideo(String videoLink, selectedVideoQuality, {onlySound = false}) async {
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

  mediaBox.put(videoTitle,{
    "status": "start",
    "downloadStatus": "0",
    "duration": videoDuration?.inMilliseconds,
    "image": videoImage
  });

  mediaBox.put("downloadId", mediaBox.get("downloadId")??0+1);

  ALDownloader.download(downloadUrl.toString(), directoryPath: "$path/youtube/", fileName: "$videoTitle.mp4",
      downloaderHandlerInterface: ALDownloaderHandlerInterface(progressHandler: (progress){
        var hiveVideoData = mediaBox.get(videoTitle);
        hiveVideoData["downloadStatus"] = (progress*100).round().toString();
        mediaBox.put(videoTitle, hiveVideoData);
        NotificationService().createNotification((progress*100).round(), mediaBox.get("downloadId"), videoTitle);
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
    redownloadIfNeeded: true
  );



}


