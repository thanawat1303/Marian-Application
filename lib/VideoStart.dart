import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoSchool extends StatefulWidget {
  const VideoSchool({key});

  @override
  State<VideoSchool> createState() => _VideoSchoolState();
}

class _VideoSchoolState extends State<VideoSchool> {
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;

  bool stateDispose = true;

  void loopVideo(int milli, VideoPlayerController controller) {
    Future.delayed(Duration(milliseconds: milli + 100), () {
      if (stateDispose) {
        controller.seekTo(Duration(milliseconds: 0));
        controller.play();
        loopVideo(milli, controller);
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller1.play();
      _controller2.play();
      loopVideo(29766, _controller1);
      loopVideo(29733, _controller2);
    });

    super.initState();
    _controller1 = VideoPlayerController.asset('assets/video/video1.mp4');
    _controller1.setVolume(1.0);
    _controller1.initialize().then((_) {
      setState(() {});
    });

    _controller2 = VideoPlayerController.asset('assets/video/video2.mp4',
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    _controller2.setVolume(1.0);
    _controller2.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller1.dispose();
    _controller2.dispose();
    stateDispose = false;
    print("not focus");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 15, bottom: 15),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TextRMUTT(),
          _controller1.value.isInitialized
              ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent, width: 1),
                  ),
                  padding: EdgeInsets.all(20),
                  child: AspectRatio(
                    aspectRatio: _controller1.value.aspectRatio,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: VideoPlayer(_controller1)),
                  ),
                )
              : Container(),
          _controller2.value.isInitialized
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.transparent, width: 1),
                  ),
                  padding: EdgeInsets.all(20),
                  child: AspectRatio(
                    aspectRatio: _controller2.value.aspectRatio,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: VideoPlayer(_controller2)),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Row TextRMUTT() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.blue.shade200,
          ),
          padding: EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 25),
          child: Text(
            "@RMUTT",
            style: TextStyle(
                fontFamily: 'NatoSansThai',
                fontSize: 23,
                fontWeight: FontWeight.w900),
          ),
        )
      ],
    );
  }
}
