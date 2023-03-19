import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../add_new_video_link_window.dart';
import '../functions/formatDuration.dart';
import '../videoplayer/videoplayer.dart';


class MediaPlayerPage extends StatefulWidget {
  var videoFile;
  bool videoOnly;

  MediaPlayerPage({Key? key, this.videoFile, this.videoOnly = false}) : super(key: key);

  @override
  State<MediaPlayerPage> createState() => _MediaPlayerPageState();
}

class _MediaPlayerPageState extends State<MediaPlayerPage> {
  var mediaBox = Hive.box('mediaBox');

  deleteFile(videoTitle) async {
    await widget.videoFile.delete();
    mediaBox.delete(videoTitle);
    setState(() {
      widget.videoFile = null;
    });
  }

  writeLocalDB(videoTitle){
    if(mediaBox.get(videoTitle) != null ) return;

    mediaBox.put(videoTitle, {
      "typ": "ownMedia",
      "position" : 0
    });
  }

  @override
  Widget build(BuildContext context) {

    videoInfoContainer(){
      String videoTitle = widget.videoFile.path.split("/").last.replaceAll(".mp4", "");
      writeLocalDB(videoTitle);
      Map videoData = mediaBox.get(videoTitle) ?? {};
      String status = videoData["status"] ?? "";
      Duration duration =  Duration(milliseconds: videoData["duration"] ?? 0);
      String videoImage = videoData["image"] ?? "";

      return Container(
        margin: const EdgeInsets.all(10),
        child: Row(
          children: [
            if(videoImage.isNotEmpty) Image.network(videoImage, scale: 1.3),
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
                      ),
                      )),
                      const SizedBox(width: 10),
                      IconButton(
                          onPressed: () => deleteFile(videoTitle),
                          color: Colors.red,
                          iconSize: 30,
                          icon: const Icon(Icons.delete)
                      )
                    ],
                  ),
                  Row(
                    children: [
                      if(status.isNotEmpty) Text("Status: $status / "),
                      if(duration.inMilliseconds != 0) Text("${formatDuration(duration)}")
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
        if(widget.videoFile == null && !widget.videoOnly) InkWell(
          onTap: () => addNewVideoWindow(context, null),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all()
            ),
            height: 220,
            width: double.infinity,
            child: const Center(
              child: Text("Video auswählen oder neues Video hinzufügen"),
            ),
          ),
        ),
        if(widget.videoFile != null && !widget.videoOnly) videoInfoContainer()
      ],
    );
  }
}

