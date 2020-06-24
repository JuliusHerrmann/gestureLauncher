// Copyright 2017 Ashraff Hathibelagal.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:launcher_assist/launcher_assist.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
	@override
	_MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
	var numberOfInstalledApps;
	var installedApps;
	var wallpaper;
	var fistSwipe = "null";
	var indexToOpen = 0;
	var showGrid = false;
	var selectedApps = new List();

	@override
	Widget build(BuildContext context) {
		return new MaterialApp(
		home: Scaffold(
						body:	WillPopScope(
						onWillPop: () => Future(() => false),
						child: SwipeDetector(
									child: Stack(
											children: <Widget>[
												WallpaperContainer(wallpaper: wallpaper),
												Visibility(
														visible: showGrid,
														child: ForegroundWidget(installedApps: installedApps, selectedApps: selectedApps),
														),
												RaisedButton(
														child: Text("show Grid"),
														onPressed: (){
														setState(() {
															showGrid = !showGrid;
															//save data to disk
														});},
														),
											],
											),
							onSwipeLeft: (){
									setState(() {
										print("swipe left detected");
										if (fistSwipe == "null"){
											fistSwipe = "left";
											indexToOpen += 0;
										}else{
											fistSwipe = "null";
											indexToOpen += 0;
											if(selectedApps.length - 1 >= indexToOpen){
												LauncherAssist.launchApp(selectedApps[indexToOpen]);
											}else{
												print("Not set $indexToOpen");
											}
											indexToOpen = 0;
										}
									});
							},
							onSwipeUp: (){
								print(indexToOpen);
									setState(() {
										if (fistSwipe == "null"){
											fistSwipe = "up";
											indexToOpen += 4;
										}else{
											fistSwipe = "null";
											indexToOpen += 1;
											if(selectedApps.length - 1 >= indexToOpen){
												LauncherAssist.launchApp(selectedApps[indexToOpen]);
											}else{
												print("Not set $indexToOpen");
											}
											indexToOpen = 0;
										}
									});
							},
							onSwipeRight: (){
									setState(() {
										if (fistSwipe == "null"){
											fistSwipe = "right";
											indexToOpen += 8;
										}else{
											fistSwipe = "null";
											indexToOpen += 2;
											if(selectedApps.length - 1 >= indexToOpen){
												LauncherAssist.launchApp(selectedApps[indexToOpen]);
											}else{
												print("Not set $indexToOpen");
											}
											indexToOpen = 0;
										}
									});
							},
							onSwipeDown: (){
									setState(() {
										if (fistSwipe == "null"){
											fistSwipe = "down";
											indexToOpen += 12;
										}else{
											fistSwipe = "null";
											indexToOpen += 3;
											if(selectedApps.length - 1 >= indexToOpen){
												LauncherAssist.launchApp(selectedApps[indexToOpen]);
											}else{
												print("Not set $indexToOpen");
											}
											indexToOpen = 0;
										}
									});
							},
							swipeConfiguration: SwipeConfiguration(
								verticalSwipeMinVelocity: 10.0,
								verticalSwipeMinDisplacement: 10.0,
								verticalSwipeMaxWidthThreshold: 100.0,
								horizontalSwipeMaxHeightThreshold: 100.0,
								horizontalSwipeMinDisplacement:10.0,
								horizontalSwipeMinVelocity: 10.0
								),
							),
						),
					),
				);
	}

	@override
	initState() {
		super.initState();

		requestPermission(Permission.storage);

		// Get all apps
		LauncherAssist.getAllApps().then((apps) {
			setState(() {
				numberOfInstalledApps = apps.length;
				installedApps = apps;
			});
		});

		// Get wallpaper as binary data
		LauncherAssist.getWallpaper().then((imageData) {
			setState(() {
				wallpaper = imageData;
			});
		});
	}

	Future<void> requestPermission(Permission permission) async {
		final status = await permission.request();

		setState(() {
			print(status);
		});
	}
}


class ForegroundWidget extends StatefulWidget {
  const ForegroundWidget({
    Key key,
    @required this.installedApps,
    @required this.selectedApps,
  }) : super(key: key);

  final installedApps;
	final selectedApps;

  @override
  _ForegroundWidgetState createState() => _ForegroundWidgetState();
}

class _ForegroundWidgetState extends State<ForegroundWidget>{

  @override
  Widget build(BuildContext context) {
      return Container(
        padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
        //child: gridViewContainer(widget.installedApps),
				child: gridViewContainer(widget.installedApps, widget.selectedApps)
      );
  }


  gridViewContainer(installedApps, selectedApps) {
    return GridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: 40,
      physics: BouncingScrollPhysics(),
      children: List.generate(
        installedApps != null ? installedApps.length : 0,
			(index) {
				//return GestureDetector(
						return GridEntry(isSelected: false, installedApps: installedApps, index: index, selectedApps: selectedApps);
					//child: Container(
						//child: Column(
							//mainAxisSize: MainAxisSize.min,
							//children: <Widget>[
								//iconContainer(index),
								//SizedBox(height: 10),
								//Text(
									//installedApps[index]["label"],
									//style: TextStyle(
										//color: Colors.white,
									//),
									//textAlign: TextAlign.center,
									//maxLines: 1,
									//overflow: TextOverflow.ellipsis,
								//),
							//],
						//),
					//),
				//
					//onTap: () {
						//setState(() {
								//selectedApps[0] = index;
								//print("$index was selected");
						//});
					//}
				//);
			},
      ),
    );
  }


  iconContainer(index) {
    try {
      return Image.memory(
        widget.installedApps[index]["icon"] != null
            ? widget.installedApps[index]["icon"]
            : Uint8List(0),
        height: 50,
        width: 50,
      );
    } catch (e) {
      return Container();
    }
  }
}

class WallpaperContainer extends StatelessWidget{
	const WallpaperContainer({
		Key key,
		@required this.wallpaper,
	}) : super (key: key);

 	final wallpaper;

	@override
	Widget build(BuildContext context){
		return Container(
				color: Colors.black,
				height: MediaQuery.of(context).size.height,
				width: MediaQuery.of(context).size.width,
				child: Image.memory(
					wallpaper != null
						? wallpaper
						: Uint8List(0),
						fit: BoxFit.cover,
						)
				);
	}
}

class GridEntry extends StatefulWidget {
  GridEntry({
    Key key,
    @required this.isSelected,
		@required this.installedApps,
		@required this.index,
		@required this.selectedApps,
  }) : super(key: key);

	var installedApps;
	var isSelected = false;
	var index;
	var selectedApps;

  @override
  _GridEntryState createState() => _GridEntryState();
}

class _GridEntryState extends State<GridEntry>{

  @override
  Widget build(BuildContext context) {
      return Container(
					child: GestureDetector(
						child: Column(
								children: [
									iconContainer(widget.index),
									widget.selectedApps.indexOf(widget.installedApps[widget.index]["package"]) != -1  ? Text(widget.selectedApps.indexOf(widget.installedApps[widget.index]["package"]).toString()) : Text("NotSelected"),
								],
								),
					
					onTap: () {
						setState(() {
								widget.selectedApps.add(widget.installedApps[widget.index]["package"]);
								print(widget.index.toString());
						});
					}
				),
      );
  }

  iconContainer(index) {
    try {
      return Image.memory(
        widget.installedApps[index]["icon"] != null
            ? widget.installedApps[index]["icon"]
            : Uint8List(0),
        height: 50,
        width: 50,
      );
    } catch (e) {
      return Container();
    }
  }
}
