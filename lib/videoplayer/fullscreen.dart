import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';


class VideoFullScreen extends StatefulWidget {
  final VideoPlayerController videoPlayer;

  const VideoFullScreen({Key? key, required this.videoPlayer}) : super(key: key);

  @override
  State<VideoFullScreen> createState() => _VideoFullScreenState();
}

class _VideoFullScreenState extends State<VideoFullScreen> {

  @override
  void initState(){
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          VideoPlayer(widget.videoPlayer),
          Positioned(bottom:10, right:0, child: IconButton(
            color: Colors.red,
            iconSize: 30,
            icon: Icon(Icons.fullscreen),
            onPressed: (){
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ]);
              Navigator.pop(context);
            },
          ))
        ],
      ),
    );
  }
}

