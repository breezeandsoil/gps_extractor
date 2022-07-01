import 'dart:isolate';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:stream_channel/isolate_channel.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:geolocator/geolocator.dart'; //!!
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; //!!
import 'package:package_info_plus/package_info_plus.dart';

import 'package:gps_extractor/src/modules/mqtt/mqtt_client.dart';
import 'package:gps_extractor/src/utils/debug/debug.dart';
import 'package:gps_extractor/src/widgets/alert_example.dart';
import 'package:gps_extractor/src/app_interface.dart';

/*** Insert variables / constants into below Dart Files  ***/
import 'package:gps_extractor/src/app_data.dart';
import 'package:gps_extractor/src/app_constant.dart';

/*************************
	MQTT Send Isolate
*************************/

// Packet Flow : Widget -> MQTT Handler	
void mqtt_send_handler(Map<String, dynamic> map) async {	
	app_logger.i(Printer.format(StackTrace.current, "mqtt_handler start!"));

	int mqtt_pong_counter = 0;
	Map<String, dynamic> config = map['config'];

	//emulator uses 10.0.2.2 for localhost
	//mqtt brocker uses 1883 for listen port..
	MqttClientHandler mqtt = MqttClientHandler(
		clientIdentifier: config['mqtt_broker']['send']['clientIdentifier'],
		host: config['mqtt_broker']['send']['host'],
		port: config['mqtt_broker']['send']['port'],
		timeout: config['mqtt_broker']['send']['timeout'],
		keepAlive: config['mqtt_broker']['send']['keepAlive'],
		logging: config['mqtt_broker']['send']['logging'],
		autoReconnect: config['mqtt_broker']['send']['autoReconnect'],

		onConnected: () {
			app_logger.d(Printer.format(StackTrace.current, 
				"onConnected - Client connection was successful"));
		},
		onDisconnected: () {
			app_logger.d(Printer.format(StackTrace.current, 
				"onDisconnected - Client disconnection"));
		},
		onSubscribed: (String topic) {
			app_logger.d(Printer.format(StackTrace.current,
				"Subscription confirmed for topic $topic"));
		},
		onUnsubscribed: (String? topic) {
			app_logger.d(Printer.format(StackTrace.current,
				"Subscription confirmed for topic $topic"));
		},
		onSubscribeFail: (String topic) {
			app_logger.d(Printer.format(StackTrace.current,
				"Subscription fail for topic $topic"));
		},
		pongCallback: () {
			mqtt_pong_counter++;
			app_logger.v(Printer.format(StackTrace.current,
				"Ping received : ${mqtt_pong_counter.toString()}"));
		}
	);

	try {
		await mqtt.connect(
			updates: (topic, message) async {	
				app_logger.i(Printer.format(StackTrace.current, 
					"Change notification: topic is <$topic>, payload is <$message>"));
				
				switch (topic) {
				case MqttTopic.ctrl_term_send:
					mqtt.unsubscribe(MqttTopic.ctrl_term_send);
					
					// Wait for the unsubscribe message from the broker if you wish.
					await Future.delayed(Duration(seconds: 3));
					mqtt.disconnect();
				
					app_logger.i(Printer.format(StackTrace.current, "terminate mqtt."));
					Isolate.current.kill();
					break;

				default:
					// Nothing to do
					break;
				
				}
			},

		published: (topic, qos) {
				app_logger.v(Printer.format(StackTrace.current,
					"Published notification: topic is ${topic}, with Qos ${qos}"));
			}
		);

	} on NoConnectionException catch (e) {
		app_logger.e(Printer.format(StackTrace.current, "client exception - $e"));
		// do something here
		rethrow;

	} on SocketException catch (e) {
		app_logger.e(Printer.format(StackTrace.current, "socket exception - $e"));
		// do something here
		rethrow;

	} catch (e) {
		app_logger.e(Printer.format(StackTrace.current, "unknown exception - $e"));
		// do something here
		rethrow;

	}

	mqtt.subscribe(MqttTopic.ctrl_term_send,  MqttQos.exactlyOnce);
	
	var channel_1 = IsolateChannel.connectSend(map[MqttTopic.data_type_gps]! as SendPort);

	channel_1.stream.listen((message) {

		mqtt.publish(MqttTopic.data_type_gps, message, MqttQos.atLeastOnce);

		app_logger.d(Printer.format(StackTrace.current, 
			"Published topic: ${MqttTopic.data_type_gps}, message: $message"));

	});

	/*
	var channel_2 = IsolateChannel.connectSend(map[MqttTopic.data_type_4]! as SendPort);

	channel_2.stream.listen((message) {

		mqtt.publish(MqttTopic.data_type_4, message, MqttQos.atLeastOnce);

		app_logger.d(Printer.format(StackTrace.current, 
			"Published topic: ${MqttTopic.data_type_4}, message: $message"));

	});
	*/
}

/*************************
	MQTT Receive Isolate
*************************/

// Packet Flow : MQTT Handler -> Widget
void mqtt_recv_handler(Map<String, dynamic> map) async {
	
	app_logger.i(Printer.format(StackTrace.current, "mqtt_handler start!"));
	
	int mqtt_pong_counter = 0;
	Map<String, dynamic> config = map['config'];
	
	//emulator uses 10.0.2.2 for localhost
	//mqtt brocker uses 1883 for listen port..
	MqttClientHandler mqtt = MqttClientHandler(
		clientIdentifier: config['mqtt_broker']['recv']['clientIdentifier'],
		host: config['mqtt_broker']['recv']['host'],
		port: config['mqtt_broker']['recv']['port'],
		timeout: config['mqtt_broker']['recv']['timeout'],
		keepAlive: config['mqtt_broker']['recv']['keepAlive'],
		logging: config['mqtt_broker']['recv']['logging'],
		autoReconnect: config['mqtt_broker']['recv']['autoReconnect'],

		onConnected: () {
			app_logger.d(Printer.format(StackTrace.current, 
				"onConnected - Client connection was successful"));
		},
		onDisconnected: () {
			app_logger.d(Printer.format(StackTrace.current, 
				"onDisconnected - Client disconnection"));
		},
		onSubscribed: (String topic) {
			app_logger.d(Printer.format(StackTrace.current,
				"Subscription confirmed for topic $topic"));
		},
		onUnsubscribed: (String? topic) {
			app_logger.d(Printer.format(StackTrace.current,
				"Subscription confirmed for topic $topic"));
		},
		onSubscribeFail: (String topic) {
			app_logger.d(Printer.format(StackTrace.current,
				"Subscription fail for topic $topic"));
		},
		pongCallback: () {
			mqtt_pong_counter++;
			app_logger.v(Printer.format(StackTrace.current,
				"Ping received : ${mqtt_pong_counter.toString()}"));
		}
	);

	try {
		await mqtt.connect(
			updates: (topic, message) async {	
				app_logger.i(Printer.format(StackTrace.current, 
					"Change notification: topic is <$topic>, payload is <$message>"));
				
				switch (topic) {
				case MqttTopic.ctrl_term_recv:
					mqtt.unsubscribe(MqttTopic.ctrl_term_recv);
					//mqtt.unsubscribe(MqttTopic.data_type_1);
					//mqtt.unsubscribe(MqttTopic.data_type_2);
					
					// Wait for the unsubscribe message from the broker if you wish.
					await Future.delayed(Duration(seconds: 3));
					mqtt.disconnect();
				
					app_logger.i(Printer.format(StackTrace.current, "terminate mqtt."));
					Isolate.current.kill();
					break;
				
				/*
				case MqttTopic.data_type_1:
					(map[MqttTopic.data_type_1]! as SendPort).send(message);
					break;
					
				case MqttTopic.data_type_2:
					(map[MqttTopic.data_type_2]! as SendPort).send(message);
					break;
				*/

				default:
					// Nothing to do
					break;
				
				}
			},

			published: (topic, qos) {
				app_logger.v(Printer.format(StackTrace.current,
					"Published notification: topic is ${topic}, with Qos ${qos}"));
			}
		);

	} on NoConnectionException catch (e) {
		app_logger.e(Printer.format(StackTrace.current, "client exception - $e"));
		// do something here
		rethrow;

	} on SocketException catch (e) {
		app_logger.e(Printer.format(StackTrace.current, "socket exception - $e"));
		// do something here
		rethrow;

	} catch (e) {
		app_logger.e(Printer.format(StackTrace.current, "unknown exception - $e"));
		// do something here
		rethrow;

	}
	
	// mqtt.subscribe(MqttTopic.data_type_1, MqttQos.atMostOnce);
	// mqtt.subscribe(MqttTopic.data_type_2, MqttQos.atMostOnce);
	mqtt.subscribe(MqttTopic.ctrl_term_recv,  MqttQos.exactlyOnce);
}



void main() async {
	
	WidgetsFlutterBinding.ensureInitialized();
	
	PackageInfo app_package_info = await PackageInfo.fromPlatform();
	app_logger.i(Printer.format(StackTrace.current, "======= Software name    : ${app_package_info.appName} ======="));
	app_logger.i(Printer.format(StackTrace.current, "======= Software version : ${app_package_info.version} ======="));


	// [1] Read and parse application configuration file.
	app_logger.i(Printer.format(StackTrace.current, "Parsing app config file : $app_path_config"));
	
	try {
		final json = await rootBundle.loadString(app_path_config);
		assert(json!=null);
		app_config = jsonDecode(json);
		
	} on FormatException catch(e) {
		(app_init_completer.isCompleted) ? null : app_init_completer.completeError(e); 

		runApp(MyApp());
		return;

	} catch (e) {
		(app_init_completer.isCompleted) ? null : app_init_completer.completeError(e); 
	
		runApp(MyApp());
		return;

	}

	// [2] Create Isolate for MQTT Client Handler (Recv).
	app_logger.i(Printer.format(StackTrace.current, "Create MQTT client handlers (recv)."));

	// "Ports" to communicate from MQTT Handler to Widgets.
	// Use ReceivePort.listen() function.
	// ReceivePort mqtt_recv_handler_port_1 = ReceivePort();
	// ReceivePort mqtt_recv_handler_port_2 = ReceivePort();

	// [2-2] "Ports" to handle child isolate error / exit case.
	ReceivePort mqtt_recv_handler_port_on_error = ReceivePort();
	ReceivePort mqtt_recv_handler_port_on_exit = ReceivePort();
	
	// when error occurred, forward error into flutter mobile app.
	mqtt_recv_handler_port_on_error.listen((data) async {
		List errors = data as List;
		(app_init_completer.isCompleted) ? null : app_init_completer.completeError(errors.first); 
	});

	// when exit occurred, close resources (ports)
	mqtt_recv_handler_port_on_exit.listen((data) {
		app_logger.i(Printer.format(StackTrace.current, "isolate exit with: $data => close resources."));

		// mqtt_recv_handler_port_1.close();
		// mqtt_recv_handler_port_2.close();
		mqtt_recv_handler_port_on_error.close();
		mqtt_recv_handler_port_on_exit.close();
	});

	Isolate.spawn(
		// callback to be invoked as isolate.
		mqtt_recv_handler,
		
		// Map<String, dynamic> to be passed as argument.
		{
			"config": app_config,
			// MqttTopic.data_type_1: mqtt_recv_handler_port_1.sendPort,
			// MqttTopic.data_type_2: mqtt_recv_handler_port_2.sendPort	
		},

		// ports to handle child isolate error / exit case.
		onExit: mqtt_recv_handler_port_on_exit.sendPort,
		onError: mqtt_recv_handler_port_on_error.sendPort
	);

	app_mqtt_recv_ports = <String, ReceivePort>{
		// MqttTopic.data_type_1: mqtt_recv_handler_port_1,
		// MqttTopic.data_type_2: mqtt_recv_handler_port_2,

		/* [EXAMPLE CODE]
			mqtt_recv_handler_port_1.listen((data){
				app_logger.i(Printer.format(StackTrace.current,	
					"recv data from child isolate: ${data}"));
			});

			mqtt_recv_handler_port_2.listen((data){
				app_logger.i(Printer.format(StackTrace.current,	
					"recv data from child isolate: ${data}"));
			});
		*/
	};

	// [3] Create Isolate for MQTT Client Handler (Send).
	app_logger.i(Printer.format(StackTrace.current, "Create MQTT client handlers (send)."));
	
	// "Port" to communicate from Widgets to MQTT Handler
	// Use channel.sink.add function.
	ReceivePort mqtt_send_handler_port_1 = ReceivePort();
	var channel_1 = IsolateChannel.connectReceive(mqtt_send_handler_port_1);
	
	// ReceivePort mqtt_send_handler_port_2 = ReceivePort();
	// var channel_2 = IsolateChannel.connectReceive(mqtt_send_handler_port_2);
	
	// "Ports" to handle child isolate error / exit case.
	ReceivePort mqtt_send_handler_port_on_error = ReceivePort();
	ReceivePort mqtt_send_handler_port_on_exit = ReceivePort();
	
	// when error occurred, forward error into flutter mobile app.
	mqtt_send_handler_port_on_error.listen((data) async {
		List errors = data as List;
		(app_init_completer.isCompleted) ? null : app_init_completer.completeError(errors.first); 
	});

	// when exit occurred, close resources (ports).
	mqtt_send_handler_port_on_exit.listen((data) {
		app_logger.i(Printer.format(StackTrace.current, "isolate exit with: $data => close resources."));	
		mqtt_send_handler_port_1.close();
		// mqtt_send_handler_port_2.close();
		mqtt_send_handler_port_on_error.close();
		mqtt_send_handler_port_on_exit.close();
	});

	Isolate.spawn(
		//callback to be invoked as isolate.
		mqtt_send_handler,	

		// Map<String, dynamic> to be passed as argument.
		{
			"config": app_config,
			MqttTopic.data_type_gps: mqtt_send_handler_port_1.sendPort,
			// MqttTopic.data_type_4: mqtt_send_handler_port_2.sendPort
		},

		// ports to handle child isolate error / exit case.
		onExit: mqtt_send_handler_port_on_exit.sendPort,
		onError: mqtt_send_handler_port_on_error.sendPort
	);

	app_mqtt_send_channels =  <String, IsolateChannel>{
		MqttTopic.data_type_gps: channel_1,
		// MqttTopic.data_type_4: channel_2

		/* [EXAMPLE CODE]
			channel_1.stream.listen((data) {
				app_logger.i(Printer.format(StackTrace.current,
					"recv data from child isolate: ${data}"));
			});
			
			channel_1.sink.add("send data from main-isolate");
			
			channel_2.stream.listen((data) {
				app_logger.i(Printer.format(StackTrace.current,
					"recv data from child isolate: ${data}"));
			});
			
			channel_2.sink.add("send data from main-isolate");
		*/
	};

	// [4] launch flutter app.
	app_logger.i(Printer.format(StackTrace.current, "Launching Flutter App."));

	Future.delayed(
		Duration(seconds: app_config['init_proc']['timeout']),
		() => (app_init_completer.isCompleted) ? null : app_init_completer.complete()
	);
	
	runApp(MyApp());
}

