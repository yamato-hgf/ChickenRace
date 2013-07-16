//
//  CCLayerGame.h
//  ChickenRace
//
//  Created by 小川 穣 on 2013/04/14.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "CCLayerExtension.h"
#import "cocos2d.h"
@class CCLayerTitle;

#define NUM_OF_GAMES 3

typedef enum PartTypes : NSUInteger {
	PartTypeEyeL,
	PartTypeEyeR,
	PartTypeHead,
	PartTypeFace,
	PartTypeChin,
	PartTypeTail,
	PartTypeMax
} PartTypes;

@interface PartCtrl: NSObject {
}
-(id) initWithParam:(CCSprite*)sprite_ type:(PartTypes)type_;
@property (assign) PartTypes type;
@property (assign) CCSprite *sprite;
@end

@interface CCLayerGame : CCLayerExtension <GKAchievementViewControllerDelegate,
    GKLeaderboardViewControllerDelegate>
{
	CCLayer *layerUnit;

	NSMutableArray *unitCtrls;

	CCSprite *ccsTutorial;
	CCLayerColor *cclFade;

	CCSprite *ccsIza;
	CCSprite *ccsTouch;
	bool isDispIzaTouch;

	CCSprite *ccsFight;

	CCSprite* ccsResult;
	CCSprite* ccsRetry;
	CCSprite* ccsNext;

    CCLayerTitle *layerTitle;
    
    CCLayer *cclInfo;
	CCLayer *cclSpark;

	CCLabelTTF* cclScore;
	CCLabelTTF* cclResult;

	float stateTimeCount;

    float waitForBiteTime;
    float biteHeadHeightBegin;
    float biteChinHeightBegin;

	CGPoint touchPoint;
    float inputCount;
	bool isTouchBegan;
	bool isTouchMoved;
	bool isTouchEnd;

    NSDate *startTime;
	NSTimeInterval elapsedTime;

	float avoidTime;

	int gameCount;
	int scores[NUM_OF_GAMES];

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

-(void) createDogStand;

@end
