/*
 *  DebugLog.h
 *  DebugLog
 *
 *  Created by Karl Kraft on 3/22/09.
 *  Copyright 2009 Karl Kraft. All rights reserved.
 *
 */

#ifdef DEBUG

#define DebugLog(args...) _DebugLog(args);

#else

#define DebugLog(x...)

#endif

void _DebugLog(NSString *format,...);
