
//  Probe.m
//  Circuitz
//
//  Created by Tanvir Kazi on 15/04/2010.
//  Copyright 2010 Hackers. All rights reserved.


#import "Probe.h"
#import "CircuitGameObj.h"
#import "LevelDataManager.h"

#pragma mark -
#pragma mark Interface decl

@interface Probe()

-(id) initWithInput1Index:(int) index;
-(id) initWithOneInputTwoOutput:(int) index;
-(id) initWithTwoInputOneOutput:(int) index;

@end

#pragma mark -

static Probe* GenerateOneInputOneOutputProbe(int index);
static Probe* GenerateBoostedProbe(int index);
static Probe* GenerateInvertedProbe(int index);
static Probe* GenerateLatchedProbe(int index);
static Probe* GenerateOneInputTwoOutputProbe(int index);
static Probe* GenerateTwoInputSingleOutputProbe(int index);


static Probe* (*probeGeneratorTable[]) (int index)=
{
	&GenerateOneInputOneOutputProbe,
	&GenerateBoostedProbe,
	&GenerateInvertedProbe,
	&GenerateLatchedProbe
};

static Probe* (*doubleProbeGeneratorTable[]) (int index)=
{
	&GenerateOneInputTwoOutputProbe,
	&GenerateTwoInputSingleOutputProbe
};

static int CurrentLevel=0;

#define SINGLE_PROBE_ELEMENTS	(sizeof(probeGeneratorTable)/sizeof(probeGeneratorTable[0]))
#define DOUBLE_PROBE_ELEMENTS	(sizeof(doubleProbeGeneratorTable)/sizeof(doubleProbeGeneratorTable[0]))

#pragma mark -
#pragma mark Probe methods

@implementation Probe

@synthesize ActivationCount=_activeCount;

+(void)SetLevel:(int)level
{
	CurrentLevel	= level;
	
	[[LevelDataManager sharedInstance]LoadLevelData:CurrentLevel];
}

#pragma mark -
#pragma mark init / dealloc methods


//Factory method to generate probe types
+(Probe*)GenerateProbe:(CellColor)c index:(int)i
{
	ProbeType mainType;
	ProbeDesc pd;
	Probe* probe;
    int jumptableIndex		= 0;
    const int NUM_TABLES	= 2;
	
	
	pd.isActionRunning	= FALSE;
	mainType			= Single;
    
    if (![[LevelDataManager sharedInstance]DoesLevelExist]) {
        
                
        int tableIndex			= arc4random()%NUM_TABLES;
        
        assert(tableIndex < NUM_TABLES);
        
        if (tableIndex==0 || (([CircuitGameObj  MaxCells]-i)<3)) {
            
            jumptableIndex			= arc4random()%SINGLE_PROBE_ELEMENTS;
            
            assert(jumptableIndex>=0 && jumptableIndex<SINGLE_PROBE_ELEMENTS);
            
            probe			=  (*probeGeneratorTable[jumptableIndex]) (i);
            
        }
        else {
            
            jumptableIndex			= arc4random()%DOUBLE_PROBE_ELEMENTS;
            
            assert(jumptableIndex>=0 && jumptableIndex<DOUBLE_PROBE_ELEMENTS);
            
            probe			=  (*doubleProbeGeneratorTable[jumptableIndex]) (i);
            
        }	
        
    }
    else
    {
        [[LevelDataManager sharedInstance]GetProbeDesc:i side:c mainType:&mainType inputType:&pd];
        
        switch (mainType) {
            case Single:
                probe = [[[Probe alloc]initWithInput1Index:i]autorelease];
                break;
            case SingleInputTwoOutput:
                probe = [[[Probe alloc]initWithOneInputTwoOutput:i]autorelease];
                break;
            case TwoInputSingleOutput:
                probe = [[[Probe alloc]initWithTwoInputOneOutput:i]autorelease];
                break;
            default:
                break;
        }        
        
        probe.ProbeDescs[Input1].isBoosted      = pd.isBoosted;
        probe.ProbeDescs[Input1].isInverted     = pd.isInverted;
        probe.ProbeDescs[Input1].isLatched      = pd.isLatched;
        probe.ProbeDescs[Input1].isMutex        = pd.isMutex;
        probe.ProbeDescs[Input1].isFlashSlow    = pd.isFlashSlow;
    }
	
	
	return probe;
	
}

-(ProbeType)GetProbeType
{
	return _probeType;
}

-(int)GetCurrentInputIndex
{
	return _currentInputIndex;
}

-(void)ResetState
{
	_probebDescArray[Input1].isActive	= FALSE; 	
    
    
	_probebDescArray[Input2].isActive	= FALSE;  
        
	_probebDescArray[Output1].isActive	= FALSE;  
	_probebDescArray[Output2].isActive	= FALSE; 
   
	_probebDescArray[Input1].isActionRunning	= FALSE; 	
	_probebDescArray[Input2].isActionRunning	= FALSE;  
	_probebDescArray[Output1].isActionRunning	= FALSE;  
	_probebDescArray[Output2].isActionRunning	= FALSE; 
	
}

#pragma mark -
#pragma mark private methods

-(id) initWithInput1Index:(int) index
{
	self = [super init];
	
	if (self) {
		
		for(int i=1;i<4;i++)
		{
			_probebDescArray[i].index = -1;
			_probebDescArray[i].isNull = TRUE;
			_probebDescArray[i].isActive = FALSE;	
		}
		
		_probebDescArray[Input1].index	= index;  //init input1 to index - init other input \ outputs to -1
		_probebDescArray[Output1].index = index;
		_currentInputIndex				= index;
		_probeType						= Single;
		
		
	}
	
	return self;
}

-(id) initWithOneInputTwoOutput:(int) index 
{
	self = [super init];
	
	if (self) {
		
		_probeType						= SingleInputTwoOutput;
		_probebDescArray[Input1].index	= index+1;  
		
		_probebDescArray[Input2].index	= index+1; 		
		_probebDescArray[Output1].index = index;
		_probebDescArray[Output2].index = index+2;
		_currentInputIndex				= _probebDescArray[Output2].index;
	}
	
	return self;
}

-(id) initWithTwoInputOneOutput:(int) index
{
	self = [super init];
	
	if (self) {
		
		_probeType						= TwoInputSingleOutput;
		_probebDescArray[Input1].index	= index;  
		
		_probebDescArray[Input2].index	= index+2; 		
		_probebDescArray[Output1].index = index+1;
		
		_currentInputIndex				= _probebDescArray[Input2].index;
	}
	
	return self;
}

- (ProbeDesc *)ProbeDescs
{
    return _probebDescArray;
}


-(void)dealloc
{
//	[self.AnimArray release];
//	[self.ActionArray release];
	
	[super dealloc];
}

static Probe* GenerateOneInputOneOutputProbe(int index)
{
	Probe* probe = [ [Probe alloc] initWithInput1Index:index];
	
	probe.ProbeDescs[Input1].isNull = FALSE;
    
	
	
	
//		//int probe		=0;
//		
//		probe			= [Probe SetIsNull:probe isNull:FALSE type:Input1];
//		probe			= [Probe SetIsNull:probe isNull:TRUE type:Input2];
//		probe			= [Probe SetIndex:probe index:index type:Input1];
//		
//		
//		
//		probe.newProbe	= probe;
//		probe.nextIndex	= index + 1;
	
	
	return probe;
}

static Probe* GenerateBoostedProbe(int index)
{
	Probe* probe =  GenerateOneInputOneOutputProbe(index);
	
	probe.ProbeDescs[Input1].isBoosted = true;  
	
	return probe;
}

static Probe* GenerateInvertedProbe(int index)
{
	Probe* probe = GenerateOneInputOneOutputProbe(index);
	
	probe.ProbeDescs[Input1].isInverted = true;
	
	return probe;
}

static Probe* GenerateLatchedProbe(int index)
{
	Probe* probe = GenerateOneInputOneOutputProbe(index);
	
	probe.ProbeDescs[Input1].isLatched = true;
	
	return probe;
}

static Probe* GenerateOneInputTwoOutputProbe(int index)
{
	Probe* probe = [ [Probe alloc] initWithOneInputTwoOutput:index];
	
	return probe;
}

static Probe* GenerateTwoInputSingleOutputProbe(int index)
{
	Probe* probe = [ [Probe alloc] initWithTwoInputOneOutput:index];
	
	return probe;
}

@end