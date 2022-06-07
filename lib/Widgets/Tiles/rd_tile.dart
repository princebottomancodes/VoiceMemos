import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../Utils/app_icons.dart';

class RecentlyDeletedTile extends StatelessWidget {
  final String tileTitle;
  const RecentlyDeletedTile({Key? key, required this.tileTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                AppIcons.delete,
                const Divider(endIndent: 10),
                Text(tileTitle, style: const TextStyle(fontSize: 16)),
              ],
            ),
            Row(
              children: const [
                Text('0',
                    style: TextStyle(
                        color: CupertinoColors.systemGrey, fontSize: 16)),
                Divider(indent: 5),
                AppIcons.folderArrow
              ],
            )
          ],
        ));
  }
}
