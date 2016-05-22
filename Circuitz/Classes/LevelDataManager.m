//
//  LevelDataManager.m
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 08/02/2011.
//  Copyright 2011 Hackers. All rights reserved.
//

#import "LevelDataManager.h"

#pragma mark -
#pragma mark LevelDataManager interface

@interface LevelDataManager()

-(void)InitData;
-(void)ReadDataFile;
-(int)GetIndexFromString:(NSString*)s;
-(void)GetComponentValuesFromDesc:(NSString*)desc mainType:(ProbeType*)m inputType:(ProbeDesc*)p;
@end


@implementation LevelDataManager

//static LevelDataManager *sharedInstance = nil;

typedef enum   {Unknown, InLeftSide, InRightSide }ParserState;

#pragma mark -
#pragma mark Singleton methods


+ (LevelDataManager *)sharedInstance
{
    static LevelDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LevelDataManager alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

#pragma mark -
#pragma mark Public methods

-(LevelDataManager*)init
{
	self = [super init];
	
	if (self) 
	{
		
	}
	
	return self;
}

-(void)LoadLevelData:(int)level
{
    _currentLevel = level;
   //_currentLevel = 8;
	[self InitData];
	
	if (_levelDataFound) {
		[self ReadDataFile];
	}	
}

-(bool)GetProbeDesc:(int)currentProbeIndex side:(CellColor)s mainType:(ProbeType*)m inputType:(ProbeDesc*)p
{
	bool ret			= FALSE;
	NSMutableArray* a	= s==LeftSide?_leftInputs:_rightInputs;
	p->isActive			= p->isBoosted = p->isInverted = p->isLatched = p->isFlashSlow = p->isMutex = FALSE;
	
	for (int i=0; i<[a count]; i++) {
		
		NSString* elem = [a objectAtIndex:i];
		int probeIndex = [self GetIndexFromString:elem];
		
		if (currentProbeIndex==probeIndex) {
			ret=TRUE;
			
			[self GetComponentValuesFromDesc:elem mainType:m inputType:p];
			
			break;
		}
	}
	
	return ret;
}

-(void)dealloc
{
	[_levelDataPath release];
	[_rightInputs release];
	[_leftInputs release];
	[super dealloc];	
}

#pragma mark -
#pragma mark Private methods

-(void)GetComponentValuesFromDesc:(NSString*)desc mainType:(ProbeType*)m inputType:(ProbeDesc*)p
{
	NSArray* dataArray	= [desc componentsSeparatedByString: @","];
	
	if ([dataArray count]<=1) {
		return;
	}	
	
	if ([dataArray count]>=2) {
		
		NSString* mainTypeStr = [dataArray objectAtIndex:1];
		
		if ([mainTypeStr isEqualToString:@"SingleInputTwoOutput"])  {
			*m = SingleInputTwoOutput;
		}
		else if ([mainTypeStr isEqualToString:@"SingleInputTwoOutput"]){
			*m = SingleInputTwoOutput;
		}
		else if ([mainTypeStr isEqualToString:@"TwoInputSingleOutput"]){
			*m = TwoInputSingleOutput;
		}
		else if ([mainTypeStr isEqualToString:@"TwoInputSingleOutput"]){
			*m = TwoInputSingleOutput;
		}
		else if ([mainTypeStr isEqualToString:@"TwoInputTwoOutput"]){
			*m = TwoInputTwoOutput;
		}	
        
	}
	if ([dataArray count]>=3) {
		
		NSString* inputTypeStr = [dataArray objectAtIndex:2];
		
		if ([inputTypeStr isEqualToString:@"isBoosted"])  {
			p->isBoosted=TRUE;
		}
		else if ([inputTypeStr isEqualToString:@"isInverted"]){
			p->isInverted=TRUE;
		}
		else if ([inputTypeStr isEqualToString:@"isLatched"]){
			p->isLatched=TRUE;
		}
		else if ([inputTypeStr isEqualToString:@"isMutex"]){
			p->isMutex=TRUE;
		}
        else if([inputTypeStr isEqualToString:@"FlashSlow"])
        {
            p->isFlashSlow =TRUE;
        }
        else if([inputTypeStr isEqualToString:@"FlashFast"])
        {
            p->isFlashFast =TRUE;
        }
	}
    
    if ([dataArray count]>=4) {
        
        NSString* inputTypeStr = [dataArray objectAtIndex:3];
        
        if([inputTypeStr isEqualToString:@"FlashSlow"])
        {
            p->isFlashSlow =TRUE;
        }
        else if([inputTypeStr isEqualToString:@"FlashFast"])
        {
            p->isFlashFast =TRUE;
        }
    }
}

-(int)GetIndexFromString:(NSString*)s
{
	int index			= -1;
	
	if (s==nil) {
		return index;
	}
	
	NSRange startRange	= [s rangeOfString:@","];
	
	if (startRange.location==NSNotFound) {
		return index;
	}
	
	NSString* str		= [s substringToIndex:startRange.location];
	
	index				= [str intValue];
	
	return index;
}

-(void)InitData
{
	NSString* file				= [NSString	stringWithFormat:@"%d",_currentLevel];
	_levelDataPath				= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:file];
	
	NSFileManager *fileManager	= [NSFileManager defaultManager];
	
	_levelDataFound				= [fileManager fileExistsAtPath:_levelDataPath];
	
}

-(bool)DoesLevelExist
{
    return _levelDataFound;
}

-(void)ReadDataFile
{
	
	if (_leftInputs != nil) {
		[_leftInputs release];
	}
	
	if (_rightInputs) {
		[_rightInputs release];
	}
	
	_leftInputs			= [[NSMutableArray alloc]initWithCapacity:12];
	_rightInputs		= [[NSMutableArray alloc]initWithCapacity:12];
    
    NSError* err;
	
	NSString* line      = [NSString stringWithContentsOfFile:_levelDataPath encoding:NSUTF8StringEncoding error:&err];    
    NSArray* dataArray  = [line componentsSeparatedByString:@"\n"];
	
	if ([dataArray count]==0) {
		return;
	}	
	
	NSString* leftSide	= @"LeftSide";
	NSString* rightSide	= @"RightSide";
	
	int index			= 0;
	ParserState state;
	
	if ([[dataArray objectAtIndex:0] isEqualToString:leftSide]) {
		state = InLeftSide;
		index++;
	}
	else {
		return;
	}

	
	while (index<[dataArray count]) {		
		
		
		if ([[dataArray objectAtIndex:index] isEqualToString:rightSide])  {
			index++;
			
			if (index==[dataArray count]) {
				return;
			}
			
			state=InRightSide;
		}
		
		switch (state) {
			case InLeftSide:	
				[_leftInputs addObject:[dataArray objectAtIndex:index]];
                
                NSLog([dataArray objectAtIndex:index]);
                
				break;
			case InRightSide:	
				[_rightInputs addObject:[dataArray objectAtIndex:index]];
				break;
			default:
				break;
		}	
		
		index++;		
	}
    
    NSLog(@"Exited ReadDataFile");
}
@end
