import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'folderPage.dart';
import 'mediaPlayerPage.dart';
import 'youtube.dart';

class MyHomePage extends StatefulWidget {
  var videoFile;

  MyHomePage({super.key, this.videoFile});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Widget> tabPages;
  var selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    tabPages = <Widget>[
      MediaPlayerPage(videoFile: widget.videoFile),
      const FolderPage(),
    ];
    createFolders();
    super.initState();
  }

  createFolders() async {
    var directory = await getApplicationDocumentsDirectory();
    createYoutubeFolder(directory);
  }

  createYoutubeFolder(directory) async{
    var youtubePath =  "${directory.path}/youtube";
    final checkPathExistence = await Directory(youtubePath).exists();

    if(!checkPathExistence){
      Directory(youtubePath).create();
    }
  }

  @override
  Widget build(BuildContext context) {

    openNewVideoWindow() {
      var linkController = TextEditingController();

      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, windowState) {
              return AlertDialog(
                content: Column(
                  children: [
                    TextField(
                      controller: linkController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter a Youtube link',
                      ),
                    ),
                    SizedBox(height: 20),
                    FloatingActionButton.extended(
                        label: Text("Download"),
                        onPressed: () {
                          downloadVideo(linkController.text);
                          Navigator.pop(context);
                        },
                    ),
                  ],
                ),
              );
            });
          });
    }

    return SafeArea(
      child: Scaffold(
          body: Center(
            child: tabPages.elementAt(selectedIndex),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => openNewVideoWindow(),
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: CustomBottomNavigationBar(
            onNavigationItemTapped: _onItemTapped,
            selectNavigationItem: selectedIndex,
          )),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  var onNavigationItemTapped;
  int selectNavigationItem;

  CustomBottomNavigationBar(
      {required this.onNavigationItemTapped,
      required this.selectNavigationItem});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: kBottomNavigationBarHeight,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey,
                  width: 0.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Theme.of(context).colorScheme.primary,
              currentIndex: selectNavigationItem,
              selectedItemColor: Colors.white,
              onTap: onNavigationItemTapped,
              items: <BottomNavigationBarItem>[
                const BottomNavigationBarItem(
                  icon: Icon(Icons.music_note),
                  label: 'Media Player',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.folder),
                  label: 'Folder',
                ),
              ],
            ),
          ),
        ));
  }
}
