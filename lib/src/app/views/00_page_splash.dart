import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:gps_extractor/src/app/views/views_common_interface.dart';
import 'package:gps_extractor/src/app/app_models_interface.dart';
import 'package:gps_extractor/src/app/app_views_interface.dart';
import 'package:gps_extractor/src/app/app_controllers_interface.dart';
import 'package:gps_extractor/src/widgets/alert_example.dart';

class PageSplash extends StatefulWidget {
	static final String pageName = "PageSplash";
	
	final double appbar_height_ratio;

	PageSplash({
		Key? key, 
		this.appbar_height_ratio = 0.1,
	}) : super(key: key);

	@override
	State createState() => _PageSplashState();
}

class _PageSplashState extends StateMVC<PageSplash> {
	late ControllerSplash _controller_splash;
	late Timer _timer;
	
	void app_init_process(BuildContext context) {
			
		app_screen_height = MediaQuery.of(context).size.height;
		app_screen_width = MediaQuery.of(context).size.width;

		// If the first catchError call happens after this future has completed with an error,
		// then the error is reported as unhandled error. => ignore message.
		app_init_completer.future.then(
			//  (_) => app_logger.i(Printer.format(StackTrace.current, "MQTT Connection Success!!")), 
			(_) => Navigator.pushReplacementNamed(context, PageExample1.pageName),
			onError: (e) async {
				app_logger.e(Printer.format(StackTrace.current, "${e.toString()}"));
				List<String> token = e.toString().split(": ");
				String error_type = token.first;
				switch (error_type) {
				case "FormatException":
					await ErrorHandlingAlert.popUpErrorMessage(context, "-1", "config file format error.");
					break;
			
				case "NoConectionException":
					await ErrorHandlingAlert.popUpErrorMessage(context, "-2", "client fails to connect");
					break;
				
				case "SocketException":
					await ErrorHandlingAlert.popUpErrorMessage(context, "-3", "no available broker.");
					break;
				
				default:
					await ErrorHandlingAlert.popUpErrorMessage(context, "-999", "unknown error.");
					break;
				}

				exit(-1);

			}
		);
	}

	@override
	void initState() {
		super.initState();

		//*** something code here. ***/
		app_logger.v(Printer.format(StackTrace.current, "initState is called."));
		
		// Link with the StateMVC.
		// So, ControllerMVC.setState((){}); will work.
		_controller_splash = ControllerSplash(ModelSplash(this), this);
		add(_controller_splash);
		
		_timer = Timer.periodic(Duration(seconds:1), (Timer timer) {
			_controller_splash.update(timer.tick);		
		});
		
		Future.delayed(Duration.zero, () => this.app_init_process(context));
	}

	@override
	void dispose() {
		//*** something code here. ***/
		app_logger.v(Printer.format(StackTrace.current, "dispose is called."));
		_timer.cancel();	
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
							'PageSplash',
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
							Text(
								_controller_splash.message	
							),
							Text(
								app_screen_height.toString()
							),
							Text(
								app_screen_width.toString()
							)
						]
					)
				)	
			),
			onWillPop: () async {
				return false;
			}
		);
	}
}
