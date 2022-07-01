import 'package:flutter/material.dart';
import 'package:gps_extractor/src/app_data.dart';

class ErrorHandlingAlert extends StatelessWidget{
	final double content_height;

	Widget errorCode;
	Widget message;
	Widget button;	

	ErrorHandlingAlert({
		required this.content_height,
		required this.errorCode,
		required this.message,
		required this.button
	});

	static Future<void> popUpErrorMessage(BuildContext context, String errorCode, String message) async {
		await showDialog(
			context: context,
			barrierDismissible: false,
			builder: (BuildContext context) {
				final double alert_dialog_content_height_ratio = 0.1;
				final double alert_dialog_title_error_height_ratio = 0.03;
				final double alert_dialog_content_message_height_ratio = 0.02;
				final double alert_dialog_button_text_height_ratio = 0.02;

				return ErrorHandlingAlert(
					content_height: app_screen_height * alert_dialog_content_height_ratio,
					errorCode: Text(
						"ErrorCode: " + errorCode,
						style: TextStyle(
							color: Colors.black,
							fontSize: app_screen_height * alert_dialog_title_error_height_ratio
						)
					),
					message: Text(
						message,
						style: TextStyle(
							color: Colors.black,
							fontSize: app_screen_height * alert_dialog_content_message_height_ratio
						)
					),
					button: ElevatedButton(
						child: Text(
							"Confirm",
							style: TextStyle(
								color: Colors.white,
								fontSize: app_screen_height * alert_dialog_button_text_height_ratio,
							)
						),
						style: ElevatedButton.styleFrom(
							primary: Colors.blue
						),
						onPressed: () {
							Navigator.pop(context);
						}
					)
				);
			}
		);
	}

	@override
	Widget build(BuildContext context) {
		return AlertDialog(
			title: Align(
				alignment: Alignment.center,
				child: this.errorCode
			),
			content: Container(
				height: this.content_height,
				child: Column(
					mainAxisAlignment: MainAxisAlignment.spaceEvenly,
					children: <Widget> [
						this.message
					]
				)
			),
			actions: <Widget> [
				this.button
			]
		);
	}
}
