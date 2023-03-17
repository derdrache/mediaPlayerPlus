import 'dart:io';

import 'package:al_downloader/al_downloader.dart';
import 'package:flutter/material.dart';
import 'package:glob/list_local_fs.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:glob/glob.dart';
import 'package:permission_handler/permission_handler.dart';
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
    var youtubeFiles = [];

    for(var dir in dirs){
      youtubeFiles = youtubeFiles + await getYoutubeFiles(dir);
    }

    return youtubeFiles;
  }

  getYoutubeFiles(dir) async {
    var path =  "${dir.path}/youtube";
    Directory youtubeDir = Directory(path);
    return await youtubeDir.list().toList();

  }


  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    createVideoDisplay(video){
      var videoTitle = video.path.split("/").last.replaceAll(".mp4", "");
      var videoData = mediaBox.get(videoTitle) ?? {};
      var status = videoData["status"] ?? "";
      Duration duration =  Duration(milliseconds: videoData["duration"] ?? 0);
      var videoImage = videoData["image"] ?? "";
      var downloadStatus = videoData["downloadStatus"];
      var downloadUrl = videoData["url"];

      return InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,MaterialPageRoute(builder: (context) => MyHomePage(videoFile: video)),);
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
                    Row(
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
                  icon: status == "done"
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
