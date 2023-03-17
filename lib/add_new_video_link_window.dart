import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'functions/youtube.dart';

addNewVideoWindow(context) {
  String videoQuality = "med";
  bool onlySound = false;
  TextEditingController linkController = TextEditingController();

  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, windowState) {
          return AlertDialog(
            content: Column(
              children: [
                TextField(
                  controller: linkController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a Youtube link',
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    ClipboardData? cdata =
                    await Clipboard.getData(Clipboard.kTextPlain);
                    String? copiedtext = cdata?.text;

                    windowState(() {
                      linkController.text = copiedtext ?? "";
                    });
                  },
                  icon: const Icon(Icons.content_paste),
                  iconSize: 30,
                ),
                const SizedBox(height: 20),
                CheckboxListTile(
                    title: const Text("low Quality"),
                    value: videoQuality.contains("low"),
                    onChanged: (value) {
                      if (value!) {
                        windowState(() {
                          videoQuality = "low";
                        });
                      }
                    }),
                CheckboxListTile(
                    title: const Text("med Quality"),
                    value: videoQuality.contains("med"),
                    onChanged: (value) {
                      if (value!) {
                        windowState(() {
                          videoQuality = "med";
                        });
                      }
                    }),
                CheckboxListTile(
                    title: const Text("high Quality"),
                    value: videoQuality.contains("high"),
                    onChanged: (value) {
                      if (value!) {
                        windowState(() {
                          videoQuality = "high";
                        });
                      }
                    }),
                const SizedBox(height: 20),
                CheckboxListTile(
                    title: const Text("Sound only"),
                    value: onlySound,
                    onChanged: (value) {
                      windowState(() {
                        onlySound = value!;
                      });
                    }),
                const SizedBox(height: 20),
                FloatingActionButton.extended(
                  label: const Text("Download"),
                  onPressed: () {
                    bool isYouTubeLink = linkController.text.contains("youtu");

                    if(linkController.text.isEmpty || !isYouTubeLink){
                      windowState((){
                        linkController.clear();
                      });
                      return;
                    }

                    downloadVideo(linkController.text, videoQuality,
                        onlySound: onlySound);

                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
      });
}
