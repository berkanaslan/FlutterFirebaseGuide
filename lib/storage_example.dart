import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageExample extends StatefulWidget {
  @override
  _StorageExampleState createState() => _StorageExampleState();
}

class _StorageExampleState extends State<StorageExample> {
  final Firestore _firestore = Firestore.instance;
  File _image;
  final picker = ImagePicker();

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
                  "Upload from Gallery",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blue,
                onPressed: _uploadFromGallery,
              ),
              RaisedButton(
                child: Text(
                  "Upload from Camera",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.indigo,
                onPressed: _uploadFromCamera,
              ),
              Center(
                child: _image == null ? Text("Image not found.") : Image.file(_image),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _uploadFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });

    StorageReference storageReference =
        FirebaseStorage.instance.ref().child("users_images").child("user1");
    StorageUploadTask storageUploadTask = await storageReference.putFile(_image);

    String imgUrl =
        await (await storageUploadTask.onComplete).ref.getDownloadURL();
    debugPrint("Upload done. Link: $imgUrl");
  }

  void _uploadFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      _image = File(pickedFile.path);
    });

    StorageReference storageReference =
        FirebaseStorage.instance.ref().child("users_images").child("user2");
    StorageUploadTask storageUploadTask = storageReference.putFile(_image);

    String imgUrl =
        await (await storageUploadTask.onComplete).ref.getDownloadURL();
    debugPrint("Upload done. Link: $imgUrl");
  }
}
