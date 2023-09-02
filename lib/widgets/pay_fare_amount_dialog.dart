import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


// ignore: must_be_immutable
class PayFareAmountDialog extends StatefulWidget {
  double? totalFareAmount;

  PayFareAmountDialog({this.totalFareAmount});

  @override
  _PayFareAmountDialogState createState() => _PayFareAmountDialogState();
}

class _PayFareAmountDialogState extends State<PayFareAmountDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: Colors.transparent,
      child: Container(
          margin: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(6)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Text(
                "Pay Driver ".toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Divider(thickness: 4, color: Colors.grey),
              const SizedBox(height: 16),
              Text(widget.totalFareAmount.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 30)),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    "Total Fare Amount",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 30),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.lightBlue),
                    onPressed: (){
                      Future.delayed(const Duration(milliseconds: 2000), (){
                        Navigator.pop(context, "cashPayed");
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Pay Cash",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                        ), Icon(Icons.arrow_forward, color: Colors.white, size: 20)
                      ],
                    )
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
      ),
    );
  }
}
