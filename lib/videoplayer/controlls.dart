import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:media_player_plus/videoplayer/fullscreen.dart';
import 'package:video_player/video_player.dart';
import 'package:simple_pip_mode/simple_pip.dart';

class Controlls extends StatefulWidget {
  final VideoPlayerController videoPlayer;
  var videoFile;

  Controlls({Key? key, required this.videoPlayer, this.videoFile = ""}) : super(key: key);

  @override
  State<Controlls> createState() => _ControllsState();
}

class _ControllsState extends State<Controlls> {
  bool repeatOn = false;
  double mainIconSize = 50;
  double iconSize = 35;
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

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: Icon(Icons.replay_10),
                iconSize: mainIconSize,
                onPressed: () => rewind()),
            IconButton(
              onPressed: () async{
                if(widget.videoPlayer.value.isPlaying){
                  widget.videoPlayer.pause();
                  await FlutterBackground.disableBackgroundExecution();
                }else {
                  widget.videoPlayer.play();
                  await FlutterBackground.enableBackgroundExecution();
                }

                setState(() {});
              },
              iconSize: mainIconSize,
              icon: Icon(widget.videoPlayer.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow),
            ),
            IconButton(
              iconSize: mainIconSize,
              icon: Icon(Icons.forward_10),
              onPressed: () => forward(),
            ),

          ],
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
            iconSize: iconSize,
            icon: repeatOn ? Icon(Icons.repeat_on_outlined) : Icon(Icons.repeat),
            onPressed: () => repeat(!repeatOn),
          ),
          InkWell(
            onTap: () => changeSpeed(),
            child: Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(border: Border.all(width: 2)),
              child: Center(
                  child: Text(
                    speed.toString() + "x",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
            ),
          ),
          IconButton(
            iconSize: mainIconSize - 10,
            icon: Icon(Icons.fullscreen),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VideoFullScreen(videoPlayer: widget.videoPlayer)),
              );
            },
          ),
          IconButton(
            iconSize: iconSize,
            icon: Icon(Icons.picture_in_picture),
            onPressed: () => SimplePip().enterPipMode(),
          ),
        ],)
      ],
    );
  }
}

