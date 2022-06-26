// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sliding_panel/sliding_panel.dart';
import 'package:voicememos/Screens/HomeScreen/home_bottom_bar.dart';
import 'package:voicememos/Screens/RecordingScreen/normal_sheet.dart';
import 'package:voicememos/Screens/RecordingScreen/recorded_list_view.dart';
import 'package:voicememos/constants/paths.dart';
import '../../Model/new_folder_model.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/app_icons.dart';
import '../../Widgets/Tiles/all_recordings_tile.dart';
import '../../Widgets/Tiles/favorites_tile.dart';
import '../../Widgets/Tiles/rd_tile.dart';

class AllRecordingsScreen extends StatefulWidget {
  final String tileName;
  const AllRecordingsScreen({Key? key, required this.tileName})
      : super(key: key);

  @override
  State<AllRecordingsScreen> createState() => _AllRecordingsScreenState();
}

class _AllRecordingsScreenState extends State<AllRecordingsScreen> {
  //Creates new item
  final _folders = <String, FolderModel>{};
  final db = Localstore.instance;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  //Booleans
  bool isEditMode = false;
  bool isVisible = true;

  List<String> records = [];
  Directory appFolder = Directory(Paths.recording);

  //Strings
  String allRecordingsStr = 'All Recordings';
  String favStr = 'Favorites';
  String rdStr = 'Recently Deleted';

  final textController = TextEditingController();
  final panelController = PanelController();

  @override
  void initState() {
    _subscription = db.collection('folders').stream.listen((event) {
      setState(() {
        final folder = FolderModel.fromMap(event);
        _folders.putIfAbsent(folder.id, () => folder);
      });
    });
    super.initState();

    appFolder.list().listen((onData) {
      if (onData.path.contains('.aac')) records.add(onData.path);
    }).onDone(() {
      records = records.reversed.toList();
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (_subscription != null) _subscription?.cancel();

    // appDirectory.delete();
    super.dispose();
  }

  _onRecordComplete() {
    records.clear();
    appFolder.list().listen((onData) {
      if (onData.path.contains('.aac')) records.add(onData.path);
    }).onDone(() {
      records.sort();
      records = records.reversed.toList();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      CupertinoSliverNavigationBar(
                          transitionBetweenRoutes: false,
                          padding: const EdgeInsetsDirectional.all(0),
                          trailing: isEditMode
                              ? TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isEditMode = false;
                                    });
                                  },
                                  child: const Text(
                                    'Cancel  ',
                                    style: TextStyle(
                                        color: AppColors.blue, fontSize: 16.5),
                                  ),
                                )
                              : TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isEditMode = true;
                                    });
                                  },
                                  child: const Text(
                                    '  Edit',
                                    style: TextStyle(
                                        color: AppColors.blue, fontSize: 16.5),
                                  ),
                                ),
                          largeTitle: Text(widget.tileName))
                    ],
                body: Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child:
                      RecordListView(records: records, editState: isEditMode),
                )),
            //
            // SlidingUpPanelWidget(
            //     child: Column(
            //       children: <Widget>[

            //       ],
            //     ),
            //     controlHeight: 200,
            //     // MediaQuery.of(context).size.height,
            //     panelController: panelController)
            SlidingPanel(
              panelController: panelController,
              content: PanelContent(
                headerWidget: const PanelHeaderWidget(
                  headerContent: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'This is a SlidingPanel',
                    ),
                  ),
                  options: PanelHeaderOptions(centerTitle: true),
                ),

                // The only REQUIRED parameter
                panelContent: List.generate(20, (i) {
                  return ListTile(
                    title: Text('Item : ${i + 1}'),
                  );
                }).toList(),

                bodyContent: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      panelController.collapse();
                    },
                    child: const Text('Open the panel'),
                  ),
                ),
              ),
              size: const PanelSize(closedHeight: 500),
              // apply snapping effect
              snapping: PanelSnapping.enabled,
            ),
          ],
        ),
        bottomSheet: isEditMode
            ? editModeSheet()
            : NormalSheet(onSaved: _onRecordComplete));
  }

  Widget editModeSheet() {
    return Container(
      decoration: const BoxDecoration(
          color: AppColors.lightBG,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(13), topRight: Radius.circular(13))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextButton(
              onPressed: () {
                showCupertinoModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return Container(
                        decoration: const BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10))),
                        child: CupertinoPopupSurface(
                          isSurfacePainted: false,
                          child: Scaffold(
                            body: CupertinoPageScaffold(
                                navigationBar: CupertinoNavigationBar(
                                  automaticallyImplyLeading: false,
                                  transitionBetweenRoutes: false,
                                  middle: const Text('Move Folder'),
                                  trailing: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel')),
                                ),
                                child: homeBody(context)),
                            bottomNavigationBar:
                                HomeBottomBar(isEditMode: !isEditMode),
                          ),
                        ),
                      );
                    });
              },
              child: const Text('Move',
                  style: TextStyle(color: CupertinoColors.activeBlue))),
          TextButton(
              onPressed: () {},
              child: const Text('Delete',
                  style: TextStyle(color: CupertinoColors.activeBlue)))
        ],
      ),
    );
  }

  Widget homeBottomBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 15, bottom: 5, top: 5),
            child: InkWell(
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

  Widget homeBody(BuildContext context) {
    return ListView(
      //physics: const BouncingScrollPhysics(),
      children: [
        Container(
          margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
          padding: const EdgeInsets.only(left: 15, right: 15),
          decoration: BoxDecoration(
              color: AppColors.lightBG, borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                        CupertinoPageRoute(builder: (BuildContext context) {
                      return AllRecordingsScreen(tileName: allRecordingsStr);
                    }));
                  },
                  child: AllRecordingsTile(
                    tileTitle: allRecordingsStr,
                  )),
              const Divider(
                height: 0,
                thickness: 1.0,
              ),
              FavoritesTile(tileTitle: favStr),
              const Divider(
                height: 0,
                thickness: 1.0,
              ),
              RecentlyDeletedTile(tileTitle: rdStr)
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 32.0, top: 20, bottom: 5),
          child: Text(
            'MY FOLDERS',
            style: TextStyle(color: AppColors.grey, fontSize: 14),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 5),
          child: Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
                color: AppColors.lightBG,
                borderRadius: BorderRadius.circular(8)),
            child: ListView.separated(
                separatorBuilder: (context, index) => const Divider(
                      height: 0,
                      thickness: 1.0,
                    ),
                physics: const BouncingScrollPhysics(),
                itemCount: _folders.keys.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final key = _folders.keys.elementAt(index);
                  final folder = _folders[key]!;
                  return Container(
                    decoration: BoxDecoration(
                        color: AppColors.lightBG,
                        borderRadius: BorderRadius.circular(8)),
                    child: SizedBox(
                        height: 55,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                AppIcons.folderBlue,
                                const Divider(endIndent: 10),
                                Text(folder.title,
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                            Row(
                              children: const [
                                Text('0',
                                    style: TextStyle(
                                        color: CupertinoColors.systemGrey,
                                        fontSize: 16)),
                                Divider(indent: 3),
                                AppIcons.folderArrow
                              ],
                            ),
                          ],
                        )),
                  );
                }),
          ),
        )
      ],
    );
  }
}
