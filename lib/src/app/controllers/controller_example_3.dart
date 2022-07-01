import 'package:chassis_app/src/app/controllers/controllers_common_interface.dart';
import 'package:chassis_app/src/app/app_models_interface.dart';

class ControllerExample_3 extends ControllerMVC {

	static 	ControllerExample_3? _this;

	factory ControllerExample_3(ModelMVC model, [StateMVC? state]) {
		return _this ??= ControllerExample_3._(model, state);
	}

	ControllerExample_3._(ModelMVC model, StateMVC? state) : _model = model, super(state);
	
	final ModelMVC _model;
}
