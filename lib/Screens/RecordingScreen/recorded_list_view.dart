import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voicememos/Utils/app_icons.dart';
import 'package:voicememos/Model/custom_expansion_tile.dart';
import '../../Utils/app_colors.dart';

class RecordListView extends StatefulWidget {
  final List<String> records;
  final bool editState;
  const RecordListView({
    Key? key,
    required this.editState,
    required this.records,
  }) : super(key: key);

  @override
  _RecordListViewState createState() => _RecordListViewState();
}

class _RecordListViewState extends State<RecordListView> {
  late int _totalDuration;
  late int _currentDuration;
  double _completedPercentage = 0.0;
  bool _isPlaying = false;
  int _selectedIndex = -1;
  bool isTapped = false;
  bool isVisible = true;
  bool isPlaying = false;
  List<int> selectedItems = [];
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemCount: widget.records.length,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        separatorBuilder: (context, index) => const Divider(height: 0),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              if (!selectedItems.contains(index)) {
                setState(() {
                  selectedItems.add(index);
                });
              } else if (selectedItems.contains(index)) {
                setState(() {
                  selectedItems.removeWhere((value) => value == index);
                });
              }
            },
            child: CustomExpansionTile(
              editState: widget.editState,
              selectiveIcon: Visibility(
                visible: widget.editState,
                child: Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: !selectedItems.contains(index)
                      ? const Icon(CupertinoIcons.circle, color: AppColors.grey)
                      : const Icon(CupertinoIcons.check_mark_circled_solid,
                          color: AppColors.blue),
                ),
              ),
              title: Text('New Recording ${widget.records.length - index}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              subtitle: Text(_getDateFromFilePath(
                  filePath: widget.records.elementAt(index))),
              recordDuration: const Text('00:00'),
              moreIcon: InkWell(
                  onTap: () {
                    //TODO: Show More Modal Bottom Sheet
                  },
                  child: const Icon(
                    CupertinoIcons.ellipsis_circle,
                    color: CupertinoColors.systemBlue,
                  )),
              linearProgressIndicator: LinearProgressIndicator(
                minHeight: 5,
                backgroundColor: Colors.black,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
                value: _selectedIndex == index ? _completedPercentage : 0,
              ),
              timerRow: Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [Text('00:00'), Text('00:00')],
                ),
              ),
              leadingIcon: InkWell(onTap: () {}, child: AppIcons.adjustIcon),
              middleRow: Row(
                  //Three Buttons Row
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AppIcons.prev,
                    Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 15),
                        child: AnimatedIconButton(
                            padding: EdgeInsets.zero,
                            icons: [
                              AnimatedIconItem(
                                  icon: AppIcons.play,
                                  onPressed: () {
                                    onPlay(
                                        filePath:
                                            widget.records.elementAt(index),
                                        index: index);
                                  }),
                              AnimatedIconItem(
                                  icon: AppIcons.pause,
                                  onPressed: () {
                                    onPause();
                                  }),
                            ])),
                    AppIcons.forward
                  ]),
              trailingIcon: InkWell(onTap: () {}, child: AppIcons.delete),
            ),
          );
        });
  }

  onPause() {
    if (!_isPlaying) {
      audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  Future<void> onPlay({required String filePath, required int index}) async {
    audioPlayer.play(filePath, isLocal: true);
    setState(() {
      _selectedIndex = index;
      _completedPercentage = 0.0;
      _isPlaying = true;
    });

    audioPlayer.onPlayerCompletion.listen((_) {
      setState(() {
        _isPlaying = false;
        _completedPercentage = 0.0;
      });
    });

    audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration.inMicroseconds;
      });
    });

    audioPlayer.onAudioPositionChanged.listen((duration) {
      setState(() {
        _currentDuration = duration.inMicroseconds;
        _completedPercentage =
            _currentDuration.toDouble() / _totalDuration.toDouble();
      });
    });
  }

  String _getDateFromFilePath({required String filePath}) {
    String fileDate = filePath.substring(
        filePath.lastIndexOf('/') + 1, filePath.lastIndexOf('.'));
    DateTime recordedDate =
        DateTime.fromMillisecondsSinceEpoch(int.parse(fileDate));
    String fullDate =
        DateFormat().addPattern('yyyy/MM/dd').format(recordedDate);
    String dayDate = DateFormat().add_EEEE().format(recordedDate);

    final today = DateTime.utc(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    int difference = recordedDate.difference(today).inDays;

    String recordDate() {
      if (difference == 0) {
        return 'Today';
      } else if (difference == -1) {
        return 'Yesterday';
      } else {
        if (difference == -2 ||
            difference == -3 ||
            difference == -4 ||
            difference == -5 ||
            difference == -6) {
          return dayDate;
        }
        return fullDate;
      }
    }

    return recordDate();
  }
}
