import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'homepage.dart';

class FolderPage extends StatefulWidget {
  const FolderPage({Key? key}) : super(key: key);

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  var mediaBox = Hive.box('mediaBox');

  getAllVideos() async {
    var dir = await getApplicationDocumentsDirectory();
    var youtubePath =  "${dir.path}/youtube";
    Directory youtubeDir = Directory(youtubePath);

    return await youtubeDir.list().toList();
  }

  @override
  Widget build(BuildContext context) {

    showAllVideos(){
      return FutureBuilder(
          future: getAllVideos(),
          builder: (context, AsyncSnapshot snapshot) {
            if(snapshot.data != null){
              var allVideos = snapshot.data!;
              List<Widget> videosContainerList = [];


              for(var video in allVideos){
                var videoTitle = video.path.split("/").last.replaceAll(".mp4", "");
                var videoData = mediaBox.get(videoTitle) ?? {};
                var status = videoData["status"] ?? "";
                Duration duration =  Duration(milliseconds: videoData["duration"]);
                var videoImage = videoData["image"] ?? "";

                videosContainerList.add(
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,MaterialPageRoute(builder: (context) => MyHomePage(videoFile: video)),);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Image.network(videoImage, scale: 1.3),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text(
                                        videoTitle,maxLines: 2, style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black
                                      ),
                                      )),
                                      const SizedBox(width: 10),
                                      IconButton(
                                          onPressed: () async {
                                            await video.delete();
                                            setState(() {

                                            });
                                          },
                                          color: Colors.red,
                                          iconSize: 30,
                                          icon: const Icon(Icons.delete)
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("Status: $status / "),
                                      Text("${duration.inMinutes}:${duration.inSeconds} min")
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                );
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
