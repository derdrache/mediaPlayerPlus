import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

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

  @override
  void initState() {
    super.initState();
    initVideoPlayer();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  initVideoPlayer() {
    _videoController = VideoPlayerController.file(widget.mediaFile,
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true))
      ..initialize().then((_) {
        setState(() {});
      });
    _videoController.addListener(() {
      setState(() {
        videoProgress = _videoController.value.position;
        videoLength = _videoController.value.duration;
        videoBuffered = videoLength;
      });
    });
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
