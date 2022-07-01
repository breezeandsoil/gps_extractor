import 'package:gps_extractor/src/app/models/models_common_interface.dart';

class ModelExample_1 extends ModelMVC {
	// ? means '_this variable can be null'
	static ModelExample_1? _this;

	// [] means 'state argument is optional'
	// ??= means 'assign value to the variable on its left, only if that variable is null'
	factory ModelExample_1([StateMVC? state]) {
		return _this ??= ModelExample_1._(state);
	}

	// constructor
	ModelExample_1._(StateMVC? state) : super(state);

	static const String kLocationServicesDisabledMessage = 'Location services are disabled.';
	static const String kPermissionDeniedMessage = 'Permission denied.';
	static const String kPermissionDeniedForeverMessage = 'Permission denied forever.';

	String _message = "initial_data";
	String get message => _message;
	void setMessage(String message) => _message = message;
}
