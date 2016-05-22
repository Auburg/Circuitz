//
//  EndGameScene.h
//  Circuitz
//
//  Created by Tanvir Kazi on 26/11/2011.
//  Copyright (c) 2011 Hackers. All rights reserved.
//

#import "cocos2d.h"

@interface EndGameLayer : CCLayerColor {
@private
	CCLabelTTF* _menuLabel;
}


// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end

@interface EndGameScene : CCScene {
	//MainGameLayer *_layer;
}
@end