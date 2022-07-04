import 'package:gps_extractor/src/app/controllers/controllers_common_interface.dart';
import 'package:gps_extractor/src/app/app_models_interface.dart';
import 'package:gps_extractor/src/app_data.dart';
import 'package:gps_extractor/src/app_constant.dart';

import 'package:geolocator/geolocator.dart';

class ControllerExample_1 extends ControllerMVC {

	static 	ControllerExample_1? _this;

	factory ControllerExample_1( ModelMVC model, [StateMVC? state]) {
		return _this ??= ControllerExample_1._(model, state);
	}

	ControllerExample_1._(ModelMVC model, StateMVC? state) : _model = model, super(state);

	final ModelMVC _model;

	final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

	// Note, the counter comes from a separate class, ModelExample_1.
	// The Controller know how to 'talk to' the Model and to the View (interface).
	// Call the State, (a.k.a View) object's setState() function to reflect the change.
	
	bool get isStreamInitialized => (_model as ModelExample_1).isStreamInitialized;
	int get positionItemLength => (_model as ModelExample_1).positionItemsLength;
	
	PositionItem getPositionItem(int index) => (_model as ModelExample_1).getPositionItem(index);

	void _updatePositionList(PositionItemType type, String displayValue) {
		(_model as ModelExample_1).addPositionItem(PositionItem(type, displayValue));
		setState((){});
	}

	void clearPositionItems() {
		(_model as ModelExample_1).clearPositionItems();	
		setState((){});
	}

	void toggleListening() {
		ModelExample_1 model = _model as ModelExample_1;
	
		if (!model.isStreamInitialized) {
			model.stream = _geolocatorPlatform.getPositionStream().handleError((error) {
				model.stream = null;	
			}).listen((gpsPosition) {
				_updatePositionList(PositionItemType.position, gpsPosition.toString());
				app_mqtt_send_channels[MqttTopic.data_type_gps]?.sink.add(gpsPosition.toString());
			});
			
			_updatePositionList(PositionItemType.log, "Listening Start");
		} else {
			model.stream = null;
			_updatePositionList(PositionItemType.log, "Listening Stopped");
		}
	}

	Future<void> getCurrentGPSPosition() async {
		ModelExample_1 model = _model as ModelExample_1;

		var serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
		if (!serviceEnabled) {
			_updatePositionList(PositionItemType.log, ModelExample_1.kLocationServicesDisabledMessage);
			return;
		}

		var permission = await _geolocatorPlatform.checkPermission();
		if (permission == LocationPermission.denied) {
			permission = await _geolocatorPlatform.requestPermission();
			if (permission == LocationPermission.denied) {
				// Permissions are denied, next time you could try
				// requesting permissions again (this is also where
				// Android's shouldShowRequestPermissionRationale
				// returned true. According to Android guidelines
				// your App should show an explanatory UI now.

				_updatePositionList(PositionItemType.log, ModelExample_1.kPermissionDeniedMessage);
    	    	return;
			}
    	}
    
		if (permission == LocationPermission.deniedForever) {
			// Permissions are denied forever, handle appropriately.
   
			_updatePositionList(PositionItemType.log, ModelExample_1.kPermissionDeniedForeverMessage);
			return;
		}

		var gpsPosition = await _geolocatorPlatform.getCurrentPosition();
  
		_updatePositionList(PositionItemType.position, gpsPosition.toString());

		app_mqtt_send_channels[MqttTopic.data_type_gps]?.sink.add(gpsPosition.toString());
	}
}
