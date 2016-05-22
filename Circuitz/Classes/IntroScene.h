//
//  IntroScene.h
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 29/04/2010.
//  Copyright 2010 Hackers. All rights reserved.
//

#import "cocos2d.h"
#import "SimpleAudioEngine.h"

@interface IntroScene : CCLayerColor {

@private
	CCLabelTTF* _titleLabel;
	CCLabelTTF* _newGameLabel;
	CCLabelTTF* _continueGameLabel;
	CCLabelTTF* _howToLabel;
    CCLabelTTF* _creditsLabel;
	
    ALuint _introMusicID;
    int _currentLevel;
	int _timerCount;
    NSMutableString* _titleStr;
}


// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
