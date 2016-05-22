//
//  RenderOps.h
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 12/05/2010.
//  Copyright 2010 Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface RenderOps : NSObject {
	
	

}

+(void)DrawLine: (CGPoint) from to:(CGPoint) to color:(ccColor4B)c;
+(void) ccFillPoly: (CGPoint*) poli numPoints:(int) points closePoly:(BOOL) closePolygon;

@end
