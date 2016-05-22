//
//  GameSettings.h
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 29/12/2010.
//  Copyright 2010 Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"    

@interface GameSettings : NSObject {

@private
	NSDictionary *_gameData; 
	NSString* _gameDocPath;
    int _maxAlternateCellsLevel;
    int _maxRightCellLevel;
    int _maxLeftCellLevel;
    int _hardAILevelStart;
}

@property int CurrentLevel;

-(GameSettings*)init;
-(int)GetStartLevel;
-(CellConfig)GetCellConfig;
-(void)WriteDataToFile;
-(void)ReadDataFromFile;
-(void)dealloc;
-(int)GetHardAILevelStart;

@end
