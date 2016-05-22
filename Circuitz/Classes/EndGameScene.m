//
//  EndGameScene.m
//  Circuitz
//
//  Created by Tanvir Kazi on 26/11/2011.
//  Copyright (c) 2011 Hackers. All rights reserved.
//

#import "EndGameScene.h"
#import "IntroScene.h"
#import "StringOps.h"

#pragma mark -
#pragma mark EndGameScene methods

@implementation EndGameScene


- (id)init {
	
	if ((self = [super init])) {
		
		EndGameLayer *layer = [EndGameLayer node];
		[self addChild:layer];
	}
	return self;
}

- (void)onExit
{
	[self removeAllChildrenWithCleanup:TRUE];
	[super onExit];
}

- (void)dealloc {
	//[_layer release];
	//_layer = nil;
	[super dealloc];
}

@end

#pragma mark -
#pragma mark EndGameLayer methods


@interface EndGameLayer()

-(void)InitBackground:(CGSize)windowSize;
-(void)InitLabels:(CGSize)windowSize;


@end


@implementation EndGameLayer

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	EndGameLayer *layer = [EndGameLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(0,0,0,255)] )) {
		
		// ask director the the window size		
		CGSize windowSize			= [[CCDirector sharedDirector] winSize];
        
		[self InitBackground:windowSize];
		[self InitLabels:windowSize];
		
		self.isTouchEnabled = YES;
		
		
	}
	return self;
}

-(void)InitLabels:(CGSize)windowSize
{	
    const char text1[] =
	"You have demonstrated a level of skill greater than coded for this AI. But the challenge has only begun...";
    
    NSString* nsText1			= [[NSString alloc] initWithBytes:text1 length:sizeof(text1) encoding:NSASCIIStringEncoding];
    
	CGSize containerSize		= [StringOps CalculateIdealSize:nsText1 font:@"ethnocentric" size:18];    
    
    CCLabelTTF* endMessage		= [StringOps InitLabelWithPreferredSize:nsText1 containerSize:containerSize fontSize:18];

	CCLabelTTF* label1          = [StringOps InitLabel:@"Well Done !" fontSize:18];
    
    label1.position             =  ccp( (windowSize.width /2)-40  , 260);
    endMessage.position			= ccp(windowSize.width/2  , 220);
    
    _menuLabel                  = [CCLabelTTF labelWithString:@"Return To Menu" fontName:@"ethnocentric" fontSize:16];
	_menuLabel.color            = ccc3(120,236,111);
    _menuLabel.position			= ccp(windowSize.width/2  , 160);

    [nsText1 release];
    
    [self addChild:label1];
    [self addChild:endMessage];
    [self addChild:_menuLabel];
    
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// Choose one of the touches to work with
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	if (CGRectContainsPoint([_menuLabel boundingBox],location)) 
    {
        CCScene * scene = [CCScene node];
        [scene addChild: [IntroScene node] z:0];
        
        [[CCDirector sharedDirector] replaceScene: scene];
		
	}	
	
}


-(void)InitBackground:(CGSize)windowSize
{
	
		
    
}


@end
