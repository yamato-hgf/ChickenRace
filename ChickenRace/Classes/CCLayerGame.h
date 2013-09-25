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

#define NUM_OF_GAMES 5

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
	// タイトル
	CCLayer* cclTitle;
	CCSprite *ccsStartButton;
	CCSprite *ccsTweetButton;
	CCSprite *ccsRankingButton;
	BOOL flagCanTweet;

	// ゲーム
	CCLayer *layerUnit;

	NSMutableArray *unitCtrls;

	CCSprite *background;

	CCSprite *ccsTutorial;
	CCLayerColor *cclFade;

	CCSprite *ccsIza;
	CCSprite *ccsTouch;
	bool isDispIzaTouch;

	bool isFlash;

	CCSprite *ccsFight;

	CCSprite* ccsRetry;
	CCSprite* ccsNext;
	CCSprite* ccsHome;

    CCLayerTitle *layerTitle;
    
    CCLayer *cclInfo;
	CCLayer *cclSpark;

	CCSprite* ccsScoreBack;
	CCLabelTTF* cclLastScore;

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
	float biteAngle;
	float timeScale;

	float biteEffSec;
	float biteEffRealSec;
	CCSprite* biteEff[2];
	CCSprite* effBiteSplash;

	int gameCount;
	float scores[NUM_OF_GAMES];

	CCLayer *cclScores;

	enum ResultType {
		None,
		Success,
		TooFast,
		TooRate,
		TooFar,
		Max
	} resultType;

	NSArray* resultMessages[4];

	float biteTimeCount;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

+(CCLayerGame*) get;

@end
