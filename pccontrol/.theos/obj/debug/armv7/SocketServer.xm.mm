#line 1 "SocketServer.xm"
#include "SocketServer.h"
#include "Task.h"

CFSocketRef socketRef;
CFWriteStreamRef writeStreamRef;
CFReadStreamRef readStreamRef;

void socketServer()
{
    @autoreleasepool {
		
        
        
        
        
        
        
        CFSocketRef _socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, TCPServerAcceptCallBack, NULL);
        
        if (_socket == NULL) {
            NSLog(@"### com.zjx.springboard: failed to create socket.");
            return;
        }
        
        UInt32 reused = 1;
        
        
        setsockopt(CFSocketGetNative(_socket), SOL_SOCKET, SO_REUSEADDR, (const void *)&reused, sizeof(reused));
        
        
        struct sockaddr_in Socketaddr;
        memset(&Socketaddr, 0, sizeof(Socketaddr));
        Socketaddr.sin_len = sizeof(Socketaddr);
        Socketaddr.sin_family = AF_INET;
        
        
        Socketaddr.sin_addr.s_addr = inet_addr(ADDR);
        
        Socketaddr.sin_port = htons(PORT);
        
        
        CFDataRef address = CFDataCreate(kCFAllocatorDefault,  (UInt8 *)&Socketaddr, sizeof(Socketaddr));
        
        
        if (CFSocketSetAddress(_socket, address) != kCFSocketSuccess) {
            
            
            if (_socket) {
                CFRelease(_socket);
                
            }
            
            _socket = NULL;
        }
        
        
        NSLog(@"### com.zjx.springboard: connection waiting");
        
        CFRunLoopRef cfrunLoop = CFRunLoopGetCurrent();
        
        CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket, 0);
        

        CFRunLoopAddSource(cfrunLoop, source, kCFRunLoopCommonModes);

        CFRelease(source);
        
        CFRunLoopRun();
    }

}

static void readStream(CFReadStreamRef readStream, CFStreamEventType eventype, void * clientCallBackInfo) 
{
    UInt8 readDataBuff[2048];
    
	memset(readDataBuff, 0, sizeof(readDataBuff));
    
    
    CFIndex hasRead = CFReadStreamRead(readStream, readDataBuff, sizeof(readDataBuff));
    

    if (hasRead > 0) {

        
        
        for(char * charSep = strtok((char*)readDataBuff, "\n\r"); charSep != NULL; charSep = strtok(NULL, "\n\r")) {
            UInt8 *buff = (UInt8*)charSep;
            processTask(buff);
            NSLog(@"com.zjx.springboard: get data: %s", buff);
        }
       
		
    }

    
}

static void TCPServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    
    if (kCFSocketAcceptCallBack == type) {
        
        
        CFSocketNativeHandle  nativeSocketHandle = *(CFSocketNativeHandle *)data;
        
        
        uint8_t name[SOCK_MAXADDRLEN];
        
        socklen_t namelen = sizeof(name);
        
        


        
        
        
        
        
        
        
        if (getpeername(nativeSocketHandle, (struct sockaddr *)name, &namelen) != 0) {
            
            NSLog(@"### com.zjx.springboard: ++++++++getpeername+++++++");
            
            exit(1);
        }
        
        
        struct sockaddr_in *addr_in = (struct sockaddr_in *)name;
        
        
        NSLog(@"### com.zjx.springboard: connection starts", inet_ntoa(addr_in-> sin_addr), addr_in->sin_port);
        
        
        readStreamRef = NULL;
        writeStreamRef = NULL;
        
        
        
        
        
        
		
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStreamRef, &writeStreamRef);
       
        
        if (readStreamRef && writeStreamRef) {
            
            CFReadStreamOpen(readStreamRef);
            CFWriteStreamRef(writeStreamRef);
            
            
            
            
            CFStreamClientContext context = {0, NULL, NULL, NULL };
            
            
            
            
            
            
            
            if (!CFReadStreamSetClient(readStreamRef, kCFStreamEventHasBytesAvailable, readStream, &context)) {
                NSLog(@"### com.zjx.springboard: error 1");
                
            }
            
            
            CFReadStreamScheduleWithRunLoop(readStreamRef, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
			
            
            
            
            
			
        }
        else
        {
            
            close(nativeSocketHandle);
        }
		
    }
    
}




void socketClient()
{






















	return;

 }
