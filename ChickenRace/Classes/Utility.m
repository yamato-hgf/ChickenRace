//
//  AppDelegate.m
//  ChickenRace
//
//  Created by 小川 穣 on 2013/04/14.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"

@implementation Utility

float screenScaleRate_;
float spriteScaleRate_;
float adBannerHeight_;

+ (void) setScreenScaleRate:(float)rate
{
	screenScaleRate_ = rate;
}

+ (void) setSpriteScaleRate:(float)rate
{
	spriteScaleRate_ = rate;
}

+ (void) setAdBannerHeight:(float)pixel
{
	adBannerHeight_ = pixel;
}

+ (float) screenScaleRate 
{
	return screenScaleRate_;
}

+ (float) spriteScaleRate
{
	return spriteScaleRate_;
}

+ (float) adBannerHeight
{
	return adBannerHeight_;
}

+ (float) s2w:(float)pixel
{
	return pixel * screenScaleRate_;
}

+ (float) s2r:(float)pixel
{
	return pixel * spriteScaleRate_;
}

@end

