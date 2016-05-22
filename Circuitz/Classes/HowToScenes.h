//
//  HowToScene1.h
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 16/01/2011.
//  Copyright 2011 Hackers. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface HowToScenes : CCScene {
	
}

@end

@interface BasicLayoutLayer : CCLayerColor {
@private
	
	//CCLabelTTF* _gameDescLabel;
	CCLabelTTF* _nextLabel;
	
	CCSprite *_menuSprite;
}
@end

@interface SwipeUpDownToMoveLayer : CCLayerColor {
@private
	
	//CCLabelTTF* _gameDescLabel;
	CCLabelTTF* _nextLabel;
    CCLabelTTF* _prevLabel;
	CCSprite *_menuSprite;
}

@end

@interface DoubleTapToActivateLayer : CCLayerColor
{
@private
	CCLabelTTF* _prevLabel;
	CCLabelTTF* _nextLabel;
    CCSprite *_menuSprite;
}

@end

@interface InputTypesLayer : CCLayerColor {
@private	
	
	CCLabelTTF* _prevLabel;
    CCSprite *_menuSprite;
	
}

@end

@interface HowToWinLayer : CCLayerColor {
@private	
	
	CCLabelTTF* _nextLabel;
	CCLabelTTF* _prevLabel;
    CCSprite *_menuSprite;
	
}

@end