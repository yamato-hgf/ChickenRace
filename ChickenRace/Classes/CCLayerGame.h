//
//  CCLayerGame.h
//  ChickenRace
//
//  Created by 小川 穣 on 2013/04/14.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "cocos2d.h"
@class CCLayerTitle;

@interface CCLayerGame : CCLayer <GKAchievementViewControllerDelegate,
    GKLeaderboardViewControllerDelegate>
{
	CCSprite *ccsDogBody;
	CCSprite *ccsDogHead;

	CCSprite *ccsTutorial;
	CCLayerColor *cclFade;

	CCSprite *ccsIza;
	CCSprite *ccsTouch;
	bool isDispIzaTouch;

	CCSprite* ccsDogAgo;
	CCSprite* ccsDogFace;

	CCSprite* ccsResult;
	CCSprite* ccsRetry;
	CCSprite* ccsNext;

	CCSprite* ccsPressedButton;
	CGRect pressedButtonRect;

    CCLayerTitle *layerTitle;

	CCLabelTTF* cclScore;
	CCLabelTTF* cclResult;
	CCMenu* ccmMain;

    float waitForBiteCount;
    float biteHeadHeightBegin;
    float biteAgoHeightBegin;

	CGPoint touchPoint;
    float inputCount;
	bool isTouchBegan;
	bool isTouchMoved;
	bool isTouchEnd;

	float avoidTime;
	float score;

	enum ResultType {
		None,
		Success,
		TooFast,
		TooRate,
		TooFar
	} resultType;

	float biteTimeCount;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

+(CCLayerGame*) get;

-(void) gameStart;

@end
