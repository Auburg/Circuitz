//
//  CellList.m
//  Circuitz
//
//  Created by Tanvir Kazi on 15/04/2010.
//  Copyright 2010 Hackers. All rights reserved.
//

#import "CellList.h"

static const int MAX_CELLS = 12;


@implementation CellList

-(CellList*)initCells
{
	self = [super init];
	
	if (self) {
		
		cells = [NSMutableArray arrayWithCapacity:MAX_CELLS];
		
        for(int i=0;i<MAX_CELLS;i++)
        {
            CellColor currentColor = i%2==0?LeftSide:RightSide;
            
            Cell* cell =  [[Cell alloc] initWithCellColor:currentColor index:i  isSlowFlash:false isFastFlash:false];
            [cells addObject:cell];
            
            [cell release];
        }
		
	}
	
	return self;
}

+(int)MaxCells
{
	return MAX_CELLS;
}


-(Cell*)getCell:(int)index
{
	if (index<MAX_CELLS) {
		
		return [cells objectAtIndex:index];
	}
	
	return nil;
}

-(void)print
{
	NSLog(@"---------------------");
	NSLog(@"-- Cell list contents --");
	
	int index = 0;
	
	for(Cell* cell in cells)
	{
		NSLog(@"%i %@",index++,[cell description]);	
	}
	
	NSLog(@"---------------------");
}

-(void)dealloc
{
	[cells release];
	
	[super dealloc];
}

@end
