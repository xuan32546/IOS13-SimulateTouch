// TODO: multiple client write back support


#include "SocketServer.h"
#include "Task.h"


CFSocketRef socketRef;
CFWriteStreamRef writeStreamRef = NULL;
CFReadStreamRef readStreamRef = NULL;
static NSMutableDictionary *socketClients = NULL;
// Reference: https://www.jianshu.com/p/9353105a9129

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
                //exit(1);
            }
            
            _socket = NULL;
        }
        
        socketClients = [[NSMutableDictionary alloc] init];

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
        //don't know how it works, copied from https://www.educative.io/edpresso/splitting-a-string-using-strtok-in-c
        
        for(char * charSep = strtok((char*)readDataBuff, "\r\n"); charSep != NULL; charSep = strtok(NULL, "\r\n")) {
            UInt8 *buff = (UInt8*)charSep;
            id temp = [socketClients objectForKey:@((long)readStreamRef)];
            if (temp != nil)
                processTask(buff, (CFWriteStreamRef)[temp longValue]);
            else
                processTask(buff);
            //NSLog(@"com.zjx.springboard: get data: %s", buff);
        }
        //NSLog(@"com.zjx.springboard: return value: %d, ref: %d", CFWriteStreamWrite(writeStreamRef, (UInt8 *)"str", 3), writeStreamRef);

		//countsss++;
    }
}
int notifyClient(UInt8* msg, CFWriteStreamRef client)
{
    __block int result;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"com.zjx.springboard: client: %x", client);
        if (client != 0)
        {
            result = CFWriteStreamWrite(client, msg, strlen((char*)msg));
        }
        result = -1;
    });
    return result;
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
            CFWriteStreamOpen(writeStreamRef);
            
            CFStreamClientContext context = {0, NULL, NULL, NULL };

            if (!CFReadStreamSetClient(readStreamRef, kCFStreamEventHasBytesAvailable, readStream, &context)) {
                NSLog(@"### com.zjx.springboard: error 1");
                return;
            }
            
            CFReadStreamScheduleWithRunLoop(readStreamRef, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);

			[socketClients setObject:@((long)writeStreamRef) forKey:@((long)readStreamRef)];
            //const char *str = "+++welcome++++\n";
            
            //CFWriteStreamWrite(writeStreamRef, (UInt8 *)str, strlen(str) + 1);	
        }
        else
        {
            close(nativeSocketHandle);
        }
		
    }
    
}
