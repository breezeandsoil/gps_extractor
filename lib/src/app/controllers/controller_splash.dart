import 'package:gps_extractor/src/app/controllers/controllers_common_interface.dart';
import 'package:gps_extractor/src/app/app_models_interface.dart';

class ControllerSplash extends ControllerMVC {

	static 	ControllerSplash? _this;

	factory ControllerSplash(ModelMVC model, [StateMVC? state]) {
		return _this ??= ControllerSplash._(model, state);
	}

	ControllerSplash._(ModelMVC model, StateMVC? state) : _model = model, super(state);
	
	final ModelMVC _model;

	String get message => (_model as ModelSplash).message;

	void update(int tick) {
		var model = _model as ModelSplash;
		model.message_ext = ((tick % 4) == 0 ) ? ("") : (model.message_ext + ".");
		setState((){
			model.message = model.message_base + model.message_ext;	
		});
	}
}

