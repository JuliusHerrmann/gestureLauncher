// Copyright 2017 Ashraff Hathibelagal.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:async';
import 'dart:io';

import 'storage.dart';
import 'ForegroundWidget.dart';

import 'package:flutter/material.dart';
import 'package:launcher_assist/launcher_assist.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swipedetector/swipedetector.dart';

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
	var selectedApps = new List(16);
	var storage = StorageClass();
	

	@override
	Widget build(BuildContext context) {
		return new MaterialApp(
		home: Scaffold(
						body:	WillPopScope(
						onWillPop: () => Future(() => false),
						child: SwipeDetector(
									child: Stack(
											children: <Widget>[
												GestureDetector(
													child: WallpaperContainer(wallpaper: wallpaper),
													onLongPress: (){setState(() {
																showGrid = !showGrid;
															});}
												),
												Visibility(
														visible: showGrid,
														child: ForegroundWidget(installedApps: installedApps, selectedApps: selectedApps),
														),
												Column(
														children: [
															RaisedButton(
																	child: Text("show Grid"),
																	onPressed: (){
																	setState(() {
																		showGrid = !showGrid;
																		//save data to disk
																		storage.writeApps(selectedApps);
																	});},
																	),
															RaisedButton(
																	child: Text("reset apps"),
																	onPressed: (){
																	setState(() {
																		storage.writeApps(new List(16));
																		selectedApps = new List(16);
																	});},
														),
														],
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
								verticalSwipeMaxWidthThreshold: 300.0,
								horizontalSwipeMaxHeightThreshold: 300.0,
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

			storage.readSelectedApps().then((List apps){
				selectedApps = apps;
				print(apps.toString());
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
