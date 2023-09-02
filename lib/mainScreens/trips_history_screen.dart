import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kabbs_universal_rider/infoHandler/app_info.dart';
import 'package:kabbs_universal_rider/widgets/history_design_ui.dart';
import 'package:provider/provider.dart';

class TripsHistoryScreen extends StatefulWidget {

  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Trip History"),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => SystemNavigator.pop())),
      body: ListView.separated(
              separatorBuilder: (context, i) => const Divider(color: Colors.grey, thickness: 2, height: 2),
              itemBuilder: (context, i){
                return HistoryUIWidget(
                  tripHistoryModel: Provider.of<AppInfo>(context, listen: false).allTripHistoryInformationList[i]
                );
              },
              itemCount: Provider.of<AppInfo>(context, listen: false).allTripHistoryInformationList.length,
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true
      ),
      
    );
  }
}
