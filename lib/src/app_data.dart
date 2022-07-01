import 'dart:async';
import 'package:logger/logger.dart';

final String app_path_config = "assets/configs/app_config.json";

final Completer app_init_completer = Completer();

final Logger app_logger = Logger(
	filter: null,
	output: null,
	printer: PrettyPrinter(
		noBoxingByDefault: true,
		methodCount: 0
	),
	level: Level.debug
);

double app_screen_height = 0.0;
double app_screen_width = 0.0;

late final dynamic app_config;
late final dynamic app_mqtt_recv_ports;
late final dynamic app_mqtt_send_channels;
late final dynamic app_package_info;
