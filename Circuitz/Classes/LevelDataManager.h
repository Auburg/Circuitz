//
//  LevelDataManager.h
//  Coco2DCircuitz
//
//  Created by Tanvir Kazi on 08/02/2011.
//  Copyright 2011 Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"

@interface LevelDataManager : NSObject {
	int _currentLevel;
	NSString* _levelDataPath;
	NSMutableArray* _leftInputs;
	NSMutableArray* _rightInputs;
	bool _levelDataFound;
}

+(LevelDataManager *)sharedInstance;
-(void)LoadLevelData:(int)level;
-(bool)GetProbeDesc:(int)currentProbeIndex side:(CellColor)s mainType:(ProbeType*)m inputType:(ProbeDesc*)p;
-(bool)DoesLevelExist;
@end
