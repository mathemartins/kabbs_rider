import 'package:flutter/material.dart';
import 'package:kabbs_universal_rider/assistants/request_assistant.dart';
import 'package:kabbs_universal_rider/global/map_key.dart';
import 'package:kabbs_universal_rider/models/predicted_places.dart';
import 'package:kabbs_universal_rider/widgets/place_prediction_tile.dart';

class SearchPlacesScreen extends StatefulWidget {
  @override
  _SearchPlacesScreenState createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  List<PredictedPlaces> placesPredictedList = [];
  void findPlaceAutoCompleteSearch(String inputText) async {
    if(inputText.length > 1) {
      String urlAutoCompleteSearch = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:NG";
      var responseAutoCompleteSearch = await RequestAssistant.receiveRequest(urlAutoCompleteSearch);
      if(responseAutoCompleteSearch == "Error Occurred, Failed. No Response.") {
        return;
      }
      if(responseAutoCompleteSearch["status"] == "OK") {
        var placePredictions = responseAutoCompleteSearch["predictions"];
        var placePredictionsList = (placePredictions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();
        setState(() {
          placesPredictedList = placePredictionsList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          //search place ui
          Container(
            height: 200,
            decoration: const BoxDecoration(
              color: Colors.black54,
              boxShadow:
              [
                BoxShadow(
                  color: Colors.blueGrey,
                  blurRadius: 8,
                  spreadRadius: 0.5,
                  offset: Offset(
                    0.7,
                    0.7,
                  ),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [

                  const SizedBox(height: 40),

                  Stack(
                    children: [

                      GestureDetector(
                        onTap: ()
                        {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.blueGrey,
                        ),
                      ),

                      const Center(
                        child: Text(
                          "Search ",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16.0),

                  Row(
                    children: [

                      const Icon(
                        Icons.adjust_sharp,
                        color: Colors.grey,
                      ),

                      const SizedBox(width: 18.0,),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: (valueTyped)
                            {
                              findPlaceAutoCompleteSearch(valueTyped);
                            },
                            decoration: const InputDecoration(
                              hintText: "Search Destination Location",
                              fillColor: Colors.white54,
                              filled: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                left: 11.0,
                                top: 8.0,
                                bottom: 8.0,
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),

          //display place predictions result
          (placesPredictedList.length > 0)
              ? Expanded(
            child: ListView.separated(
              itemCount: placesPredictedList.length,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index)
              {
                return PlacePredictionTileDesign(
                  predictedPlaces: placesPredictedList[index],
                );
              },
              separatorBuilder: (BuildContext context, int index)
              {
                return const Divider(
                  height: 1,
                  color: Colors.white,
                  thickness: 1,
                );
              },
            ),
          )
              : Container(),
        ],
      ),
    );
  }
}
