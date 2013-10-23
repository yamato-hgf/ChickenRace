//
//  Utility.h
//  ChickenRace
//
//  Created by 小川 穣 on 2013/04/14.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface Utility {}
+ (void) setScreenScaleRate:(float)rate;
+ (void) setHeightScaleRate:(float)rate;
+ (void) setSpriteScaleRate:(float)rate;
+ (void) setAdBannerHeight:(float)pixel;
+ (float) screenScaleRate;
+ (float) heightScaleRate;
+ (float) spriteScaleRate;
+ (float) adBannerHeight;
+ (float) s2w:(float)pixel;
+ (float) s2h:(float)pixel;
+ (float) s2r:(float)pixel;

@end
