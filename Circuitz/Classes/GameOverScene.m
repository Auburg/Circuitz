//
//  GameOverScene.m
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 03/04/2011.
//  Copyright 2011 Hackers. All rights reserved.
//

#import "GameOverScene.h"

#pragma mark -
#pragma mark LevelLostOrDrawnLayer methods

@interface LevelLostOrDrawnLayer()

-(void)InitLayer;

@end

@implementation LevelLostOrDrawnLayer

- (id)init {
	
	if( (self=[super initWithColor: ccc4(0,0,0,255)]) ) {
        
        [[SimpleAudioEngine sharedEngine]preloadBackgroundMusic:@"71062__phr4kture__astrovapor.wav"];
		
		[self InitLayer];		
	}
	
	return self;
}

-(void)InitLayer
{
	CGSize windowSize		= [[CCDirector sharedDirector] winSize];
	
	CGPoint pos				=  ccp( windowSize.width /2  , 100);
	
	MenuLayer* menuLayer	= [[MenuLayer alloc]initShouldShowNext:FALSE atPosition:pos];
	
	[self addChild:menuLayer];
    
    [menuLayer release];
	
}

- (void)dealloc {
	
	[super dealloc];
}

@end



#pragma mark -
#pragma mark LevelWonLayer methods

@interface LevelWonLayer()

-(void)InitLayer;

@end

@implementation LevelWonLayer

- (id)init {
	
	if( (self=[super initWithColor: ccc4(0,0,0,255)]) ) {
        
        
		
		[self InitLayer];		
	}
	
	return self;
}

-(void)InitLayer
{
	CGSize windowSize		= [[CCDirector sharedDirector] winSize];
	
	CGPoint pos				=  ccp( windowSize.width /2  , 100);
	
	MenuLayer* menuLayer	= [[MenuLayer alloc]initShouldShowNext:true atPosition:pos];
	
	[self addChild:menuLayer];
    
    [menuLayer release];	
}

- (void)dealloc {
	
	[super dealloc];
}

@end


#pragma mark -
#pragma mark MenuLayer methods

@interface MenuLayer()

-(void)InitMenu:(bool)showNext  atPosition:(CGPoint)p;
-(void) alignMenusH;
-(void) menuCallbackBack: (id) sender;
-(void)InitBackground:(CGSize)windowSize;

@end

@implementation MenuLayer

-(id) init
{
	if( (self=[super initWithColor: ccc4(0,0,0,255)]) ) {
		
		CGSize windowSize		= [[CCDirector sharedDirector] winSize];
		
		CGPoint pos				=  ccp( windowSize.width /2  , 260);
        
        
		
		[self InitMenu:FALSE atPosition:pos];		
	}
	
	return self;
}

-(id) initShouldShowNext:(bool)b atPosition:(CGPoint)p
{
	if( (self=[super initWithColor: ccc4(0,0,0,255)]) ) {
        
        CGSize windowSize		= [[CCDirector sharedDirector] winSize];
        
        [self InitBackground:windowSize];
		
		[self InitMenu:b atPosition:p];		
        
        [[SimpleAudioEngine sharedEngine]playBackgroundMusic:@"71062__phr4kture__astrovapor.wav" loop:true];
	}
	
	return self;
}

-(void)InitMenu:(bool)showNext   atPosition:(CGPoint)p
{
	[CCMenuItemFont setFontName: @"ethnocentric"];
	[CCMenuItemFont setFontSize:18];
	CCMenu *menu = nil;
    
    
		
	if (showNext) {
		//CCMenuItemFont *item1	= [CCMenuItemFont itemFromString:@"Replay" target:self selector:@selector(menuCallbackBack:)];
		CCMenuItemFont *item1	= [CCMenuItemFont itemFromString:@"Next" target:self selector:@selector(menuCallbackBack:)];
		CCMenuItemFont *item2	= [CCMenuItemFont itemFromString:@"Menu" target:self selector:@selector(menuCallbackBack:)];
		
		item1.color				= item2.color  = ccc3(120,236,111);
		item1.tag				= Next;
		item2.tag				= Menu;
		
		
		menu					= [CCMenu menuWithItems:item1,item2, nil];
	}
	else {
		
		CCMenuItemFont *item1	= [CCMenuItemFont itemFromString:@"Replay" target:self selector:@selector(menuCallbackBack:)];
		CCMenuItemFont *item2	= [CCMenuItemFont itemFromString:@"Menu" target:self selector:@selector(menuCallbackBack:)];
				
		item1.color				= item2.color = ccc3(120,236,111);
		item1.tag				= Retry;
		item2.tag				= Menu;
		
		menu					= [CCMenu menuWithItems:item1,item2, nil];
	}

	
	
	[self addChild:menu z:0 tag:100];
	_centeredMenu			= p;
	
	
	_alignedH				= YES;
	[self alignMenusH];	
	
}

-(void)InitBackground:(CGSize)windowSize
{
	
	CCSprite *spback			= [(CCSprite*)[CCSprite alloc] init];
	[self addChild:spback];
	
	CCSprite *background		= [CCSprite spriteWithFile:@"EndGameBackground.png"];
	
	background.position			= ccp(windowSize.width/2, windowSize.height/2);
	//background.opacity			= 100;
	
    [self addChild:background];
    
    [spback release];
	
    
}

-(void) menuCallbackBack: (id) sender
{
	CCScene * scene = [CCScene node];
    
    [[SimpleAudioEngine sharedEngine]stopBackgroundMusic];
	
	switch ([sender tag]) {
			
		case Next:
			
			[[CircuitGameObj sharedInstance]AdvanceLevel];		
			
		case Retry:			
			
			[scene addChild: [MainGameScene node] z:0];
			[[CCDirector sharedDirector] replaceScene: scene];
			
			break;
			
		case Menu:	
			[[CCDirector sharedDirector] replaceScene:[IntroScene scene]];
            [[SimpleAudioEngine sharedEngine]playBackgroundMusic:@"intro.wav"];
			
			break;
		default:
			break;
	}
    
    
}

-(void) alignMenusH
{
	CCMenu *menu	= (CCMenu*)[self getChildByTag:100];
	menu.position	= _centeredMenu;
	// TIP: if no padding, padding = 5
	[menu alignItemsHorizontallyWithPadding:250];
	[menu alignItemsHorizontally];			
	CGPoint p		= menu.position;
	menu.position	= ccpAdd(p, ccp(0,80));
}

-(void) dealloc
{
	[super dealloc];
}


@end
