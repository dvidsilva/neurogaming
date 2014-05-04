//
//  pstAppDelegate.m
//  ServerTest
//
//  Created by Dvid Silva on 5/3/14.
//  Copyright (c) 2014 postatlantic. All rights reserved.
//

#import "pstAppDelegate.h"
#import <Firebase/Firebase.h>


#ifdef __cplusplus
#include "edk.h"
#include "edkErrorCode.h"
#include "EmoStateDLL.h"
#endif


int state = 0;


@implementation pstAppDelegate


- (void)tryToSaveDataToFirebase: (int)aNumber
{
    
    // Insert code here to initialize your application
    
    NSString* url = @"https://neurogaming.firebaseio.com/epoc/0/connected/";
    Firebase* f = [[Firebase alloc] initWithUrl:url];
   
    
    [f setValue:@"pollito"];
    
    
    
    [f observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"%@ -> %@", snapshot.name, snapshot.value);
    }];


//    int j = 0;
//    while(j < aNumber){
//        j = j + 1;
//        NSLog(@"string %d", j);
//    }
}


- (void)tryToReadTheThingFromTheEpoc
{
    
    
    
    NSString* url = @"https://neurogaming.firebaseio.com/epoc/0/";
    Firebase* f = [[Firebase alloc] initWithUrl:url];
    // Firebase* newPushRef = [listRef childByAutoId];

    unsigned int userID = 0;
    EmoEngineEventHandle eEvent = EE_EmoEngineEventCreate();
    EmoStateHandle eState = EE_EmoStateCreate();
    bool connected = FALSE;

    if(EE_EngineConnect() == EDK_OK)
        connected = TRUE;
    else
    {
        connected = FALSE;
        NSLog(@"Cannot connect to the EmoEngine !");
    }
    if(connected){
        
        
        [[f childByAppendingPath:@"connected"] setValue:@"true"];
        [[f childByAppendingPath:@"events"] setValue:@"POLLITO"];
//        [f observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//            NSLog(@"%@ -> %@", snapshot.name, snapshot.value);
//        }];
        
        int j  = 0;
        while(true){

            state = EE_EngineGetNextEvent(eEvent);
            if(state == EDK_OK)
            {
            
                EE_Event_t eventType = EE_EmoEngineEventGetType(eEvent);
                EE_EmoEngineEventGetUserId(eEvent, &userID);
                if(eventType == EE_EmoStateUpdated)
                {
                    EE_EmoEngineEventGetEmoState(eEvent, eState);
                    
                    // time from start
                    [[f childByAppendingPath:@"events"] setValue:@"POllO"];
                    const float timestart = ES_GetTimeFromStart(eState);
                    NSLog(@"%f",timestart);
                    
                }
                
            }
            j =  j + 1;
        }
    }
    
    EE_EmoStateFree(eState);
    EE_EmoEngineEventFree(eEvent);

}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self tryToReadTheThingFromTheEpoc];
    
    //[self tryToSaveDataToFirebase : 10 ];
}

@end
