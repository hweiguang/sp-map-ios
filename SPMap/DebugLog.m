/*
 *  DebugLog.m
 *  DebugLog
 *
 *  Created by Karl Kraft on 3/22/09.
 *  Copyright 2009 Karl Kraft. All rights reserved.
 *
 */

#include "DebugLog.h"

void _DebugLog(NSString *format,...) {
  va_list ap;
	
  va_start (ap, format);
  if (![format hasSuffix: @"\n"]) {
    format = [format stringByAppendingString: @"\n"];
	}
	NSString *body =  [[NSString alloc] initWithFormat: format arguments: ap];
	va_end (ap);
	fprintf(stderr,"%s",[body UTF8String]);
	[body release];	
}

