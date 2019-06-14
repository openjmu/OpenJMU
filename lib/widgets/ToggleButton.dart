import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';


class ToggleButton extends StatefulWidget {
    final Widget activeWidget;
    final Widget unActiveWidget;
    final ValueChanged<bool> activeChanged;
    bool active;
    ToggleButton({
        this.activeWidget,
        this.unActiveWidget,
        this.activeChanged,
        this.active: false,
    });
    @override
    _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {

    @override
    Widget build(BuildContext context) {
        return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
                setState(() {
                    widget.active = !widget.active;
                    widget.activeChanged?.call(widget.active);
                });
            },
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(10.0), vertical: Constants.suSetSp(10.0)),
                child: widget.active ? widget.activeWidget : widget.unActiveWidget,
            ),
        );
    }
}
