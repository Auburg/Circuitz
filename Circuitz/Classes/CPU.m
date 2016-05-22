//
//  CPU.m
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 04/10/2010.
//  Copyright 2010 Hackers. All rights reserved.
//

#import "CPU.h"
#import "CircuitGameObj.h"

@interface CPU()

-(void)Run;

-(void)UpdateIdlePos;
-(void)UpdateLocatingPos;
-(void)FindNextInputProbe;
-(void)BasicFind;
-(void)IntermediateFind;
-(void)AdvancedFind;
-(void)SetRightProbeIndex:(Probe*)p;
-(void)ActivateProbe;
-(void)InitProbeTables;
-(BOOL)ShouldActivateCell:(int)index;

-(Probe*)IndexOfAvailableProbeInQueue:(NSMutableArray*)inputsQueue;

@end


@implementation CPU

const int DELTA					= 1;
const int MAX_SELECTED_PROBES	= 4;

#define GETPROBEFROMARRAY(i) ( [[CircuitGameObj sharedInstance].RightSideInputs objectAtIndex:i])
#define GETPROBEATINDEX(i) ( [[CircuitGameObj sharedInstance] GetProbeAtIndex:i side:RightSide])
#define GETNEXTPROBEINDEX(i,d) ([[CircuitGameObj sharedInstance] GetNextProbeIndex:i swipeDir:d side:RightSide])

#define GETRIGHTPROBEINDEX ([CircuitGameObj sharedInstance].RightPulseIndex)	
#define PROBEINDEXMATCH(p,t) p.ProbeDescs[t].index==CircuitGameObj sharedInstance].RightPulseIndex
#define ISPROBEACTIVE(p,t) (p.ProbeDescs[t].isActive)
#define SETRIGHTPROBEINDEX(i) ([CircuitGameObj sharedInstance].RightPulseIndex=i)
#define MAX_PROBES ([[[CircuitGameObj sharedInstance].RightSideInputs]count])
#define GETCELLCOLORATINDEX(i) ([[[CircuitGameObj sharedInstance]RetrieveCellFromIndex:i] OrigCellColor])
#define DOESLEFTPROBEEXIST(i) ([[CircuitGameObj sharedInstance]DoesLeftProbeExistAtOutputIndex:i])

#pragma mark -
#pragma mark CPU Init \ dealloc

-(CPU*) init
{
	self = [super init];
	
	if (self) {
		_cpuState		= Idle;
		
		//__block Probe* p=nil;
//		
//		_probeTest= Block_copy(^ (id obj, NSUInteger idx, BOOL *stop) 
//		{
//			p = (Probe*)obj;
//			if ((!ISPROBEACTIVE(p,Input1) && !ISPROBEACTIVE(p,Input2))) {
//				
//				
//				return YES;
//			} 
//			
//			return NO;
//			
//		});
	}
	
	return self;
}

-(void)dealloc
{	//Block_release(_probeTest);
	
	[super dealloc];	
}

#pragma mark -
#pragma mark Public methods

-(void)Start:(AILevel)level
{
	if (!_initialised) {
		
		_aiLevel					= level;
		
		_probeIndexDirection		= Down;
		
		_cpuState					= Idle;
		
		_initialised				= TRUE;
		
		_currentInputsQueue			= Ideal;
		
		_currentCPUProbeIndex		= 0;		
				
		[self InitProbeTables];
		
		[self performSelector:@selector(Run) withObject:nil afterDelay:DELTA];		
	}
}

-(void)Stop
{
	[_idealInputsArray release];
	[_medianInputsArray release];
	[_fallbackInputsArray release];
	_initialised = FALSE;
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(Run) object:nil];
	
}

-(bool)IsInitialised
{
	return _initialised;
}


#pragma mark -
#pragma mark Private methods

-(void)InitProbeTables
{
	_idealInputsArray		=  [[NSMutableArray alloc]init];
	_medianInputsArray		=  [[NSMutableArray alloc]init];
	_fallbackInputsArray	=  [[NSMutableArray alloc]init];	
	
	
	int index1;
	int index2;
	CellColor c1,c2;
	
	for (Probe *probe in [CircuitGameObj sharedInstance].RightSideInputs) {
		
		ProbeType t = [probe GetProbeType];
		
		switch (t) 
		{
			case Single:	
				
				index1	= probe.ProbeDescs[Output1].index;
				c1		= GETCELLCOLORATINDEX(index1);
                
//                if (c1==RightSide) {
//                    break;
//                }
				
				
				if (probe.ProbeDescs[Input1].isInverted && c1==RightSide) {
					
					[_idealInputsArray addObject:probe];
				}
				else 
				{
					//If no corresponding left probe exists, prioritise this probe if its output is of the opposite color
					if (((!DOESLEFTPROBEEXIST(index1) && (c1==LeftSide)) || (c1==LeftSide) || (probe.ProbeDescs[Input1].isMutex))) {
						[_idealInputsArray addObject:probe];
					}
					else 
                    {
						[_medianInputsArray addObject:probe];
					}					
				}
								
				break;
				
			case SingleInputTwoOutput:
				
                index1  = probe.ProbeDescs[Output1].index;
				index2	= probe.ProbeDescs[Output2].index;
                c1      = GETCELLCOLORATINDEX(index1);
				c2		= GETCELLCOLORATINDEX(index2);
                
                if (c1==RightSide && c2==RightSide) {
                    break;
                }
				
				//If there's no corresponding left probes for these outputs and the cell colors are already Right,
				//then this probe is superfluous
				if ((!DOESLEFTPROBEEXIST(index1) && !DOESLEFTPROBEEXIST(index2))&&
					(c1==RightSide && c2==RightSide)) {
					
					[_fallbackInputsArray addObject:probe];					
				}
				else {
					[_idealInputsArray addObject:probe];
				}
				
				break;
				
			case TwoInputTwoOutput:
				
				[_fallbackInputsArray addObject:probe];	
				
				break;
				
			default:
				break;
		}	
	}	
    
}

-(BOOL)ShouldActivateCell:(int)index
{
    BOOL ret = true;
    
    Cell* cell =[[CircuitGameObj sharedInstance]RetrieveCellFromIndex:index];
    
    if (cell==NULL) {
        return ret;
    }
    
    if ([cell IsSlowFlash] && [cell CurrentCellColor]==LeftSide) {
        ret = FALSE;
    }
    
    return ret;
}

-(void)Run
{
	/*
	 If in idle state, do the following :
	 - Attempt to find suitable input probe to activate. If suitable probe found, switch state to Locating
	 - If no probe found this iteration, then adjust circuitgameObj RightPulseIndex either up or down to make it look like
	 - CPU is idle
	 
	 If in Locating state, do the following :
	 - Move RightPulseIndex up or down depending on index of selected probe. If RightPulseIndex == index of target probe, activate probe.
	 See if current input probe is 2-input single output probe - if so set next input to be next probe input if not already activated.
	 Otherwise, set state to idle.
	 	 
	 */	
	
	if (_cpuState==Idle) {
		[self FindNextInputProbe];
		
		if (_cpuState==Idle) {
			
			[self UpdateIdlePos];
			
//			NSLog(@"probe found");
//
//			NSLog(@"Idle %d",[CircuitGameObj sharedInstance].RightPulseIndex);	
		}
	}
	
	if (_cpuState==Locating) {
        
		[self UpdateLocatingPos];
	}
	
    double delay = _aiLevel==Basic?DELTA:0.5;
    
	[self performSelector:@selector(Run) withObject:nil afterDelay:delay];	
}

-(void)UpdateIdlePos
{
	bool changedDir = FALSE;
	
	_currentCPUProbeIndex= GETNEXTPROBEINDEX(_currentCPUProbeIndex,_probeIndexDirection);	
	
	if (_probeIndexDirection==Down) {
		
		if (_currentCPUProbeIndex>([CircuitGameObj sharedInstance].LastRightProbeIndex)) {
			_probeIndexDirection = Up;
			changedDir = TRUE;
			
			
		}
	}
	if (_probeIndexDirection==Up) {
		
		if (_currentCPUProbeIndex<([CircuitGameObj sharedInstance].FirstRightProbeIndex)) {
			
			_probeIndexDirection = Down;
			changedDir = TRUE;
		}
	}
	
	if (changedDir) {
		_currentCPUProbeIndex= GETNEXTPROBEINDEX(_currentCPUProbeIndex,_probeIndexDirection);
	}
	
	Probe* currentProbe	= GETPROBEATINDEX(_currentCPUProbeIndex);
	
	[self SetRightProbeIndex:currentProbe];
	
}

-(void)UpdateLocatingPos
{
	if (_currentCPUProbeIndex == _locatedProbeInputIndex && [self ShouldActivateCell:_currentCPUProbeIndex]) {		
		[self ActivateProbe];
	}
	else {
		if (_currentCPUProbeIndex<_locatedProbeInputIndex) {
			
			_probeIndexDirection = Down;
			
			
		}
		else {
			_probeIndexDirection = Up;
			
		}
		
		_currentCPUProbeIndex =  GETNEXTPROBEINDEX(_currentCPUProbeIndex,_probeIndexDirection);
		
		Probe*p	= GETPROBEATINDEX(_currentCPUProbeIndex);	
		
		[self SetRightProbeIndex:p];
	}
}

-(void)ActivateProbe
{
	//NSLog(@"probe found,activating probe index %d", [CircuitGameObj sharedInstance].RightPulseIndex);
	[[CircuitGameObj sharedInstance]ActivateRightProbe];
	_cpuState				= Idle;
	
}
				
-(void)SetRightProbeIndex:(Probe*)p
{
	if ([p GetProbeType]==TwoInputSingleOutput) 
	{
		if (_probeIndexDirection==Down) {
			
			if (GETRIGHTPROBEINDEX<p.ProbeDescs[Input1].index) {
				SETRIGHTPROBEINDEX(p.ProbeDescs[Input1].index);
			}
			else {
				SETRIGHTPROBEINDEX(p.ProbeDescs[Input2].index);
			}

		}
		else {
			
			if (GETRIGHTPROBEINDEX>p.ProbeDescs[Input2].index) {
				SETRIGHTPROBEINDEX(p.ProbeDescs[Input2].index);
			}
			else {
				SETRIGHTPROBEINDEX(p.ProbeDescs[Input1].index);
			}
		}
	}
	else 
	{
		SETRIGHTPROBEINDEX(p.ProbeDescs[Input1].index);
	}
			
}

-(void)FindNextInputProbe
{
	if ([CircuitGameObj sharedInstance].RightHandPulses==0) {
		return;
	}
		 
	switch (_aiLevel) {
		case Basic:
			[self BasicFind];
			break;
		case Inter:
			[self IntermediateFind];
			break;
		case Advanced:
			[self BasicFind];
			break;
		default:
			break;
	}
}

-(Probe*)IndexOfAvailableProbeInQueue:(NSMutableArray*)inputsQueue
{
	NSArray* sortedArray =  [inputsQueue sortedArrayUsingComparator:^(id p1,id p2)
    {
        Probe* probe1 = (Probe*)p1;
        Probe* probe2 = (Probe*)p2;
        
        return probe1.ActivationCount>probe2.ActivationCount;
        
    }];
	
	for (int i=0;i<[sortedArray count];i++)
	{
		Probe* p = [sortedArray objectAtIndex:i];
        
		if (!ISPROBEACTIVE(p,Output1) && !ISPROBEACTIVE(p,Output2)) {
		
			return p;	
            
		} 
			
	}
	
	return nil;
}

- (void)BasicFind
{
	_locatedProbeInputIndex	= -1;
	//bool found = FALSE;
	bool isFallBack=FALSE;
	NSMutableArray* nextInputsQueue;
	
	//InputsQueue tempQueue;
	NSMutableArray* currentQueue = nil;//	= side==LeftSide?self.LeftSideInputs:self.RightSideInputs;
	
	//test if the current index is >= current queue count. If so, move to the next queue and perform search
	//If not increment
	
	switch (_currentInputsQueue) {
		case Ideal:
			currentQueue	= _idealInputsArray;
			nextInputsQueue	= _medianInputsArray;
			//tempQueue		= Median;
			
			break;
		case Median:
			currentQueue	= _medianInputsArray;
			nextInputsQueue	= _fallbackInputsArray;
			
			
			break;
		case FallBack:
			currentQueue	= _fallbackInputsArray;
			nextInputsQueue	= _idealInputsArray;
			//tempQueue		= Ideal;
			isFallBack		= TRUE;
			break;
	
		default:
			break;
	}
	
	Probe* p = [self IndexOfAvailableProbeInQueue:currentQueue];
	
	if (p!=nil) {
		
		//found = TRUE;
	}
	else {
		
		if (isFallBack) 
        {
			//Even though we're meant to be searching through the fallback queue, have a look at the other 2 queues for any possible
			//active probes (its not called a fallback queue for nothing ;-)
			p =   [self IndexOfAvailableProbeInQueue:_idealInputsArray];
			
			if (p==nil) {
				p = [self IndexOfAvailableProbeInQueue:_medianInputsArray];
				
				if (p==nil) 
				{
					p = [self IndexOfAvailableProbeInQueue:_fallbackInputsArray];
					
					if (p!=nil) 
					{
						_currentInputsQueue	= FallBack;
//						currentQueue		=_fallbackInputsArray;
//						found = TRUE;	
					}
										
				}
				else 
				{
					
					_currentInputsQueue = Median;
//					currentQueue		=_medianInputsArray;
//					found = TRUE;	
				}

			}
			else {
				
				_currentInputsQueue = Ideal;
//				currentQueue		=_idealInputsArray;
//				found = TRUE;
			}

		}
		else {
            
            p = [self IndexOfAvailableProbeInQueue:nextInputsQueue];
			
			if (p!=nil) 
			{
//				_currentInputsQueue = tempQueue; 
//				currentQueue		=nextInputsQueue;
//				
//				found = TRUE;					
			}
            else
            {
//                _currentInputsQueue	= Ideal;
//                nextInputsQueue	= _medianInputsArray;
            }
		}
	}
	
    
	if (p!=nil) {
		
		
		_locatedProbeInputIndex	= p.ProbeDescs[Input1].index;
		_cpuState		= Locating;
	}
	else {
        
		_cpuState = Idle;
	}
}
	 
	 
	 
	 
- (void)IntermediateFind
{
	
}

- (void)AdvancedFind
{
	
}

@end
