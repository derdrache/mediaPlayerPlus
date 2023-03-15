import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final mediaBox = Hive.box('mediaBox');
  List speicherPfad =  ["Interner Speicher", "SD-Karte"];
  late String speicherPfadSelected;

  checkSDExist() async {
    Directory? externalDirectory  = await getExternalStorageDirectory();

    if(externalDirectory != null) return;

    speicherPfad.removeLast();
  }

@override
  void initState() {
  speicherPfadSelected= mediaBox.get("speicherPfad") ?? "Interner Speicher";

    checkSDExist();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(children: [
            Expanded(child: Text("Speicherpfad", style: TextStyle(fontSize: 20),),),
            SizedBox(width:5),
            DropdownButton(
              value: speicherPfadSelected,
                items: speicherPfad.map<DropdownMenuItem>((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                }).toList(),
                onChanged: (value){
                  mediaBox.put("speicherPfad", value);
                  setState(() {
                    speicherPfadSelected = value;
                  });
                })
          ],)
        ],
      ),
    );
  }
}
