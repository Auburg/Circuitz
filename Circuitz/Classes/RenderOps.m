//
//  RenderOps.m
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 12/05/2010.
//  Copyright 2010 Hackers. All rights reserved.
//

#import "RenderOps.h"


@implementation RenderOps



+(void)DrawLine: (CGPoint) from to:(CGPoint) to color:(ccColor4B)c {
	
	const ccColor4B backColor = ccc4(255,0,0,255);
	glDisable(GL_LINE_SMOOTH);
	glLineWidth( 5.0f );
	glColor4ub(c.r,c.g,c.b,255);
	ccDrawLine( from, to );
	
	glColor4ub(backColor.r,backColor.g,backColor.b,255);
}


+(void) ccFillPoly: (CGPoint*) poli numPoints:(int) points closePoly:(BOOL) closePolygon
{
	 
	const ccColor4B backColor = ccc4(255,0,0,255);
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY,
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2, GL_FLOAT, 0, poli);
	if( closePolygon )
		//	 glDrawArrays(GL_LINE_LOOP, 0, points);
		glDrawArrays(GL_TRIANGLE_FAN, 0, points);
	else
		glDrawArrays(GL_LINE_STRIP, 0, points);
	
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
	// restore original values
	glLineWidth(1);
	glColor4ub(backColor.r,backColor.g,backColor.b,255);
	glPointSize(1);
	
}

@end
