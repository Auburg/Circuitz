//
//  GameSettings.m
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 29/12/2010.
//  Copyright 2010 Hackers. All rights reserved.
//

#import "GameSettings.h"

@interface GameSettings()

-(void)InitGameData;
-(int)GetSetting:(NSString*)name;

@end

@implementation GameSettings

#define CURRENT_LEVEL_KEY "cl"
#define AlternateCellLimit "MaxAlternateCellLimit"
#define RightCellLimit "MaxRightCellLimit"
#define LeftCellImit  "MaxLeftCellLimit"
#define HardAILevelStart "HardAILevelStart"

@synthesize CurrentLevel;

#pragma mark -
#pragma mark init / dealloc methods

-(GameSettings*)init
{
	self = [super init];
	
	if (self) {
		
		NSArray *keys			= [NSArray arrayWithObjects:@CURRENT_LEVEL_KEY,@AlternateCellLimit,@RightCellLimit,@LeftCellImit,@HardAILevelStart,nil];
        CurrentLevel			= 0;
        
        NSNumber *defaultLevel	= [NSNumber numberWithInt:CurrentLevel];	
        NSNumber *defaultNumber = [NSNumber numberWithInt:0];        
        NSArray *objects		= [NSArray arrayWithObjects:defaultLevel,defaultNumber,defaultNumber,defaultNumber,defaultNumber ,nil];
        
        _gameData				= [[NSDictionary alloc] initWithObjects:objects forKeys:keys];

		
		[self ReadDataFromFile];
	}
	
	return self;	
}

-(void)dealloc
{
	[_gameData release];
	[_gameDocPath release];
	[super dealloc];
}

#pragma mark -
#pragma mark public methods

-(int)GetStartLevel
{
	NSNumber *defaultLevel	= [_gameData objectForKey:@CURRENT_LEVEL_KEY];
	
	return [defaultLevel intValue];
}

-(int)GetHardAILevelStart
{
    return _hardAILevelStart;
}

-(void)ReadDataFromFile
{
    [self InitGameData];
}

-(CellConfig)GetCellConfig
{
    CellConfig cl;
    
    if (CurrentLevel<=_maxAlternateCellsLevel) {
        cl = Alternate;
    }
    else if(CurrentLevel>_maxAlternateCellsLevel && CurrentLevel <= _maxRightCellLevel)
    {
        cl = AllRight;
    }
    else
    {
        cl = Alternate;
    }
    
    return cl;
}

-(void)WriteDataToFile
{
	NSNumber *defaultLevel	= [NSNumber numberWithInt:CurrentLevel];
	
	[_gameData setValue:defaultLevel forKey:@CURRENT_LEVEL_KEY];	
	bool ret = [_gameData writeToFile: _gameDocPath atomically:YES];
    
    if (ret) {
        NSLog(@"Wrote game data to file");
    }
    else
    {
        NSLog(@"Failed to write game data to file");
    }
}


#pragma mark -
#pragma mark private methods
 
-(void)InitGameData
{
	NSError *error;
	NSArray *paths					= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
	NSString *documentsDirectory	= [paths objectAtIndex:0]; //2
    
    if (_gameDocPath != nil) {
        [_gameDocPath release];
    }
    
	_gameDocPath					= [[documentsDirectory stringByAppendingPathComponent:@"GameInfo.plist"]retain]; //3
    
    //NSLog(@"Entered InitGameData, doc path is %@",_gameDocPath);
	
	NSFileManager *fileManager		= [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath: _gameDocPath]) //4
	{
		NSString *bundle = [[NSBundle mainBundle] pathForResource:@"GameInfo" ofType:@"plist"]; //5
		
		[fileManager copyItemAtPath:bundle toPath: _gameDocPath error:&error]; //6
	}
	else {
		
		[_gameData release];
		_gameData               = [[NSMutableDictionary alloc] initWithContentsOfFile: _gameDocPath];
        
        CurrentLevel            = [self GetSetting:@CURRENT_LEVEL_KEY];
        
        _maxAlternateCellsLevel = [self GetSetting:@AlternateCellLimit];
        _maxRightCellLevel      = [self GetSetting:@RightCellLimit];
        _maxLeftCellLevel       = [self GetSetting:@LeftCellImit];
        _hardAILevelStart       = [self GetSetting:@HardAILevelStart];
	}
    
    //[paths release];
}

-(int)GetSetting:(NSString*)name
{
    NSNumber *defaultLevel	= [_gameData objectForKey:name];
    
    return [defaultLevel intValue];

}

@end
