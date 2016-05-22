//
//  PulseSprite.h
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 29/06/2010.
//  Copyright 2010 Hackers. All rights reserved.
//

#import "cocos2d.h"


@interface PulseSprite : CCSprite  {

	
	int _currentIndex;
	CGRect _rect;
}

@property int CurrentIndex;

@property(nonatomic) CGRect Rect;
+ (id)pulseSpriteTexture:(CCTexture2D *)texture Position:(CGPoint)pos;
-(void)SetYPos:(int)Y;

@end
