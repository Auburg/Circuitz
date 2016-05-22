//
//  CPU.h
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 04/10/2010.
//  Copyright 2010 Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"
#import "Probe.h"

typedef enum   { Idle,Locating }CPUState;
typedef enum {Ideal,Median,FallBack}InputsQueue;

@interface CPU : NSObject {
	
	@private
	
	bool _initialised;
	AILevel _aiLevel;
	CPUState _cpuState;
	Direction _probeIndexDirection;
	int _locatedProbeInputIndex;
	int _currentCPUProbeIndex;
	NSMutableArray *_idealInputsArray;
	NSMutableArray *_medianInputsArray;
	NSMutableArray* _fallbackInputsArray;
	
	InputsQueue _currentInputsQueue;
	//BOOL (^_probeTest) (id obj, NSUInteger idx, BOOL *stop);
		
}

-(CPU*) init;
-(void)Start:(AILevel)level;
-(void)Stop;
-(bool)IsInitialised;


@end
