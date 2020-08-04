import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class CrudExample extends StatefulWidget {
  @override
  _CrudExampleState createState() => _CrudExampleState();
}

class _CrudExampleState extends State<CrudExample> {
  final Firestore _firestore = Firestore.instance;
  String screenMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firestore Learning"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text(
                  "Add data",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blue,
                onPressed: _addData,
              ),
              RaisedButton(
                child: Text(
                  "Read data",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.indigo,
                onPressed: _readData,
              ),
              RaisedButton(
                child: Text(
                  "Update data",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.green,
                onPressed: _updateData,
              ),
              RaisedButton(
                child: Text(
                  "Delete data",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.red,
                onPressed: _deleteData,
              ),
              RaisedButton(
                child: Text(
                  "Start stream",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.deepPurple,
                onPressed: _startStream,
              ),
              RaisedButton(
                child: Text(
                  "Add new message (Stream)",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.amber,
                onPressed: _newStreamMessage,
              ),
              Text("$screenMessage"),
            ],
          ),
        ),
      ),
    );
  }

  void _addData() {
    Map<String, dynamic> msgData = Map();
    msgData['msgID'] = 1;
    msgData['msg'] = "I'm a data.";

    _firestore
        .collection('example_collection')
        .document('example_document')
        .setData(msgData)
        .then((value) {
      setState(() {
        screenMessage += "\nData added.";
      });
    }).catchError((e) {
      setState(() {
        screenMessage += "\nError: $e";
      });
    });
  }

  Future<void> _readData() async {
    DocumentReference docRef = _firestore.document('example_collection/example_document');
    docRef.get().then((DocumentSnapshot documentSnapshot) {
      setState(() {
        screenMessage +=
            "\nID: ${documentSnapshot.data['msgID']} Message: ${documentSnapshot.data['msg']}";
      });
    }).catchError((e) {
      setState(() {
        screenMessage += "\nError: $e";
      });
    });

    // then() metodu yerine veriler DocumentSnapshot nesnesine aktarılabilir.
    // Ancak bu sefer başına asenkron çalıştığını belirtmek gerekir.
    // Tüm datayı forEach() ile ele alabiliriz:
    DocumentSnapshot snapshot = await docRef.get();
    snapshot.data.forEach((key, value) {
      debugPrint("$key: $value");
    });

    // DocumentSnapshot nesnesi üzerinden de veri hakkında bilgi sahibi olabiliriz:
    debugPrint("Data exists: ${snapshot.exists.toString()}");
    debugPrint("Pending write: ${snapshot.metadata.hasPendingWrites}");
    debugPrint("From cache: ${snapshot.metadata.isFromCache}");

    // Çoklu döküman okunabilir:
    _firestore.collection("example_collection").getDocuments().then((querySnapshots) {
      debugPrint("Total docs in example_collection: ${querySnapshots.documents.length}");

      // Döküman içeriği döngü ile yazdırılabilir:
      for (int i = 0; i <= querySnapshots.documents.length; i++) {
        debugPrint("${querySnapshots.documents[i].data}");
      }
    }).catchError((e) {
      setState(() {
        screenMessage += "\nError: $e";
      });
    });
  }

  void _updateData() {
    //updateData() var olmayan yeni bir veriyi de ekleyebilir.
    //setData()'ın merge attribute'u true geçilirse üstüne eklemeye yeni mapler verilerek veriler eklenebilir.

    Map<String, dynamic> newData = Map();
    newData['msgID'] = FieldValue.increment(1);
    newData['msg'] = "I'm a new data.";
    newData['date'] = FieldValue.serverTimestamp();

    DocumentReference docRef = _firestore.document('example_collection/example_document');
    docRef.updateData(newData).then((value) {
      setState(() {
        screenMessage += "\nData updated.";
      });
    }).catchError((e) {
      setState(() {
        screenMessage += "\nError: $e";
      });
    });
  }

  void _deleteData() {
    DocumentReference docRef = _firestore.document('example_collection/example_document');
    docRef.delete().then((value) {
      setState(() {
        screenMessage += "\nData deleted.";
      });
    }).catchError((e) {
      setState(() {
        screenMessage += "\nError: $e";
      });
    });
  }

  void _startStream() {
    // Stream ile dinleme yapılabilir: Konsola dikkat edin:
    CollectionReference colRef = _firestore.collection("messages");
    colRef.snapshots().listen((event) {
      debugPrint("${event.documents.length}");
    });
  }

  void _newStreamMessage() {
    CollectionReference collectionReference = _firestore.collection("messages");

    var rng = new Random();

    String messageID = collectionReference.document().documentID;

    Map<String, dynamic> messageMap = Map();
    messageMap['msgID'] = messageID;
    messageMap['msg'] = "It's a random numbers: ${rng.nextInt(50)}";

    collectionReference
        .document(messageID)
        .setData(messageMap)
        .then((value) => debugPrint("Message added"))
        .catchError((e) {
      setState(() {
        screenMessage += "\nError: $e";
      });
    });
  }
}
