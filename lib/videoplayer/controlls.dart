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

    ownIconButton({icon, function, double size = 60}){
      return Container(
        margin: EdgeInsets.all(15),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 2)
        ),
        child: IconButton(
          onPressed: function,
          iconSize: size >= 80 ? 40 : 35,
          icon: icon,
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ownIconButton(
              icon: Icon(Icons.replay_10),
              function: () => rewind(),
            ),
            ownIconButton(
                icon: Icon(widget.videoPlayer.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow),
                  function:  () async{
                  if(widget.videoPlayer.value.isPlaying){
                    widget.videoPlayer.pause();
                    await FlutterBackground.disableBackgroundExecution();
                  }else {
                    widget.videoPlayer.play();
                    await FlutterBackground.enableBackgroundExecution();
                  }

                  setState(() {});
                },
                size: 80
            ),
            ownIconButton(
              icon: Icon(Icons.forward_10),
              function: () => forward(),
            ),
          ],
        ),
        SizedBox(height: 25,),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ownIconButton(
            icon: repeatOn ? Icon(Icons.repeat_on_outlined) : Icon(Icons.repeat),
            function: () => repeat(!repeatOn)
          ),
          InkWell(
            onTap: () => changeSpeed(),
            child: Container(
              width: 60,
              height: 60,
              margin: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 2)
              ),
              child: Center(
                  child: Text(
                    speed.toString() + "x",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
            ),
          ),
          ownIconButton(
            icon: Icon(Icons.fullscreen),
            function: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VideoFullScreen(videoPlayer: widget.videoPlayer)),
              );
            }
          ),

          ownIconButton(
            icon: Icon(Icons.picture_in_picture),
            function: () => SimplePip().enterPipMode()
          ),
        ],),
        SizedBox(height: 15)
      ],
    );
  }
}

