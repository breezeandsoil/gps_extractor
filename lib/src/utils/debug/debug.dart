import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';
import 'package:sprintf/sprintf.dart';

class StackTraceParser {
	static Tuple3<String, String, String> parse(StackTrace trace) {
		List<StackFrame> frames = StackFrame.fromStackTrace(trace);
		StackFrame top_frame = frames[0];
		return Tuple3<String, String, String>(top_frame.className, top_frame.method, top_frame.packagePath);
	}	
}

class Printer {
	static String format(StackTrace trace, String log, {bool path_use = false}) {
		Tuple3<String, String, String> tuple = StackTraceParser.parse(trace);
		String class_name = tuple.item1;
		String func_name = tuple.item2;
		String path = tuple.item3;
		String chunk = ((class_name == "") ? func_name : class_name + ":" + func_name); 
		return (path_use) ? sprintf("file>> %s\n[%s] %s", [path, chunk, log]) 
				: sprintf("[%s] %s", [chunk, log]);
	}
}
