import 'package:chassis_app/src/app/views/views_common_interface.dart';
import 'package:chassis_app/src/app/app_models_interface.dart';
import 'package:chassis_app/src/app/app_views_interface.dart';
import 'package:chassis_app/src/app/app_controllers_interface.dart';

class PageExample2 extends StatefulWidget {
	static final String pageName = "PageExample2";
	
	final double appbar_height_ratio;

	PageExample2({
		Key? key, 
		this.appbar_height_ratio = 0.1,
	}) : super(key: key);

	@override
	State createState() => _PageExample2State();
}

class _PageExample2State extends StateMVC<PageExample2> {
	late ControllerExample_2 _controller;
	late Timer _timer_msec;
	late Timer _timer_sec;

	@override
	void initState() {
		super.initState();

		//*** something code here. ***/
		app_logger.v(Printer.format(StackTrace.current, "initState is called."));
		
		// Link with the StateMVC.
		// So, ControllerMVC.setState((){}); will work.
		_controller = ControllerExample_2(ModelExample_2(this), this);
		add(_controller);

		_timer_msec = Timer.periodic(Duration(milliseconds:1), (Timer timer) {
			_controller.increment_msec();
		
			//for each 100msec, update rendering.
			if (timer.tick % 100 == 0) {
				_controller.updateView();
			}
			
		});

		_timer_sec = Timer.periodic(Duration(seconds:1), (Timer timer) {
			_controller.increment_sec();	
		});
	}

	@override
	void dispose() {
		//*** something code here. ***/
		app_logger.v(Printer.format(StackTrace.current, "dispose is called."));
	
		_timer_msec.cancel();
		_timer_sec.cancel();
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
							'PageExample2',
							style: TextStyle(
								color: Colors.black
							)	
						),
						actions: <Widget>[
							ElevatedButton(
								child: Text('Pop'),
								onPressed: () {
									Navigator.pop(context);
								}
							)
						]
					)
				),
				body: FractionallySizedBox(
					alignment: Alignment.topCenter,
					widthFactor: 1.0,
					child: Container(
						color: Colors.green,
						child: Column(
							mainAxisAlignment: MainAxisAlignment.spaceEvenly,
							children: <Widget> [
								Text (
									"view update count: ${_controller.rendering}"
								),
								Text (
									"msec             : ${_controller.msec}"
								),
								Text (
									"msec->sec        : ${_controller.msec_sec}"
								),
								Text (
									"sec              : ${_controller.sec}"
								)
							]
						)
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

