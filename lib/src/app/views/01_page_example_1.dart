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
				body: Center(
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: <Widget>[
							Text("[GPS]: ${_controller_example_1.gps}"),
							
							OutlinedButton(
								child: Text("Get Current GPS Position"),
								onPressed: () {
									_controller_example_1.getCurrentGPSPosition();
								}
							),

							OutlinedButton(
								child: Text("MQTT Send Message"),
								onPressed: () {
									app_mqtt_send_channels[MqttTopic.data_type_gps]?.sink.add(_controller_example_1.gps);
								}
							),
							
							/*
							ElevatedButton(
								child: Text("Go To Next Page"),
								onPressed: () {
									Navigator.pushNamed(context, PageExample2.pageName);
								}
							)
							*/
						]
					)
				)
			),
			onWillPop: () async {
				// when return false.
				// make System-UI disable.
				return false;
			}
			
		);
	}
}
