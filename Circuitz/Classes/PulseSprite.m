//
//  PulseSprite.m
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 29/06/2010.
//  Copyright 2010 Hackers. All rights reserved.
//

#import "PulseSprite.h"


@implementation PulseSprite


@synthesize CurrentIndex=_currentIndex;
@synthesize Rect=_rect;

const int LEFT_SIDE_PULSE_POS_X = 30;


+ (id)pulseSpriteTexture:(CCTexture2D *)texture Position:(CGPoint)pos
{
	PulseSprite* p	= [[self alloc] initWithTexture:texture];
	
	p.position		= CGPointMake(pos.x,pos.y);
	
	return [p autorelease];
}

- (id)initWithTexture:(CCTexture2D *)aTexture
{
	if ((self = [super initWithTexture:aTexture]) ) {
		
		CGSize s = [aTexture contentSize];
		self.Rect =  CGRectMake(-s.width/2 , -s.height /2, s.width, s.height);
		
		//self.PulsePosition	= ccp(LEFT_SIDE_PULSE_POS_X,yPos);
	}
	
	return self;
}

-(void)SetYPos:(int)Y
{
	int x			= self.position.x;
	
	self.position	= CGPointMake(x,Y);
}


@end
