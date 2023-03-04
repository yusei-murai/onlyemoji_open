import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class FunctionUtils {
  static Future<dynamic> getImageFromGallery() async {
    ImagePicker picker = ImagePicker();
    final pickerFile = await picker.pickImage(source: ImageSource.gallery);

    return pickerFile;
  }

  static Future<String> uploadImage(String uid,File image) async {
    final FirebaseStorage storageInstance = FirebaseStorage.instance;
    final Reference ref = storageInstance.ref();
    await ref.child(uid).putFile(image);
    String downloadUrl = await storageInstance.ref(uid).getDownloadURL();

    return downloadUrl;
  }

  static Future<void> openUri(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'リンクをひらけませんでした';
    }
  }
}