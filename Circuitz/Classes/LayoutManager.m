//
//  LayoutManager.m
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 11/06/2010.
//  Copyright 2010 Hackers. All rights reserved.
//

#import "LayoutManager.h"
#import "Probe.h"

@implementation LayoutManager

@synthesize CellSize=_cellSize;
@synthesize CellOrigin=_cellOrigin;
@synthesize WindowsRect=_windowsRect;


const int CELL_WIDTH	= 50;
const int CELL_HEIGHT	= 15;

const int INVERTER_WIDTH = 22;
const int INVERTER_HEIGHT = 13;

const int LATCH_WIDTH	= 5;
const int LATCH_HEIGHT	= 13;
const int BAR_WIDTH		= 12;
const int BAR_HEIGHT	= 78;

const int BOOSTED_WIDTH = 14;
const int BOOSTED_HEIGHT = 13;

const int PROBE_HEIGHT	= 5;
const int PULSE_HEIGHT	= 16;
const int LEFT_EDGE		= 50;
const int TOP_EDGE_Y	= 272;
const int STATUS_WINDOW_TOP = 310;


-(LayoutManager*)initWithWindowSize:(CGSize) windowSize
{
	self = [super init];
	
	if (self) {
		
		//x,y,w,h
		self.WindowsRect				= CGRectMake (LEFT_EDGE,TOP_EDGE_Y,windowSize.width-LEFT_EDGE,windowSize.height); 
		
		self.CellSize					= CGSizeMake(CELL_WIDTH	, CELL_HEIGHT);
								
		self.CellOrigin					= ccp(self.WindowsRect.size.width/2,TOP_EDGE_Y);
	}
	
	return self;	
}

-(int)GetFullWidth
{
	return  self.CellOrigin.x-(LEFT_EDGE);
}

-(CGPoint)GetPulsePosition:(CellColor)c
{
	CGPoint position;
	
	position.x = c==LeftSide?10:self.WindowsRect.size.width+10;
	position.y = STATUS_WINDOW_TOP;
	
	return position;
}

-(CGPoint)GetStandyByTextPosition
{
	return ccp([self WindowsRect].size.width/2+30,[self WindowsRect].size.height/2);	
}

-(CGPoint)GetStartLevelTextPosition
{
    CGPoint p = [self GetStandyByTextPosition];
    p.y-=20;
	return p;	
}

-(CGPoint)GetResultsTextPosition
{
	return [self GetStandyByTextPosition];
}

-(int)GetLeftSideXPos:(bool)isFullWidth
{
	int width	= isFullWidth ?[self GetFullWidth]:[self GetFullWidth]/2;

	return  self.WindowsRect.origin.x + (width/2);
}

-(int)GetRightSideXPos:(bool)isFullWidth;
{
	int width	= isFullWidth ?[self GetFullWidth]:[self GetFullWidth]/2;

	return (self.CellOrigin.x+CELL_WIDTH) + (width/2);
}

-(CGPoint)GetBarPosition:(char)inputIndex cellColor:(CellColor)c
{
	CGPoint pos;
	
	int yPos	= [self GetInputIndexYPosition:inputIndex]-10;
	
	pos			= c==LeftSide?CGPointMake([self GetBarLeftXPos],yPos):CGPointMake([self GetBarRightXPos],yPos);
	
	return pos;
}

-(int)GetBarLeftXPos
{
	return [self GetLeftSideXPos:TRUE];
}

-(int)GetBarRightXPos
{
	return [self GetRightSideXPos:TRUE];
}

-(CGPoint)GetTimerLabelPosition
{
	return  ccp((self.WindowsRect.size.width/2)+10,STATUS_WINDOW_TOP-12);
}

-(int)GetProbeHeight
{
	return PROBE_HEIGHT;
}

+(CGSize)GetInverterDimensions
{
	return CGSizeMake(INVERTER_WIDTH, INVERTER_HEIGHT);	
}

+(CGSize)GetBoostedDimensions
{
	return CGSizeMake(BOOSTED_WIDTH, BOOSTED_HEIGHT);
}

+(CGSize)GetLatchdDimensions
{
	return CGSizeMake(LATCH_WIDTH, LATCH_HEIGHT);
}

+(CGSize)GetMutexDimensions
{
	return CGSizeMake(LATCH_WIDTH, LATCH_HEIGHT);
}

+(CGSize)GetBarDimensions
{
	return CGSizeMake(BAR_WIDTH, BAR_HEIGHT);
}

-(NSMutableArray*)GetProbeSizeAndPosition:(Probe*)probe cellColor:(CellColor)c
{
	NSMutableArray* array = [[NSMutableArray alloc]init];
	
	int width;
	int input1Y,input2y,inputX;	
	int out1Y,out2Y;
	int outX;
	
	int fullWidth	= [self GetFullWidth];
	int halfWidth	= fullWidth / 2;	
		
	if ([probe GetProbeType]==Single) {
		
		inputX					= c==LeftSide?[self GetLeftSideXPos:TRUE]:[self GetRightSideXPos:TRUE];
		
		SpriteDim* input1Dim	= [SpriteDim alloc];
		
		input1Y					= [self GetInputIndexYPosition:probe.ProbeDescs[Input1].index];

		width					= fullWidth;
		
		input1Dim.size			= CGSizeMake(width,PROBE_HEIGHT);
		input1Dim.position		= CGPointMake(inputX,input1Y);
		
		[array addObject:input1Dim];
		
		[input1Dim release];

	}
	else if ([probe GetProbeType]==SingleInputTwoOutput){
		
		SpriteDim* input1Dim	= [SpriteDim alloc];
		SpriteDim* op1Dim		= [SpriteDim alloc];
		SpriteDim* op2Dim		= [SpriteDim alloc];
		
		input1Y					= [self GetInputIndexYPosition:probe.ProbeDescs[Input2].index];
		width					= halfWidth;
		
		inputX					= c==LeftSide?[self GetLeftSideXPos:FALSE]:[self GetRightSideXPos:FALSE]+ (halfWidth);
		
		out1Y					= [self GetInputIndexYPosition:probe.ProbeDescs[Output1].index];
		out2Y					= [self GetInputIndexYPosition:probe.ProbeDescs[Output2].index];		
		
		outX					= c==LeftSide? inputX + halfWidth:inputX-halfWidth;		
		
		input1Dim.size			= CGSizeMake(width,PROBE_HEIGHT);
		input1Dim.position		= CGPointMake(inputX,input1Y);
		
		op1Dim.size				= CGSizeMake(width,PROBE_HEIGHT);
		op1Dim.position			= CGPointMake(outX,out1Y);
		
		op2Dim.size				= CGSizeMake(width,PROBE_HEIGHT);
		op2Dim.position			= CGPointMake(outX,out2Y);

		[array addObject:input1Dim];
		[array addObject:op1Dim];
		[array addObject:op2Dim];
		
		[input1Dim release];
		[op1Dim release];
		[op2Dim release];
		
		
	}
	else if ([probe GetProbeType]==TwoInputSingleOutput){
		
		SpriteDim* input1Dim	= [SpriteDim alloc];
		SpriteDim* input2Dim	= [SpriteDim alloc];
		SpriteDim* op1Dim		= [SpriteDim alloc];
		
		input1Y					= [self GetInputIndexYPosition:probe.ProbeDescs[Input1].index];
		input2y					= [self GetInputIndexYPosition:probe.ProbeDescs[Input2].index];
		width					= halfWidth;
		
		inputX					= c==LeftSide?[self GetLeftSideXPos:FALSE]:[self GetRightSideXPos:FALSE]+ (halfWidth);
		
		out1Y					= [self GetInputIndexYPosition:probe.ProbeDescs[Output1].index];
			
		
		outX					= c==LeftSide? inputX + halfWidth:inputX-halfWidth;		
		
		
		input1Dim.size			= CGSizeMake(width,PROBE_HEIGHT);
		input1Dim.position		= CGPointMake(inputX,input1Y);
		
		input2Dim.size			= CGSizeMake(input1Dim.size.width,input1Dim.size.height);
		input2Dim.position		= CGPointMake(inputX,input2y);
		
		op1Dim.size				= CGSizeMake(width,PROBE_HEIGHT);
		op1Dim.position			= CGPointMake(outX,out1Y);
		
		[array addObject:input1Dim];
		[array addObject:input2Dim];
		[array addObject:op1Dim];
		
		[input1Dim release];
		[input2Dim release];
		[op1Dim release];
		
	}

		
	return [array autorelease];
}

-(float)GetInputIndexYPosition:(int)cellIndex
{
	return [self GetIndexYPosition:cellIndex]+self.CellSize.height/2;
}

-(float)GetIndexYPosition:(int)cellIndex
{
	return self.WindowsRect.origin.y -(cellIndex*(self.CellSize.height+(self.CellSize.height/2)));
}


@end
