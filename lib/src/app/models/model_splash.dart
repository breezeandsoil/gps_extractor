import 'package:gps_extractor/src/app/models/models_common_interface.dart';

class ModelSplash extends ModelMVC {
	static ModelSplash? _this;

	factory ModelSplash([StateMVC? state]) {
		return _this ??= ModelSplash._(state);
	}

	ModelSplash._(StateMVC? state) : super(state);

	final String message_base = "App Loading";
	String message_ext = "";
	String message = "";	
}
