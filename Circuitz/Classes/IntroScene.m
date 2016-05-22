//
//  IntroScene.m
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 29/04/2010.
//  Copyright 2010 Hackers. All rights reserved.
//

#import "IntroScene.h"
#import	"MainGameScene.h"
#import "CircuitGameObj.h"
#import "HowToScenes.h"
#import "EndGameScene.h"
#import "CreditsScene.h"

@interface IntroScene()

-(void)InitBackground:(CGSize)windowSize;
-(void)InitLabels:(CGSize)windowSize;
-(void)ShowPlayer1Scene;
-(void)ShowHowToScene;
-(void)ShowCreditsScene;
-(void)timerCallBack:(ccTime) dt;


@end

const NSString* Title= @"Circuitz";
const float timerDelta = 0.1;

@implementation IntroScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroScene *layer = [IntroScene node];

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
		
		[self schedule:@selector(timerCallBack:) interval:timerDelta];
	}
	return self;
}

-(void)timerCallBack:(ccTime) dt
{
	if (++_timerCount==[Title length]) {
		[self unschedule:@selector(timerCallBack:)];
	}
	
	float length		= [Title length];
	
	float opacityIncrement = 1 / length;
	
	_newGameLabel.opacity+=(opacityIncrement * 255);
	_howToLabel.opacity+=(opacityIncrement * 255);
    _creditsLabel.opacity+=(opacityIncrement * 255);
    
    
	if (_currentLevel>0) {
		_continueGameLabel.opacity+=(opacityIncrement * 255);
	}
	
	
	[_titleStr appendFormat:@"%c", [Title characterAtIndex:_timerCount-1]];
	
	[_titleLabel setString:_titleStr];	
}


-(void)InitLabels:(CGSize)windowSize
{	
	_currentLevel = [[CircuitGameObj sharedInstance]GetStartLevel];
	
	NSLog(@"Current loaded level %d",_currentLevel);
	
	 //create and initialize  Labels
	_titleLabel				= [CCLabelTTF labelWithString:@"" fontName:@"ethnocentric" fontSize:18];
	_titleStr               =[[NSMutableString alloc] init];
	_titleLabel.color		= ccc3(120,1,0);
	_titleLabel.position	=  ccp( windowSize.width /2  , 260);
	
	_newGameLabel			= [CCLabelTTF labelWithString:@"New Game" fontName:@"ethnocentric" fontSize:18];
	_newGameLabel.color		= ccc3(120,236,111);
	
	if (_currentLevel>0) {
		
		_continueGameLabel			= [CCLabelTTF labelWithString:@"Continue Game" fontName:@"ethnocentric" fontSize:18];
		_continueGameLabel.opacity	= 0;
		_continueGameLabel.position	= ccp(_titleLabel.position.x,_titleLabel.position.y-60);
		_continueGameLabel.color	= _newGameLabel.color;
		[self addChild: _continueGameLabel z:1];
		_newGameLabel.position		= ccp(_continueGameLabel.position.x,_continueGameLabel.position.y-60);
	}
	else {
		_newGameLabel.position		= ccp(_titleLabel.position.x,_titleLabel.position.y-60);
	}	
	
	_newGameLabel.opacity	= 0;
	
	_howToLabel				= [CCLabelTTF labelWithString:@"How To Play" fontName:@"ethnocentric" fontSize:18];
	_howToLabel.color		= ccc3(120,236,111);
	_howToLabel.position	= ccp(_titleLabel.position.x,_newGameLabel.position.y-60);
	_howToLabel.opacity		= 0;
    
    _creditsLabel			= [CCLabelTTF labelWithString:@"Credits" fontName:@"ethnocentric" fontSize:18];
    _creditsLabel.color		= ccc3(120,236,111);
	_creditsLabel.position	= ccp(_howToLabel.position.x,_howToLabel.position.y-60);
	_creditsLabel.opacity	= 0;

    
	// add the label as a child to this Layer
	[self addChild: _titleLabel z:1];
	[self addChild:_newGameLabel z:1];
	[self addChild:_howToLabel z:1];
    [self addChild:_creditsLabel z:1];
	

}

-(void)InitBackground:(CGSize)windowSize
{
	
	CCSprite *spback			= [(CCSprite*)[CCSprite alloc] init];
	[self addChild:spback];
	
	CCSprite *background		= [CCSprite spriteWithFile:@"IntroBackground.png"];
	
	background.position			= ccp(windowSize.width/2, windowSize.height/2);
	background.opacity			= 100;
	
    [self addChild:background];
    
    [spback release];
	
		
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// Choose one of the touches to work with
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
    
	
	if (CGRectContainsPoint([_howToLabel boundingBox],location)) {
		[self ShowHowToScene];
        
	}	
	
	if (CGRectContainsPoint([_newGameLabel boundingBox],location)) {
        
        [[CircuitGameObj sharedInstance]SetStartLevel:0];
        
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        
		[self ShowPlayer1Scene];
        
	}
	
    if (CGRectContainsPoint([_continueGameLabel boundingBox],location)) {
        
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        
		[self ShowPlayer1Scene];
	}
    
    if (CGRectContainsPoint([_creditsLabel boundingBox], location)) {
        [self ShowCreditsScene];        
    }
   
}

-(void)ShowPlayer1Scene
{
	MainGameScene *mainGameScene = [MainGameScene node];
    
    [[CCDirector sharedDirector] replaceScene:mainGameScene];	
    
    [[SimpleAudioEngine sharedEngine]stopEffect:_introMusicID];
    
//    EndGameScene* scene = [EndGameScene node];
//    
//    [[CCDirector sharedDirector] replaceScene:scene];	
	
	
	
}

-(void)ShowCreditsScene
{
    CreditsScene* creditsScene = [CreditsLayer node];
    
    [[CCDirector sharedDirector] replaceScene:creditsScene];	
}

-(void)ShowHowToScene
{
	HowToScenes	*howToScene = [HowToScenes node];
	
//	id fadeout = [CCFadeOutBLTiles actionWithSize:ccg(16,12) duration:1.0];
//	id back = [fadeout reverse];
//	id delay = [CCDelayTime actionWithDuration:1.0f];
//	
//	id seq = [CCSequence actions: fadeout, nil, nil, nil];
//	
//	[self runAction:seq];
//	
//	
//	
//	 id fadein = [CCFadeOutBLTiles actionWithSize:ccg(16,12) duration:1.0];
//	id seq1 = [CCSequence actions: fadein, nil, nil, nil];
		
	
	//CCScene *s = [CCScene node];
//	id child = [HowToScenes node];
//	[s addChild:howToScene];
	//[s runAction:seq];
	//[[CCDirector sharedDirector] replaceScene:s];
	
	
	
	
	//[self addChild: howToScene];
	//[howToScene runAction:seq];
	
	//[[[CCDirector sharedDirector] runningScene] 
    
	[[CCDirector sharedDirector] replaceScene:howToScene];	
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	//[Title release];
	//[_titleLabel release];
	// don't forget to call "super dealloc"
    [_titleStr release];
	[super dealloc];
}
@end



