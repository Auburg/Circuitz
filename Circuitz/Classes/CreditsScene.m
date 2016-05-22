//
//  CreditsScene.m
//  Circuitz
//
//  Created by Tanvir Kazi on 27/01/2012.
//  Copyright (c) 2012 Hackers. All rights reserved.
//

#import "CreditsScene.h"
#import "IntroScene.h"

@implementation CreditsScene


- (id)init {
	
	if ((self = [super init])) {
		
		CreditsLayer *layer = [CreditsLayer node];
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
#pragma mark CreditsLayer methods


@interface CreditsLayer()

-(void)InitBackground:(CGSize)windowSize;
-(void)InitLabels:(CGSize)windowSize;
-(void)timerCallBack:(ccTime) dt;
-(void)onMenu;
@end



@implementation CreditsLayer

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CreditsLayer *layer = [CreditsLayer node];
    
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
        
        _timerDelta = 0.1;
		
		[self schedule:@selector(timerCallBack:) interval:_timerDelta];
	}
	return self;
}

-(void)InitLabels:(CGSize)windowSize
{	
    
    CCLabelTTF* label1			= [CCLabelTTF labelWithString:@"Circuitz" fontName:@"ethnocentric" fontSize:18];
    label1.color		        = ccc3(120,1,0);

    CCLabelTTF* label2			= [CCLabelTTF labelWithString:@"Programming & Graphics" fontName:@"ethnocentric" fontSize:18];
    label2.color                = ccc3(120,236,0);
    
    CCLabelTTF* label3			= [CCLabelTTF labelWithString:@"Auburg" fontName:@"ethnocentric" fontSize:18];
    label3.color                = ccc3(120,236,111);
    
    CCLabelTTF* label4			= [CCLabelTTF labelWithString:@"Music & FX" fontName:@"ethnocentric" fontSize:18];
    label4.color                = ccc3(120,236,0);
    
    CCLabelTTF* label5			= [CCLabelTTF labelWithString:@"Courtesy of the following:" fontName:@"ethnocentric" fontSize:18];
    label5.color                = ccc3(120,236,0);
    
    CCLabelTTF* label6			= [CCLabelTTF labelWithString:@"chip115.wav" fontName:@"ethnocentric" fontSize:12];
    label6.color                = ccc3(120,236,111);
    
    CCLabelTTF* label7			= [CCLabelTTF labelWithString:@"www.freesound.org/people/HardPCM/" fontName:@"ethnocentric" fontSize:12];
    label7.color                = ccc3(120,236,111);
    
    CCLabelTTF* label8			= [CCLabelTTF labelWithString:@"flak-gun-sound.wav" fontName:@"ethnocentric" fontSize:12];
    label8.color                = ccc3(120,236,111);
    
    CCLabelTTF* label9			= [CCLabelTTF labelWithString:@"www.freesound.org/people/smcameron" fontName:@"ethnocentric" fontSize:12];
    label9.color                = ccc3(120,236,111);
    
    CCLabelTTF* label10			= [CCLabelTTF labelWithString:@"chip054.wav" fontName:@"ethnocentric" fontSize:12];
    label10.color               = ccc3(120,236,111);
    
    CCLabelTTF* label11			= [CCLabelTTF labelWithString:@"www.freesound.org/people/HardPCM/sounds/32954/" fontName:@"ethnocentric" fontSize:12];
    label11.color               = ccc3(120,236,111);
    
    CCLabelTTF* label12			= [CCLabelTTF labelWithString:@"laser.wav" fontName:@"ethnocentric" fontSize:12];
    label12.color               = ccc3(120,236,111);
    
    CCLabelTTF* label13			= [CCLabelTTF labelWithString:@"www.freesound.org/people/THE_bizniss/sounds/39459/" fontName:@"ethnocentric" fontSize:12];
    label13.color               = ccc3(120,236,111);


    
	label1.position  	        = ccp( windowSize.width /2  , 0);
    label2.position             = ccp( windowSize.width /2  , label1.position.y-80);
    label3.position             = ccp( windowSize.width /2  , label2.position.y-30);
    label4.position             = ccp( windowSize.width /2  , label3.position.y-40);
    label5.position             = ccp( windowSize.width /2  , label4.position.y-30);
    label6.position             = ccp( windowSize.width /2  , label5.position.y-30);
    label7.position             = ccp( windowSize.width /2  , label6.position.y-30);
    label8.position             = ccp( windowSize.width /2  , label7.position.y-30);
    label9.position             = ccp( windowSize.width /2  , label8.position.y-30);
    label10.position            = ccp( windowSize.width /2  , label9.position.y-30);
    label11.position            = ccp( windowSize.width /2  , label10.position.y-30);
    label12.position            = ccp( windowSize.width /2  , label11.position.y-30);
    label13.position            = ccp( windowSize.width /2  , label12.position.y-30);

    
    _labelsArray                = [[NSArray alloc]initWithObjects:label1,label2,label3,label4,label5,label6,label7,label8,label9,label10,label11,label12,label13 ,nil];
    
    for (CCLabelTTF* label in _labelsArray) {
        
        [self addChild:label];      
        
    }        
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {	
    
    UITouch *touch		= [touches anyObject];
	CGPoint location	= [touch locationInView:[touch view]];
	location			= [[CCDirector sharedDirector] convertToGL:location];
	
	if (CGRectContainsPoint([_menuLabel boundingBox],location)) {
        
        [self unschedule:@selector(timerCallBack:)];
        [_labelsArray release];
        _labelsArray = nil;
        
		[self onMenu];
	}
	 
}

-(void)onMenu
{
	CCScene * scene = [CCScene node];
	[scene addChild: [IntroScene node] z:0];
	
	[[CCDirector sharedDirector] replaceScene: scene];
}


-(void)InitBackground:(CGSize)windowSize
{    
    _menuLabel				= [CCSprite spriteWithFile:@"Menu.png"];
    
    [self addChild:_menuLabel];	
	
	_menuLabel.position     = ccp(windowSize.width-15,windowSize.height-10);
}



-(void)timerCallBack:(ccTime) dt
{
	for (CCLabelTTF* label in _labelsArray) {
        
        label.position = ccp(label.position.x , label.position.y+2);  
        
    }
    
    CGSize windowSize			= [[CCDirector sharedDirector] winSize];
    
    CCLabelTTF* lastLabel = [_labelsArray objectAtIndex:_labelsArray.count-1];
    
    if (lastLabel.position.y==windowSize.height+12) {
        [self onMenu];
    }
}


- (void)dealloc {
	
    
	[super dealloc];
}



@end
