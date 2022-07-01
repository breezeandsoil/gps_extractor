class MqttTopic {
	/***** subscribe common topics to control mqtt handler *****/
	static const String ctrl_term_send = "ctrl/term/send";
	static const String ctrl_term_recv = "ctrl/term/recv";
	// somethig newly here.

	/***** subscribe topics to receive data for mobile *****/
	//static const String data_type_1 = "data/type/1";
	//static const String data_type_2 = "data/type/2";
	// someting newly here.

	/***** publish topics to send data from mobile *****/
	static const String data_type_gps = "data/type/gps";
	// something newly here.

}

