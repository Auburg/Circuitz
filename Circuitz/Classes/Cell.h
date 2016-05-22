//
//  Cell.h
//  Circuitz
//
//  Created by Tanvir Kazi on 15/04/2010.
//  Copyright 2010 Hackers. All rights reserved.
//


#import "Types.h"

@class Cell;
@protocol CellDelegate

-(void)flashCompleteDelegate:(Cell*)cell;
-(void)CellCompleteDelegate:(Cell*)cell;

@end



@interface Cell : NSObject {
	
	@private
	CellColor origCellColor; 
	CellColor currentCellColor; 
    CellColor activationSide;
	CellColor activatedCellColor;
	CellState currentCellState;
    bool _isSlowFlash;
    bool _isFastFlash;
	int _duration;
	NSDate* _cellActivationStart;
	NSDate* _cellFlashStart;
	int _cellIndex;
	bool _isLatched;
	bool _isMutex;
    bool _isInverted;
    int _prevTick;
	//CellActivationCompletionBlock _completionBlock;
    

}

@property CellColor CurrentCellColor;
@property CellColor ActivationSide;
@property (assign) int CellIndex;
@property (nonatomic, assign) bool IsInverted;
@property (nonatomic, readonly) CellColor OrigCellColor;
//@property  (nonatomic) CellActivationCompletionBlock CompletionBlock;
@property (nonatomic, assign) id<CellDelegate> delegate;


-(Cell*) initWithCellColor:(CellColor) color index:(int)i isSlowFlash:(BOOL)s isFastFlash:(bool)f;


-(CellState)CellState;
-(void)SetLatched;

-(bool) activate:(CellColor) color activationSide:(CellColor)a duration:(int)d probedesc:(ProbeDesc)pd;

-(void) Reset;
-(bool) IsLatched;
-(bool) IsSlowFlash;

-(void)update;

-(NSString*)description;

@end
