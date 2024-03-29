import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_player_plus/pages/settings.dart';
import 'package:path_provider/path_provider.dart';

import '../add_new_video_link_window.dart';
import 'folderPage.dart';

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
      FolderPage(),
      const SettingsPage()
    ];

    return SafeArea(
      child: Scaffold(
          body: tabPages.elementAt(selectedIndex),
          floatingActionButton: FloatingActionButton(
            onPressed: () => addNewVideoWindow(context, update),
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
        child: SizedBox(
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
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.folder),
                  label: 'Folder',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),

          ),
        ));
  }
}
