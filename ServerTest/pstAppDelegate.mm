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

const char* LowerFaceAction(EmoStateHandle);



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
        
        
        
        
        [f observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            NSLog(@"%@ -> %@", snapshot.name, snapshot.value);
        }];
        [f observeEventType:FEventTypeChildAdded  withBlock:^(FDataSnapshot *snapshot){
            NSLog(@"CHILD WAS ADDED!! ");
        }];
        
        [[f childByAppendingPath:@"connected"] setValue:@"true"];
        [[f childByAppendingPath:@"events"] setValue:@"POLLITO"];
        
        int j  = 0;
        
        
        NSString *_state = @"";
        int _strenght = 0;
        int _smileForce = 0;
        
        while(true){

            

            state = EE_EngineGetNextEvent(eEvent);
            if(state == EDK_OK)
            {
            
                EE_Event_t eventType = EE_EmoEngineEventGetType(eEvent);
                EE_EmoEngineEventGetUserId(eEvent, &userID);
                

                
                if(eventType == EE_EmoStateUpdated)
                {
                    EE_EmoEngineEventGetEmoState(eEvent, eState);

                    if(ES_ExpressivIsRightWink(eState) == 0)
                    {
                        _state = @"no blink";
                    }
                    else
                    {
                        _state = @"yes blink";
                        _strenght += 1;
                        [[f childByAppendingPath:@"events"] setValue: [NSString stringWithFormat: @"  %@, %d " , _state , _strenght  ] ];
                    }

                    const char* lowerFaceAction = LowerFaceAction( eState );
                    if ( "Smile" ==  lowerFaceAction  ){ // lowerFaceAction == "Smile"
                        _smileForce += 1;
                        [[f childByAppendingPath:@"smile"] setValue: [NSString stringWithFormat:@" TRUE, %d", _smileForce]];
                    }
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


const char* LowerFaceAction(EmoStateHandle eState)
{
	EE_ExpressivAlgo_t lowerFaceAction = ES_ExpressivGetLowerFaceAction( eState );
	if( lowerFaceAction == EXP_SMILE)
		return "Smile";
	else if( lowerFaceAction == EXP_CLENCH)
		return "Clench";
	else if( lowerFaceAction == EXP_SMIRK_LEFT)
		return "Smirk left";
	else if( lowerFaceAction == EXP_SMIRK_RIGHT)
		return "Smirk right";
	else if( lowerFaceAction == EXP_LAUGH )
		return "Laugh";
	return "-";
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self tryToReadTheThingFromTheEpoc];
    
    //[self tryToSaveDataToFirebase : 10 ];
}

@end
