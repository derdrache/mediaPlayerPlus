import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simple_pip_mode/actions/pip_action.dart';
import 'package:simple_pip_mode/actions/pip_actions_layout.dart';
import 'package:simple_pip_mode/pip_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';
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
  late VideoPlayerController _videoController;
  late var videoPlayerWidget;


  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    initVideoPlayer();
    videoPlayerWidget = OwnVideoPlayer(mediaFile: widget.videoFile, videoController: _videoController,);
  }


  @override
  void dispose() {
    Wakelock.disable();
    _videoController.dispose();
    super.dispose();
  }

  initVideoPlayer() {
    var videoTitle = widget.videoFile.path.split("/").last.replaceAll(".mp4", "");
    var savedPosition = Duration(seconds: mediaBox.get(videoTitle)?["position"] ?? 0);

    _videoController = VideoPlayerController.file(widget.videoFile,
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true))
      ..initialize().then((_) {
        setState(() {
          _videoController.seekTo(savedPosition);
        });
      });

    _videoController.play();
  }

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

    return PipWidget(
        builder: (context) =>Scaffold(
          appBar: AppBar(
              title: Text("Video"),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              )
          ),
          body: Column(
            children: [
              if(widget.videoFile != null) videoPlayerWidget,
              if(widget.videoFile == null) InkWell(
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
              if(widget.videoFile != null) videoInfoContainer()
            ],
          ),
        ),
      pipChild: Scaffold(body: videoPlayerWidget),
      pipLayout: PipActionsLayout.media_only_pause,
      onPipAction: (action){
        switch (action) {
          case PipAction.play:
            _videoController.play();
            break;
          case PipAction.pause:
            _videoController.pause();
            break;
        }
      },
    );
  }
}

