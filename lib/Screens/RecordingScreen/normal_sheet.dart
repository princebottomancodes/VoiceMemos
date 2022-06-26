// ignore_for_file: constant_identifier_na
import 'dart:io';
import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voicememos/constants/paths.dart';
import '../../Utils/app_colors.dart';

class NormalSheet extends StatefulWidget {
  final Function onSaved;
  const NormalSheet({Key? key, required this.onSaved}) : super(key: key);

  @override
  State<NormalSheet> createState() => _NormalSheetState();
}

class _NormalSheetState extends State<NormalSheet> {
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;

  @override
  void initState() {
    super.initState();

    initRecorder();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            color: AppColors.lightBG,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13), topRight: Radius.circular(13))),
        child: Center(
            child: Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black45, width: 2),
              borderRadius: const BorderRadius.all(Radius.circular(30))),
          height: 60,
          width: 60,
          child: AnimatedIconButton(
            padding: EdgeInsets.zero,
            icons: [
              AnimatedIconItem(
                backgroundColor: Colors.red.shade400,
                icon: Icon(Icons.circle, color: Colors.red.shade400, size: 50),
                onPressed: () async {
                  await startRecording();
                  setState(() {});
                },
              ),
              AnimatedIconItem(
                icon: Icon(Icons.square_rounded, color: Colors.red.shade400),
                onPressed: () async {
                  await stopRecording();
                  setState(() {});
                },
              ),
            ],
          ),
        )));
  }

  initRecorder() async {
    final status = await Permission.microphone.request();
    await Permission.storage.request();

    if (status != PermissionStatus.granted) {
      throw 'Microphone Permission not granted';
    }

    //
    await recorder.openRecorder();
    isRecorderReady = true;
  }

  startRecording() async {
    if (!isRecorderReady) return;

    Directory appFolder = Directory(Paths.recording);

    bool appFolderExists = await appFolder.exists();
    if (!appFolderExists) {
      final create = await appFolder.create(recursive: true);
      debugPrint(create.path);
    }

    String filePath =
        '${Paths.recording}/${DateTime.now().millisecondsSinceEpoch}.aac';

    await recorder.startRecorder(toFile: filePath, codec: Codec.aacADTS);
  }

  stopRecording() async {
    await recorder.stopRecorder();
    widget.onSaved();
  }
}
