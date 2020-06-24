import 'dart:typed_data';
import 'dart:async';
import 'dart:io';

import 'storage.dart';

import 'package:flutter/material.dart';
import 'package:launcher_assist/launcher_assist.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swipedetector/swipedetector.dart';

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
		return Expanded(
				child: Container(
						padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
						child: gridViewContainer(widget.installedApps, widget.selectedApps)
				)
		);
	}


	gridViewContainer(installedApps, selectedApps) {
		return GridView.count(
				crossAxisCount: 4,
				mainAxisSpacing: 10,
				crossAxisSpacing: 5,
				shrinkWrap: true,
				physics: BouncingScrollPhysics(),
				children: List.generate(
						installedApps != null ? installedApps.length : 0,
						(index) {
							return GridEntry(installedApps: installedApps, index: index, selectedApps: selectedApps);
						},
				),
		);
	}
}


class GridEntry extends StatefulWidget {
	GridEntry({
		Key key,
		@required this.installedApps,
		@required this.index,
		@required this.selectedApps,
		}) : super(key: key);

	var installedApps;
	var index;
	var selectedApps;

	@override
	_GridEntryState createState() => _GridEntryState();
}

class _GridEntryState extends State<GridEntry>{

	@override
	Widget build(BuildContext context) {
		return InkResponse(
				child: Container(
						padding: EdgeInsets.fromLTRB(5, 8, 5, 0),
						decoration: BoxDecoration(
								shape: BoxShape.rectangle,
								borderRadius: BorderRadius.circular(10.0),
								color: Colors.blue,
						),
						child: Column(
								children: [
									iconContainer(widget.index),
									Expanded(
											child: widget.selectedApps.indexOf(widget.installedApps[widget.index]["package"]) != -1  
											? Text(widget.selectedApps.indexOf(widget.installedApps[widget.index]["package"]).toString(),
													maxLines: 1,
													overflow: TextOverflow.ellipsis,
											)
											: Text("NotSelected",
													maxLines: 1,
													overflow: TextOverflow.ellipsis,
											),
									),
								],
						),
						),
						onTap: () {
							_asyncInputDialog(context).then((input) => act(input, widget.index));
						},
					);
	}

	void act(input, index){
		setState(() {
			if(input == -2){
				print(index.toString());
				print("ay");
				widget.selectedApps[widget.selectedApps.indexOf(widget.installedApps[index]["package"])] = "";
			}else if (input > -1 && input < 16){
				//delete old entry first

				if(widget.selectedApps.indexOf(widget.installedApps[widget.index]["package"]) != -1){
					widget.selectedApps [widget.selectedApps.indexOf(widget.installedApps[widget.index]["package"])] = "";
				}
				widget.selectedApps[input] = widget.installedApps[index]["package"];
			}
		});
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


	Future<int> _asyncInputDialog(BuildContext context) async {
		int input = 0;
		return showDialog<int>(
				context: context,
				barrierDismissible: false, // dialog is dismissible with a tap on the barrier
				builder: (BuildContext context) {
					return AlertDialog(
							title: Text('Enter a number'),
							content: new Row(
									children: <Widget>[
										new Expanded(
												child: new TextField(
														autofocus: true,
														decoration: new InputDecoration(
																labelText: 'Number', hintText: '0 to 15'),
														keyboardType: TextInputType.number,
														onChanged: (value) {
															input = int.parse(value);
														},
												))
									],
							),
							actions: <Widget>[
								FlatButton(
										child: Text('Ok'),
										onPressed: () {
											Navigator.of(context).pop(input);
										},
								),
								FlatButton(
										child: Text('cancel'),
										onPressed: () {
											Navigator.of(context).pop(-1);
										},
								),
								widget.selectedApps.indexOf(widget.installedApps[widget.index]["package"]) != -1
										?FlatButton(
												child: Text('unset'),
												onPressed: () {
													Navigator.of(context).pop(-2);
												},
										)
										: Container(),
										],
										);
				},
				);
	}
}
