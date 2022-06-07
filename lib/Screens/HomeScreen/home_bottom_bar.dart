import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:voicememos/Utils/app_colors.dart';

import '../../Model/new_folder_model.dart';
import '../../Utils/app_icons.dart';

class HomeBottomBar extends StatefulWidget {
  final bool isEditMode;
  const HomeBottomBar({Key? key,required this.isEditMode}) : super(key: key);

  @override
  State<HomeBottomBar> createState() => _HomeBottomBarState();
}

class _HomeBottomBarState extends State<HomeBottomBar> {
  final textController = TextEditingController();
  final _folders = <String, FolderModel>{};

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.lightBG,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 15, bottom: 5, top: 5),
            child: widget.isEditMode ? const SizedBox(height: 30) : InkWell(
              onTap: () {
                showCupertinoDialog(
                    context: context,
                    builder: (_) => CupertinoAlertDialog(
                          title: const Text("New Folder"),
                          content: Column(children: [
                            const Text("Enter a name for this folder"),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CupertinoTextField(
                                placeholder: 'Name',
                                controller: textController,
                              ),
                            )
                          ]),
                          actions: [
                            // Close the dialog
                            // You can use the CupertinoDialogAction widget instead
                            CupertinoButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                            CupertinoButton(
                              child: const Text('Save'),
                              onPressed: () {
                                setState(() {
                                  final id = Localstore.instance
                                      .collection('folders')
                                      .doc()
                                      .id;
                                  final folder = FolderModel(
                                      title: textController.text, id: id);
                                  folder.save();
                                  _folders.putIfAbsent(folder.id, () => folder);
                                });
                                //Resets Text in the Field
                                textController.clear();
                                //Then close the dialog
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        ));
              },
              child: AppIcons.folderPlus,
            ),
          )
        ],
      ),
    );
  }
}
