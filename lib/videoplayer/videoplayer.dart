import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import 'controlls.dart';

class OwnVideoPlayer extends StatefulWidget {
  var mediaFile;

  OwnVideoPlayer({Key? key, required this.mediaFile}) : super(key: key);

  @override
  State<OwnVideoPlayer> createState() => _OwnVideoPlayerState();
}

class _OwnVideoPlayerState extends State<OwnVideoPlayer> {
  late VideoPlayerController _videoController;
  var videoProgress = Duration(seconds: 0);
  var videoBuffered = Duration(seconds: 0);
  var videoLength = Duration(seconds: 0);
  var mediaBox = Hive.box('mediaBox');


  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    initVideoPlayer();
  }

  @override
  void dispose() {
    Wakelock.disable();
    _videoController.dispose();
    super.dispose();
  }

  initVideoPlayer() {
    var videoTitle = widget.mediaFile.path.split("/").last.replaceAll(".mp4", "");
    var savedPosition = Duration(seconds: mediaBox.get(videoTitle)?["position"] ?? 0);

    _videoController = VideoPlayerController.file(widget.mediaFile,
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true))
      ..initialize().then((_) {
        setState(() {
          _videoController.seekTo(savedPosition);
        });
      });

    _videoController.addListener(() {
      var videoData = mediaBox.get(videoTitle);

      var videoPosition = _videoController.value.position;
      if(videoPosition.inSeconds == 0 && videoData != null){
        videoData["position"] = 0;
        mediaBox.put(videoTitle,videoData);
      }else if(videoPosition.inSeconds > 20&& videoData != null){
        videoData["position"] = videoPosition.inSeconds - 10;
        mediaBox.put(videoTitle,videoData);
      }


      setState(() {
        videoProgress = videoPosition;
        videoLength = _videoController.value.duration;
        videoBuffered = videoLength;
      });
    });


    _videoController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: _videoController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                )
              : Container(),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: ProgressBar(
            progress: videoProgress,
            buffered: videoBuffered,
            total: videoLength,
            onSeek: (duration) {
              _videoController.seekTo(duration);
            },
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: Controlls(
            videoPlayer: _videoController,
          ),
        ),
      ],
    );
  }
}