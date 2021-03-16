/*
 *  IOMobileFramebuffer.h
 *  iPhoneVNCServer
 *
 *  Created by Steven Troughton-Smith on 25/08/2008.
 *  Copyright 2008 Steven Troughton-Smith. All rights reserved.
 *
 *  Disassembly work by Zodttd
 *
 */

#import "IOTypes.h"
#import "IOKitLib.h"
#import <UIKit/UIKit.h>

#include <stdio.h> // For mprotect
#include <sys/mman.h>


#define kIOMobileFramebufferError 0xE0000000

typedef kern_return_t IOMobileFramebufferReturn;
typedef io_service_t IOMobileFramebufferService;
typedef io_connect_t IOMobileFramebufferConnection;








//IOMobileFramebufferReturn
//IOMobileFramebufferGetID(
//						 IOMobileFramebufferService *connect,
//						 CFTypeID *id );

/*
 IOMobileFramebufferGetDisplaySize(io_connect_t connect, CGSize *t);
 */
