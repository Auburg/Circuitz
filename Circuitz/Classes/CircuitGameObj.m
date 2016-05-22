//
//  CircuitGameObj.m
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 03/05/2010.
//  Copyright 2010 Hackers. All rights reserved.
//

#import "CircuitGameObj.h"
#import "CPU.h"
#import "Probe.h"


@interface CircuitGameObj()

-(void)HandleLeftPulseTap;
-(void)UpdateCells;
-(bool)ActivateCell:(CellColor) cellColor;
-(void)InitNewGame;
-(void)GenerateProbes:(CellColor)side;
-(int)GetProbeIndex:(Probe*)p CurrentIndex:(int)i Direction:(Direction)d;
-(void)InitCells;
-(bool)IsSlowFlashInput:(int)index;
-(bool)IsFastFlashInput:(int)index;
-(void)ReleaseProbeResources:(NSMutableArray*)a;
@end


@implementation CircuitGameObj



#pragma mark -
#pragma mark Singleton methods

+ (CircuitGameObj *)sharedInstance
{
    static CircuitGameObj *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CircuitGameObj alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}



//+ (id)allocWithZone:(NSZone *)zone {
//	@synchronized(self) {
//	if (sharedInstance == nil) {
//			sharedInstance = [super allocWithZone:zone];
//			return sharedInstance; // assignment and return on first allocation
//			}
//	}
//	return nil; // on subsequent allocation attempts return nil
//}
//
//- (id)copyWithZone:(NSZone *)zone
//{
//	return self;
//}
//
//- (id)retain {
//	return self;
//}
//
//- (unsigned)retainCount {
//	return UINT_MAX; // denotes an object that cannot be released
//}
//
//- (void)release {
//	//do nothing
//}
//
//- (id)autorelease {
//	return self;
//}

#pragma mark -
#pragma mark init / dealloc methods

const int MAX_CELLS							= 12;

const int DEFAULT_CELL_ACTIVATION_DURATION	= 8;
const int BOOSTED_CELL_ACTIVATION_DURATION	= 12;

-(CircuitGameObj*)init
{
	self = [super init];
	
	if (self) {
		
		_currentAILevel			= Basic;
        
        _gameSettings			= [[[GameSettings alloc]init]retain];
                		
	}
	
	return self;	
}

-(void)dealloc
{
	[_gameSettings release];
	[super dealloc];
	
}

-(void)end
{
    [self ReleaseProbeResources:self.LeftSideInputs];
    [self ReleaseProbeResources:self.RightSideInputs];
    
    [_cells release];
	[self.LeftSideInputs release];
    [self.RightSideInputs release];
	[_gameStart release];
	[_cpu release];
	
	[_rightProbeActiveBlock release];
}

-(void)ReleaseProbeResources:(NSMutableArray*)a
{
    for (Probe* p in a )
    {
        [p.ProbeDescs[Input1].animation release];
        [p.ProbeDescs[Input2].animation release];
        [p.ProbeDescs[Output1].animation release];
        [p.ProbeDescs[Output2].animation release];
        
        [p.ProbeDescs[Input1].action release];
        [p.ProbeDescs[Input2].action release];
        [p.ProbeDescs[Output1].action release];
        [p.ProbeDescs[Output2].action release];
    }
}

#pragma mark -
#pragma mark Synthesized properties

@synthesize LeftSideInputs;
@synthesize RightSideInputs;

@synthesize LeftHandPulses=_numLeftHandPulses;
@synthesize RightHandPulses=_numRightHandPulses;

@synthesize LeftPulseIndex=_leftPulseIndex;
@synthesize RightPulseIndex=_rightPulseIndex;
@synthesize Cells=_cells;
@synthesize MaxDuration=_maxDur;
@synthesize RightProbeActiveBlock=_rightProbeActiveBlock;
@synthesize TimerActiveBlock=_timerActiveBlock;
@synthesize FirstRightProbeIndex=_firstRightProbeIndex;
@synthesize LastRightProbeIndex=_lastRightProbeIndex;


#pragma mark -
#pragma mark class methods

-(void)GenerateProbes:(CellColor)side
{
	int currentIndex	= 0;
	
	NSMutableArray* a	= side==LeftSide?self.LeftSideInputs:self.RightSideInputs;
	
	[a removeAllObjects];
	
	while (currentIndex<MAX_CELLS) {		
		
		Probe* p = [Probe GenerateProbe:side index:currentIndex]; 
		
		currentIndex = [p GetCurrentInputIndex];
		
		currentIndex++;
		
		[a addObject:p];
	}
	
	if (side==RightSide) {
		Probe* first				= [a objectAtIndex:0];
		Probe* last					= [a lastObject];
		self.FirstRightProbeIndex	= first.ProbeDescs[Input1].index;
		
		if ([last GetProbeType]==TwoInputSingleOutput) {
			self.LastRightProbeIndex	= last.ProbeDescs[Input2].index;
		}
		else {
			self.LastRightProbeIndex	= last.ProbeDescs[Input1].index;
		}
	}
	

	//[a release];
}

+(int)MaxCells
{
	return MAX_CELLS;
}

-(int) GetGameTimeElapsed
{
	if ([self  GetGameState]!=Running) 
	{
		return self.MaxDuration;
	}
	else 
	{
        return [_gameStart timeIntervalSinceNow];
	}
}

-(bool)DoesLeftProbeExistAtOutputIndex:(int)index
{
	bool ret = false;
	
	for (Probe *probe in [CircuitGameObj sharedInstance].LeftSideInputs	) 
	{
	  if ([probe GetProbeType]==SingleInputTwoOutput || [probe GetProbeType]==TwoInputTwoOutput) 
	  {
		  if (probe.ProbeDescs[Output1].index==index || probe.ProbeDescs[Output2].index==index) {
			  ret=TRUE;
			  break;
		  }
	  }
	  else 
	  {
		  if (probe.ProbeDescs[Output1].index==index) {
			  ret=TRUE;
			  break;
		  }	
		
	  }
	}
	
	return ret;
}

-(Cell*)RetrieveCellFromIndex:(int)index
{
	if (index>=0 && index <  MAX_CELLS) {
		
		return [self.Cells objectAtIndex:index];//_cells[index];
	}
	else {
		return nil;
	}
}

-(void)ActivateRightProbe
{
	if (self.RightHandPulses>0) {
		
		if(![self ActivateCell:RightSide]) return;
		
		self.RightHandPulses--;
		
		if (self.RightProbeActiveBlock != nil) {
			self.RightProbeActiveBlock();
		}
	}	
}

-(int) GetNextProbeIndex:(int)currentIndex swipeDir:(Direction)dir side:(CellColor)c
{
	
	int newIndex		= currentIndex;
	
	NSMutableArray* a	= c==LeftSide?self.LeftSideInputs:self.RightSideInputs;
    
    int maxProbes       = [a count]-1;
	
	if (dir==Down ) {
        
        Probe* lastProbe    = [a objectAtIndex:maxProbes];
        int maxProbeIndex   = [self GetProbeIndex:lastProbe CurrentIndex:maxProbes Direction:dir];
        
        //wrap round to the first probe if we're at the last index and going down
        if (currentIndex==maxProbeIndex) {
            
            Probe* p = [a objectAtIndex:0];
            
            return [self GetProbeIndex:p CurrentIndex:currentIndex Direction:dir];
        }
		
		for (Probe* p in a )
		{
			if (p.ProbeDescs[Input1].index>currentIndex) {
				newIndex = p.ProbeDescs[Input1].index;
				break;
			}

			if (p.ProbeDescs[Input2].index>currentIndex) {
				newIndex = p.ProbeDescs[Input2].index;
				break;
			}
		}
		
	}
	else if(dir==Up){
		
        Probe* firstProbe    = [a objectAtIndex:0];
        int firstProbeIndex  = [self GetProbeIndex:firstProbe CurrentIndex:0 Direction:dir];
        
        //wrap round to the last probe if we're at 0 index and going up
        if (currentIndex==firstProbeIndex) {
            
            Probe* p = [a objectAtIndex:maxProbes];
            
            return [self GetProbeIndex:p CurrentIndex:currentIndex Direction:dir];
        }
        
		for (int i= maxProbes; i>=0; i--) {
			
			Probe* p = [a objectAtIndex:i];
			
			if ([p GetProbeType]==TwoInputSingleOutput) {
                
                //TODO BUG - Logic doesn't work when going up - skips Input1 index
                if (p.ProbeDescs[Input2].index<currentIndex) {
                    newIndex = p.ProbeDescs[Input2].index;   
                    break;
                    
                }
                else if (p.ProbeDescs[Input1].index<currentIndex){
                    newIndex = p.ProbeDescs[Input1].index;   
                    break;
                }				
            }
            else {
                
                if (p.ProbeDescs[Input1].index<currentIndex) {
                    newIndex = p.ProbeDescs[Input1].index;          
                    break;
                }
            }
		}
		
	}
	
	return newIndex;
}

-(int)GetProbeIndex:(Probe*)p CurrentIndex:(int)i Direction:(Direction)d
{
    int index = -1;
    
    if ([p GetProbeType]==TwoInputSingleOutput && d==Up) {
        
        index = p.ProbeDescs[Input2].index; 			
    }
    else {
        
        index = p.ProbeDescs[Input1].index;  
    }
    
    return index;
}

/*
 
 Method:GetProbeAtIndex
 Desc:Gets the probe at a given index for a given type
 Args:  index - index to retrieve for
		Type  - The type of probe to retrieve (input1,input2 etc)
 Returns: The requested probe if found, otherwise -1
 
 */
-(Probe*) GetProbeAtIndex:(int)index side:(CellColor)c
{
	//assert(index<[[self LeftSideInputs]count]);
	NSMutableArray* a	= c==LeftSide?self.LeftSideInputs:self.RightSideInputs;
	
	for (Probe* p in  a) {
	
		if (p.ProbeDescs[Input1].index==index || p.ProbeDescs[Input2].index==index) {
			return p;
		}
	}
						
	return NULL;
}

-(Probe*) GetProbeMatchingOutputIndex:(int)index side:(CellColor)c
{
	//assert(index<[[self LeftSideInputs]count]);
	NSMutableArray* a	= c==LeftSide?self.LeftSideInputs:self.RightSideInputs;
	
	for (Probe* p in  a) {
        
		if (p.ProbeDescs[Output1].index==index || p.ProbeDescs[Output2].index==index) {
			return p;
		}
	}
    
	return NULL;
}


-(void)update:(BOOL) tapDetected
{
	NSTimeInterval interval =  [_gameStart timeIntervalSinceNow];	
	
	switch (_gameState) {
			
		case NotStarted:
			
			if (fabs(interval)>STARTING_DURATION) 
			{
				[self RunGame];				
			}	
						
			break;
			
			
		case Started:
			
			break;
			
		case Running:
			
			if (interval<=0) 
			{	
				[self stopGame];
			}
			else if(_gameState==Running)
			{
				
				//add game logic here
					
				if (tapDetected) {
						
					[self HandleLeftPulseTap];
				}
					
				[self UpdateCells];				
			}		
			
			break;
			
		case Stopped:
			
			if (interval<=0) 
			{
				[self CompleteGame];				
			}	
			
			break;
			
		default:
			break;
	}			
}

-(void)CompleteGame
{
	_gameState = Completed;	
}

-(void)RunGame
{
	_gameState = Running;
	
	[_gameStart release];
	
	_gameStart = [[NSDate alloc]
				  initWithTimeIntervalSinceNow:[self MaxDuration]];
    
    AILevel level = Basic;
	
	if(![_cpu IsInitialised])
	{
        if (_gameSettings.CurrentLevel>=_gameSettings.GetHardAILevelStart) {
            level = Advanced;
        }
        
		[_cpu Start:level];
	}	
}

-(void)startGame
{
    [self end];
	[self InitNewGame];	
	_gameState = NotStarted;
	_gameStart = [[NSDate alloc] init];
}

-(void)stopGame
{
	_gameState = Stopped;	
	
	[_cpu Stop];
	
	[_gameStart release];
	
	_gameStart = [[NSDate alloc]
				  initWithTimeIntervalSinceNow:ENDING_DURATION];
    
}

-(GameState)GetGameState
{
	return _gameState;	
}

-(GameResult)GetGameResult
{
	__block GameResult gameResult;
	__block int player1Cells=0;
	
	[_cells enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop) 
    { 
        Cell* c = (Cell*)obj;
        
        NSLog([c description]);
        
        if([obj CurrentCellColor]==LeftSide) 
        {
            
            player1Cells++;
        }
        
	}];
    
    NSLog(@"player cells won %d",player1Cells);

    
	if (player1Cells==MAX_CELLS/2) {
		gameResult=Deadlock;
	}
	else {
		gameResult = player1Cells>MAX_CELLS/2?PlayerWon:CPUWon;
	}
    
	return gameResult;
}

-(int)GetStartLevel
{
	return _gameSettings.CurrentLevel;
}

-(void)SetStartLevel:(int)level
{
    _gameSettings.CurrentLevel = level;
}

-(void)AdvanceLevel
{
	_gameSettings.CurrentLevel++;
	
	self.LeftHandPulses+=self.LeftHandPulses;
	
}

-(void)ReadDataFromFile
{
	[_gameSettings ReadDataFromFile];
}

-(void)WriteDataToFile
{
	[_gameSettings WriteDataToFile];
}

#pragma mark -
#pragma mark private methods



-(void) InitNewGame
{
    _cpu					= [[CPU alloc]init];
    _gameState				= NotStarted;
    
    
    _maxDur					= 20;
    STARTING_DURATION		= 1;
    ENDING_DURATION			= 2;
    self.Cells				= [[NSMutableArray alloc] initWithCapacity:MAX_CELLS];
    
    
    //[self InitCells];
    
    self.LeftSideInputs		= [[NSMutableArray alloc] init];	
    self.RightSideInputs	= [[NSMutableArray alloc] init];

    CellConfig cellConfig   = [_gameSettings GetCellConfig];
    
    if (cellConfig==Alternate) 
    {
        self.LeftHandPulses		= 5;
    }
    else if(cellConfig==AllRight)
    {
        self.LeftHandPulses		= 11;
        _maxDur = 12;
    }
    else
    {
        self.LeftHandPulses		= 4;
    }
        
    
    self.RightHandPulses	= 8;
	
	[Probe SetLevel:[self GetStartLevel]];   
    
	
	[self GenerateProbes:LeftSide];	
	[self GenerateProbes:RightSide];
    
    [self InitCells];
	
}

-(void)InitCells
{
    CellConfig cellConfig = [_gameSettings GetCellConfig];
    
    bool cellColorSet = false;
    
//	for(int i=0;i<MAX_CELLS;i++)
//	{
//		Cell* c = (Cell*)[self.Cells objectAtIndex:i];
//		[c Reset];
//		
//	}
    
//    for (Cell* c in self.Cells) {
//        [c release];
//    }
    
    [self.Cells removeAllObjects];
    
    CellColor currentColor;
    
    if (cellConfig!=Alternate) {
        
        cellColorSet = TRUE;
        currentColor = cellConfig==AllLeft?LeftSide:RightSide;
    }
    
    for (int i=0; i<MAX_CELLS; i++) 
    {
         if (!cellColorSet) {
             
             currentColor	= i%2==0?LeftSide:RightSide;
         } 
        
        bool isFlashSlow   = [self IsSlowFlashInput:i];
        bool isFastFlash   = [self IsFastFlashInput:i];
        
        Cell* cell         = [[Cell alloc] initWithCellColor:currentColor index:i  isSlowFlash:isFlashSlow isFastFlash:isFastFlash];
     
        [self.Cells insertObject:cell atIndex:i];
     
        [cell release];
     
     } 
}

-(bool)IsSlowFlashInput:(int)index
{
    for (Probe* p in self.LeftSideInputs) {
        
        if (p.ProbeDescs[Input1].index==index) {
            return p.ProbeDescs[Input1].isFlashSlow;
        }
        
    }
    
    return false;
}

-(bool)IsFastFlashInput:(int)index
{
    for (Probe* p in self.LeftSideInputs) {
        
        if (p.ProbeDescs[Input1].index==index) {
            return p.ProbeDescs[Input1].isFlashFast;
        }
        
    }
    
    return false;
}

-(void)HandleLeftPulseTap
{
	Probe* probe        = [self GetProbeAtIndex:self.LeftPulseIndex side:LeftSide];    
    int minimumInput    = probe.ProbeDescs[Input1].isLatched ? 2:1;    
	
	if (self.LeftHandPulses>=minimumInput) {
		
		if (![self ActivateCell:LeftSide]) {
            return;
        };
		
		self.LeftHandPulses-=minimumInput;
        
	}
}

-(bool)ActivateCell:(CellColor) cellColor
{
	int output1Index;
	int output2Index;
	int inputIndex		= cellColor==LeftSide?self.LeftPulseIndex:self.RightPulseIndex;
	BOOL activateCell	= FALSE;
	
	Probe* probe = [self GetProbeAtIndex:inputIndex side:cellColor];
	
	assert(probe != NULL);
    
	switch ([probe GetProbeType]) {
		case Single:
			
			//we implictly know that input index = output index for standard probe
			probe.ProbeDescs[Input1].isActive = probe.ProbeDescs[Output1].isActive = TRUE;			
			
			Cell* cell				= [self RetrieveCellFromIndex:probe.ProbeDescs[Input1].index];
			
			int cellActivationDur	= probe.ProbeDescs[Input1].isBoosted?BOOSTED_CELL_ACTIVATION_DURATION:DEFAULT_CELL_ACTIVATION_DURATION;
			
			
			if(![cell activate:cellColor activationSide:cellColor  duration:cellActivationDur probedesc:probe.ProbeDescs[Input1]]) return false; 
			
			probe.ProbeDescs[Output1].isActive = TRUE;
            			
			break;
		case SingleInputTwoOutput:
			
			output1Index			= probe.ProbeDescs[Output1].index;
			output2Index			= probe.ProbeDescs[Output2].index;
			Cell* cell1				= [self RetrieveCellFromIndex:output1Index];
			Cell* cell2				= [self RetrieveCellFromIndex:output2Index];
			
			probe.ProbeDescs[Input1].isActive = probe.ProbeDescs[Output1].isActive = 
			probe.ProbeDescs[Output2].isActive = FALSE;	
			
			bool b1 = [cell1 activate:cellColor activationSide:cellColor duration:DEFAULT_CELL_ACTIVATION_DURATION probedesc:probe.ProbeDescs[Output1]]; 
			bool b2 = [cell2 activate:cellColor activationSide:cellColor duration:DEFAULT_CELL_ACTIVATION_DURATION probedesc:probe.ProbeDescs[Output2]]; 
			
            if (b1) {
                probe.ProbeDescs[Output1].isActive = TRUE;
            }
			
            if (b2) {
                probe.ProbeDescs[Output2].isActive = TRUE;
            }
            
            if (!b1 && !b2) {
                return false;
            }
						
			break;
		case TwoInputSingleOutput:
			
			if (probe.ProbeDescs[Input1].index==inputIndex) 
			{
				if (!probe.ProbeDescs[Input1].isActive) 
				{
					probe.ProbeDescs[Input1].isActive = TRUE;
					
					if(probe.ProbeDescs[Input2].isActive == TRUE)
					{
						activateCell = TRUE;
					}
				}
			}
			else 
			{
				if(!probe.ProbeDescs[Input2].isActive)
				{
					probe.ProbeDescs[Input2].isActive = TRUE;
					
					if(probe.ProbeDescs[Input1].isActive == TRUE)
					{
						activateCell = TRUE;
					}
					
				}				
				
			}

			if (activateCell) {
				output1Index	= probe.ProbeDescs[Output1].index;
				
				
				Cell* cell1		= [self RetrieveCellFromIndex:output1Index];
				
				bool b1 = [cell1 activate:cellColor activationSide:cellColor duration:DEFAULT_CELL_ACTIVATION_DURATION probedesc:probe.ProbeDescs[Output1]]; 
				
                if (b1) {
                    probe.ProbeDescs[Output1].isActive = TRUE;
                }
                else
                {
                    return false;
                }
			}
				
			break;
		case TwoInputTwoOutput:
			
			break;


		default:
			break;
	}	
    
    return true;
}

-(void) UpdateCells
{
	int max = [CircuitGameObj MaxCells];
	
	for (int i=0; i<max; i++) 
	{
		Cell* cell = [self RetrieveCellFromIndex:i];
		
		[cell update];
	}
	
}

@end
