//
//  StringOps.m
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 26/05/2011.
//  Copyright 2011 Hackers. All rights reserved.
//

#import "StringOps.h"


@implementation StringOps

+(CGSize)CalculateIdealSize: (NSString*)str font:(NSString*)f  size:(int)s
{
	CGSize maxSize				= { 450, 2000 };		// Start off with an actual width and a height.
	
	// Calculate the actual size of the text with the font, size and line break mode.
	CGSize actualSize			= [str sizeWithFont:[UIFont fontWithName:f size:s]
							 constrainedToSize:maxSize
								 lineBreakMode:UILineBreakModeWordWrap];
	
	return actualSize;
}

+(CCLabelTTF*)InitLabel:(NSString*)str fontSize:(int)s
{
	CCLabelTTF* label				= [CCLabelTTF labelWithString:str fontName:@"Marker Felt" fontSize:s];
	
	label.anchorPoint	= ccp(0,0);
	label.color		= ccc3(120,236,111);
	return label;	
}

+(CCLabelTTF*)InitLabelWithPreferredSize:(NSString*)str containerSize:(CGSize)c fontSize:(int)s
{
	CCLabelTTF* l = [CCLabelTTF labelWithString:str
                                     dimensions:c
                                      alignment:UITextAlignmentLeft
                                       fontName:@"Marker Felt"
                                       fontSize:s];
	
	//l.anchorPoint = ccp(0,0);
	l.color		= ccc3(120,236,111);
	return l;	
	
}


@end
