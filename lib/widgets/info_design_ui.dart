import 'package:flutter/material.dart';

class InfoDesignUIWidget extends StatefulWidget {
  String? textInfo;
  IconData? iconData;

  InfoDesignUIWidget({this.textInfo, this.iconData});

  @override
  State<InfoDesignUIWidget> createState() => _InfoDesignUIWidgetState();
}

class _InfoDesignUIWidgetState extends State<InfoDesignUIWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white54,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: ListTile(
        leading: Icon(widget.iconData, color: Colors.white),
        title: Text(widget.textInfo!, style: TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold
        ))
      )
    );
  }
}
