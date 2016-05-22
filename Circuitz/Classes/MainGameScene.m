    //
//  MainGameScene.m
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 01/05/2010.
//  Copyright 2010 Hackers. All rights reserved.q
//

#import "MainGameScene.h"
#import "IntroScene.h"
#import "GameOverScene.h"
#import "RenderOps.h"
#import "PulseSprite.h"
#import "Probe.h"
#import "SimpleAudioEngine.h"
#import "StringOps.h"

#pragma mark -
#pragma mark MainGameScene methods

@implementation MainGameScene
//@synthesize layer = _layer;

- (id)init {
	
	if ((self = [super init])) {
		
		MainGameLayer *layer = [MainGameLayer node];
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
#pragma mark MainGameLayer methods

@interface MainGameLayer()

-(void)InitBackground:(CGSize)windowSize;
-(void)InitSounds;
-(void)PlayTimerBeep;
-(void)PlayEndGameSound;

@end

@implementation MainGameLayer
@synthesize label = _label;
@synthesize downSwipeRecognizer = _downSwipeRecognizer;
@synthesize upSwipeRecognizer = _upSwipeRecognizer;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;

BOOL _tapDetected;
int _selectedProbe;
BOOL _probeInited;
bool _endSoundPlayed;
GameResult _gameResult;

CCSprite* InitSprite(CCTexture2D* texture,int index,ProbeIndex t,SpriteDim* d);
void InitActivationFrames(CCTexture2D* texture,CCSpriteBatchNode* spritesheet,Probe* probe,ProbeIndex i,CCSprite* sprite,SpriteDim* d,CellColor c);
void ToggleCell(CCSprite* cell,bool parentToChild);

#pragma mark -
#pragma mark init methods

-(id) init
{
	if( (self=[super initWithColor:_backColor] )) {
		
		//self.isTouchEnabled			= YES;
        
        _touchPoint                 = 0;
        
        _dir                        = None;
        
        //self.isAccelerometerEnabled = YES;
		 
		_probeInited				= FALSE;
		
		_started					= FALSE;
        
        _endSoundPlayed             = false;
		
		_backColor					= ccc4(255,0,0,255);		
		CGSize windowSize			= [[CCDirector sharedDirector] winSize];
		
		[self InitBackground:windowSize];
		
		_layoutManager				= [[LayoutManager alloc] initWithWindowSize:windowSize];		
       	_leftInverterTexture		= [[CCTextureCache sharedTextureCache] addImage:@"Inverter1.png"];
		_leftBoostedTexture			= [[CCTextureCache sharedTextureCache] addImage:@"Booster.png"];
		_rightBoostedTexture		= [[CCTextureCache sharedTextureCache] addImage:@"RedBooster.png"];
		_blueProbesTexture			= [[CCTextureCache sharedTextureCache] addImage:@"BlueProbesAtlas1.png"];
		_leftLatchTexture			= [[CCTextureCache sharedTextureCache] addImage:@"Latch1.png"];
		_rightLatchTexture			= [[CCTextureCache sharedTextureCache] addImage:@"Latch2.png"];
		_leftProbeBarTexture		= [[CCTextureCache sharedTextureCache] addImage:@"BlueBar.png"];
		_rightProbeBarTexture		= [[CCTextureCache sharedTextureCache] addImage:@"RedBar.png"];
		_leftMutexTexture			= [[CCTextureCache sharedTextureCache] addImage:@"mutex.png"];
		_rightMutexTexture			= [[CCTextureCache sharedTextureCache] addImage:@"RedMutex.png"];
		
		
		_blueProbesSheet			= [CCSpriteBatchNode batchNodeWithFile:@"BlueProbesAtlas1.png"];
		[self addChild:_blueProbesSheet z:0 tag:kTagBlueSpriteSheetAtlas];
		
		_redProbesTexture			= [[CCTextureCache sharedTextureCache] addImage:@"RedProbesAtlas1.png"];
		_redProbesSheet				= [CCSpriteBatchNode batchNodeWithFile:@"RedProbesAtlas1.png"];
		[self addChild:_redProbesSheet z:0 tag:kTagRedSpriteSheetAtlas];
		
		[self InitTimeElapsed];	
		
//		RightProbeActivateBlock b = ^{	
//			
//			[self ActivateProbe:RightSide];
//			
//		};
		
		[CircuitGameObj sharedInstance].RightProbeActiveBlock = Block_copy(^{[self ActivateProbe:RightSide];});
        
        
        
        
//        [b copy];
//        
//        [b release];
		
		
		[self schedule:@selector(doStep:)];
		
		[self schedule:@selector(DrawPulses) interval:0.2];
        
        
		
		[[CircuitGameObj sharedInstance] startGame];
		
		
		[self InitCells];		
		[self InitLeftSpriteProbes];
		[self InitRightSpriteProbes];
		[self InitPulses];		
        [self InitSounds];
				
	}	
	return self;
}


-(void) InitSounds
{
    [[SimpleAudioEngine sharedEngine]preloadEffect:@"ActivateProbe.wav"];
    //[[SimpleAudioEngine sharedEngine]preloadEffect:@"standyBy.wav"];
    [[SimpleAudioEngine sharedEngine]preloadEffect:@"19911__ls__beep.wav"];
    [[SimpleAudioEngine sharedEngine]preloadEffect:@"32954__hardpcm__chip054.wav"];
    [[SimpleAudioEngine sharedEngine]preloadEffect:@"34231__hardpcm__chip115.wav"];
    [[SimpleAudioEngine sharedEngine]preloadEffect:@"51465__smcameron__flak-gun-sound.wav"];
    
         
}

-(void)InitBackground:(CGSize)windowSize
{
	
	CCSprite *spback			= [(CCSprite*)[CCSprite alloc] init];
	[self addChild:spback];
    [spback release];
	
	CCSprite *background		= [CCSprite spriteWithFile:@"Background.png"];
	CCSprite* chip				= [CCSprite spriteWithFile:@"Chip.png"];
	background.position			= ccp(windowSize.width/2, windowSize.height/2);
	
	
	chip.position				= ccp(windowSize.width/2, (windowSize.height/2)-5);
	
	background.opacity			= 100;
	[spback addChild:background];
	[self addChild:chip z:1];
}

-(void)InitPulses
{
	//CCSprite* currentLeftPulse	= [CCSprite spriteWithFile:@"Pulse.png"];
	
	CCSprite *pulseSprite							= [CCSprite spriteWithFile:@"Pulse.png"];
	CCSprite *redPulseSprite						= [CCSprite spriteWithFile:@"RedPulse.png"];
	pulseSprite.position							= [_layoutManager GetPulsePosition:LeftSide];
	redPulseSprite.position							= [_layoutManager GetPulsePosition:RightSide];
	[self addChild:pulseSprite z:0 tag:kTagPulsesAtlas];
	[self addChild:redPulseSprite z:0 tag:kTagRightPulseAtlas];
	
	/////////////////
	CCTexture2D *pulseTexture						= [[CCTextureCache sharedTextureCache] addImage:@"Pulse.png"];
	CCTexture2D *redPulseTexture					= [[CCTextureCache sharedTextureCache] addImage:@"RedPulse.png"];
	
	Probe* first									= [[CircuitGameObj sharedInstance].LeftSideInputs objectAtIndex:0];

	
	int firstProbeIndex								= first.ProbeDescs[Input1].index;
	
	int yPos										= [_layoutManager GetInputIndexYPosition:firstProbeIndex];
    
	CGPoint leftPulsePos							= CGPointMake(pulseSprite.position.x,yPos);
	
	_leftPulseSprite								= [PulseSprite pulseSpriteTexture:pulseTexture Position:leftPulsePos];
		
	
	//[_leftPulseSprite SetPos:pulseSprite.position.x YPos:yPos];
	_leftPulseSprite.CurrentIndex					= firstProbeIndex;
	[CircuitGameObj sharedInstance].LeftPulseIndex	= firstProbeIndex;
	[self addChild:_leftPulseSprite];
	
	///////////
	
	
	
	Probe* redFirst									= [[CircuitGameObj sharedInstance].RightSideInputs objectAtIndex:0];
	int redfirstProbeIndex							= redFirst.ProbeDescs[Input1].index;
	
	yPos											= [_layoutManager GetInputIndexYPosition:redfirstProbeIndex];
	CGPoint rightPulsePos							= CGPointMake(redPulseSprite.position.x,yPos);
	
	_rightPulseSprite								= [PulseSprite pulseSpriteTexture:redPulseTexture Position:rightPulsePos];

	//[_rightPulseSprite SetPos:redPulseSprite.position.x YPos:yPos];
	_rightPulseSprite.CurrentIndex					= redfirstProbeIndex;
	[CircuitGameObj sharedInstance].RightPulseIndex	= redfirstProbeIndex;
	[self addChild:_rightPulseSprite];
	
	///////////////////////////////
	
	
	
	NSString *strLeftPulses		= [NSString stringWithFormat:@"%02d",[CircuitGameObj sharedInstance].LeftHandPulses];
		
	CCLabelAtlas *pulsesAtlas	= [CCLabelAtlas labelWithString:strLeftPulses charMapFile:@"LEDNumbers.png" itemWidth:13 itemHeight:25 startCharMap:'0'];
	[self addChild:pulsesAtlas z:100 tag:kTagLeftPulseAtlas];
	pulsesAtlas.position		= ccp(pulseSprite.position.x+10,pulseSprite.position.y-10);	
	
	////////////////////////////////
	
	NSString* strRightPulses		= [NSString stringWithFormat:@"%02d",[CircuitGameObj sharedInstance].RightHandPulses];
	CCLabelAtlas *pulsesAtlasRight	= [CCLabelAtlas labelWithString:strRightPulses charMapFile:@"LEDNumbers.png" itemWidth:13 itemHeight:25 startCharMap:'0'];
	pulsesAtlasRight.position		= ccp(redPulseSprite.position.x-34,redPulseSprite.position.y-10);	
	[self addChild:pulsesAtlasRight z:100 tag:kTagRightPulsesString];
}

-(void)InitTimeElapsed
{
	NSString *strTime			= [NSString stringWithFormat:@"%02d",[[CircuitGameObj sharedInstance] GetGameTimeElapsed]];
	
		
	CCLabelAtlas *labelAtlas	= [CCLabelAtlas labelWithString:strTime charMapFile:@"LEDNumbers.png" itemWidth:13 itemHeight:25 startCharMap:'0'];
	[self addChild:labelAtlas z:100 tag:kTagTimeElapsedAtlas];
	labelAtlas.position			= [_layoutManager GetTimerLabelPosition];	
}


-(void) InitCells
{
	int max				= [CircuitGameObj MaxCells];
	
	_redCellTexture		= [[CCTextureCache sharedTextureCache] addImage:@"RedCell.png"];
	_blueCellTexture	= [[CCTextureCache sharedTextureCache] addImage:@"BlueCell.png"];
	
	for (int i=0; i<max; i++) 
	{
		Cell* cell = [[CircuitGameObj sharedInstance] RetrieveCellFromIndex:i];
		CCSprite* spriteRight;
		CCSprite* spriteLeft;
		
		
		float y_offset = [_layoutManager GetIndexYPosition:i];
		
		spriteLeft = [CCSprite spriteWithTexture:_blueCellTexture ]; 
		spriteRight = [CCSprite spriteWithTexture:_redCellTexture  ];
		
		CGPoint pos = CGPointMake(_layoutManager.CellOrigin.x+(_redCellTexture.contentSize.width/2-4),
																  y_offset+8);

		
		if(cell.CurrentCellColor==LeftSide)
		{
			spriteRight.opacity = 0;
			spriteRight.anchorPoint = CGPointZero;
			spriteLeft.position = pos;
			[spriteLeft addChild:spriteRight z:0 tag:1];	
			[self addChild:spriteLeft z:1 tag:kTagCellAtlas+i];
			
		}
		else {
			
			spriteLeft.opacity = 0;
			spriteLeft.anchorPoint = CGPointZero;
			spriteRight.position = pos;
			[spriteRight addChild:spriteLeft z:0 tag:1];	
			[self addChild:spriteRight z:1 tag:kTagCellAtlas+i];
		}
        
        cell.delegate = self;
	}
	
}

-(void)InitProbe:(Probe*)p cellColor:(CellColor)c
{
	NSMutableArray* spriteDimArray;

	NSAutoreleasePool* tempPool = [[NSAutoreleasePool alloc]init];
	
	CCTexture2D* probeTexture	= c==LeftSide?_blueProbesTexture:_redProbesTexture;
	CCTexture2D* barTexture		= c==LeftSide?_leftProbeBarTexture:_rightProbeBarTexture;
	CCSpriteBatchNode* spriteSheet	= c==LeftSide?_blueProbesSheet:_redProbesSheet;
	
	if ([p GetProbeType]==Single) 
	{
		spriteDimArray				= [[_layoutManager GetProbeSizeAndPosition:p cellColor:c]copy];
		
		SpriteDim* input1Dim		= [spriteDimArray objectAtIndex:0];
		
		[spriteDimArray release];
		
		CCSprite* sprite			= InitSprite(probeTexture,p.ProbeDescs[Input1].index,Input1,input1Dim);
		
		
		InitActivationFrames(probeTexture,spriteSheet,p,Input1,sprite,input1Dim,c);			
		
		
		if (p.ProbeDescs[Input1].isInverted) 
		{
			CCSpriteFrame *invFrame		= [CCSpriteFrame frameWithTexture:_leftInverterTexture rect:CGRectMake(0, 0, _leftInverterTexture.pixelsWide*2,
																									_leftInverterTexture.pixelsHigh-3)];
			
			CCSprite *Invsprite			= [CCSprite spriteWithSpriteFrame:invFrame];
			
			Invsprite.position			= CGPointMake(input1Dim.position.x,input1Dim.position.y);
			
			[self addChild:Invsprite];
			
		}
		
		if (p.ProbeDescs[Input1].isBoosted) 
		{
			CCTexture2D* boostedTexture	= c==LeftSide?_leftBoostedTexture:_rightBoostedTexture;
			
			CCSpriteFrame *boostedFrame	= [CCSpriteFrame frameWithTexture:boostedTexture rect:CGRectMake(0, 0, boostedTexture.pixelsWide,
																											  boostedTexture.pixelsHigh-4) ];
			
			CCSprite *boostedSprite		= [CCSprite spriteWithSpriteFrame:boostedFrame];
			
			boostedSprite.position		= CGPointMake(input1Dim.position.x,input1Dim.position.y);
			
			[self addChild:boostedSprite];
			
		}
		
		if (p.ProbeDescs[Input1].isLatched) {
			
			CCTexture2D* latchedTexture	= c==LeftSide?_leftLatchTexture:_rightLatchTexture;
			
			CCSpriteFrame *latchedFrame	= [CCSpriteFrame frameWithTexture:latchedTexture rect:CGRectMake(0, 0, latchedTexture.pixelsWide,
																											latchedTexture.pixelsHigh-3) ];
			
			CCSprite *latchedSprite		= [CCSprite spriteWithSpriteFrame:latchedFrame];
			
			latchedSprite.position		= CGPointMake(input1Dim.position.x,input1Dim.position.y);
			
			[self addChild:latchedSprite];
			
		}
		
		if (p.ProbeDescs[Input1].isMutex) {
			
			CCTexture2D* mutexTexture	= c==LeftSide?_leftMutexTexture:_rightMutexTexture;
			
			CCSpriteFrame *mutexFrame	= [CCSpriteFrame frameWithTexture:mutexTexture rect:CGRectMake(0, 0, mutexTexture.pixelsWide,
																										 mutexTexture.pixelsHigh) ];
			
			CCSprite *s					= [CCSprite spriteWithSpriteFrame:mutexFrame];
			
			s.position					= CGPointMake(input1Dim.position.x,input1Dim.position.y);
			
			[self addChild:s];			
			
		}
		
	}	
	
	if ([p GetProbeType]==SingleInputTwoOutput) {
		
		spriteDimArray				= [_layoutManager GetProbeSizeAndPosition:p cellColor:c];
		
		assert([spriteDimArray count]==3);
		
		SpriteDim* input1Dim		= [spriteDimArray objectAtIndex:0];	
		SpriteDim* op1Dim			= [spriteDimArray objectAtIndex:1];	
		SpriteDim* op2Dim			= [spriteDimArray objectAtIndex:2];	
		
		CCSprite* sprite1			= InitSprite(probeTexture, p.ProbeDescs[Input1].index,Input1,input1Dim);
		CCSprite* sprite2			= InitSprite(probeTexture,p.ProbeDescs[Output1].index,Input2,op1Dim);
		CCSprite* sprite3			= InitSprite(probeTexture,p.ProbeDescs[Output2].index,Output2,op2Dim);
		
		InitActivationFrames(probeTexture,spriteSheet,p,Input1,sprite1,input1Dim,c);	
		InitActivationFrames(probeTexture,spriteSheet,p,Output1,sprite2,op1Dim,c);	
		InitActivationFrames(probeTexture,spriteSheet,p,Output2,sprite3,op2Dim,c);
		
		CGPoint pos					= [_layoutManager GetBarPosition:p.ProbeDescs[1].index cellColor:c];		
		[self AddBar:pos barTexture:barTexture];
		
	}
	
	if ([p GetProbeType]==TwoInputSingleOutput) {
		
		spriteDimArray				= [_layoutManager GetProbeSizeAndPosition:p cellColor:c];
		
		assert([spriteDimArray count]==3);
		
		SpriteDim* input1Dim		= [spriteDimArray objectAtIndex:0];	
		SpriteDim* input2Dim		= [spriteDimArray objectAtIndex:1];	
		SpriteDim* op1Dim			= [spriteDimArray objectAtIndex:2];				
		
		CCSprite* sprite1			= InitSprite(probeTexture,p.ProbeDescs[Input1].index,Input1,input1Dim);
		CCSprite* sprite2			= InitSprite(probeTexture,p.ProbeDescs[Input2].index,Input2,input2Dim);
		CCSprite* sprite3			= InitSprite(probeTexture,p.ProbeDescs[Output1].index,Output1,op1Dim);
		
		InitActivationFrames(probeTexture,spriteSheet,p,Input1,sprite1,input1Dim,c);	
		InitActivationFrames(probeTexture,spriteSheet,p,Input2,sprite2,input1Dim,c);	
		InitActivationFrames(probeTexture,spriteSheet,p,Output1,sprite3,input1Dim,c);
		
		
		CGPoint pos					= [_layoutManager GetBarPosition:p.ProbeDescs[Output1].index cellColor:c];			
		[self AddBar:pos barTexture:barTexture];
		
	}
	
	[tempPool drain];
}

-(void)InitRightSpriteProbes
{
	for (Probe* p in [CircuitGameObj sharedInstance].RightSideInputs) 
	{
		[self InitProbe:p cellColor:RightSide];
	}
}

-(void) InitLeftSpriteProbes
{
	for (Probe* p in [CircuitGameObj sharedInstance].LeftSideInputs) 
	{
		[self InitProbe:p cellColor:LeftSide];
	}
}

CCSprite* InitSprite(CCTexture2D* texture,int index,ProbeIndex t,SpriteDim* d)
{
	int height					= d.size.height;
	
	int width					= d.size.width;
	//		
	CCSpriteFrame *frame0		= [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(0, height*0, width, height) ];
	
	CCSprite *sprite			= [CCSprite spriteWithSpriteFrame:frame0];
	sprite.position				= d.position;
	
	return sprite;
	//[self addChild:sprite z:0 tag:index+kTagProbeBlueProbesAtlas];	
	
}

void InitActivationFrames(CCTexture2D* texture ,CCSpriteBatchNode* spritesheet,Probe* probe,ProbeIndex i,CCSprite* sprite,SpriteDim* d,CellColor c)
{
	int tag						= c==LeftSide?kTagBlueSpriteSheetAtlas:kTagRedSpriteSheetAtlas;
	
	CCSpriteFrame *frame0		= [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(0, d.size.height*0, d.size.width, d.size.height) ];
	CCSpriteFrame *frame1		= [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(0, d.size.height*1, d.size.width, d.size.height)];             
	CCSpriteFrame *frame2		= [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(0, d.size.height*2, d.size.width, d.size.height)];      
	CCSpriteFrame *frame3		= [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(0, d.size.height*3, d.size.width, d.size.height)];      
	CCSpriteFrame *frame4		= [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(0, d.size.height*4, d.size.width, d.size.height) ];

	NSMutableArray *animFrames	= [[NSMutableArray alloc]init];
	
	[animFrames addObject:frame0];
	[animFrames addObject:frame1];
	[animFrames addObject:frame2];
	[animFrames addObject:frame3];
    [animFrames addObject:frame4];
    
    [probe.ProbeDescs[i].animation release];
    [probe.ProbeDescs[i].action release];
    
    probe.ProbeDescs[i].animation	= [[CCAnimation animationWithFrames:animFrames delay:0.3f]retain];	
	probe.ProbeDescs[i].action		= [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:
																	 probe.ProbeDescs[i].animation restoreOriginalFrame:YES]]retain];
	
	[spritesheet addChild:sprite z:0 tag:probe.ProbeDescs[i].index +tag]; 
    
    [animFrames release];
    	
}

-(void) AddBar:(CGPoint) position barTexture:(CCTexture2D*)t
{
	
	CGSize	size				= [LayoutManager GetBarDimensions];
    
    CCSpriteFrame *frame0		= [CCSpriteFrame frameWithTexture:t rect:CGRectMake(0, 0, size.width, size.height)];	
	
	CCSprite *sprite			= [CCSprite spriteWithSpriteFrame:frame0];
	sprite.position				= position;
	
	
	[self addChild:sprite z:2];
	

}

#pragma mark -
#pragma mark Touch handling methods

- (void)onEnter
{
	
    
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [_panRecognizer setMinimumNumberOfTouches:1];
    [_panRecognizer setMaximumNumberOfTouches:1];
    
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:_panRecognizer];
    
       
    self.downSwipeRecognizer    = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDownSwipe:)] autorelease];
    
    self.upSwipeRecognizer      = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpSwipe:)] autorelease];
    
    self.tapGestureRecognizer   = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)]autorelease];
        
    _downSwipeRecognizer.direction  = UISwipeGestureRecognizerDirectionDown;
    
    _upSwipeRecognizer.direction    = UISwipeGestureRecognizerDirectionUp;
    
    _tapGestureRecognizer.numberOfTapsRequired = 2;
        
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:_downSwipeRecognizer]; 
    
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:_upSwipeRecognizer];
    
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:_tapGestureRecognizer];
    
    //[_panRecognizer requireGestureRecognizerToFail : _downSwipeRecognizer];
    //[_upSwipeRecognizer requireGestureRecognizerToFail : _panRecognizer];
    
    //_panRecognizer.delegate = self;
    _upSwipeRecognizer.delegate = self;
    _downSwipeRecognizer.delegate = self;
    
        
	[super onEnter];
}

- (void)onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:_downSwipeRecognizer];
    
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:_panRecognizer];
    
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:_upSwipeRecognizer];
    
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:_tapGestureRecognizer];
    
	[super onExit];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


- (void)handleDownSwipe:(UISwipeGestureRecognizer *)swipeRecognizer
{
     _dir = Down;
}

- (void)handleUpSwipe:(UISwipeGestureRecognizer *)swipeRecognizer
{
    _dir = Up;
}

- (void)handleTap:(UITapGestureRecognizer*)tapRecognizer
{
    _tapDetected = TRUE;
}



-(void)pan:(UIPanGestureRecognizer *)recognizer {    
    
    CGPoint p;
    
    switch (recognizer.state) {
            
        case UIGestureRecognizerStateBegan:
            _touchDetected = true;
            break;
       case UIGestureRecognizerStateEnded:
            
            break;
        case UIGestureRecognizerStateChanged:     
            
            p  =  [recognizer translationInView:[[CCDirector sharedDirector] openGLView]];
            
            if (p.y>=60) {
                _dir = Down;
            }
            else if(p.y<=-60)
            {
                _dir = Up;
            }
            
            
            _touchDetected = false;                    
        default:
            break;
    }    
}


#pragma mark -
#pragma mark  game logic handling methods

- (void)doStep:(ccTime)delta
{
	[[CircuitGameObj sharedInstance] update:_tapDetected];
	
	switch ([[CircuitGameObj sharedInstance] GetGameState]) {
			
		case NotStarted:
			
                                    
			break;

			
		case Started:
						
			break;
			
		case Running:
			
			if (_tapDetected) {
                
				[self ActivateProbe:LeftSide];					
			}
            			
			break;
			
		case Stopped:    
            
            [self HandleGameStopped];
			
			break;
			
		case Completed:
            
            [self schedule:@selector(MainGameDone) interval:1];			
			
			break;
			
		default:
			break;
	}
	
	_tapDetected = FALSE;
	
}

-(void)ActivateProbe:(CellColor)c
{
    
	int tag					= c==LeftSide?kTagBlueSpriteSheetAtlas:kTagRedSpriteSheetAtlas;
	
	int activatedProbeIndex = c==LeftSide?[[CircuitGameObj sharedInstance] LeftPulseIndex]:[[CircuitGameObj sharedInstance]RightPulseIndex];	
	
	int numPulses			= c==LeftSide?[[CircuitGameObj sharedInstance]LeftHandPulses]:[[CircuitGameObj sharedInstance]RightHandPulses];	
	
	
	Probe* probe			= [[CircuitGameObj sharedInstance] GetProbeAtIndex:activatedProbeIndex side:c];    
    
    
    if (numPulses<0) {
        return;
    }
    
    //check at least 2 input limit for latched
    if ([probe GetProbeType]==Single ) {
        
        if (probe.ProbeDescs[Input1].isLatched) {
            
            if (numPulses<1) {
                
                return;
            }
        }
        
        //check if this cell type is flash, if so check current cell color
        if (probe.ProbeDescs[Input1].isFlashSlow) {
           //Cell* cell   = [[CircuitGameObj sharedInstance]RetrieveCellFromIndex:probe.ProbeDescs[Input1].index];
            //tag         = cell.CurrentCellColor==LeftSide?kTagBlueSpriteSheetAtlas:kTagRedSpriteSheetAtlas;
        }
    }
    
    
    
	[self ActivateProbeSprite:probe tag:tag activatedIndex:activatedProbeIndex]; 	
    
}

-(void)ActivateProbeSprite:(Probe*)p  tag:(int)tag  activatedIndex:(int)i;
{
	id sheet;
	id input1Sprite,input2Sprite,output1Sprite,output2Sprite;
	int input1CellIndex,input2CellIndex,output1CellIndex,output2CellIndex;
	
	sheet				= [self getChildByTag:tag];
    bool isactiveSet    = false;
    
	
	//get appropriate cell indexes based on probe type
	//set cell completion block(s) for cells
	switch ([p GetProbeType]) {
		case Single:
			
			if (p.ProbeDescs[Input1].isActionRunning || !p.ProbeDescs[Input1].isActive) {				
				return;
			}
            
            
			
			input1CellIndex		= p.ProbeDescs[Input1].index;
			input1Sprite		= [sheet getChildByTag: input1CellIndex +tag];
			
			//[self SetCellCompletionBlock: input1Sprite cellIndex:input1CellIndex probeIndex:Input1 tag:tag];
			
			[input1Sprite runAction: p.ProbeDescs[Input1].action];
			
			p.ProbeDescs[Input1].isActionRunning = TRUE;
            
            if (p.ProbeDescs[Input1].isInverted) {		
                
				return;
			}
            
            isactiveSet = true;

			
			break;
		case SingleInputTwoOutput:
			
			if (p.ProbeDescs[Input1].isActionRunning || !p.ProbeDescs[Output1].isActive) {
				
				return;
			}
			
			input1CellIndex		= p.ProbeDescs[Input1].index;
			output1CellIndex	= input1CellIndex -1;
			output2CellIndex	= input1CellIndex +1;
			input1Sprite		= [sheet getChildByTag: input1CellIndex +tag];	
			output1Sprite		= [sheet getChildByTag: output1CellIndex +tag];	
			output2Sprite		= [sheet getChildByTag: output2CellIndex +tag];	
			
            [input1Sprite runAction: p.ProbeDescs[Input1].action];
			[output1Sprite runAction: p.ProbeDescs[Output1].action];
			[output2Sprite runAction: p.ProbeDescs[Output2].action];
			
			p.ProbeDescs[Input1].isActionRunning = TRUE;
            
            isactiveSet = true;
			
			break;
		case TwoInputTwoOutput:
			break;
		case TwoInputSingleOutput:	
			
			input1CellIndex		= p.ProbeDescs[Input1].index;
			input2CellIndex		= p.ProbeDescs[Input2].index;
			output1CellIndex	= p.ProbeDescs[Output1].index;
			
			if (i==p.ProbeDescs[Input1].index && !p.ProbeDescs[Input1].isActionRunning) {
				
				input1Sprite		= [sheet getChildByTag: input1CellIndex +tag];		
		
				[input1Sprite runAction: p.ProbeDescs[Input1].action];
				
				p.ProbeDescs[Input1].isActionRunning = true;
                //isactiveSet = true;
			}
            
						
			if (i==p.ProbeDescs[Input2].index && !p.ProbeDescs[Input2].isActionRunning) {
				
				input2Sprite		= [sheet getChildByTag: input2CellIndex +tag];				
				[input2Sprite runAction: p.ProbeDescs[Input2].action];
				
				p.ProbeDescs[Input2].isActionRunning = true;
                //isactiveSet = true;
			}
						
			if (p.ProbeDescs[Input1].isActive && p.ProbeDescs[Input2].isActive ) {
				
				output1Sprite		= [sheet getChildByTag: output1CellIndex +tag];	
				//[self SetCellCompletionBlock:output1Sprite cellIndex:output1CellIndex probeIndex:Output1 tag:tag];
				
				[output1Sprite runAction: p.ProbeDescs[Output1].action];
				
				p.ProbeDescs[Output1].isActionRunning = TRUE;
                isactiveSet = true;
			}			
						
			break;
		default:
			break;
	}
    
    if (!isactiveSet) {
        
        return;
    }
    
    p.ActivationCount++;
    
    [self ToggleCellColor:p];
    
    [[SimpleAudioEngine sharedEngine]playEffect:@"ActivateProbe.wav"];
	
}

-(void)ToggleCellColor:(Probe*)p
{
	id  mainCell1;	
	id  mainCell2;
	
	int outputIndex1;
	int outputIndex2;
    
	if ([p GetProbeType]==Single) {
		
		outputIndex1	= p.ProbeDescs[Output1].index;		
		mainCell1		= [self getChildByTag:kTagCellAtlas+outputIndex1];		
		Cell* cell		= [[CircuitGameObj sharedInstance] RetrieveCellFromIndex: p.ProbeDescs[Input1].index];
        
		if (cell.CurrentCellColor!=cell.OrigCellColor) 
        {
            ToggleCell(mainCell1,TRUE);
		}
        
	}
    else if([p GetProbeType]==TwoInputSingleOutput)
    {
        outputIndex1	= p.ProbeDescs[Output1].index;		
		mainCell1		= [self getChildByTag:kTagCellAtlas+outputIndex1];		
		Cell* cell		= [[CircuitGameObj sharedInstance] RetrieveCellFromIndex: p.ProbeDescs[Output1].index];
        
		if (cell.CurrentCellColor!=cell.OrigCellColor) 
        {
            ToggleCell(mainCell1,TRUE);
		}
    }
	else if ([p GetProbeType]==SingleInputTwoOutput){	
		
		outputIndex1	= p.ProbeDescs[Output1].index;
		outputIndex2	= p.ProbeDescs[Output2].index;
		
		Cell* cell1		= [[CircuitGameObj sharedInstance] RetrieveCellFromIndex:outputIndex1];
		Cell* cell2		= [[CircuitGameObj sharedInstance] RetrieveCellFromIndex:outputIndex2];
		
		if (cell1.CurrentCellColor!=cell1.OrigCellColor) {
			mainCell1	= [self getChildByTag:kTagCellAtlas+outputIndex1];
			ToggleCell(mainCell1,TRUE);		}
		
		if (cell2.CurrentCellColor!=cell2.OrigCellColor) {
			mainCell2	= [self getChildByTag:kTagCellAtlas+outputIndex2];
			ToggleCell(mainCell2,TRUE);
		}
	}
	
}

void ToggleCell(CCSprite* cell,bool parentToChild)
{
	float interval	= 0.5f;
	id action1		=[CCFadeOut actionWithDuration:interval];
	id action2		=[CCFadeIn actionWithDuration:interval];
	id childCell	= [cell getChildByTag:1];
    
	if (parentToChild) {
		
		[cell runAction:action1];
		[childCell runAction:action2];
        
	}
	else {
		
		[childCell runAction:action1];
		[cell runAction:action2];
        
	}
}

-(void)flashCompleteDelegate:(Cell*)cell
{
    id cellSprite		= [self getChildByTag:kTagCellAtlas+cell.CellIndex];
    
    if (cell.CurrentCellColor==cell.OrigCellColor) {
        ToggleCell(cellSprite,FALSE);
    }
    else
    {
        ToggleCell(cellSprite,true);
    }
    
}


-(void)CellCompleteDelegate:(Cell*)cell
{

    int t				= cell.ActivationSide==LeftSide?kTagBlueSpriteSheetAtlas:kTagRedSpriteSheetAtlas;
    
    id sheet			= [self getChildByTag:t];
    
    Probe* p			= [[CircuitGameObj sharedInstance] GetProbeMatchingOutputIndex:cell.CellIndex side:cell.ActivationSide];
    
    ProbeType type = [p GetProbeType];
    
    if ([cell IsLatched]) {
        return;
    }
    
    if (type==Single) {
        
        id input1Sprite		= [sheet getChildByTag: p.ProbeDescs[Input1].index +t];
        
        [self ResetProbeSpriteFrame:input1Sprite probe:p probeType:Input1];	
        
        [self ResetOpposingProbeSpriteFrameIfInverted:cell];
    }
    
    if (type==TwoInputSingleOutput) {
        
        id input1Sprite		= [sheet getChildByTag: p.ProbeDescs[Input1].index +t];
        id input2Sprite		= [sheet getChildByTag: p.ProbeDescs[Input2].index +t];
        id output1Sprite	= [sheet getChildByTag:p.ProbeDescs[Output1].index +t];
        
        
        [self ResetProbeSpriteFrame:input1Sprite probe:p probeType:Input1];
        [self ResetProbeSpriteFrame:input2Sprite probe:p probeType:Input2];
        [self ResetProbeSpriteFrame:output1Sprite probe:p probeType:Output1];
        
        
    }
    
    if (type==SingleInputTwoOutput) {
        
        Cell* cell1			= [[CircuitGameObj sharedInstance] RetrieveCellFromIndex: p.ProbeDescs[Output1].index];
        Cell* cell2			= [[CircuitGameObj sharedInstance] RetrieveCellFromIndex: p.ProbeDescs[Output2].index];
        
        if (![cell1 IsLatched]) {
            
            id output1Sprite	= [sheet getChildByTag: p.ProbeDescs[Output1].index +t];
            [self ResetProbeSpriteFrame:output1Sprite probe:p  probeType:Output1];
            id cellSprite1		= [self getChildByTag:kTagCellAtlas+p.ProbeDescs[Output1].index];
            ToggleCell(cellSprite1,FALSE);
            
        }
        
        if (![cell2 IsLatched]) {
            
            id input1Sprite		= [sheet getChildByTag: p.ProbeDescs[Input1].index +t];
            
            id output2Sprite	= [sheet getChildByTag: p.ProbeDescs[Output2].index +t];
            
            
            [self ResetProbeSpriteFrame:input1Sprite probe:p  probeType:Input1];
            
            [self ResetProbeSpriteFrame:output2Sprite probe:p  probeType:Output2];                    
            id cellSprite2		= [self getChildByTag:kTagCellAtlas+p.ProbeDescs[Output2].index];  
            
            ToggleCell(cellSprite2,FALSE);

        }
    }
    
    if (type==Single || type==TwoInputSingleOutput)
    {
        id cellSprite		= [self getChildByTag:kTagCellAtlas+p.ProbeDescs[Output1].index];
        
        //if (cell.CurrentCellColor==cell.OrigCellColor) {
        ToggleCell(cellSprite,FALSE);
        //}	
    }
    
    [p ResetState];
}

-(void)ResetOpposingProbeSpriteFrameIfInverted:(Cell*)c
{
    int t                   = c.ActivationSide==LeftSide?kTagRedSpriteSheetAtlas:kTagBlueSpriteSheetAtlas;
    
    CellColor oppositeColor = c.ActivationSide==LeftSide?RightSide:LeftSide;
    
    id sheet                = [self getChildByTag:t];
    
    Probe* p                = [[CircuitGameObj sharedInstance] GetProbeMatchingOutputIndex:c.CellIndex side:oppositeColor];
    
    if (p==nil) {
        return;
    }
    
    if (p.ProbeDescs[Input1].isInverted) {
        
        id sprite		= [sheet getChildByTag: p.ProbeDescs[Input1].index +t];
        
        [self ResetProbeSpriteFrame:sprite probe:p probeType:Input1];	
    }

}

-(void)ResetProbeSpriteFrame:(CCSprite*)s probe:(Probe*)p  probeType:(ProbeIndex)pi
{
    [s stopAction: p.ProbeDescs[pi].action];
				
	id f = [p.ProbeDescs[pi].animation.frames objectAtIndex:0];
			
	[s setDisplayFrame:f];
	
}

-(void) draw
{
	GameState st = [[CircuitGameObj sharedInstance] GetGameState];
	
	switch (st) {
		
		case NotStarted:
			
			[self MainGameStarted];
				
			break;
			
		case Running:
		
			[self MainGameRunning];

			break;
	
		case Stopped:
			
			break;
			
		case Completed:
			
			
			break;


		default:
			break;
	}
}

-(void)MainGameStarted
{
	if (!_started) {	
        
        NSString *level             = [NSString stringWithFormat:@"Circuit %d",[[CircuitGameObj sharedInstance]GetStartLevel]+1];
        
        CCLabelTTF* levelLabel		= [CCLabelTTF labelWithString:level fontName:@"ethnocentric" fontSize:18];
        
        levelLabel.position         = [_layoutManager GetStartLevelTextPosition];
        
        levelLabel.color			= ccc3(27,179,27);        
		
		CCSprite *standbySprite		= [CCSprite spriteWithFile:@"standby.png"];		
        
        [self addChild:standbySprite z:100 tag:kTagStandyByAtlas];
        
        [self addChild:levelLabel z:100 tag:kTagStandyByAtlas+1];
        
		standbySprite.position		= [_layoutManager GetStandyByTextPosition];
        
        [[SimpleAudioEngine sharedEngine]playEffect:@"standby.wav"];
        		
		_started = TRUE;
	}
}

-(void)MainGameRunning
{	
	if (_started) {
		
		[self removeChildByTag:kTagStandyByAtlas cleanup:TRUE];
        [self removeChildByTag:kTagStandyByAtlas+1 cleanup:TRUE];
		_started = FALSE;
		
	}
	
	[self UpdateTimerDisplay];	
	[self DrawPulsesRemaining];
}

-(void)HandleGameStopped
{
    if (_endSoundPlayed) {
        return;
    }
    
    _endSoundPlayed = true;
    
    CCSprite *textSprite;
    
	_gameResult		= [[CircuitGameObj sharedInstance] GetGameResult];
	
	switch (_gameResult) {
		case PlayerWon:
            
			textSprite = [CCSprite spriteWithFile:@"WinnerText.png"];
            
            
            
            //[[SimpleAudioEngine sharedEngine]playEffect:@"win.wav"];
			
			break;
			
		case CPUWon:
			
			textSprite = [CCSprite spriteWithFile:@"LoseText.png"];  
            
			break;
			
		case Deadlock:
			
			textSprite = [CCSprite spriteWithFile:@"DeadLockText.png"];
				
			break;

		default:
			break;
	}
	
	[self addChild:textSprite z:100 tag:kTagResultText];	
	textSprite.position	= [_layoutManager GetResultsTextPosition];	
    
    [self schedule:@selector(PlayEndGameSound) interval:0.5];
    
}


- (void)MainGameDone 
{
	CCScene * scene = [CCScene node];
	if ([[CircuitGameObj sharedInstance]GetGameResult]==PlayerWon) {
    
		[scene addChild: [LevelWonLayer node] z:0];
	}
	else {
		
		[scene addChild: [LevelLostOrDrawnLayer node] z:0];
	}
    
    [_label release];
    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFrames]; 
		
	_label = nil;

	[[CCDirector sharedDirector] replaceScene: scene];
	
    [self unscheduleAllSelectors];    
    
}

#pragma mark -
#pragma mark Drawing methods

-(void)DrawPulses
{
        
	if (_dir!=None) {
		//_touchDetected									= FALSE;
        
        int newIndex									= [[CircuitGameObj sharedInstance]GetNextProbeIndex:_leftPulseSprite.CurrentIndex swipeDir:_dir side:LeftSide];
        
        NSLog(@"current index = %d",_leftPulseSprite.CurrentIndex);
        
        _leftPulseSprite.CurrentIndex					= newIndex;
        
        NSLog(@"new index = %d",newIndex);
        
        [CircuitGameObj sharedInstance].LeftPulseIndex	=newIndex;
        
        int yPos										= [_layoutManager GetInputIndexYPosition:newIndex];
                
        [_leftPulseSprite SetYPos:yPos];
		
        _dir=None;
        
        NSLog(@"dir none");
	}
	
	int yRightPos = [_layoutManager GetInputIndexYPosition:[CircuitGameObj sharedInstance].RightPulseIndex];
	[_rightPulseSprite SetYPos:yRightPos];
}

-(void)DrawPulsesRemaining
{
	
	NSString *strLeftPulses		= [NSString stringWithFormat:@"%02d",[CircuitGameObj sharedInstance].LeftHandPulses];
	NSString *strRightPulses	= [NSString stringWithFormat:@"%02d",[CircuitGameObj sharedInstance].RightHandPulses];
	
	CCLabelAtlas *labelAtlas	= (CCLabelAtlas*) [self getChildByTag:kTagLeftPulseAtlas];
	[labelAtlas setString:strLeftPulses];
	
	CCLabelAtlas *leftLabelAtlas	= (CCLabelAtlas*) [self getChildByTag:kTagRightPulsesString];
	[leftLabelAtlas setString:strRightPulses];
	
}

-(void)UpdateTimerDisplay
{
    int timeElapsed             = [[CircuitGameObj sharedInstance] GetGameTimeElapsed];
	NSString *strTime           = [NSString stringWithFormat:@"%02d",timeElapsed];
	CCLabelAtlas *labelAtlas    = (CCLabelAtlas*) [self getChildByTag:kTagTimeElapsedAtlas];
	[labelAtlas setString:strTime];
    
//    if (timeElapsed==6) {
//        
//        
//        [self schedule:@selector(PlayTimerBeep) interval:1];
//    }
//    
//    if (timeElapsed==0) {
//        
//        [self unschedule:@selector(PlayTimerBeep)];
//    }
	
}

-(void)PlayEndGameSound
{
    //NSLog(@"play game sound");
    
    switch (_gameResult) {
        case PlayerWon:
            
            [[SimpleAudioEngine sharedEngine]playEffect:@"32954__hardpcm__chip054.wav"];
            
            break;
        case CPUWon:            
            
            [[SimpleAudioEngine sharedEngine]playEffect:@"51465__smcameron__flak-gun-sound.wav"];
            
            break;
            
        case Deadlock:
            
            [[SimpleAudioEngine sharedEngine]playEffect:@"34231__hardpcm__chip115.wav"];
            break;
        default:
            break;
    }    
    
    [self unschedule:@selector(PlayEndGameSound)];    
    
}

-(void)PlayTimerBeep
{
    [[SimpleAudioEngine sharedEngine]playEffect:@"19911__ls__beep.wav"];
}

- (void)dealloc {
	
    [_downSwipeRecognizer release];
    _downSwipeRecognizer = nil;

    [_upSwipeRecognizer release];
    _upSwipeRecognizer = nil;
    
    [_tapGestureRecognizer release];
    _tapGestureRecognizer = nil;
    
    [_panRecognizer release]; 
    _panRecognizer = nil;
    
    [_layoutManager release];
	[super dealloc];
}

@end