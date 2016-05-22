//
//  MainGameScene.h
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 01/05/2010.
//  Copyright 2010 Hackers. All rights reserved.
//

#import "cocos2d.h"
#import "CircuitGameObj.h"
#import "LayoutManager.h"
#import "PulseSprite.h"


enum {
	kTagPulsesAtlas = 1,kTagRightPulseAtlas,kTagRightPulsesString,kTagTimeElapsedAtlas,kTagLeftPulseAtlas,kTagBlueSpriteSheetAtlas=3000,
	kTagRedSpriteSheetAtlas=4000,kTagCellAtlas=5000,kTagStandyByAtlas=5100,kTagResultText
};

@interface MainGameLayer : CCLayerColor<CellDelegate> {
	@private
	bool _started;
	CCLabelTTF *_label;	
	//float timerInterval;
	ccColor4B _backColor;
	//CircuitGameObj* _circuitGameObj;
	LayoutManager* _layoutManager;
	//CGPoint _vertices[4];
	PulseSprite* _leftPulseSprite;
	PulseSprite* _rightPulseSprite;

	CCSpriteBatchNode *_blueProbesSheet;
	CCSpriteBatchNode *_redProbesSheet;
		
	CCTexture2D *_leftLatchTexture;
	CCTexture2D *_rightLatchTexture;
	CCTexture2D *_leftMutexTexture;
	CCTexture2D *_rightMutexTexture;
	CCTexture2D *_leftInverterTexture;	
	CCTexture2D *_blueProbesTexture;	
	CCTexture2D *_leftBoostedTexture;
	CCTexture2D *_rightBoostedTexture;
	CCTexture2D *_leftProbeBarTexture;
	CCTexture2D * _rightProbeBarTexture;
	CCTexture2D *_redCellTexture;
	CCTexture2D *_blueCellTexture;
    
	CCTexture2D *_redProbesTexture;
	
    //bool _playCountdownSound;
	bool _touchDetected;
   // bool _touchStarted;
   // bool _isOneTimeInit;
	Direction _dir;
    float _touchPoint;
    
    UISwipeGestureRecognizer * _downSwipeRecognizer;
    UISwipeGestureRecognizer * _upSwipeRecognizer;
    UITapGestureRecognizer* _tapGestureRecognizer;
    UIPanGestureRecognizer *_panRecognizer;
    
    
    
}
@property (nonatomic, retain) CCLabelTTF *label;
@property (retain) UISwipeGestureRecognizer * downSwipeRecognizer;
@property (retain) UISwipeGestureRecognizer * upSwipeRecognizer;
@property (retain) UITapGestureRecognizer * tapGestureRecognizer;

- (void)MainGameDone;
-(void)MainGameStarted;
-(void)MainGameRunning;
-(void)draw;

-(void)InitProbe:(Probe*)p cellColor:(CellColor)c;
-(void)InitCells;
-(void)InitPulses;
-(void)InitLeftSpriteProbes;
-(void)InitRightSpriteProbes;
-(void)InitTimeElapsed;
-(void)UpdateTimerDisplay;

-(void)DrawPulsesRemaining;
-(void)DrawPulses;
-(void)HandleGameStopped;

-(void)ActivateProbe:(CellColor)c; 
-(void)ActivateProbeSprite:(Probe*)p  tag:(int)tag activatedIndex:(int)i;
-(void)ToggleCellColor:(Probe*)p;
-(void)SetCellCompletionBlock:(CCSprite*)s cellIndex:(int)ci probeIndex:(ProbeIndex)i tag:(int)t;
//-(void)SetFlashCellCompletionBlock:(Cell*)cell cellIndex:(int)ci;
-(void)ResetProbeSpriteFrame:(CCSprite*)s probe:(Probe*)p  probeType:(ProbeIndex)pt;

-(void)ResetOpposingProbeSpriteFrameIfInverted:(Cell*)c;

-(void) AddBar:(CGPoint) position barTexture:(CCTexture2D*)t;

@end

@interface MainGameScene : CCScene {
	//MainGameLayer *_layer;
}
//@property (nonatomic, retain) MainGameLayer *layer;
@end