import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:voicememos/Model/new_folder_model.dart';
import 'package:voicememos/Screens/HomeScreen/home_bottom_bar.dart';
import 'package:voicememos/Screens/RecordingScreen/all_recordings_screen.dart';
import 'package:voicememos/Utils/app_colors.dart';
import 'package:voicememos/Utils/app_icons.dart';
import 'package:voicememos/Widgets/Tiles/all_recordings_tile.dart';
import 'package:voicememos/Widgets/Tiles/favorites_tile.dart';
import 'package:voicememos/Widgets/Tiles/rd_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //Creates new item
  final _folders = <String, FolderModel>{};
  final db = Localstore.instance;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  //subCollections
  //final subDB = Localstore.instance.collection('folders').doc().collection('');

  //Gets item by id
  //final data = await db.collection('todos').doc(id).get();

  //Delete item by id
  //db.collection('todos').doc(id).delete();

  //Fetch the documents for the collection
  //final items = await db.collection('todos').get();

  //Using stream
  //final stream = db.collection('todos').stream;

  //Booleans
  bool isEditMode = false;
  bool isVisible = true;

  //Strings
  String allRecordingsStr = 'All Recordings';
  String favStr = 'Favorites';
  String rdStr = 'Recently Deleted';

  final textController = TextEditingController();

  @override
  void initState() {
    _subscription = db.collection('folders').stream.listen((event) {
      setState(() {
        final folder = FolderModel.fromMap(event);
        _folders.putIfAbsent(folder.id, () => folder);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    if (_subscription != null) _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
            headerSliverBuilder: (context, isScrolled) => [homeAppBar(context)],
            body: homeBody(context)),
        bottomNavigationBar: HomeBottomBar(
          isEditMode: isEditMode,
        ));
  }

  Widget homeAppBar(BuildContext context) {
    return CupertinoSliverNavigationBar(
        transitionBetweenRoutes: false,
        padding: const EdgeInsetsDirectional.all(0),
        trailing: isEditMode
            ? TextButton(
                onPressed: () {
                  setState(() {
                    isEditMode = false;
                    isVisible = true;
                  });
                },
                child: const Text(
                  'Cancel  ',
                  style: TextStyle(color: AppColors.blue, fontSize: 16.5),
                ),
              )
            : TextButton(
                onPressed: () {
                  setState(() {
                    isEditMode = true;
                    isVisible = false;
                  });
                },
                child: const Text(
                  '  Edit',
                  style: TextStyle(color: AppColors.blue, fontSize: 16.5),
                ),
              ),
        largeTitle: const Text('Voice Memos'));
  }

  Widget homeBody(BuildContext context) {

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: IgnorePointer(
            ignoring: isEditMode ? true : false,
            child: Container(
              padding: const EdgeInsets.only(left: 15, right: 15),
              foregroundDecoration: isEditMode
                  ? BoxDecoration(
                      color: Colors.black.withAlpha(40),
                      borderRadius: BorderRadius.circular(8))
                  : BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8)),
              decoration: BoxDecoration(
                  color: AppColors.lightBG,
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                            CupertinoPageRoute(builder: (BuildContext context) {
                          return AllRecordingsScreen(
                              tileName: allRecordingsStr);
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
                                isEditMode
                                    ? InkWell(
                                        onTap: () {
                                          setState(() {
                                            folder.delete();
                                            _folders.remove(folder.id);
                                          });
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.only(right: 15.0),
                                          child: Icon(
                                              CupertinoIcons.minus_circle_fill,
                                              color: AppColors.red),
                                        ),
                                      )
                                    : const Text(''),
                                AppIcons.folderBlue,
                                const Divider(endIndent: 10),
                                Text(folder.title,
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                            Row(
                              children: [
                                Visibility(
                                  visible: isVisible,
                                  child: Row(
                                    children: const [
                                      Text('0',
                                          style: TextStyle(
                                              color: CupertinoColors.systemGrey,
                                              fontSize: 16)),
                                      Divider(indent: 3),
                                      AppIcons.folderArrow
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: !isVisible,
                                  child: Row(
                                    children: [
                                      InkWell(
                                          child: AppIcons.folderMore,
                                          onTap: () {
                                            //STack this view...


                                            // showPopover(
                                            //     context: myContext as BuildContext,
                                            //     bodyBuilder: (myContext) {
                                            //       return const SizedBox(
                                            //         height: 50,
                                            //         width: 50,
                                            //       );
                                            //     });
                                          }),
                                      const Padding(
                                        padding:
                                            EdgeInsets.only(top: 8, bottom: 8),
                                        child: VerticalDivider(
                                          width: 15,
                                          thickness: 1.5,
                                        ),
                                      ),
                                      AppIcons.folderReorder
                                    ],
                                  ),
                                )
                              ],
                            )
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
