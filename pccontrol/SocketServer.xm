// TODO: multiple client write back support


#include "SocketServer.h"
#include "Task.h"

CFSocketRef socketRef;
CFWriteStreamRef writeStreamRef = NULL;
CFReadStreamRef readStreamRef = NULL;

// Reference: https://www.jianshu.com/p/9353105a9129

void socketServer()
{
    @autoreleasepool {
		
        //创建Socket， 指定TCPServerAcceptCallBack
        //作为kCFSocketAcceptCallBack 事件的监听函数
        //参数1： 指定协议族，如果参数为0或者负数，则默认为PF_INET
        //参数2：指定Socket类型，如果协议族为PF_INET，且该参数为0或者负数，则它会默认为SOCK_STREAM,如果要使用UDP协议，则该参数指定为SOCK_DGRAM
        //参数3：指定通讯协议。如果前一个参数为SOCK_STREAM,则默认为使用TCP协议，如果前一个参数为SOCK_DGRAM,则默认使用UDP协议
        //参数4：指定下一个函数所监听的事件类型
        CFSocketRef _socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, TCPServerAcceptCallBack, NULL);
        
        if (_socket == NULL) {
            NSLog(@"### com.zjx.springboard: failed to create socket.");
            return;
        }
        
        UInt32 reused = 1;
        
        //设置允许重用本地地址和端口
        setsockopt(CFSocketGetNative(_socket), SOL_SOCKET, SO_REUSEADDR, (const void *)&reused, sizeof(reused));
        
        //定义sockaddr_in类型的变量， 该变量将作为CFSocket的地址
        struct sockaddr_in Socketaddr;
        memset(&Socketaddr, 0, sizeof(Socketaddr));
        Socketaddr.sin_len = sizeof(Socketaddr);
        Socketaddr.sin_family = AF_INET;
        
        //设置服务器监听地址
        Socketaddr.sin_addr.s_addr = inet_addr(ADDR);
        //设置服务器监听端口
        Socketaddr.sin_port = htons(PORT);
        
        //将ipv4 的地址转换为CFDataRef
        CFDataRef address = CFDataCreate(kCFAllocatorDefault,  (UInt8 *)&Socketaddr, sizeof(Socketaddr));
        
        //将CFSocket 绑定到指定IP地址
        if (CFSocketSetAddress(_socket, address) != kCFSocketSuccess) {
            
            //如果_socket 不为NULL， 则f释放_socket
            if (_socket) {
                CFRelease(_socket);
                //exit(1);
            }
            
            _socket = NULL;
        }
        
        //启动h循环箭筒客户链接
        NSLog(@"### com.zjx.springboard: connection waiting");
        //获取当前线程的CFRunloop
        CFRunLoopRef cfrunLoop = CFRunLoopGetCurrent();
        //将_socket包装成CFRunLoopSource
        CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket, 0);
        //为CFRunLoop对象添加source

        CFRunLoopAddSource(cfrunLoop, source, kCFRunLoopCommonModes);

        CFRelease(source);
        //运行当前线程的CFrunLoop
        CFRunLoopRun();
    }

}

static void readStream(CFReadStreamRef readStream, CFStreamEventType eventype, void * clientCallBackInfo) 
{
    UInt8 readDataBuff[2048];
    
	memset(readDataBuff, 0, sizeof(readDataBuff));
    
    //--从可读的数据流中读取数据，返回值是多少字节读到的， 如果为0 就是已经全部结束完毕，如果是-1 则是数据流没有打开或者其他错误发生
    CFIndex hasRead = CFReadStreamRead(readStream, readDataBuff, sizeof(readDataBuff));
    

    if (hasRead > 0) {

        //don't know how it works, copied from https://www.educative.io/edpresso/splitting-a-string-using-strtok-in-c
        
        for(char * charSep = strtok((char*)readDataBuff, "\n\r"); charSep != NULL; charSep = strtok(NULL, "\n\r")) {
            UInt8 *buff = (UInt8*)charSep;
            processTask(buff);
            //NSLog(@"com.zjx.springboard: get data: %s", buff);
        }
        //向客户端输出数据
        //NSLog(@"com.zjx.springboard: return value: %d, ref: %d", CFWriteStreamWrite(writeStreamRef, (UInt8 *)"str", 3), writeStreamRef);

		//countsss++;
    }
}

int notifyClient(UInt8* msg)
{
    return CFWriteStreamWrite(writeStreamRef, msg, strlen((char*)msg));
}

static void TCPServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    //如果有客户端Socket连接进来
    if (kCFSocketAcceptCallBack == type) {
        
        //获取本地Socket的Handle， 这个回调事件的类型是kCFSocketAcceptCallBack，这个data就是一个CFSocketNativeHandle类型指针
        CFSocketNativeHandle  nativeSocketHandle = *(CFSocketNativeHandle *)data;
        
        //定义一个255数组接收这个新的data转成的socket的地址，SOCK_MAXADDRLEN表示最长的可能的地址
        uint8_t name[SOCK_MAXADDRLEN];
        //这个地址数组的长度
        socklen_t namelen = sizeof(name);
        
        /*
         
         */
        
        //MARK:获取socket信息
        //第一个参数 已经连接的socket
        //第二个参数 用来接受地址信息
        //第三个参数 地址长度
        //getpeername 从已经连接的socket中获的地址信息， 存到参数2中，地址长度放到参数3中，成功返回0， 如果失败了则返回别的数字，对应不同错误码
        
        if (getpeername(nativeSocketHandle, (struct sockaddr *)name, &namelen) != 0) {
            
            NSLog(@"### com.zjx.springboard: ++++++++getpeername+++++++");
            
            exit(1);
        }
        
        //获取连接信息
        struct sockaddr_in *addr_in = (struct sockaddr_in *)name;
        
        // inet_ntoa 将网络地址转换成"." 点隔的字符串格式
        NSLog(@"### com.zjx.springboard: connection starts", inet_ntoa(addr_in-> sin_addr), addr_in->sin_port);
        
        //创建一组可读/可写的CFStream
        readStreamRef = NULL;
        writeStreamRef = NULL;
        
        //创建一个和Socket对象相关联的读取数据流
        //参数1 ：内存分配器
        //参数2 ：准备使用输入输出流的socket
        //参数3 ：输入流
        //参数4 ：输出流
		
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStreamRef, &writeStreamRef);
       
        //CFStreamCreatePairWithSocket() 操作成功后，readStreamRef和writeStream都指向有效的地址，因此判断是不是还是之前设置的NULL就可以了
        if (readStreamRef && writeStreamRef) {
            //打开输入流 和输出流
            CFReadStreamOpen(readStreamRef);
            CFWriteStreamOpen(writeStreamRef);
            
            //一个结构体包含程序定义数据和回调用来配置客户端数据流行为            
            CFStreamClientContext context = {0, NULL, NULL, NULL };
            
            
            //指定客户端的数据流， 当特定事件发生的时候， 接受回调
            //参数1 : 需要指定的数据流
            //参数2 : 具体的事件，如果为NULL，当前客户端数据流就会被移除
            //参数3 : 事件发生回调函数，如果为NULL，同上
            //参数4 : 一个为客户端数据流保存上下文信息的结构体，为NULL同上
            //CFReadStreamSetClient  返回值为true 就是数据流支持异步通知， false就是不支持
            if (!CFReadStreamSetClient(readStreamRef, kCFStreamEventHasBytesAvailable, readStream, &context)) {
                NSLog(@"### com.zjx.springboard: error 1");
                return;
            }
            
            //将数据流加入循环
            CFReadStreamScheduleWithRunLoop(readStreamRef, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
			
            //const char *str = "+++welcome++++\n";
            
            //向客户端输出数据
            //CFWriteStreamWrite(writeStreamRef, (UInt8 *)str, strlen(str) + 1);
			
        }
        else
        {
            //如果失败就销毁已经连接的socket
            close(nativeSocketHandle);
        }
		
    }
    
}



/***** useless function *****/
void socketClient()
{

/*

 //创建套接字
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    //向服务器（特定的IP和端口）发起请求
    struct sockaddr_in serv_addr;
    memset(&serv_addr, 0, sizeof(serv_addr));  //每个字节都用0填充
    serv_addr.sin_family = AF_INET;  //使用IPv4地址
    serv_addr.sin_addr.s_addr = inet_addr(SERVER_ADDRESS);  //具体的IP地址
    serv_addr.sin_port = htons(PORT);  //端口
    connect(sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
   

    //recv(sock, buffer, sizeof(buffer)-1, 0);
	char str[] = "test";
    //send(sock, str, sizeof(str), 0);
	send(sock, str, sizeof(str), 0);
   
    //关闭套接字
    close(sock);
	*/
	return;

 }