import 'dart:io';

import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:media_player_plus/homepage.dart';
import 'package:path_provider/path_provider.dart';
import 'videoplayer/videoplayer.dart';


class MediaPlayerPage extends StatefulWidget {
  var videoFile;

  MediaPlayerPage({Key? key, this.videoFile}) : super(key: key);

  @override
  State<MediaPlayerPage> createState() => _MediaPlayerPageState();
}

class _MediaPlayerPageState extends State<MediaPlayerPage> {

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
              bool isSelected = widget.videoFile == null ? false : video.path == widget.videoFile.path;
              var videoTitle = video.path.split("/").last.replaceAll(".mp4", "");
              var videoSize = (video.lengthSync() / 1000000).round();

              videosContainerList.add(
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,MaterialPageRoute(builder: (context) => MyHomePage(videoFile: video)),);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(
                              videoTitle,maxLines: 2, style: TextStyle(
                                fontSize: 20,
                                color: isSelected ? Colors.blue: Colors.black
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
                        Text("Size: ${videoSize} mb")
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
        if(widget.videoFile != null) OwnVideoPlayer(mediaFile: widget.videoFile),
        if(widget.videoFile == null) Container(
          decoration: BoxDecoration(
            border: Border.all()
          ),
          height: 220,
          width: double.infinity,
          child: Center(
            child: Text("Video auswählen oder neues Video hinzufügen"),
          ),
        ),
        showAllVideos()
      ],
    );
  }
}

