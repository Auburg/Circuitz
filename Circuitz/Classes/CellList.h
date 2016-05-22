//
//  CellList.h
//  Circuitz
//
//  Created by Tanvir Kazi on 15/04/2010.
//  Copyright 2010 Hackers. All rights reserved.
//


#import "Types.h"
#import "Cell.h"
#import "Constants.h"



@interface CellList : NSObject {

	NSMutableArray* cells;
}

+(int)MaxCells;

-(CellList*)initCells;

-(Cell*)getCell:(int)index;

-(void)dealloc;
-(void)print;

@end
