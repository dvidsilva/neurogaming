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

NSNumber *ropeForce = 0;
NSString *myusername = @"david";
int multiplier = -1;
const char* actionMagicalThing = "Push"; // Smile, Blink, Push


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
    NSString* url2 = @"https://neurogaming.firebaseio.com/rope/";
    Firebase* rope = [[Firebase alloc] initWithUrl:url2];

    
    NSString* url3 = @"https://neurogaming.firebaseio.com/users/";
    Firebase* user = [[Firebase alloc] initWithUrl:url3];

    
    
    [rope setValue: @0];

    // Firebase* newPushRef = [listRef childByAutoId];

    unsigned int userID = 0;
    EmoEngineEventHandle eEvent = EE_EmoEngineEventCreate();
    EmoStateHandle eState = EE_EmoStateCreate();
    bool connected = FALSE;

    if(EE_EngineConnect() == EDK_OK)
    {
        connected = TRUE;
        [[user childByAppendingPath:@"david" ] setValue:@"true" ];
    }
        else
    {
        connected = FALSE;
        NSLog(@"Cannot connect to the EmoEngine !");
    }
    if(connected){
        NSLog(@"connected");
     
        [f observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            NSLog(@"%@ -> %@", snapshot.name, snapshot.value);
        }];
        [f observeEventType:FEventTypeChildAdded  withBlock:^(FDataSnapshot *snapshot){
            NSLog(@"CHILD WAS ADDED!! ");
        }];
        

        [rope observeEventType:FEventTypeValue  withBlock:^(FDataSnapshot *snapshot){
            
            NSLog(@"ROPE CHANGED!!");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"value: %@",snapshot);
                if ([snapshot.name isEqualToString:@"rope"])
                    
                {
                    double value = [snapshot.value doubleValue];
                    NSLog(@"value:%f",value);
                    if (value && value >= -100 & value <= 100)
                        [self.slider setDoubleValue:value];
                    ropeForce = [NSNumber numberWithDouble:value];
                }
            });
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

                    if("Blink"== actionMagicalThing){
                        if(ES_ExpressivIsRightWink(eState) == 0)
                        {
                            _state = @"no blink";
                        }
                        else
                        {
                            _strenght += 8;
                            int temp = [ropeForce intValue];
                            temp += (1 * multiplier);
                            NSNumber *set = [NSNumber numberWithInt:temp];
                            NSLog(@" %@", ropeForce);
                            [rope setValue: set];
                        }
                    }
                    const char* lowerFaceAction = LowerFaceAction( eState );
                    const char* something = CognitivSuite(eState);
                    if ( something ==  actionMagicalThing  ){
                        _smileForce += 1;

                        int temp = [ropeForce intValue];
                        temp += (1 * multiplier);
                        NSNumber *set = [NSNumber numberWithInt:temp];
                        NSLog(@" %@", ropeForce);
                        [rope setValue: set];
                    }
                    
                    if (lowerFaceAction == actionMagicalThing){
                        int temp = [ropeForce intValue];
                        temp += (1 * multiplier);
                        NSNumber *set = [NSNumber numberWithInt:temp];
                        NSLog(@" %@", ropeForce);
                        [rope setValue: set];
                    }
                    
                    
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



const char* CognitivSuite(EmoStateHandle eState)
{
	EE_CognitivAction_t cognitivAction = ES_CognitivGetCurrentAction(eState);
	if( cognitivAction == COG_NEUTRAL)
		return "Neutral";
	else if(cognitivAction == COG_PUSH)
		return "Push";
	else if( cognitivAction == COG_PULL)
		return "Pull";
	else if(cognitivAction == COG_LIFT)
		return "Lift";
	else if( cognitivAction == COG_DROP)
		return "Drop";
	else if( cognitivAction == COG_LEFT)
		return "Left";
	else if(cognitivAction == COG_RIGHT)
		return "Right";
	else if( cognitivAction == COG_ROTATE_LEFT)
		return "Rotate Left";
	else if( cognitivAction == COG_ROTATE_RIGHT)
		return "Rotate Right";
	else if(cognitivAction == COG_ROTATE_CLOCKWISE)
		return "Rotate_ClockWise";
	else if(cognitivAction==COG_ROTATE_COUNTER_CLOCKWISE)
		return "Rotate_Counter_ClockWise";
	else if( cognitivAction == COG_ROTATE_FORWARDS)
		return "Rotate_Forwards";
	else if(cognitivAction == COG_ROTATE_REVERSE)
		return "Rotate_Reverse";
	else if( cognitivAction == COG_DISAPPEAR)
		return "Disappear";
	
	return "-";
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [self tryToReadTheThingFromTheEpoc];
        
    });
}

@end
