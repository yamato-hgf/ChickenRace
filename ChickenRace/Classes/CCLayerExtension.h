//
//  CCLayerExtension.h
//  ChickenRace
//
//  Created by 小川 穣 on 2013/04/14.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCLayerExtension : CCLayer {
	CCSprite *ccsTouchBegan;
}
-(bool)touchBeganButton:(CCSprite *)sprite touchLocation:(CGPoint)location;
-(bool)touchEndButton:(CCSprite *)sprite touchLocation:(CGPoint)location;
-(bool)touchEndButton:(CCSprite *)sprite touchLocation:(CGPoint)location isRespawn:(bool)respawn;

@end
