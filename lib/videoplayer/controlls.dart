import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Controlls extends StatelessWidget {
  final VideoPlayerController videoPlayer;

  const Controlls({Key? key, required this.videoPlayer}) : super(key: key);

  play(){
    videoPlayer.play();
  }

  pause(){
    videoPlayer.pause();
  }

  rewind() async {
    Duration position = await videoPlayer.position ?? Duration(seconds: 0);
    videoPlayer.seekTo(Duration(seconds: position.inSeconds - 10));
  }

  forward() async{
    Duration position = await videoPlayer.position ?? Duration(seconds: 0);
    videoPlayer.seekTo(Duration(seconds: position.inSeconds + 10));
  }

  


  @override
  Widget build(BuildContext context) {
    double iconSize = 50;


    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            icon: Icon(Icons.replay_10),
            iconSize: iconSize,
            onPressed: ()=> rewind()),
        IconButton(
          onPressed: (){
            videoPlayer.value.isPlaying
                ? videoPlayer.pause()
                : videoPlayer.play();
          },
          iconSize: iconSize,
          icon: Icon(
              videoPlayer.value.isPlaying ? Icons.pause : Icons.play_arrow),
        ),
        IconButton(
          iconSize: iconSize,
          icon: Icon(Icons.forward_10), //IconBadge(icon: Icon(Icons.fast_forward), text: "+15"),
          onPressed: ()=> forward(),
        ),
      ],
    );
  }
}