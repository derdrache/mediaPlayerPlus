import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../add_new_video_link_window.dart';
import '../functions/formatDuration.dart';
import '../videoplayer/videoplayer.dart';


class MediaPlayerPage extends StatefulWidget {
  var videoFile;

  MediaPlayerPage({Key? key, this.videoFile}) : super(key: key);

  @override
  State<MediaPlayerPage> createState() => _MediaPlayerPageState();
}

class _MediaPlayerPageState extends State<MediaPlayerPage> {
  var mediaBox = Hive.box('mediaBox');


  @override
  Widget build(BuildContext context) {

    videoInfoContainer(){
      var videoTitle = widget.videoFile.path.split("/").last.replaceAll(".mp4", "");
      var videoData = mediaBox.get(videoTitle) ?? {};
      var status = videoData["status"] ?? "";
      Duration duration =  Duration(milliseconds: videoData["duration"]);
      var videoImage = videoData["image"] ?? "";

      return Container(
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
                      ),
                      )),
                      const SizedBox(width: 10),
                      IconButton(
                          onPressed: () async {
                            await widget.videoFile.delete();
                            setState(() {
                              widget.videoFile = null;
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
                      Text("${formatDuration(duration)}")
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      );
    }


    return Column(
      children: [
        if(widget.videoFile != null) OwnVideoPlayer(mediaFile: widget.videoFile),
        if(widget.videoFile == null) InkWell(
          onTap: () => addNewVideoWindow(context),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all()
            ),
            height: 220,
            width: double.infinity,
            child: Center(
              child: Text("Video auswählen oder neues Video hinzufügen"),
            ),
          ),
        ),
        if(widget.videoFile != null) videoInfoContainer()
      ],
    );
  }
}

