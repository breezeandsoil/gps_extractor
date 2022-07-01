import 'package:chassis_app/src/app/models/models_common_interface.dart';

class ModelExample_2 extends ModelMVC {
	static ModelExample_2? _this;

	factory ModelExample_2([StateMVC? state]) {
		return _this ??= ModelExample_2._(state);
	}

	ModelExample_2._(StateMVC? state) : super(state);

	/*** Data will be here.***/
	int _counter_msec = 0;
	int _counter_msec_sec = 0;
	int _counter_sec = 0;
	int _counter_rendering = 0;

	int get counter_msec => _counter_msec;
	int get counter_msec_sec => _counter_msec_sec;
	int get counter_sec => _counter_sec;
	int get counter_rendering => _counter_rendering;

	void increment_msec() {
		if (++_counter_msec == 1000) {
			_counter_msec = 0;
			_counter_msec_sec++;
		}
	}
	int increment_sec() => ++_counter_sec;
	int increment_rendering() => ++_counter_rendering; 
}
