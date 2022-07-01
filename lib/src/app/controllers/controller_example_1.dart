import 'package:gps_extractor/src/app/controllers/controllers_common_interface.dart';
import 'package:gps_extractor/src/app/app_models_interface.dart';
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
	String get gps => (_model as ModelExample_1).message;

	// The Controller know how to 'talk to' the Model and to the View (interface).
	
	// Call the State, a.k.a View) object's setState() function to reflect the change.
	
	void getCurrentGPSPosition() async {
		ModelExample_1 model = _model as ModelExample_1;

		var serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
		if (!serviceEnabled) {
			setState((){
				model.setMessage(ModelExample_1.kLocationServicesDisabledMessage);
			});
			
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

				setState((){
					model.setMessage(ModelExample_1.kPermissionDeniedMessage);
				});

    	    	return;
			}
    	}
    
		if (permission == LocationPermission.deniedForever) {
			// Permissions are denied forever, handle appropriately.
   
			setState((){
				model.setMessage(ModelExample_1.kPermissionDeniedForeverMessage);
			});

			return;
		}

		var gpsPosition = await _geolocatorPlatform.getCurrentPosition();
   
		setState((){
			model.setMessage(gpsPosition.toString());	
		});
	}
}
