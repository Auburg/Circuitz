/*
 *  Types.h
 *  Circuitz
 *
 *  Created by Tanvir Kazi on 15/04/2010.
 *  Copyright 2010 Hackers. All rights reserved.
 *
 */

#import "cocos2d.h"

typedef void(^CellActivationCompletionBlock)(void);
typedef void(^RightProbeActivateBlock)(void);
typedef void(^TimerCountdownBlock)(void);

typedef enum   { LeftSide=1, RightSide=2 }CellColor;
typedef enum   { On, Off }InputState; 
typedef enum   {Up,Down,None}Direction;
typedef enum   {Basic,Inter,Advanced}AILevel;
typedef enum   {AllLeft,Alternate,AllRight}CellConfig;

typedef enum   { Inactive, Active, Intermediate }CellState;

typedef enum   { NotStarted,Started,Running,Stopped,Completed}GameState;
typedef enum   {Input1,Input2,Output1,Output2}ProbeIndex;
typedef enum   {Single,SingleInputTwoOutput,TwoInputSingleOutput,TwoInputTwoOutput,FlashSlow}ProbeType;
typedef enum   {PlayerWon,CPUWon,Deadlock}GameResult;


//typedef struct  {
//	CGSize size;
//	CGPoint position;
//}SpriteDims;

typedef struct {
	
	bool isNull;
	bool isBoosted;
	bool isInverted;
	bool isActive;
	bool isLatched;
	bool isMutex;
    bool isFlashSlow;
    bool isFlashFast;
	char index;	
	CCAnimation* animation;
	CCAction* action;
	bool isActionRunning;
}ProbeDesc;


