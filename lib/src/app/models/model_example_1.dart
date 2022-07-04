import 'package:gps_extractor/src/app/models/models_common_interface.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

enum PositionItemType {
	log,
	position,
}

class PositionItem {
	PositionItem(this.type, this.displayValue);

	final PositionItemType type;
	final String displayValue;
}

class ModelExample_1 extends ModelMVC {
	// ? means '_this variable can be null'
	static ModelExample_1? _this;
	static const String kLocationServicesDisabledMessage = 'Location services are disabled.';
	static const String kPermissionDeniedMessage = 'Permission denied.';
	static const String kPermissionDeniedForeverMessage = 'Permission denied forever.';
	
	// [] means 'state argument is optional'
	// ??= means 'assign value to the variable on its left, only if that variable is null'
	factory ModelExample_1([StateMVC? state]) {
		return _this ??= ModelExample_1._(state);
	}

	// constructor
	ModelExample_1._(StateMVC? state) : super(state);

	StreamSubscription<Position>? _positionStreamSubscription;
	bool get isStreamInitialized => !(_positionStreamSubscription == null);
	set stream(StreamSubscription<Position>? stream) {
		if(stream != null) {
			_positionStreamSubscription = stream;
		} else {
			_positionStreamSubscription?.cancel();
			_positionStreamSubscription = null;
		}

		_positionStreamSubscription = (stream == null) ? null : stream;
	}
	
	final List<PositionItem> _positionItems = <PositionItem>[];
	
	int get positionItemsLength => _positionItems.length;
	void addPositionItem(PositionItem item) => _positionItems.add(item);
	void clearPositionItems() => _positionItems.clear();
	PositionItem getPositionItem(int index) {
		if (_positionItems.length == 0) {
			return PositionItem(PositionItemType.log, "list: empty");
		} else if ( index >= _positionItems.length) {
			return PositionItem(PositionItemType.log, "list: out of range");
		} else {
			return _positionItems[index];
		}
	}
}
