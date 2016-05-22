//
//  StringOps.h
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 26/05/2011.
//  Copyright 2011 Hackers. All rights reserved.
//

#import "cocos2d.h"


@interface StringOps : NSObject {

	
}

+(CGSize)CalculateIdealSize: (NSString*)str font:(NSString*)f  size:(int)s;
+(CCLabelTTF*)InitLabel:(NSString*)str fontSize:(int)s;
+(CCLabelTTF*)InitLabelWithPreferredSize:(NSString*)str containerSize:(CGSize)c fontSize:(int)s;

@end
