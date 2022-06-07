import 'package:flutter/material.dart';

class CustomExpansionTile extends StatefulWidget {
  const CustomExpansionTile(
      {Key? key,
      this.leading,
      required this.title,
      required this.subtitle,
      this.onExpansionChanged,
      this.trailing,
      this.initiallyExpanded = false,
      this.maintainState = false,
      required this.moreIcon,
      required this.recordDuration,
      required this.trailingIcon,
      required this.leadingIcon,
      required this.middleRow,
      required this.linearProgressIndicator,
      required this.editState,
      required this.selectiveIcon,
      required this.timerRow})
      : super(key: key);

  final Widget? leading;
  final Widget title;
  final Widget subtitle;
  final Widget recordDuration;
  final ValueChanged<bool>? onExpansionChanged;
  final Widget trailingIcon;
  final Widget leadingIcon;
  final Row middleRow;
  final Widget? trailing;
  final bool initiallyExpanded;
  final bool maintainState;
  final LinearProgressIndicator linearProgressIndicator;
  final Widget timerRow;
  final Widget moreIcon;
  final bool editState;
  final Widget selectiveIcon;

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = PageStorage.of(context)?.readState(context) as bool? ??
        widget.initiallyExpanded;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        InkWell(
          onTap: () {
            if (!widget.editState) {
              _handleTap();
            } else if (widget.editState == true) {
              _isExpanded = false;
              setState(() {});
            } else {
              _isExpanded = false;
              setState(() {});
            }
          },
          child: Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            child: Row(
              //First Row
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  widget.selectiveIcon,
                  Column(
                    //StartColumn
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.title,
                      const SizedBox(height: 6),
                      widget.subtitle
                    ],
                  ),
                ]),
                _isExpanded
                    ? widget.moreIcon
                    : Column(
                        //EndColumn
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            '',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 5),
                          widget.recordDuration
                        ],
                      ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            //Second SizedBox Padding
            padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
            child: SizedBox(
              child: Column(
                children: [
                  widget.linearProgressIndicator,
                  widget.timerRow,
                  Padding(
                    //Buttons Row Padding
                    padding: const EdgeInsets.only(top: 15, bottom: 20),
                    child: Row(
                      //Main Row
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.leadingIcon,
                        widget.middleRow,
                        widget.trailingIcon
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        else if (_isExpanded && widget.editState)
          const SizedBox()
        else
          const SizedBox()
      ],
    );
  }
}
