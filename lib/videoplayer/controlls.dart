import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Controlls extends StatefulWidget {
  final VideoPlayerController videoPlayer;

  const Controlls({Key? key, required this.videoPlayer}) : super(key: key);

  @override
  State<Controlls> createState() => _ControllsState();
}

class _ControllsState extends State<Controlls> {
  bool repeatOn = false;
  double iconSize = 50;
  double speed = 1.0;

  play() {
    widget.videoPlayer.play();
  }

  pause() {
    widget.videoPlayer.pause();
  }

  rewind() async {
    Duration position =
        await widget.videoPlayer.position ?? Duration(seconds: 0);
    widget.videoPlayer.seekTo(Duration(seconds: position.inSeconds - 10));
  }

  forward() async {
    Duration position =
        await widget.videoPlayer.position ?? Duration(seconds: 0);
    widget.videoPlayer.seekTo(Duration(seconds: position.inSeconds + 10));
  }

  repeat(repeatStatus) async {
    widget.videoPlayer.setLooping(repeatStatus);

    setState(() {
      repeatOn = repeatStatus;
    });
  }

  changeSpeed() async {
    double newSpeed = 0;

    if(speed == 1.0){
      newSpeed = 1.5;
    }else if(speed == 1.5){
      newSpeed = 0.5;
    }else if(speed == 0.5){
      newSpeed = 0.7;
    }else if(speed == 0.7){
      newSpeed = 1.0;
    }

    widget.videoPlayer.setPlaybackSpeed(newSpeed);
    setState(() {
      speed = newSpeed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            icon: Icon(Icons.replay_10),
            iconSize: iconSize,
            onPressed: () => rewind()),
        IconButton(
          onPressed: () {
            widget.videoPlayer.value.isPlaying
                ? widget.videoPlayer.pause()
                : widget.videoPlayer.play();
          },
          iconSize: iconSize,
          icon: Icon(widget.videoPlayer.value.isPlaying
              ? Icons.pause
              : Icons.play_arrow),
        ),
        IconButton(
          iconSize: iconSize,
          icon: Icon(Icons.forward_10),
          //IconBadge(icon: Icon(Icons.fast_forward), text: "+15"),
          onPressed: () => forward(),
        ),
        IconButton(
          iconSize: iconSize - 10,
          icon: repeatOn ? Icon(Icons.repeat_on_outlined) : Icon(Icons.repeat),
          //IconBadge(icon: Icon(Icons.fast_forward), text: "+15"),
          onPressed: () => repeat(!repeatOn),
        ),
        InkWell(
          onTap: () => changeSpeed(),
          child: Container(
            width: iconSize - 15,
            height: iconSize - 15,
            decoration: BoxDecoration(border: Border.all(width: 2)),
            child: Center(
                child: Text(
                  speed.toString() + "x",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
          ),
        )
      ],
    );
  }
}
