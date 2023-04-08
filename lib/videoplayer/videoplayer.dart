import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:video_player/video_player.dart';

import 'controlls.dart';

class OwnVideoPlayer extends StatefulWidget {
  var mediaFile;
  var videoController;

  OwnVideoPlayer({Key? key, required this.mediaFile, this.videoController}) : super(key: key);

  @override
  State<OwnVideoPlayer> createState() => _OwnVideoPlayerState();
}

class _OwnVideoPlayerState extends State<OwnVideoPlayer> {
  var videoProgress = Duration(seconds: 0);
  var videoBuffered = Duration(seconds: 0);
  var videoLength = Duration(seconds: 0);
  var mediaBox = Hive.box('mediaBox');
  var listenerFunction;

  initVideoPlayer() {
    var videoTitle = widget.mediaFile.path.split("/").last.replaceAll(".mp4", "");

    listenerFunction = () {
      var videoData = mediaBox.get(videoTitle);

      var videoPosition = widget.videoController.value.position;
      if(videoPosition.inSeconds == 0 && videoData != null){
        videoData["position"] = 0;
        mediaBox.put(videoTitle,videoData);
      }else if(videoPosition.inSeconds > 20&& videoData != null){
        videoData["position"] = videoPosition.inSeconds - 10;
        mediaBox.put(videoTitle,videoData);
      }

      setState(() {
        videoProgress = videoPosition;
        videoLength = widget.videoController.value.duration;
        videoBuffered = videoLength;
      });
    };


    widget.videoController.addListener(listenerFunction);

    widget.videoController.play();
  }

  @override
  void initState() {
    initVideoPlayer();

    super.initState();
  }

  @override
  void dispose() {
    widget.videoController.removeListener(listenerFunction);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Center(
          child: widget.videoController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: widget.videoController.value.aspectRatio,
                  child: VideoPlayer(widget.videoController),
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
              widget.videoController.seekTo(duration);
            },
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: Controlls(
            videoPlayer: widget.videoController,
            videoFile: widget.mediaFile,
          ),
        ),
      ],
    );
  }
}

