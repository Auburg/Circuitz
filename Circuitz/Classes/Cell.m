//
//  Cell.m
//  Circuitz
//
//  Created by Tanvir Kazi on 15/04/2010.
//  Copyright 2010 Hackers. All rights reserved.
//

#import "Cell.h"

@interface Cell()

-(void)TriggerCompletionBlock;
-(void)TriggerFlashCompletionBlock;

@end


@implementation Cell

@synthesize CurrentCellColor=currentCellColor;
@synthesize ActivationSide=activationSide;
@synthesize OrigCellColor=origCellColor;
//@synthesize CompletionBlock=_completionBlock;
@synthesize IsInverted=_isInverted;
@synthesize CellIndex=_cellIndex;
@synthesize delegate=_delegate;


-(Cell*) initWithCellColor:(CellColor) color index:(int)i isSlowFlash:(BOOL)s isFastFlash:(bool)f
{
	self = [super init];
	
	if (self) {
		origCellColor		= color;
		currentCellColor	= origCellColor;
		currentCellState	= Inactive;
		_isSlowFlash        = s;
        _isFastFlash        = f;
        self.CellIndex      = i;
	}
	
	return self;
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"cell index is %i orig color is %u current color is %i  ",_cellIndex,origCellColor,currentCellColor];
}

-(void) Reset
{
	self.CurrentCellColor	= origCellColor;
	currentCellState		= Inactive;
    
    //NSLog(@"cell %i reset to %i orig color is %i",_cellIndex,self.CurrentCellColor,self.OrigCellColor);
}

-(bool) IsLatched
{
    return _isLatched;
}

-(bool) IsSlowFlash
{
    return _isSlowFlash;
}

-(bool) activate:(CellColor) color activationSide:(CellColor)a duration:(int)d probedesc:(ProbeDesc)pd;
{
	/*
	 i - release curent input instance
	 ii - set to input param
	 iii - retain current input param	 */
    
	if ( currentCellState==Active && !self.IsInverted){// && !pd.isBoosted && !self.IsInverted && _isLatched) {
        
		return false;
	}
	else {
        
        if (!self.IsInverted) {
           // [self TriggerCompletionBlock];
        }
	}
    
    if (pd.isInverted) {
        self.IsInverted = true;
    }
    else if(self.IsInverted)
    {
        //currentCellColor	= color;  
        currentCellColor	= color==LeftSide?RightSide:LeftSide;

        
    }
    else if(!_isSlowFlash)
    {
        currentCellColor	= color;
        activatedCellColor	= color;
        
    }
	
	currentCellState	= Active;
	
	
	_duration			= d;
    _prevTick           = 0;
	
	if (currentCellColor != color && _isLatched) {
        
        return false;
	}
    
    if (pd.isLatched) {
        [self SetLatched];
    }
	
	if (pd.isLatched || pd.isMutex) {
        
        
		_duration = -1;
	}
	
	//if this is the same color as the original colour and this is a mutex, 
	if (currentCellColor==origCellColor && pd.isMutex) {
		_duration = 650000;
	}
	
	if (_cellActivationStart!=nil) {
		[_cellActivationStart release];
	}
	
	
    self.ActivationSide = a;
	
	_cellActivationStart = [[NSDate alloc] initWithTimeIntervalSinceNow:_duration];
    
    return true;	
}


-(void) setColor:(CellColor) newColor
{
	currentCellColor = newColor;
}

-(CellState)CellState
{
	return currentCellState;
}

-(void)SetLatched
{
	_isLatched = TRUE;
}

-(void)update
{
    if (_isSlowFlash &&  [self CellState]==Inactive) {
        
        if (_cellFlashStart == nil) {
            
            _cellFlashStart = [[NSDate alloc] initWithTimeIntervalSinceNow:1];
            
            return;
        }
        else
        {
            
            NSDate* d = [NSDate date];
            
            if ([d compare:_cellFlashStart]==NSOrderedDescending) 
            {
                self.CurrentCellColor = self.CurrentCellColor == LeftSide?RightSide:LeftSide;
                
                [self TriggerFlashCompletionBlock];
                
                [_cellFlashStart release];
                
                _cellFlashStart = nil;           
            }
            
        }
    }
    else if ([self CellState]==Active) {
        
		NSTimeInterval interval = [_cellActivationStart timeIntervalSinceNow];
        
        if ((int)interval==0) 
        {
            [self TriggerCompletionBlock];
            
            [self Reset];
        }	
	}
}

-(void)TriggerCompletionBlock
{
	self.IsInverted = false;
    
    [self.delegate CellCompleteDelegate:self];

}

-(void)TriggerFlashCompletionBlock
{
    [self.delegate flashCompleteDelegate:self]; 
}

-(void)dealloc
{
	[_cellActivationStart release];
	//[self.CompletionBlock release];
    
	[super dealloc];
	
}



@end
