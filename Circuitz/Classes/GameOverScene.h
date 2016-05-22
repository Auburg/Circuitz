//
//  GameOverScene.h
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 03/04/2011.
//  Copyright 2011 Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CircuitGameObj.h"
#import "MainGameScene.h"
#import	"IntroScene.h"

typedef enum {
	Retry,Menu,Next
}MenuOptions;

@interface LevelWonLayer : CCLayerColor
{
@private
	
}
@end

@interface LevelLostOrDrawnLayer : CCLayerColor
{
@private
	
}
@end

@interface MenuLayer : CCLayerColor {
	
@private
	CGPoint	_centeredMenu;
	BOOL _alignedH;
}

-(id) initShouldShowNext:(bool)b atPosition:(CGPoint)p;
@end
