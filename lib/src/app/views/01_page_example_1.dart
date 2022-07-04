import 'package:gps_extractor/src/app/views/views_common_interface.dart';
import 'package:gps_extractor/src/app/app_models_interface.dart';
import 'package:gps_extractor/src/app/app_views_interface.dart';
import 'package:gps_extractor/src/app/app_controllers_interface.dart';
import 'package:gps_extractor/src/app_constant.dart';

class PageExample1 extends StatefulWidget {
	static final String pageName = "PageExamle1";
	
	final double appbar_height_ratio;

	PageExample1({
		Key? key, 
		this.appbar_height_ratio = 0.1,
	}) : super(key: key);

	@override
	State createState() => _PageExample1State();
}

class _PageExample1State extends StateMVC<PageExample1> {
	late ControllerExample_1 _controller_example_1;

	@override
	void initState() {
		super.initState();

		//*** something code here. ***/
		app_logger.v(Printer.format(StackTrace.current, "initState is called."));
		
		// Link with the StateMVC.
		// So, ControllerMVC.setState((){}); will work.
		_controller_example_1 = ControllerExample_1(ModelExample_1(this), this);

		add(_controller_example_1);
	
		/*
		app_mqtt_recv_ports[MqttTopic.data_type_1]?.listen((data) {
			app_logger.i(Printer.format(StackTrace.current, "recv data : $data"));
			_controller_example_1.setMessage(data);
		});
		*/
	}

	@override
	void dispose() {
		//*** something code here. ***/
		app_logger.v(Printer.format(StackTrace.current, "dispose is called."));
		
		
		
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {

		return WillPopScope(
			child: Scaffold(
				appBar: PreferredSize(
					preferredSize: Size.fromHeight(app_screen_height * widget.appbar_height_ratio),
					child: AppBar(
						backgroundColor: Colors.white,
						title: Text(
							'PageExample1',
							style: TextStyle(
								color: 	Colors.black
							)
						),
					)
				),
			
				body : ListView.builder(
					itemCount: _controller_example_1.positionItemLength,
					itemBuilder: (context, index) {
						final positionItem = _controller_example_1.getPositionItem(
							_controller_example_1.positionItemLength - index - 1);

						if (positionItem.type == PositionItemType.log) {
							return ListTile(
								title: Text(positionItem.displayValue,
									textAlign: TextAlign.center,
									style: const TextStyle(
										color: Colors.black,
										fontWeight: FontWeight.bold
									)
								)
							);
						} else {
							return Card(
								child: ListTile(
									title: Text(
										positionItem.displayValue,
										style: const TextStyle(
											color: Colors.black
										)
									)
								)
							);
						}
					}
				),

				floatingActionButton: Column(
					crossAxisAlignment: CrossAxisAlignment.end,
					mainAxisAlignment: MainAxisAlignment.end,
					children: [
						FloatingActionButton(
							child: (_controller_example_1.isStreamInitialized) 
								? const Icon(Icons.pause)
								: const Icon(Icons.play_arrow),
							heroTag: "GPS Stream",
							onPressed: () {
								_controller_example_1.toggleListening();
							},
							tooltip: (_controller_example_1.isStreamInitialized) ? "Stop" : "Start",
							backgroundColor: (_controller_example_1.isStreamInitialized) ? Colors.green : Colors.red
						),
		
						FloatingActionButton(
							child: const Icon(Icons.my_location),
							heroTag: "Current GPS",
							onPressed: () {
								_controller_example_1.getCurrentGPSPosition();
							},
							tooltip: "Current GPS"
						),

						FloatingActionButton(
							child: const Icon(Icons.cleaning_services),
							heroTag: "Clear Screen",
							onPressed: () {
								_controller_example_1.clearPositionItems();
							},
							tooltip: "Clear Screen"
						),



					],
				)

				/*
				body: Center(
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: <Widget>[
							ElevatedButton(
								child: Text("Go To Next Page"),
								onPressed: () {
									Navigator.pushNamed(context, PageExample2.pageName);
								}
							)
						
						]
					)
				)
				*/
			),
			onWillPop: () async {
				// when return false.
				// make System-UI disable.
				return false;
			}
			
		);
	}
}
