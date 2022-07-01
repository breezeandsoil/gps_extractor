import 'package:chassis_app/src/app/controllers/controllers_common_interface.dart';
import 'package:chassis_app/src/app/app_models_interface.dart';

class ControllerExample_2 extends ControllerMVC {

	static 	ControllerExample_2? _this;

	factory ControllerExample_2(ModelMVC model, [StateMVC? state]) {
		return _this ??= ControllerExample_2._(model, state);
	}

	ControllerExample_2._(ModelMVC model, StateMVC? state) : _model = model, super(state);
	
	final ModelMVC _model;

	int get msec => (_model as ModelExample_2).counter_msec;
	int get msec_sec => (_model as ModelExample_2).counter_msec_sec;
	int get sec => (_model as ModelExample_2).counter_sec;
	int get rendering => (_model as ModelExample_2).counter_rendering;
	
	void increment_msec() => (_model as ModelExample_2).increment_msec();
	
	void increment_sec() => (_model as ModelExample_2).increment_sec();
	
	void updateView() => setState(() => (_model as ModelExample_2).increment_rendering() );
}
