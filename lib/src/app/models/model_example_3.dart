import 'package:chassis_app/src/app/models/models_common_interface.dart';

class ModelExample_3 extends ModelMVC {
	static ModelExample_3? _this;

	factory ModelExample_3([StateMVC? state]) {
		return _this ??= ModelExample_3._(state);
	}

	ModelExample_3._(StateMVC? state) : super(state);

	/*** Data will be here.***/
}
