import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionExample extends StatefulWidget {
  @override
  _TransactionExampleState createState() => _TransactionExampleState();
}

class _TransactionExampleState extends State<TransactionExample> {
  final Firestore _firestore = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firestore Learning"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text(
                "Add users data",
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.blue,
              onPressed: _addData,
            ),
            RaisedButton(
              child: Text(
                "Send money",
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.green,
              onPressed: _moneyTransaction,
            ),
            RaisedButton(
              child: Text(
                "Reset user funds",
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.pink,
              onPressed: _resetFunds,
            )
          ],
        ),
      ),
    );
  }

  void _addData() {
    String docID = _firestore.collection('users').document().documentID;

    Map<String, dynamic> firstUser = Map();
    firstUser['id'] = docID;
    firstUser['name'] = "Berkan";
    firstUser['surname'] = "ASLAN";
    firstUser['total_funds'] = 500;

    _firestore
        .document('users/$docID')
        .setData(firstUser)
        .then((value) => debugPrint("First user has been added."));

    docID = _firestore.collection('users').document().documentID;

    Map<String, dynamic> secondUser = Map();
    secondUser['id'] = docID;
    secondUser['name'] = "John";
    secondUser['surname'] = "Doe";
    secondUser['total_funds'] = 250;

    _firestore
        .document('users/$docID')
        .setData(secondUser)
        .then((value) => debugPrint("Second user has been added."));
  }

  void _moneyTransaction() {
    final DocumentReference userRef = _firestore.document('users/BWL3yKhGwMadc65Uwa6t');
    final DocumentReference receiverRef =
        _firestore.document('users/xkwu1MRyw26KbilHBH13');
    _firestore.runTransaction((transaction) async {
      DocumentSnapshot userData = await userRef.get();

      if (userData.exists) {
        var userTotalFunds = userData.data['total_funds'];
        if (userTotalFunds >= 100) {
          await transaction.update(userRef, {'total_funds': (userTotalFunds - 100)});
          DocumentSnapshot receiverData = await receiverRef.get();
          if (receiverData.exists) {
            await transaction
                .update(receiverRef, {'total_funds': FieldValue.increment(100)});
          } else {
            debugPrint("Receiver user is not found.");
          }
        } else {
          debugPrint("Insufficient funds.");
        }
      } else {
        debugPrint("User is not found.");
      }
    });
  }

  void _resetFunds() {
    _firestore
        .document('users/BWL3yKhGwMadc65Uwa6t')
        .updateData({'total_funds': 500}).then(
            (value) => debugPrint("First users's funds has been reset."));

    _firestore
        .document('users/xkwu1MRyw26KbilHBH13')
        .updateData({'total_funds': 250}).then(
            (value) => debugPrint("Second users's funds has been reset."));
  }
}
