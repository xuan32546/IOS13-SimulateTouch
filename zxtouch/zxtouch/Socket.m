//
//  Socket.m
//  zxtouch
//
//  Created by Jason on 2020/12/11.
//

#import "Socket.h"


@implementation Socket
{
    int socketHandle;
}

/**
 Connect to a server, return -1 if fail
 */
-(int) connect: (NSString*) ip byPort:(int) port
{
    //NSLog(@"ip: %@, and port: %d", ip, port);、
    int sock = 0;
    struct sockaddr_in serv_addr;

    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
        NSLog(@"### com.zjx.zxtouchb:  Socket creation error");
        return -1;
        
    }
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(port);

    // Convert IPv4 and IPv6 addresses from text to binary form
    if(inet_pton(AF_INET, [ip UTF8String], &serv_addr.sin_addr)<=0)
    {
        NSLog(@"### com.zjx.zxtouchb: Invalid address. Address not supported");
        return -1;
    }

    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0)
    {
        NSLog(@"### com.zjx.zxtouchb: \nConnection Failed \n");
        return -1;
    }
    socketHandle = sock;
    return 0;
}

-(void) send: (NSString*)msg
{
    const char *buffer = [msg UTF8String];
    send(socketHandle , buffer, strlen(buffer) , 0);
}

-(void) sendChar: (char*)msg
{
    send(socketHandle , msg, strlen(msg) , 0);
}

-(void)close {
    if (!socketHandle)
        return;
    close(socketHandle);
    socketHandle = 0;
}

-(void)dealloc {
    NSLog(@"Socket dealloc");
    [self close];
}

@end
