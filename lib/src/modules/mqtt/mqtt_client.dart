import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:gps_extractor/src/utils/debug/debug.dart';
import 'package:gps_extractor/src/app_data.dart';

class MqttClientHandler {
	final String _will_topic = 'will';
	final String _will_message = 'My Will Message';
	final MqttQos _will_qos = MqttQos.atLeastOnce;

	final String _host;
	final String _clientIdentifier;
	
	final int _timeout;
	final int _port;
	final int _keepAlive;

	final bool _logging;
	final bool _autoReconnect;

	final Map<String, Subscription> _subscriptions;
	MqttServerClient? _mqtt_client;

	DisconnectCallback? onDisconnected;
	ConnectCallback? onConnected;
	PongCallback? pongCallback;
	SubscribeCallback? onSubscribed;
	SubscribeFailCallback? onSubscribeFail;
	UnsubscribeCallback? onUnsubscribed;
	AutoReconnectCallback? onAutoReconnect;
	AutoReconnectCompleteCallback? onAutoReconnected;
	bool Function(X509Certificate)? onBadCertificate;

	MqttClientHandler({
		String? clientIdentifier,	
		String host = '10.0.2.2',
		int port = 1883,
		int timeout = 5,
		int keepAlive = 20,
		bool logging = false,
		bool autoReconnect = false,
		this.onDisconnected,
		this.onConnected,
		this.onSubscribed,
		this.onSubscribeFail,
		this.onUnsubscribed,
		this.onAutoReconnect,
		this.onAutoReconnected,
		this.onBadCertificate,
		this.pongCallback

	}) :  _clientIdentifier = clientIdentifier ?? 'flutter-client-' + Random().nextInt(100).toString()
		, _subscriptions = Map()
		, _timeout = timeout
		, _keepAlive = keepAlive
		, _host = host
		, _port = port
		, _logging = logging
		, _autoReconnect = autoReconnect
	{		
		this._mqtt_client = MqttServerClient.withPort(
			this._host,
			this._clientIdentifier,
			this._port
		);
		
		this._mqtt_client!.logging(on: this._logging);
		
		//this._mqtt_client.setProtocolV31(); //V3.1 (default)
		this._mqtt_client!.setProtocolV311();  //V3.1.1

		this._mqtt_client!.autoReconnect = this._autoReconnect;

		this._mqtt_client!.keepAlivePeriod = this._keepAlive;

		this._mqtt_client!.connectionMessage = MqttConnectMessage()
			.withClientIdentifier(this._clientIdentifier)
			.withWillTopic(this._will_topic)
			.withWillMessage(this._will_message)
			.withWillQos(this._will_qos)
			.startClean();
	
		this._mqtt_client!.onDisconnected = this.onDisconnected;	
		this._mqtt_client!.onConnected = this.onConnected;
		this._mqtt_client!.pongCallback = this.pongCallback;
		this._mqtt_client!.onSubscribed = this.onSubscribed;
		this._mqtt_client!.onSubscribeFail = this.onSubscribeFail;
		this._mqtt_client!.onUnsubscribed = this.onUnsubscribed;
		this._mqtt_client!.onAutoReconnect = this.onAutoReconnect;
		this._mqtt_client!.onAutoReconnected = this.onAutoReconnected;
		this._mqtt_client!.onBadCertificate = this.onBadCertificate;	
	
		app_logger.i(Printer.format(StackTrace.current, " (${Isolate.current.debugName}) -- clientIdentifier: ${_clientIdentifier}"));	
		app_logger.i(Printer.format(StackTrace.current, " (${Isolate.current.debugName}) -- host            : ${_host}"));	
		app_logger.i(Printer.format(StackTrace.current, " (${Isolate.current.debugName}) -- port            : ${_port.toString()}"));	
		app_logger.i(Printer.format(StackTrace.current, " (${Isolate.current.debugName}) -- timeout         : ${_timeout.toString()}"));	
		app_logger.i(Printer.format(StackTrace.current, " (${Isolate.current.debugName}) -- keepAlive       : ${_keepAlive.toString()}"));	
		app_logger.i(Printer.format(StackTrace.current, " (${Isolate.current.debugName}) -- logging         : ${_logging.toString()}"));	
		app_logger.i(Printer.format(StackTrace.current, " (${Isolate.current.debugName}) -- autoReconnect   : ${_autoReconnect.toString()}"));	
	}

	connect({Function(String, String)? updates, Function(String?, MqttQos?)? published}) async {
		try {
			await this._mqtt_client!.connect().timeout(
				Duration(seconds: this._timeout),
				onTimeout: () {
					throw TimeoutException("Mqtt Broker Connection Timeout: ${_timeout}");
				}
			);
		
			if (this._mqtt_client!.connectionStatus!.state != MqttConnectionState.connected) {	
				throw Exception("${this._mqtt_client!.connectionStatus}");
			}

		} on NoConnectionException catch (e) {
			this._mqtt_client!.disconnect();
			rethrow;
		
		} on SocketException catch (e) {
			this._mqtt_client!.disconnect();
			rethrow;

		} on TimeoutException catch (e) {
			this._mqtt_client!.disconnect();
			rethrow;
	
		} catch (e) {
			this._mqtt_client!.disconnect();
			rethrow;
		}
		
		//The stream on which all subscribed topic updates are published to
		this._mqtt_client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
			final receivePayload = c![0].payload as MqttPublishMessage;	
			final topic = c[0].topic as String;
			final message = MqttPublishPayload.bytesToStringAsString(receivePayload.payload.message);
			
			updates?.call(topic, message);
		});

		//Published message stream.
		//A publish message is added to this stream
		//on completion of the message publishing protocol for a Qos level.
		this._mqtt_client!.published!.listen((MqttPublishMessage message) {
			published?.call(message.variableHeader!.topicName, message.header!.qos);
		});

		app_logger.i(Printer.format(StackTrace.current, " (${Isolate.current.debugName}) -- Mosquitto client connected"));
	}

	subscribe(String topic, MqttQos qos) {
		if (! this._subscriptions.containsKey(topic)) {
			var subscription = this._mqtt_client!.subscribe(topic, qos);
			this._subscriptions[topic] = subscription!;
			app_logger.i(Printer.format(StackTrace.current, " (${Isolate.current.debugName}) -- Subscribe to the topic: ${topic} with Qos: ${qos}"));
		}
	}

	unsubscribe(String topic) {
		if ( this._subscriptions.containsKey(topic)) {
			this._subscriptions.remove(topic);
			this._mqtt_client!.unsubscribe(topic);
			app_logger.i(Printer.format(StackTrace.current, " (${Isolate.current.debugName}) -- Unsubscribe to the topic: ${topic}"));
		}
	}

	disconnect() {
		this._subscriptions.forEach((String topic, Subscription value){
			this._mqtt_client!.unsubscribe(topic);
		});
		this._subscriptions.clear();
		this._mqtt_client!.disconnect();
		app_logger.i(Printer.format(StackTrace.current, " (${Isolate.current.debugName}) -- Disconnect"));
	}

	publish(String topic, String message, MqttQos qos) {
		//encoding
		var builder = MqttClientPayloadBuilder();
		builder.addString(message);

		//publish
		this._mqtt_client!.publishMessage(topic, qos, builder.payload!);
	}
}
