//
//  IntentHandler.m
//  shortcutext
//
//  Created by Jason on 2021/2/7.
//

#import "IntentHandler.h"
#import "PerformTouchIntent.h"
#import "PerformTouchIntentHandler.h"
#import "SwitchAppIntent.h"
#import "SwitchAppIntentHandler.h"
#import "ShowAlertBoxIntent.h"
#import "ShowAlertBoxIntentHandler.h"
#import "RunShellCommandIntent.h"
#import "RunShellCommandIntentHandler.h"
#import "StartTouchRecordingIntent.h"
#import "StartTouchRecordingIntentHandler.h"
#import "StopTouchRecordingIntent.h"
#import "StopTouchRecordingIntentHandler.h"
#import "PlayScriptIntent.h"
#import "PlayScriptIntentHandler.h"
#import "StopScriptPlayingIntent.h"
#import "StopScriptPlayingIntentHandler.h"
#import "ImageMatchingIntent.h"
#import "ImageMatchingIntentHandler.h"
#import "ShowToastIntent.h"
#import "ShowToastIntentHandler.h"
#import "PickColorIntent.h"
#import "PickColorIntentHandler.h"
#import "SearchColorIntent.h"
#import "SearchColorIntentHandler.h"
#import "OCRIntent.h"
#import "OCRIntentHandler.h"
#import "PasteFromClipBoardIntent.h"
#import "PasteFromClipboardIntentHandler.h"
#import "InsertTextIntent.h"
#import "InsertTextIntentHandler.h"
#import "MoveCursorIntent.h"
#import "MoveCursorIntentHandler.h"
#import "GetScreenSizeIntent.h"
#import "GetScreenSizeIntentHandler.h"
#import "GetScreenOrientationIntent.h"
#import "GetScreenOrientationIntentHandler.h"

#import "Socket.h"

Socket *springBoardSocket;

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

@interface IntentHandler () <INSendMessageIntentHandling, INSearchForMessagesIntentHandling, INSetMessageAttributeIntentHandling>

@end

@implementation IntentHandler

- (id)init {
    self = [super init];
    if (self)
    {
        if (!springBoardSocket)
        {
            springBoardSocket = [[Socket alloc] init];
            [springBoardSocket connect:@"127.0.0.1" byPort:6000];
        }
    }
    return self;
}

- (id)handlerForIntent:(INIntent *)intent {
    // This is the default implementation.  If you want different objects to handle different intents,
    // you can override this and return the handler you want for that particular intent.
    if ([intent class] == [PerformTouchIntent class])
    {
        return [[PerformTouchIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
    else if ([intent class] == [SwitchAppIntent class])
    {
        return [[SwitchAppIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
    else if ([intent class] == [ShowAlertBoxIntent class])
    {
        return [[ShowAlertBoxIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
    else if ([intent class] == [RunShellCommandIntent class])
    {
        return [[RunShellCommandIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
    else if ([intent class] == [StartTouchRecordingIntent class])
    {
        return [[StartTouchRecordingIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
    else if ([intent class] == [StopTouchRecordingIntent class])
    {
        return [[StopTouchRecordingIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
    else if ([intent class] == [PlayScriptIntent class])
    {
        return [[PlayScriptIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
    else if ([intent class] == [StopScriptPlayingIntent class])
    {
        return [[StopScriptPlayingIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
    else if ([intent class] == [ImageMatchingIntent class])
    {
        return [[ImageMatchingIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
    else if ([intent class] == [ShowToastIntent class])
    {
        return [[ShowToastIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
    else if ([intent class] == [PickColorIntent class])
    {
        return [[PickColorIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
    else if ([intent class] == [SearchColorIntent class])
    {
        return [[SearchColorIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
    else if ([intent class] == [PasteFromClipBoardIntent class])
    {
        return [[PasteFromClipboardIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
    else if ([intent class] == [InsertTextIntent class])
    {
        return [[InsertTextIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
    else if ([intent class] == [MoveCursorIntent class])
    {
        return [[MoveCursorIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
    else if ([intent class] == [GetScreenSizeIntent class])
    {
        return [[GetScreenSizeIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
    else if ([intent class] == [GetScreenOrientationIntent class])
    {
        return [[GetScreenOrientationIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
    /*
    else if ([intent class] == [OCRIntent class])
    {
        return [[OCRIntentHandler alloc] initWithSocketInstance:springBoardSocket];
    }
     */
    return self;
}

#pragma mark - INSendMessageIntentHandling

// Implement resolution methods to provide additional information about your intent (optional).
- (void)resolveRecipientsForSendMessage:(INSendMessageIntent *)intent with:(void (^)(NSArray<INSendMessageRecipientResolutionResult *> *resolutionResults))completion {
    NSArray<INPerson *> *recipients = intent.recipients;
    // If no recipients were provided we'll need to prompt for a value.
    if (recipients.count == 0) {
        completion(@[[INSendMessageRecipientResolutionResult needsValue]]);
        return;
    }
    NSMutableArray<INSendMessageRecipientResolutionResult *> *resolutionResults = [NSMutableArray array];
    
    for (INPerson *recipient in recipients) {
        NSArray<INPerson *> *matchingContacts = @[recipient]; // Implement your contact matching logic here to create an array of matching contacts
        if (matchingContacts.count > 1) {
            // We need Siri's help to ask user to pick one from the matches.
            [resolutionResults addObject:[INSendMessageRecipientResolutionResult disambiguationWithPeopleToDisambiguate:matchingContacts]];

        } else if (matchingContacts.count == 1) {
            // We have exactly one matching contact
            [resolutionResults addObject:[INSendMessageRecipientResolutionResult successWithResolvedPerson:recipient]];
        } else {
            // We have no contacts matching the description provided
            [resolutionResults addObject:[INSendMessageRecipientResolutionResult unsupported]];
        }
    }
    completion(resolutionResults);
}

- (void)resolveContentForSendMessage:(INSendMessageIntent *)intent withCompletion:(void (^)(INStringResolutionResult *resolutionResult))completion {
    NSString *text = intent.content;
    if (text && ![text isEqualToString:@""]) {
        completion([INStringResolutionResult successWithResolvedString:text]);
    } else {
        completion([INStringResolutionResult needsValue]);
    }
}

// Once resolution is completed, perform validation on the intent and provide confirmation (optional).

- (void)confirmSendMessage:(INSendMessageIntent *)intent completion:(void (^)(INSendMessageIntentResponse *response))completion {
    // Verify user is authenticated and your app is ready to send a message.
    
    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSendMessageIntent class])];
    INSendMessageIntentResponse *response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeReady userActivity:userActivity];
    completion(response);
}

// Handle the completed intent (required).

- (void)handleSendMessage:(INSendMessageIntent *)intent completion:(void (^)(INSendMessageIntentResponse *response))completion {
    // Implement your application logic to send a message here.
    
    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSendMessageIntent class])];
    INSendMessageIntentResponse *response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeSuccess userActivity:userActivity];
    completion(response);
}

// Implement handlers for each intent you wish to handle.  As an example for messages, you may wish to also handle searchForMessages and setMessageAttributes.

#pragma mark - INSearchForMessagesIntentHandling

- (void)handleSearchForMessages:(INSearchForMessagesIntent *)intent completion:(void (^)(INSearchForMessagesIntentResponse *response))completion {
    // Implement your application logic to find a message that matches the information in the intent.
    
    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSearchForMessagesIntent class])];
    INSearchForMessagesIntentResponse *response = [[INSearchForMessagesIntentResponse alloc] initWithCode:INSearchForMessagesIntentResponseCodeSuccess userActivity:userActivity];
    // Initialize with found message's attributes
    response.messages = @[[[INMessage alloc]
        initWithIdentifier:@"identifier"
        content:@"I am so excited about SiriKit!"
        dateSent:[NSDate date]
        sender:[[INPerson alloc] initWithPersonHandle:[[INPersonHandle alloc] initWithValue:@"sarah@example.com" type:INPersonHandleTypeEmailAddress] nameComponents:nil displayName:@"Sarah" image:nil contactIdentifier:nil customIdentifier:nil]
        recipients:@[[[INPerson alloc] initWithPersonHandle:[[INPersonHandle alloc] initWithValue:@"+1-415-555-5555" type:INPersonHandleTypePhoneNumber] nameComponents:nil displayName:@"John" image:nil contactIdentifier:nil customIdentifier:nil]]
    ]];
    completion(response);
}

#pragma mark - INSetMessageAttributeIntentHandling

- (void)handleSetMessageAttribute:(INSetMessageAttributeIntent *)intent completion:(void (^)(INSetMessageAttributeIntentResponse *response))completion {
    // Implement your application logic to set the message attribute here.
    
    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSetMessageAttributeIntent class])];
    INSetMessageAttributeIntentResponse *response = [[INSetMessageAttributeIntentResponse alloc] initWithCode:INSetMessageAttributeIntentResponseCodeSuccess userActivity:userActivity];
    completion(response);
}

@end
