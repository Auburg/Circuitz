//
//  CircuitGameObj.h
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 03/05/2010.
//  Copyright 2010 Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "Cell.h"
#import "Types.h"
#import "Probe.h"
#import "GameSettings.h"

@class CPU;

@interface CircuitGameObj : NSObject {


@private
	
	NSDate* _gameStart;
	GameSettings* _gameSettings;
	GameState _gameState;
	NSMutableArray* _cells;
	//NSMutableArray* _rightSideInputs;
	CPU* _cpu;
	AILevel _currentAILevel;
	RightProbeActivateBlock _rightProbeActiveBlock;
    TimerCountdownBlock _timerActiveBlock;
	
	int STARTING_DURATION;
	int ENDING_DURATION;
	int _numLeftHandPulses;
	int _numRightHandPulses;
	int _leftPulseIndex;
	int _rightPulseIndex;
	int _firstRightProbeIndex;
	int _lastRightProbeIndex;
	int _maxDur;
}

@property (nonatomic, retain) NSMutableArray *LeftSideInputs;
@property (nonatomic, retain) NSMutableArray *RightSideInputs;
@property (nonatomic, retain) NSMutableArray *Cells;
@property  (nonatomic, copy)  RightProbeActivateBlock RightProbeActiveBlock;
@property  (nonatomic, copy)  TimerCountdownBlock TimerActiveBlock;
@property int LeftHandPulses;
@property int RightHandPulses;
@property int LeftPulseIndex;
@property int RightPulseIndex;
@property int FirstRightProbeIndex;
@property int LastRightProbeIndex;
@property int MaxDuration;

+(int)MaxCells;
/** returns a shared instance */
+(CircuitGameObj *)sharedInstance;


-(CircuitGameObj*)init;
-(GameState)GetGameState;
-(Cell*)RetrieveCellFromIndex:(int)index;
-(void)ActivateRightProbe;
-(Probe*) GetProbeAtIndex:(int)index side:(CellColor)c;
-(Probe*) GetProbeMatchingOutputIndex:(int)index side:(CellColor)c;
-(int) GetGameTimeElapsed;
-(int) GetNextProbeIndex:(int)currentIndex swipeDir:(Direction)dir side:(CellColor)c;
-(void)startGame;
-(void)update:(BOOL) tapDetected;
-(void)RunGame;
-(void)stopGame;
-(void)CompleteGame;
-(void)dealloc;
-(GameResult)GetGameResult;
-(int)GetStartLevel;
-(void)SetStartLevel:(int)level;
-(void)AdvanceLevel;
-(void)WriteDataToFile;
-(void)ReadDataFromFile;
-(bool)DoesLeftProbeExistAtOutputIndex:(int)index;
-(void)end;

@end
