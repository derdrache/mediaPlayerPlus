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
  List speicherPfadBezeichnungen =  ["Interner Speicher", "SD-Karte"];
  late String speicherPfadSelected;

  checkSDExist() async {
    var dirs  = await getExternalStorageDirectories();

    if(dirs!.length > 1) return;

    setState(() {
      speicherPfadBezeichnungen.removeLast();
    });

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
      margin: const EdgeInsets.all(15),
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(children: [
            const Expanded(child: Text("Speicherpfad", style: TextStyle(fontSize: 20),),),
            const SizedBox(width:5),
            DropdownButton(
              value: speicherPfadSelected,
                items: speicherPfadBezeichnungen.map<DropdownMenuItem>((value) {
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
