import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/trip_history_model.dart';

class HistoryUIWidget extends StatefulWidget {
  TripHistoryModel tripHistoryModel;

  HistoryUIWidget({required this.tripHistoryModel});

  @override
  State<HistoryUIWidget> createState() => _HistoryUIWidgetState();
}

class _HistoryUIWidgetState extends State<HistoryUIWidget> {
  String formatDateAndTime(int epochTimestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epochTimestamp);
    String formattedDate = "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";
    return formattedDate;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver name and Fare Amount
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(
                      "Driver: ${widget.tripHistoryModel.driverName!}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "₦ " + widget.tripHistoryModel.fareAmount!,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold
                    ),
                  ),
                ]
            ),

            const SizedBox(height: 2,),

            // Car details
            Row(
                children: [
                  Icon(Icons.car_repair, color: Colors.white ),
                  const SizedBox(width: 12),
                  Text(
                    widget.tripHistoryModel.carDetails!,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1
                    ),
                  ),
                ]
            ),

            const SizedBox(height: 10,),

            // Icon + PickUp
            Row(
              children: [
                Image.asset("images/origin.png", height: 20, width: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                      child: Text(
                          widget.tripHistoryModel.originAddress!,
                          overflow:TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16)
                      )
                  ),
                )
              ],
            ),

            const SizedBox(height: 8),

            // Icon + PickUp
            Row(
              children: [
                Image.asset("images/destination.png", height: 20, width: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    child: Text(
                        widget.tripHistoryModel.destinationAddress!,
                        overflow:TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16)
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 10,),

            // Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(""),
                Text(
                  formatDateAndTime(widget.tripHistoryModel.time!),
                  style: TextStyle(fontSize:14, color: Colors.black38),
                ),
              ],
            ),

            const SizedBox(height: 2,)
          ],
        ),
      ),
    );
  }
}
