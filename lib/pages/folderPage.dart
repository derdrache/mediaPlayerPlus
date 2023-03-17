import 'dart:io';

import 'package:al_downloader/al_downloader.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:external_path/external_path.dart';

import '../functions/formatDuration.dart';
import 'homepage.dart';

class FolderPage extends StatefulWidget {
  const FolderPage({Key? key}) : super(key: key);

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  var mediaBox = Hive.box('mediaBox');

  getAllMediaFiles() async {
    var dirs = await getExternalStorageDirectories();
    dirs = dirs!;
    List youtubeFiles = [];

    for(var dir in dirs){
      youtubeFiles = youtubeFiles + await getYoutubeFiles(dir);
    }

    var allSystemFiles = await getAllStorageAudio();

    return youtubeFiles + allSystemFiles;
  }

  getYoutubeFiles(dir) async {
    String path =  "${dir.path}/youtube";
    Directory youtubeDir = Directory(path);
    return await youtubeDir.list().toList();
  }

  getAllStorageAudio()async{
    List paths = await ExternalPath.getExternalStorageDirectories();
    List allFiles = [];

    for(var path in paths){
      var files = Directory(path).listSync(recursive: true, followLinks: false);

      for(var file in files){
        if(file.path.contains("Android")) continue;

        if(file.path.endsWith('.mp3') || file.path.endsWith('.mp4')) allFiles.add(file);
      }
    }

    return allFiles;
  }

  deleteVideo(videoTitle){

  }

  @override
  Widget build(BuildContext context) {

    createVideoDisplay(video){
      String videoTitle = video.path.split("/").last.replaceAll(".mp4", "");
      Map videoData = mediaBox.get(videoTitle) ?? {};
      String status = videoData["status"] ?? "";
      Duration duration =  Duration(milliseconds: videoData["duration"] ?? 0);
      String videoImage = videoData["image"] ?? "";
      String downloadStatus = videoData["downloadStatus"];
      String downloadUrl = videoData["url"];

      return InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,MaterialPageRoute(builder: (context) => MyHomePage(selectedIndex: 0, videoFile: video)),);
        },
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Row(
            children: [
              if(videoImage != "") Image.network(
                  videoImage, scale: 1.3,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return const Text('');
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(
                          videoTitle,maxLines: 2, style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black
                        ),
                        )),
                      ],
                    ),
                    if(videoData.isNotEmpty) Row(
                      children: [
                        Text("Status: $status - $downloadStatus % / "),
                        Text("${formatDuration(duration)}")
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                  onPressed: () async {
                    if(status != "done"){
                      ALDownloader.cancel(downloadUrl);
                      FlutterLocalNotificationsPlugin().cancel(videoData["id"]);
                    }

                    await video.delete();
                    mediaBox.delete(videoTitle);

                    setState(() {});
                  },
                  color: Colors.red,
                  iconSize: 30,
                  icon: status == "done" || videoData.isEmpty
                      ? const Icon(Icons.delete)
                      : const Icon(Icons.file_download_off)
              )
            ],
          ),
        ),
      );

    }

    showAllVideos(){
      return FutureBuilder(
          future: getAllMediaFiles(),
          builder: (context, AsyncSnapshot snapshot) {
            if(snapshot.data != null){
              var allVideos = snapshot.data!;
              List<Widget> videosContainerList = [];

              for(var video in allVideos){
                videosContainerList.add(createVideoDisplay(video));
              }

              return ListView(
                shrinkWrap: true,
                children: videosContainerList,
              );
            }else{
              return const SizedBox.shrink();
            }

          }
      );
    }

    return Column(
      children: [
        showAllVideos(),
      ],
    );
  }
}
