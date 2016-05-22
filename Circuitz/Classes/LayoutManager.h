//
//  LayoutManager.h
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 11/06/2010.
//  Copyright 2010 Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Types.h"
#import "Probe.h"
#import "SpriteDim.h"

@interface LayoutManager : NSObject {
	
		
@private
	CGSize _cellSize;
	CGPoint _cellOrigin;
	
	CGRect _windowsRect;
	
}

@property CGSize  CellSize;
@property CGRect  WindowsRect;
@property CGPoint CellOrigin;




-(LayoutManager*)initWithWindowSize:(CGSize) windowSize;
-(float)GetIndexYPosition:(int)cellIndex;
-(float)GetInputIndexYPosition:(int)cellIndex;
-(CGPoint)GetBarPosition:(char)inputIndex cellColor:(CellColor)c;
-(NSMutableArray*)GetProbeSizeAndPosition:(Probe*)probe cellColor:(CellColor)c;
-(int)GetProbeHeight;
-(CGPoint)GetPulsePosition:(CellColor)c;
-(CGPoint)GetStandyByTextPosition;
-(CGPoint)GetResultsTextPosition;
-(CGPoint)GetTimerLabelPosition;
-(int)GetBarLeftXPos;
-(int)GetBarRightXPos;
-(int)GetFullWidth;
-(int)GetRightSideXPos:(bool)isFullWidth;
-(int)GetLeftSideXPos:(bool)isFullWidth;;
-(CGPoint)GetStartLevelTextPosition;

+(CGSize)GetInverterDimensions;
+(CGSize)GetBoostedDimensions;
+(CGSize)GetLatchdDimensions;
+(CGSize)GetBarDimensions;

@end
