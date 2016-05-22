#import "HowToScenes.h"
#import "IntroScene.h"
#import "StringOps.h"

#pragma mark -
#pragma mark HowToScene1 methods

@interface HowToScenes() 



@end


@implementation HowToScenes
//@synthesize layer = _layer;

- (id)init {
	
	if ((self = [super init])) {
		
		BasicLayoutLayer *layer = [BasicLayoutLayer node];
		[self addChild:layer];
	}
	return self;
}

- (void)onExit
{
	[super onExit];
}

- (void)dealloc {
	//[_layer release];
	//_layer = nil;
	[super dealloc];
}


@end

#pragma mark -
#pragma mark HowToLayer1 interface

@interface BasicLayoutLayer()

-(void)InitBackground:(CGSize)windowSize;
-(void)InitLabels:(CGSize)windowSize;
-(void) onPushScene;
-(void)onMenu;

@end

@implementation BasicLayoutLayer

-(id) init
{
	if( (self=[super initWithColor:ccc4(0,0,0,255)] )) {	
		
		CGSize windowSize	= [[CCDirector sharedDirector] winSize];
		
		[self InitBackground:windowSize];
		[self InitLabels:windowSize];
		
		self.isTouchEnabled = YES;
		
	}	
	return self;
}

-(void)InitBackground:(CGSize)windowSize
{
	CCSprite *sprite		= [CCSprite spriteWithFile:@"BasicLayout.png"];
	_menuSprite				= [CCSprite spriteWithFile:@"Menu.png"];
	[self addChild:sprite];
	[self addChild:_menuSprite];
	
	sprite.position			= ccp(windowSize.width/2,windowSize.height/2);
	_menuSprite.position	= ccp(windowSize.width-15,windowSize.height-10);
	
}

-(void)InitLabels:(CGSize)windowSize
{	
    const char text[] =
	"Each level displays a CPU containing alternate blue / red cells and left / right sides of different inputs.";
    
    const char text1[] =
	"You control the blue cursor, the AI controls the right side";
	
	NSString* nsText			= [[NSString alloc] initWithBytes:text length:sizeof(text) encoding:NSASCIIStringEncoding];	
    NSString* nsText1			= [[NSString alloc] initWithBytes:text1 length:sizeof(text1) encoding:NSASCIIStringEncoding];	
	CGSize containerSize1		= [StringOps CalculateIdealSize:nsText font:@"Marker Felt" size:18];
    CGSize containerSize2		= [StringOps CalculateIdealSize:nsText1 font:@"Marker Felt" size:18];
	
	CCLabelTTF* sceneDesc		= [StringOps InitLabelWithPreferredSize:nsText containerSize:containerSize1 fontSize:18];
    CCLabelTTF* sceneDesc1		= [StringOps InitLabelWithPreferredSize:nsText1 containerSize:containerSize2 fontSize:18];
    
    [nsText release];
    [nsText1 release];
    
    sceneDesc.anchorPoint		= ccp(0,0);
	sceneDesc.color				= ccc3(120,236,111);
	sceneDesc.position			= ccp(0  , 260);
	
    sceneDesc1.anchorPoint		= ccp(0,0);
	sceneDesc1.color			= sceneDesc.color;	
	sceneDesc1.position			= ccp(0  , 50);
	
	[self addChild: sceneDesc z:1];
    [self addChild: sceneDesc1 z:1];
    
	_nextLabel					= [StringOps InitLabel:@">>" fontSize:30];	
	_nextLabel.position			= ccp(windowSize.width-30,10);
	
	
	[self addChild:_nextLabel];   
        
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// Choose one of the touches to work with
	UITouch *touch		= [touches anyObject];
	CGPoint location	= [touch locationInView:[touch view]];
	location			= [[CCDirector sharedDirector] convertToGL:location];
	
	if (CGRectContainsPoint([_nextLabel boundingBox],location)) {
		[self onPushScene];
	}
	
	if (CGRectContainsPoint([_menuSprite boundingBox],location)) {
		[self onMenu];
	}    
}

-(void)onMenu
{
	CCScene * scene = [CCScene node];
	[scene addChild: [IntroScene node] z:0];
	
	[[CCDirector sharedDirector] replaceScene: scene];
}

-(void) onPushScene
{
	CCScene * scene = [CCScene node];
	[scene addChild: [SwipeUpDownToMoveLayer node] z:0];
	[[CCDirector sharedDirector] pushScene: scene];
	//	[[Director sharedDirector] replaceScene:scene];
}


- (void)dealloc {	
	
	[super dealloc];
}


@end

@interface SwipeUpDownToMoveLayer()

-(void)InitBackground:(CGSize)windowSize;
-(void)InitLabels:(CGSize)windowSize;
-(void) onPushScene;
-(void) onPrevScene;
-(void)onMenu;

@end

#pragma mark -
#pragma mark HowToLayer1 methods


@implementation SwipeUpDownToMoveLayer



-(id) init
{
	if( (self=[super initWithColor:ccc4(0,0,0,255)] )) {	
		
		CGSize windowSize	= [[CCDirector sharedDirector] winSize];
		
		[self InitBackground:windowSize];
		[self InitLabels:windowSize];
		
		self.isTouchEnabled = YES;
		
	}	
	return self;
}

-(void)InitBackground:(CGSize)windowSize
{
	CCSprite *sprite		= [CCSprite spriteWithFile:@"CursorMove.png"];
	_menuSprite				= [CCSprite spriteWithFile:@"Menu.png"];
	[self addChild:sprite];
	[self addChild:_menuSprite];
	
	sprite.position			= ccp(windowSize.width/2,(windowSize.height/2)-10);
	_menuSprite.position	= ccp(windowSize.width-15,windowSize.height-10);
	
}

-(void)InitLabels:(CGSize)windowSize
{	
    
     const char text[] =
     "Swipe up or down to move cursor by small increments..";
     
     const char text1[] =
     "Dragging your finger up or down keeps the cursor moving in the desired direction.";
     
     NSString* nsText			= [[NSString alloc] initWithBytes:text length:sizeof(text) encoding:NSASCIIStringEncoding];	
     NSString* nsText1			= [[NSString alloc] initWithBytes:text1 length:sizeof(text1) encoding:NSASCIIStringEncoding];	
     CGSize containerSize1		= [StringOps CalculateIdealSize:nsText font:@"Marker Felt" size:18];
     CGSize containerSize2		= [StringOps CalculateIdealSize:nsText1 font:@"Marker Felt" size:18];
     
     CCLabelTTF* sceneDesc		= [StringOps InitLabelWithPreferredSize:nsText containerSize:containerSize1 fontSize:18];
     CCLabelTTF* sceneDesc1		= [StringOps InitLabelWithPreferredSize:nsText1 containerSize:containerSize2 fontSize:18];
     
     [nsText release];
     [nsText1 release];
     
    sceneDesc.anchorPoint		= ccp(0,0);
	sceneDesc1.anchorPoint		= ccp(0,0);
	sceneDesc.position          = ccp( 0  , 280);	
    sceneDesc1.position         = ccp(0, 240);
	
	_nextLabel					= [StringOps InitLabel:@">>" fontSize:30];	
	_nextLabel.position			= ccp(windowSize.width-30,10);
	
	[self addChild: sceneDesc z:1];
    [self addChild: sceneDesc1 z:1];
	[self addChild:_nextLabel];
    
    _prevLabel					= [StringOps InitLabel:@"<<" fontSize:30];	
	_prevLabel.position			= ccp(30,_nextLabel.position.y);	

	[self addChild:_prevLabel];

}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// Choose one of the touches to work with
	UITouch *touch		= [touches anyObject];
	CGPoint location	= [touch locationInView:[touch view]];
	location			= [[CCDirector sharedDirector] convertToGL:location];
	
	if (CGRectContainsPoint([_nextLabel boundingBox],location)) {
		[self onPushScene];
	}

    if (CGRectContainsPoint([_prevLabel boundingBox],location)) {
		[self onPrevScene];
	}

	
	if (CGRectContainsPoint([_menuSprite boundingBox],location)) {
		[self onMenu];
	}
}
  
-(void)onMenu
{
	CCScene * scene = [CCScene node];
	[scene addChild: [IntroScene node] z:0];
	
	[[CCDirector sharedDirector] replaceScene: scene];
}

-(void) onPushScene
{
	CCScene * scene = [CCScene node];
	[scene addChild: [DoubleTapToActivateLayer node] z:0];
	[[CCDirector sharedDirector] pushScene: scene];
	//	[[Director sharedDirector] replaceScene:scene];
}

-(void) onPrevScene
{
	[[CCDirector sharedDirector] popScene];
}


- (void)dealloc {
	
	
	[super dealloc];
}

@end

#pragma mark -
#pragma mark ScreenShot1Layer interface

@interface DoubleTapToActivateLayer()

-(void)InitBackground:(CGSize)windowSize;
-(void)InitLabels:(CGSize)windowSize;
-(void) onPrevScene;
-(void) onNextScene;
-(void)onMenu;
@end

#pragma mark -
#pragma mark ScreenShot1Layer methods

@implementation DoubleTapToActivateLayer

-(id) init
{
	if( (self=[super initWithColor: ccc4(0,0,0,255)]) ) {
		
		CGSize s = [CCDirector sharedDirector].winSize;
		
		[self InitBackground:s];
		[self InitLabels:s];
		self.isTouchEnabled = YES;
	}
	
	return self;
}

-(void)InitBackground:(CGSize)windowSize
{
	CCSprite *sprite	= [CCSprite spriteWithFile:@"DoubleTapCellActivate.png"];
	CCSprite *sprite1	= [CCSprite spriteWithFile:@"InputCounter.png"];
	[self addChild:sprite];
	[self addChild:sprite1];
	sprite.position = ccp(windowSize.width/2,windowSize.height/2);
	sprite1.position = ccp(windowSize.width/2,60);
    
    _menuSprite				= [CCSprite spriteWithFile:@"Menu.png"];	
	_menuSprite.position	= ccp(windowSize.width-15,windowSize.height-10);    
    [self addChild:_menuSprite];
	
}

-(void)InitLabels:(CGSize)windowSize
{
	const char text[] =
	"Double tap to activate the input to the cell and set it to your colour for a limited duration.";
	
	NSString* nsText			= [[NSString alloc] initWithBytes:text length:sizeof(text) encoding:NSASCIIStringEncoding];	
	CGSize containerSize		= [StringOps CalculateIdealSize:nsText font:@"Marker Felt" size:18];
	
	CCLabelTTF* sceneDesc			= [StringOps InitLabelWithPreferredSize:nsText containerSize:containerSize fontSize:18];
    
    [nsText release];
	
	CCLabelTTF* sceneDesc1			= [StringOps InitLabel:@"You only have a limited number of pulses" fontSize:18];
//[CCLabelTTF labelWithString:@"You only have a limited number of inputs" fontName:@"Marker Felt" fontSize:18];
	
	sceneDesc.anchorPoint		= ccp(0,0);
	sceneDesc.color				= ccc3(120,236,111);
	sceneDesc.position			= ccp(0  , 260);	
	sceneDesc1.position			= ccp(sceneDesc.position.x  , 80);
	
	
	_nextLabel					= [StringOps InitLabel:@">>" fontSize:30];
	_nextLabel.position			= ccp(windowSize.width-30,10);
	
	_prevLabel					= [StringOps InitLabel:@"<<" fontSize:30];	
	_prevLabel.position			= ccp(30,_nextLabel.position.y);
	
	[self addChild: sceneDesc z:1];
	[self addChild: sceneDesc1 z:1];

	[self addChild:_nextLabel];
	[self addChild:_prevLabel];
    
    _menuSprite				= [CCSprite spriteWithFile:@"Menu.png"];	
	_menuSprite.position	= ccp(windowSize.width-15,windowSize.height-10);    
    [self addChild:_menuSprite];

}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// Choose one of the touches to work with
	UITouch *touch		= [touches anyObject];
	CGPoint location	= [touch locationInView:[touch view]];
	location			= [[CCDirector sharedDirector] convertToGL:location];
	
	if (CGRectContainsPoint([_nextLabel boundingBox],location)) {
		[self onNextScene];
	}	
	
	if (CGRectContainsPoint([_prevLabel boundingBox],location)) {
		[self onPrevScene];
	}	
    
    if (CGRectContainsPoint([_menuSprite boundingBox],location)) {
		[self onMenu];
	}
}

-(void)onMenu
{
	CCScene * scene = [CCScene node];
	[scene addChild: [IntroScene node] z:0];
	
	[[CCDirector sharedDirector] replaceScene: scene];
}


-(void) dealloc
{
	[super dealloc];
}

-(void) onPrevScene
{
	[[CCDirector sharedDirector] popScene];
}

-(void) onNextScene
{
	CCScene *scene = [CCScene node];
	[scene addChild: [HowToWinLayer node] z:0];
	[[CCDirector sharedDirector] pushScene: scene];
}

@end


#pragma mark -
#pragma mark HowToLayer3 interface

@interface InputTypesLayer()

-(void)InitLabels:(CGSize)windowSize;
-(void)InitNextPrevLabels:(CGSize)windowSize;
-(void)InitDescLabels:(CGSize)windowSize;
-(void)InitBackground:(CGSize)windowSize;
-(void) onNextScene;
-(void) onPrevScene;
-(void)onMenu;
@end

#pragma mark -
#pragma mark HowToLayer3 methods

@implementation InputTypesLayer

-(id) init
{
	if( (self=[super initWithColor: ccc4(0,0,0,255)]) ) {
		
		CGSize s = [CCDirector sharedDirector].winSize;
		
		
		[self InitLabels:s];
		[self InitBackground:s];
		self.isTouchEnabled = YES;

	}
	
	return self;
}

-(void)InitBackground:(CGSize)windowSize
{
	CCSprite *sprite	= [CCSprite spriteWithFile:@"BoostedInput.png"];
	CCSprite *sprite1	= [CCSprite spriteWithFile:@"InvertedInput.png"];
	CCSprite *sprite2	= [CCSprite spriteWithFile:@"LatchedInput.png"];
	CCSprite *sprite3	= [CCSprite spriteWithFile:@"mutex.png"];
	
	[self addChild:sprite];
	[self addChild:sprite1];
	[self addChild:sprite2];
	[self addChild:sprite3];
	
	sprite.position		= ccp(20,240);
	sprite1.position	= ccp(20,195);
	sprite2.position	= ccp(20,150);
	sprite3.position	= ccp(20,90);
}
  

-(void)InitLabels:(CGSize)windowSize
{
	[self InitNextPrevLabels:windowSize];
	[self InitDescLabels:windowSize];
    
    _menuSprite				= [CCSprite spriteWithFile:@"Menu.png"];	
	_menuSprite.position	= ccp(windowSize.width-15,windowSize.height-10);    
    [self addChild:_menuSprite];
}

-(void)InitNextPrevLabels:(CGSize)windowSize
{
	_prevLabel					= [StringOps InitLabel:@"<<" fontSize:30];
	_prevLabel.position			= ccp(30,10);	
	
	[self addChild:_prevLabel];	
	
}

-(void)InitDescLabels:(CGSize)windowSize
{
	
	NSString* desc				= [[NSString alloc] initWithString:@"There are different types of inputs which affect cells in various ways:"];	
	
	
	CGSize descContainerSize	= [StringOps CalculateIdealSize:desc font:@"Marker Felt" size:18];
	
	CCLabelTTF* sceneDesc		= [StringOps InitLabelWithPreferredSize:desc containerSize:descContainerSize fontSize:18];	
    
	CCLabelTTF* boostedDesc		= [StringOps InitLabel:@"Boosted: Cells remain active for longer time period" fontSize:18];
		
	NSString* invertedText		= [[NSString alloc] initWithString:@"Inverted: Cell is set to the oppositions colour"];	
	
	NSString* latchedText		= [[NSString alloc] initWithString:@"Latched: Cell remains in the activated colour - 2 pulses required"];	
	
	NSString* mutexText			= [[NSString alloc] initWithString:@"Mutex: Cell remains in its original colour, so cannot be altered by opposition"];	
	
	CGSize mutexSize			= [StringOps CalculateIdealSize:mutexText font:@"Marker Felt" size:20];
	
	CGSize invertedSize			= [StringOps CalculateIdealSize:invertedText font:@"Marker Felt" size:18];
	
	CGSize latchedSize			= [StringOps CalculateIdealSize:latchedText font:@"Marker Felt" size:20];
	
	CCLabelTTF* invertedDesc	= [StringOps InitLabelWithPreferredSize:invertedText containerSize:invertedSize fontSize:18];
	
	CCLabelTTF* mutexDesc		= [StringOps InitLabelWithPreferredSize:mutexText containerSize:mutexSize fontSize:18];
	
	CCLabelTTF* latchedDesc		= [StringOps InitLabelWithPreferredSize:latchedText containerSize:latchedSize fontSize:18];
	
	sceneDesc.position			= ccp(windowSize.width/2  , 280);
	boostedDesc.position		= ccp(55,230);
	invertedDesc.position		= ccp(windowSize.width/2-30,195);
	latchedDesc.position		= ccp(windowSize.width/2+30,140);
	mutexDesc.position			= ccp(windowSize.width/2+30,80);
	
	sceneDesc.color				= ccc3(120,236,111);
		
	[self addChild:sceneDesc];	
	[self addChild:boostedDesc];
	[self addChild:invertedDesc];
	[self addChild:latchedDesc];
	[self addChild:mutexDesc];
    
    [invertedText release];    
    [desc release];
    [latchedText release];
    [mutexText release];
	
	
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// Choose one of the touches to work with
	UITouch *touch		= [touches anyObject];
	CGPoint location	= [touch locationInView:[touch view]];
	location			= [[CCDirector sharedDirector] convertToGL:location];
	
	if (CGRectContainsPoint([_prevLabel boundingBox],location)) {
		[self onPrevScene];
	}	
    
    if (CGRectContainsPoint([_menuSprite boundingBox],location)) {
		[self onMenu];
	}
}

-(void)onMenu
{
	CCScene * scene = [CCScene node];
	[scene addChild: [IntroScene node] z:0];
	
	[[CCDirector sharedDirector] replaceScene: scene];
}

-(void) onNextScene
{
	CCScene *scene = [CCScene node];
	[scene addChild: [HowToWinLayer node] z:0];
	[[CCDirector sharedDirector] pushScene: scene];
}

-(void) onPrevScene
{
	[[CCDirector sharedDirector]popScene];
}

-(void) dealloc
{
	[super dealloc];
}

-(void) onGoBack:(id) sender
{
	//[[CCDirector sharedDirector] popScene];
}

@end

#pragma mark - 
# pragma mark HowToWinLayer interface
@interface HowToWinLayer()

-(void)InitLabels:(CGSize)windowSize;
-(void)InitNextPrevLabels:(CGSize)windowSize;
-(void)InitDescLabels:(CGSize)windowSize;
-(void)InitBackground:(CGSize)windowSize;
-(void) onPrevScene;
-(void) onNextScene;	
-(void)onMenu;
@end

#pragma mark -
#pragma mark HowToWinLayer methods

@implementation HowToWinLayer

-(id) init
{
	if( (self=[super initWithColor: ccc4(0,0,0,255)]) ) {
		
		CGSize s = [CCDirector sharedDirector].winSize;
		
		[self InitNextPrevLabels:s];
		[self InitLabels:s];
		[self InitBackground:s];
		self.isTouchEnabled = YES;
		
	}
	
	return self;
}

-(void)InitLabels:(CGSize)windowSize
{
	const char text1[] =
	"You win by having more than 6 cells set to your colour when the timer reaches 0.";
	
	NSString* nsText1			= [[NSString alloc] initWithBytes:text1 length:sizeof(text1) encoding:NSASCIIStringEncoding];
	NSString* nsText2			= [[NSString alloc] initWithString:@"If 6 cells are set, the result is a deadlock: you have the option to replay the round."];
	CGSize containerSize		= [StringOps CalculateIdealSize:nsText1 font:@"Marker Felt" size:18];
	
	CCLabelTTF* sceneDesc1		= [StringOps InitLabelWithPreferredSize:nsText1 containerSize:containerSize fontSize:18];
	CCLabelTTF* sceneDesc2		= [StringOps InitLabelWithPreferredSize:nsText2 containerSize:containerSize fontSize:18];
	
	sceneDesc1.position			= ccp(windowSize.width/2  , 280);
	sceneDesc2.position			= ccp(windowSize.width/2  , 100);

	[self addChild:sceneDesc1];
	[self addChild:sceneDesc2];
    
    _menuSprite				= [CCSprite spriteWithFile:@"Menu.png"];	
	_menuSprite.position	= ccp(windowSize.width-15,windowSize.height-10);    
    [self addChild:_menuSprite];
    
    [nsText1 release];
    [nsText2 release];
}

-(void)InitNextPrevLabels:(CGSize)windowSize
{
	_nextLabel					= [StringOps InitLabel:@">>" fontSize:30];
	_nextLabel.position			= ccp(windowSize.width-30,10);	
	
	_prevLabel					= [StringOps InitLabel:@"<<" fontSize:30];
	_prevLabel.position			= ccp(30,_nextLabel.position.y);
	
	
	[self addChild:_nextLabel];	
	[self addChild:_prevLabel];	
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// Choose one of the touches to work with
	UITouch *touch		= [touches anyObject];
	CGPoint location	= [touch locationInView:[touch view]];
	location			= [[CCDirector sharedDirector] convertToGL:location];
	
	if (CGRectContainsPoint([_nextLabel boundingBox],location)) {
		[self onNextScene];
	}	
	
	if (CGRectContainsPoint([_prevLabel boundingBox],location)) {
		[self onPrevScene];
	}	
    
    if (CGRectContainsPoint([_menuSprite boundingBox],location)) {
		[self onMenu];
	}
}

-(void)onMenu
{
	CCScene * scene = [CCScene node];
	[scene addChild: [IntroScene node] z:0];
	
	[[CCDirector sharedDirector] replaceScene: scene];
}

-(void)InitDescLabels:(CGSize)windowSize
{
}

-(void)InitBackground:(CGSize)windowSize
{
	CCSprite *sprite	= [CCSprite spriteWithFile:@"Winner.png"];
	
	[self addChild:sprite];
	
	sprite.position = ccp(windowSize.width/2 ,200);
	
}

-(void) onPrevScene
{
	[[CCDirector sharedDirector] popScene];
}

-(void) onNextScene
{
	CCScene *scene = [CCScene node];
	[scene addChild: [InputTypesLayer node] z:0];
	[[CCDirector sharedDirector] pushScene: scene];
}

@end

