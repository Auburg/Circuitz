//
//  Probe.h
//  Circuitz
//
//  Created by Tanvir Kazi on 15/04/2010.
//  Copyright 2010 Hackers. All rights reserved.
//


#import "Types.h"
#import "cocos2d.h"
#import "LevelDataManager.h"

@interface Probe : NSObject {
	
	@private
	ProbeDesc _probebDescArray[4];
	int _currentInputIndex;
	ProbeType _probeType;
    int _activeCount; 		
}

@property(readonly) ProbeDesc* ProbeDescs;
@property(nonatomic,assign) int ActivationCount;

//Factory method to generate probe types
+(void)SetLevel:(int)level;
+(Probe*)GenerateProbe:(CellColor)c index:(int)i;
-(ProbeType)GetProbeType;
-(int)GetCurrentInputIndex;
-(void)ResetState;


@end
