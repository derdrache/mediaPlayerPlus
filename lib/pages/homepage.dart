import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_player_plus/pages/settings.dart';
import 'package:path_provider/path_provider.dart';

import '../add_new_video_link_window.dart';
import 'folderPage.dart';
import 'mediaPlayerPage.dart';

class MyHomePage extends StatefulWidget {
  var videoFile;
  int selectedIndex;

  MyHomePage({super.key, this.videoFile, this.selectedIndex = 3});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Widget> tabPages;

  void _onItemTapped(int index) {
    if(index == 1 || index == 2) return;

    setState(() {
      widget.selectedIndex = index;
    });
  }

  @override
  void initState() {
    tabPages = <Widget>[
      MediaPlayerPage(videoFile: widget.videoFile),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
      FolderPage(),
      const SettingsPage()
    ];
    createFolders();
    super.initState();
  }

  createFolders() async {
    var directory = await getApplicationDocumentsDirectory();
    createYoutubeFolder(directory);
  }

  createYoutubeFolder(directory) async {
    String youtubePath = "${directory.path}/youtube";
    final checkPathExistence = await Directory(youtubePath).exists();

    if (!checkPathExistence) {
      Directory(youtubePath).create();
    }
  }

  update(){
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    tabPages = <Widget>[
      MediaPlayerPage(videoFile: widget.videoFile),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
      FolderPage(),
      const SettingsPage()
    ];

    return SafeArea(
      child: Scaffold(
          body: tabPages.elementAt(widget.selectedIndex),
          floatingActionButton: FloatingActionButton(
            onPressed: () => addNewVideoWindow(context, update),
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: CustomBottomNavigationBar(
            onNavigationItemTapped: _onItemTapped,
            selectNavigationItem: widget.selectedIndex,
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
                  label: 'Player',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary,),
                  label: ""
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary,),
                  label: ""
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.folder),
                  label: 'Folder',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),

          ),
        ));
  }
}
