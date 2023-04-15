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
import 'homepage.dart';


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
  var mainColor = 0xFF5c00d2;


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
    widget.videoFile = null;
  
    Navigator.push(context,MaterialPageRoute(
      builder: (context) => MyHomePage()
    ));

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
    String videoTitle = widget.videoFile.path.split("/").last.replaceAll(".mp4", "");
    writeLocalDB(videoTitle);

    return PipWidget(
        builder: (context) =>Scaffold(
          appBar: AppBar(
              title: Text(videoTitle),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            actions: [
              IconButton(
                  onPressed: () => deleteFile(videoTitle),
                  color: Colors.red,
                  icon: const Icon(Icons.delete)
              )
            ],
            backgroundColor: Color(mainColor),
          ),
          body: Container(
            color: Color(mainColor),
            child: Column(
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
              ],
            ),
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

