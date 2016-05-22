//
//  CreditsScene.h
//  Circuitz
//
//  Created by Tanvir Kazi on 27/01/2012.
//  Copyright (c) 2012 Hackers. All rights reserved.
//

#import "cocos2d.h"

@interface CreditsLayer : CCLayerColor {
@private
	CCLabelTTF* _menuLabel;
    NSArray* _labelsArray;
    float _timerDelta;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end

@interface CreditsScene : CCScene {
	//MainGameLayer *_layer;
}
@end
