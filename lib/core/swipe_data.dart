// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/cupertino.dart';

import 'cell.dart';

class SwipeData extends InheritedWidget {
  final List<SwipeAction> actions;
  final double currentOffset;
  final bool fullDraggable;
  final Key parentKey;
  final bool firstActionWillCoverAllSpaceOnDeleting;
  final double contentWidth;
  final double contentHeight;
  final double totalActionWidth;
  final bool willPull;
  final SwipeActionCellState parentState;

  const SwipeData({
    required child,
    required this.actions,
    required this.contentHeight,
    required this.willPull,
    required this.currentOffset,
    required this.fullDraggable,
    required this.parentKey,
    required this.firstActionWillCoverAllSpaceOnDeleting,
    required this.contentWidth,
    required this.totalActionWidth,
    required this.parentState,
  }) : super(child: child);

  static SwipeData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType(aspect: SwipeData)!;
  }

  @override
  bool updateShouldNotify(SwipeData oldWidget) {
    return oldWidget.actions != actions ||
        oldWidget.currentOffset != currentOffset ||
        oldWidget.fullDraggable != fullDraggable ||
        oldWidget.parentKey != parentKey ||
        oldWidget.firstActionWillCoverAllSpaceOnDeleting !=
            firstActionWillCoverAllSpaceOnDeleting ||
        oldWidget.contentWidth != contentWidth ||
        oldWidget.totalActionWidth != totalActionWidth ||
        oldWidget.willPull != willPull ||
        oldWidget.contentHeight != contentHeight;
  }
}
