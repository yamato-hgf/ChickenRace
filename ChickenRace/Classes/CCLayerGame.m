//
//  CCLayerGame.m
//  ChickenRace
//
//  Created by 小川 穣 on 2013/04/14.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import "CCLayerGame.h"
#import "CCLayerTitle.h"
#import "GameKit/GameKit.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - CCLayerGame

// CCLayerGame implementation
@implementation CCLayerGame

static CCLayerGame* instance;
+(CCLayerGame*) get
{
	return instance;
}

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CCLayerGame *layer = [CCLayerGame node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		instance = self;

		resultType = None;
        
        // ask director for the window size
        CGSize size = [[CCDirector sharedDirector] winSize];
 		float scale = [AppController getScaleBase];
        
        CCSprite *background;
        
        background = [CCSprite spriteWithFile:@"background.png"];
        background.position = ccp(size.width/2, size.height/2);
        background.scale = scale;
        
        // add the label as a child to this Layer
        [self addChild: background];

        ccsDogBody = [CCSprite spriteWithFile:@"dog_laugh_body.png"];
        ccsDogBody.position = ccp(size.width/2, ccsDogBody.contentSize.height * 0.5f* scale);
        ccsDogBody.scale = scale;
        
        // add the label as a child to this Layer
        [self addChild: ccsDogBody];

        CGSize bodySize = ccsDogBody.contentSize;
        ccsDogHead = [CCSprite spriteWithFile:@"dog_laugh_head.png"];
        ccsDogHead.position = ccp(bodySize.width/2, bodySize.height/2-16);

        [ccsDogHead runAction: 
        	[CCRepeatForever actionWithAction:
        		[CCSequence actions: 
        			[CCEaseOut actionWithAction: 
        				[CCMoveBy actionWithDuration: 0.2 position:ccp(0,16)] rate:2
        			],
        			[CCEaseIn actionWithAction: 
        				[CCMoveBy actionWithDuration: 0.2 position:ccp(0,-16)] rate:2
        			],
        			nil
        		]
        	]
        ];
        
        // add the label as a child to this Layer
        [ccsDogBody addChild: ccsDogHead];

        layerTitle = [CCLayerTitle layerTitle];
        [self addChild:layerTitle z:0];

        [self schedule:@selector(inputUpdate:)];

		//
		// Leaderboards and Achievements
		//
		
		// Default font size will be 28 points.
		[CCMenuItemFont setFontSize:28];
		
		// Achievement Menu Item using blocks
		CCMenuItemLabel *itemAchievement =
        [CCMenuItemFont
            itemWithString:@"Achievements"
            block:^(id sender) {
                GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
                achivementViewController.achievementDelegate = self;
                AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
                [[app navController] presentModalViewController:achivementViewController animated:YES];
                [achivementViewController release];
            }
		];
        itemAchievement.color = ccBLACK;
        
		// Leaderboard Menu Item using blocks
		CCMenuItemLabel *itemLeaderboard =
        [CCMenuItemFont
            itemWithString:@"Leaderboard"
            block:^(id sender) {
                GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
                leaderboardViewController.leaderboardDelegate = self;
			
                AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			
                [[app navController] presentModalViewController:leaderboardViewController animated:YES];
			
                [leaderboardViewController release];
            }
         ];
        itemLeaderboard.color = ccBLACK;
		
		CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, nil];
		[menu alignItemsHorizontallyWithPadding:20];
		[menu setPosition:ccp( size.width/2, size.height/2 - 50)];
		
		// Add the menu to the layer
		[self addChild:menu];
        
	}
	return self;
}

- (void) gameStart
{
    // ask director for the window size
    CGSize size = [[CCDirector sharedDirector] winSize];
 	float scale = [AppController getScaleBase];
   
	ccsTutorial = [CCSprite spriteWithFile:@"tutorial.png"];
    ccsTutorial.position = ccp(size.width/2, ccsTutorial.contentSize.height * 0.5f * scale);
    ccsTutorial.scale = scale;
    [self addChild:ccsTutorial z:2];

	cclFade = [CCLayerColor layerWithColor:ccc4(0,0,0,128)];
//	[fadeLayer runAction:[CCFadeIn actionWithDuration:0.5f]];
	[self addChild:cclFade z:1];

    [self schedule:@selector(tutorialState:)];	

    self.isTouchEnabled = YES;
}

- (void) dispIzaTouch 
{
	if(isDispIzaTouch)
		return;

    CGSize size = [[CCDirector sharedDirector] winSize];
	float scale = [AppController getScaleBase];

	ccsIza = [CCSprite spriteWithFile:@"iza.png"];
    ccsIza.position = ccp(size.width/2, size.height/2);
    ccsIza.scale = scale;
    [self addChild:ccsIza];

	ccsTouch = [CCSprite spriteWithFile:@"touch.png"];
    ccsTouch.position = ccp(size.width/2, size.height/2);
    ccsTouch.scale = scale;

    id jumpUp = [CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:0.5f position:ccp(0,-25)] rate:2 ];
    id jumpDown = [CCEaseIn actionWithAction:[CCMoveBy actionWithDuration:0.5f position:ccp(0,25)] rate:2 ];
    [ccsTouch runAction: [CCRepeatForever actionWithAction: [CCSequence actions: jumpUp, jumpDown, nil] ] ];
    [self addChild:ccsTouch];
    isDispIzaTouch = TRUE;
}

- (void) hideIzaTouch 
{
	[self removeChild:ccsIza cleanup:YES];
	[self removeChild:ccsTouch cleanup:YES];
	ccsIza = NULL;
	ccsTouch = NULL;
	isDispIzaTouch = FALSE;
}

- (void) tutorialState: (ccTime)dt {
	if(isTouchBegan) {
		[self removeChild:ccsTutorial cleanup:YES];
		[self removeChild:cclFade cleanup:YES];

		[self changeReadyState: false];

		isTouchBegan = false;
	}
}

- (void) changeReadyState: (bool) retry
{
	[self dispIzaTouch];

	resultType = None;
	
	if(retry) {
        
        // ask director for the window size
        CGSize size = [[CCDirector sharedDirector] winSize];
 		float scale = [AppController getScaleBase];

	    ccsDogBody.scale = scale;

	    CCTexture2D* headTex = [[CCTextureCache sharedTextureCache] addImage: @"dog_laugh_head.png"];
		CGSize headSize = [headTex contentSize];
		CGRect headRect = CGRectMake(0, 0, headSize.width, headSize.height);
		[ccsDogHead setTexture:headTex];
		[ccsDogHead setTextureRect:headRect];
		[ccsDogHead removeAllChildrenWithCleanup:YES];

	    CGSize bodySize = ccsDogBody.contentSize;
	    ccsDogHead.position = ccp(bodySize.width/2, bodySize.height/2-16);

		[ccsDogHead stopAllActions];
        [ccsDogHead runAction: 
        	[CCRepeatForever actionWithAction:
        		[CCSequence actions: 
        			[CCEaseOut actionWithAction: 
        				[CCMoveBy actionWithDuration: 0.2 position:ccp(0,16)] rate:2
        			],
        			[CCEaseIn actionWithAction: 
        				[CCMoveBy actionWithDuration: 0.2 position:ccp(0,-16)] rate:2
        			],
        			nil
        		]
        	]
        ];
	}

	[self unschedule:@selector(tutorialState:)];
	[self schedule:@selector(readyState:)];	
}

const CGPoint readyTouchPoint = { 0, -80 };
const float readyTouchRadius = 120;
const float waitForBiteMin = 1;
const float waitForBiteMax = 3;
-(void) readyState: (ccTime)dt {
	if(isTouchBegan) {
	    CGSize size = [[CCDirector sharedDirector] winSize];
		float scale = [AppController getScaleBase];
 	    CGPoint vec = ccp(touchPoint.x - size.width/2
	    				, size.height/2 - touchPoint.y );
	   	if(ccpDistance(vec, readyTouchPoint) < readyTouchRadius) {
	   		[self hideIzaTouch];

			CCSprite* ccsFight = [CCSprite spriteWithFile:@"fight.png"];
            ccsFight.position = ccp(size.width/2, size.height/2);
		    ccsFight.scale = scale * 4.0f;
		    id actSclIn = [CCEaseIn actionWithAction:[CCScaleTo actionWithDuration:0.5f scale:scale] rate:2];
		    id actSclOut = [CCSpawn actions:[CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:0.25f scale:scale * 2.f] rate:3],
		    								[CCFadeOut actionWithDuration:0.1f], nil ];
		    id actions = [CCSequence actions: actSclIn, [CCDelayTime actionWithDuration:1], actSclOut, nil ];
		    [ccsFight runAction: actions];
		    [self addChild:ccsFight];
            
            waitForBiteCount = CCRANDOM_0_1() * waitForBiteMax - waitForBiteMin;
            waitForBiteCount = waitForBiteMin + waitForBiteCount;

            isTouchBegan = false;
            isTouchMoved = false;
            isTouchEnd = false;

		    [self unschedule:@selector(readyState:)];
		    [self schedule:@selector(gameState:) interval:1/60.f repeat:-1 delay:2];
	   	}
	   	isTouchBegan = false;
	}
}

const float warningTouchRadius = 80;
-(void) gameState: (ccTime)dt {
    
	if(isTouchMoved) {
	    CGSize size = [[CCDirector sharedDirector] winSize];
	    float scale = [AppController getScaleBase];
	    CGPoint vec = ccp(touchPoint.x - size.width/2
	    				, size.height/2 - touchPoint.y );
	    float distance = ccpDistance(vec, readyTouchPoint);
	   	if(distance > readyTouchRadius) {
			[self unschedule:@selector(gameState:)];
	   		[self changeResultState: TooFar];
		}
		else if(distance > warningTouchRadius) {
			[self dispIzaTouch];
		}
		else {
			[self hideIzaTouch];
		}
		isTouchMoved = false;
	}
	else if(isTouchEnd) {
		[self unschedule:@selector(gameState:)];
   		[self changeResultState: TooFast];			
	}
    
    waitForBiteCount -= dt;
    if(waitForBiteCount < 0) {
	    float scale = [AppController getScaleBase];

		CCTexture2D* headTex = [[CCTextureCache sharedTextureCache] addImage: @"dog_bite_head.png"];
		CGSize headSize = [headTex contentSize];
		CGRect headRect = CGRectMake(0, 0, headSize.width, headSize.height);
		[ccsDogHead stopAllActions];
		[ccsDogHead setTexture:headTex];
		[ccsDogHead setTextureRect:headRect];

        CGSize bodySize = ccsDogBody.contentSize;
		ccsDogHead.position = ccp(bodySize.width/2 + dogBitePoint.x/ scale,
								bodySize.height/2 + dogBitePoint.y/ scale + biteHeadOpenHeight/ scale);
        biteHeadHeightBegin = ccsDogHead.position.y;

		ccsDogFace = [CCSprite spriteWithFile:@"dog_bite_face.png"];
        ccsDogFace.position = ccp(headSize.width/2 + dogFacePoint.x/ scale, 
        						headSize.height/2 + dogFacePoint.y/ scale);
	    [ccsDogHead addChild:ccsDogFace z:2];

		ccsDogAgo = [CCSprite spriteWithFile:@"dog_bite_ago.png"];
        ccsDogAgo.position = ccp(headSize.width/2 + dogAgoPoint.x/ scale,
        						headSize.height/2 + dogAgoPoint.y/ scale + biteAgoOpenHeight/ scale);
        biteAgoHeightBegin = ccsDogAgo.position.y;
	    [ccsDogHead addChild:ccsDogAgo z:1];

	    biteTimeCount = 0;
	    [self unschedule:@selector(gameState:)];
	    [self schedule:@selector(biteState:)];		        
    }    
}

const CGPoint dogBitePoint = {0, -64};
const CGPoint dogAgoPoint = {8, 40};
const CGPoint dogFacePoint = {-16, 96};
const float biteDogScale = 1.5f;
const float biteHeadOpenHeight = 32;
const float biteAgoOpenHeight = -64;
const float biteTimeSec = 0.5f;
const float biteWaitTimeSec = 2.0f;
const float biteZoomTimeRate = 0.1f;

-(void) biteState: (ccTime)dt {
	float biteTimeBefore = biteTimeCount;
	biteTimeCount += dt;

	float rate = min(1, (biteTimeCount / biteTimeSec));
    rate = 1 - sin(M_PI_2 + M_PI_2 * rate);
    rate = pow(rate, 4);
	rate = min(max(rate, 0), 1);

	float zoomRate = min(1, rate / biteZoomTimeRate);
	float scale = [AppController getScaleBase];
	float zoom = biteDogScale * [AppController getScaleBase];
	ccsDogBody.scale = scale + (zoom - scale) * zoomRate;
	ccsDogHead.position = ccp(ccsDogHead.position.x,
							biteHeadHeightBegin - biteHeadOpenHeight/ scale * rate);
	ccsDogAgo.position = ccp(ccsDogAgo.position.x,
							biteAgoHeightBegin - biteAgoOpenHeight/ scale * rate);

	if(resultType == Success) {
		score = min(biteTimeSec, biteTimeCount) - avoidTime;
        cclScore.string = [NSString stringWithFormat:@"sec %.5f",score];
	}
	else if(resultType == None) {
		if(biteTimeCount < biteTimeSec) {
			if(isTouchEnd) {
                CGSize size = [[CCDirector sharedDirector] winSize];
                
                avoidTime = biteTimeCount;

                cclScore = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
                cclScore.position = CGPointMake(size.width- size.width/4, size.height - 24);
                cclScore.color = ccc3(0,0,0);
                [self addChild:cclScore];
                
				resultType = Success;
			}
		} else if( biteTimeBefore < biteTimeSec) {
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			cclFade = [CCLayerColor layerWithColor:ccc4(255,0,0,0)];
			[cclFade runAction:[CCFadeOut actionWithDuration:0.2f]];
			[self addChild:cclFade z:1];

			resultType = TooRate;
		}
	}

	if(biteTimeCount >= biteWaitTimeSec) {
		[self removeChild:cclFade cleanup:YES];
		[self unschedule:@selector(biteState:)];
		[self changeResultState: resultType];        
	}
}

-(void) changeResultState:(enum ResultType)type {
    CGSize size = [[CCDirector sharedDirector] winSize];
	float scale = [AppController getScaleBase];

	cclFade = [CCLayerColor layerWithColor:ccc4(255,255,255,192)];
	[self addChild:cclFade z:0];

    cclResult = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:16];
    cclResult.position = CGPointMake(size.width/2, size.height/2- 80);
    cclResult.color = ccc3(0,0,0);
    [self addChild:cclResult];

    if(type == Success) {
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:@"com.harvest.cr.dog.hard.high.score"];
        int64_t score64 = (score * 10000);
    scoreReporter.value = score64;
        CCLOG(@"score %d", scoreReporter.value);
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil)
        {
            // 報告エラーの処理
            NSLog(@"error %@",error);
        }
    }]; 
    }
	resultType = type;
	switch(type) {
	case Success:
		cclResult.string = [NSString stringWithFormat:@"「ふっ、やるじゃねぇか」\r\rsec %.5f",score];
		ccsResult = [CCSprite spriteWithFile:@"win.png"];
	    ccsResult.position = ccp(size.width/2, size.height/2);
	    ccsResult.scale = scale;
	    [self addChild:ccsResult];
		break;
	case TooFar:
		cclResult.string = @"「おいおい、どこへ行こうってんだ」\r\r中心から外れすぎないように！";
		[ccsDogHead setTexture:[[CCTextureCache sharedTextureCache] addImage: @"dog_akire_head.png"]];		
		ccsResult = [CCSprite spriteWithFile:@"failed.png"];
	    ccsResult.position = ccp(size.width/2, size.height/2);
	    ccsResult.scale = scale;
	    [self addChild:ccsResult];
	    break;

	case TooFast:
		cclResult.string = @"「このチキン野郎が！」\r\r噛みつかれるまで離しちゃダメだ！";
		[ccsDogHead setTexture:[[CCTextureCache sharedTextureCache] addImage: @"dog_akire_head.png"]];		
		ccsResult = [CCSprite spriteWithFile:@"failed.png"];
	    ccsResult.position = ccp(size.width/2, size.height/2);
	    ccsResult.scale = scale;
	    [self addChild:ccsResult];
		break;

	case TooRate:
		cclResult.string = @"「どうした？ブルって動けなかったかい？」\r\r噛みつかれる前に離そう！";
		ccsResult = [CCSprite spriteWithFile:@"failed.png"];
	    ccsResult.position = ccp(size.width/2, size.height/2);
	    ccsResult.scale = scale;
	    [self addChild:ccsResult];
	    break;
    default:
        break;
	}
/*
	ccsRetry = [CCSprite spriteWithFile:@"retry.png"];
    ccsRetry.position = ccp(size.width/8, size.height/8);
    ccsRetry.scale = scale;
    [self addChild:ccsRetry];

	ccsNext = [CCSprite spriteWithFile:@"next.png"];
    ccsNext.position = ccp(size.width - size.width/8, size.height/8);
    ccsNext.scale = scale;
    [self addChild:ccsNext];
*/
	CCSprite* retry = [CCSprite spriteWithFile:@"retry.png"];
	CCSprite* retrySel = [CCSprite spriteWithFile:@"retry.png"];
	retrySel.scale = 1.2f;

    CCMenuItemSprite * item1 = [CCMenuItemSprite
        itemFromNormalSprite:retry
    	selectedSprite:retrySel
		target:self 
		selector:@selector(pushSpriteButton:)
	];
    [item1 setAnchorPoint:ccp(0.5,0.5)];
    [item1 setPosition:ccp(size.width/8, size.height/8)];
	item1.scale = scale;
    item1.tag=11;
    
	CCSprite* next = [CCSprite spriteWithFile:@"next.png"];
	CCSprite* nextSel = [CCSprite spriteWithFile:@"next.png"];
	nextSel.scale = 1.2f;
    CCMenuItemSprite * item2 = [CCMenuItemSprite 
    	itemFromNormalSprite:next
    	selectedSprite:nextSel
    	block:^(id sender){ 
    		[self pushSpriteButton:sender]; 
    	} 
    ];
	[item2 setAnchorPoint:ccp(0.5,0.5)];
    [item2 setPosition:ccp(size.width - size.width/8, size.height/8)];
    item2.scale = scale;
    item2.tag=22;
    
    ccmMain  = [CCMenu menuWithItems:item1,item2, nil];
    ccmMain.position = ccp(0,0);
//    [menu alignItemsHorizontallyWithPadding:20];

//    [menu setPosition:ccp(size.width/2, size.height/2)];
    [self addChild:ccmMain];
 
	[self hideIzaTouch];
    [self schedule:@selector(resultState:)];		
}

- (void)pushSpriteButton:(id)sender
{
	[self removeChild:ccmMain cleanup:YES];
	[self removeChild:ccsResult cleanup:YES];
    [self removeChild:ccsRetry cleanup:YES];
    [self removeChild:ccsNext cleanup:YES];			
	[self removeChild:cclFade cleanup:YES];
	[self removeChild:cclScore cleanup:YES];
	[self removeChild:cclResult cleanup:YES];
	[self unschedule:@selector(resultState:)];

    CGSize size = [[CCDirector sharedDirector] winSize];
	float scale = [AppController getScaleBase];

    switch([sender tag]){
        case 11:
			[self changeReadyState: true];
			break;
        case 22:
	        // ask director for the window size
		    ccsDogBody.scale = scale;

		    CCTexture2D* headTex = [[CCTextureCache sharedTextureCache] addImage: @"dog_laugh_head.png"];
			CGSize headSize = [headTex contentSize];
			CGRect headRect = CGRectMake(0, 0, headSize.width, headSize.height);
			[ccsDogHead setTexture:headTex];
			[ccsDogHead setTextureRect:headRect];
			[ccsDogHead removeAllChildrenWithCleanup:YES];

		    CGSize bodySize = ccsDogBody.contentSize;
		    ccsDogHead.position = ccp(bodySize.width/2, bodySize.height/2-16);

			[ccsDogHead stopAllActions];
	        [ccsDogHead runAction: 
	        	[CCRepeatForever actionWithAction:
	        		[CCSequence actions: 
	        			[CCEaseOut actionWithAction: 
	        				[CCMoveBy actionWithDuration: 0.2 position:ccp(0,16)] rate:2
	        			],
	        			[CCEaseIn actionWithAction: 
	        				[CCMoveBy actionWithDuration: 0.2 position:ccp(0,-16)] rate:2
	        			],
	        			nil
	        		]
	        	]
	        ];

	        self.isTouchEnabled = NO;
        	[layerTitle dispTitle];
            break;
        default:
            CCLOG(@"???");
            break;
    }
}

-(void) resultState: (ccTime)dt {
/*
	if(isTouchBegan) {
	    CGSize size = [[CCDirector sharedDirector] winSize];
	    touchPoint.y = size.height - touchPoint.y;

	    CGRect rect = CGRectMake(ccsRetry.position.x/2,
	    						ccsRetry.position.y/2,
	    						ccsRetry.contentSize.width/2,
	    						ccsRetry.contentSize.height/2);
		if(CGRectContainsPoint(rect, touchPoint)) {
			ccsRetry->
			ccsPressedButton = ccsRetry;
		}

	    rect = CGRectMake(ccsNext.position.x/2,
						ccsNext.position.y/2,
						ccsNext.contentSize.width/2,
						ccsNext.contentSize.height/2);
		if(CGRectContainsPoint(rect, touchPoint)) {
			cc
			ccsPressedButton = ccsRetry;
		}
	}
	if(ccsPressedButton != NULL) {

	}
	if()
	if(isTouchEnd) {
	    CGSize size = [[CCDirector sharedDirector] winSize];
	    touchPoint.y = size.height - touchPoint.y;
	    CGRect rect = CGRectMake(ccsRetry.position.x/2,
	    						ccsRetry.position.y/2,
	    						ccsRetry.contentSize.width/2,
	    						ccsRetry.contentSize.height/2);
		if(CGRectContainsPoint(rect, touchPoint)) {
			[self removeChild:ccsResult cleanup:YES];
		    [self removeChild:ccsRetry cleanup:YES];
		    [self removeChild:ccsNext cleanup:YES];			
			[self removeChild:cclFade cleanup:YES];
			[self removeChild:cclScore cleanup:YES];
			[self removeChild:cclResult cleanup:YES];
			[self unschedule:@selector(resultState:)];
			[self changeReadyState: true];
		}
		isTouchEnd = false;
	}
*/
}

const float inputCancelTime = 0.5f;
-(void) inputUpdate:(float) dt
{
	if(isTouchBegan || isTouchMoved || isTouchEnd) {
		inputCount -= dt;
		if(inputCount < 0) {
			isTouchBegan =
			isTouchMoved =
			isTouchEnd 	 = false;
		}
	}
}

-(void) registerWithTouchDispatcher
{
    CCDirector *director = [CCDirector sharedDirector];
    [[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	touchPoint = [touch locationInView:[touch view]];
	isTouchBegan = true;
	inputCount = inputCancelTime;
    return TRUE;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	touchPoint = [touch locationInView:[touch view]];
	isTouchMoved = true;
	inputCount = inputCancelTime;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	touchPoint = [touch locationInView:[touch view]];
	isTouchEnd = true;
	inputCount = inputCancelTime;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end
