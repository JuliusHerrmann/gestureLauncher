import 'dart:typed_data';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class StorageClass{
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/selectedApps.txt');
  }

  Future<List> readSelectedApps() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

			var returnList = contents.split(",");

			return returnList;

    } catch (e) {
      // If encountering an error, return 0
      return new List();
    }
  }

  Future<File> writeApps (List apps) async {
    final file = await _localFile;

		String result = apps.join(",");
    // Write the file
    return file.writeAsString(result);
  }
}
