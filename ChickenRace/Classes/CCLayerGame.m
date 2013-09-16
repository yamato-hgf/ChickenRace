//
//  CCLayerGame.m
//  ChickenRace
//
//  Created by 小川 穣 on 2013/04/14.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import "CCLayerGame.h"
#import "GameKit/GameKit.h"
#import "IAdLayer.h"

#import "SimpleAudioEngine.h"

#import "Twitter/Twitter.h"
#import "Accounts/Accounts.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "Utility.h"

#pragma mark - CCLayerGame

@implementation PartCtrl

@synthesize sprite;
@synthesize type;

-(id) initWithParam:(CCSprite *)sprite_ Type:(PartTypes)type_
{
    self = [super init];
    if (self != nil) {
        sprite = sprite_;
        type = type_;
    }
    return self;
}

@end

// CCLayerGame implementation
@implementation CCLayerGame

const float infoHeight = 640;

#define DEBUG_FONT_TEST 0

#if DEBUG_FONT_TEST
CCLabelTTF* testTTF = NULL;
int testIndex = 0;
const char* fonts[] = {
    "AppleGothic",
    "Hiragino Kaku Gothic ProN",
    "HiraKakuProN-W6",
    "HiraKakuProN-W3",
    "Arial Unicode MS",
    "ArialUnicodeMS",
    "Heiti K",
    "STHeitiK-Medium",
    "STHeitiK-Light",
    "DB LCD Temp",
    "DBLCDTempBlack",
    "Helvetica",
    "Helvetica-Oblique",
    "Helvetica-BoldOblique",
    "Helvetica-Bold",
    "Marker Felt",
    "MarkerFelt-Thin",
    "Times New Roman",
    "TimesNewRomanPSMT",
    "TimesNewRomanPS-BoldMT",
    "TimesNewRomanPS-BoldItalicMT",
    "TimesNewRomanPS-ItalicMT",
    "Verdana",
    "Verdana-Bold",
    "Verdana-BoldItalic",
    "Verdana",
    "Verdana-Italic",
    "Georgia",
    "Georgia-Bold",
    "Georgia-BoldItalic",
    "Georgia-Italic",
    "Arial Rounded MT Bold",
    "ArialRoundedMTBold",
    "Trebuchet MS",
    "TrebuchetMS-Italic",
    "TrebuchetMS",
    "Trebuchet-BoldItalic",
    "TrebuchetMS-Bold",
    "STHeitiTC-Light",
    "STHeitiTC-Medium",
    "Geeza Pro",
    "GeezaPro-Bold",
    "GeezaPro",
    "Courier",
    "Courier",
    "Courier-BoldOblique",
    "Courier-Oblique",
    "Courier-Bold",
    "Arial",
    "ArialMT",
    "Arial-BoldMT",
    "Arial-BoldItalicMT",
    "Arial-ItalicMT",
    "Heiti J",
    "STHeitiJ-Medium",
    "STHeitiJ-Light",
    "Arial Hebrew",
    "ArialHebrew",
    "ArialHebrew-Bold",
    "Courier New",
    "CourierNewPS-BoldMT",
    "CourierNewPS-ItalicMT",
    "CourierNewPS-BoldItalicMT",
    "CourierNewPSMT",
    "Zapfino",
    "Zapfino",
    "American Typewriter",
    "AmericanTypewriter",
    "AmericanTypewriter-Bold",
    "Heiti SC",
    "STHeitiSC-Medium",
    "STHeitiSC-Light",
    "Helvetica Neue",
    "HelveticaNeue",
    "HelveticaNeue-Bold",
    "Thonburi",
    "Thonburi-Bold",
    "Thonburi"
};
#endif

typedef struct UnitPart {
	int identifier;
	PartTypes type;
	int parent;
	int order;
	char* file;
	CGPoint	position;
	CGPoint	anchor;
	float rotation;
} UnitPart;

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

#define BGM @"Sounds/bgm.mp3"
#define SE_BITE_DAMAGE @"Sounds/bite_damage.mp3"
#define SE_BITE_MISS @"Sounds/bite_miss.mp3"
#define SE_BUTTON_CANCEL @"Sounds/button_cancel.wav"
#define SE_BUTTON_DECIDE @"Sounds/button_decide.wav"
#define SE_BUTTON_START @"Sounds/button_start.wav"
#define SE_ROAR_BITE @"Sounds/roar_bite.mp3"
#define SE_ROAR_GRRR @"Sounds/roar_grrr.mp3"
#define SE_SLOW_MOTION @"Sounds/slow_motion.wav"
#define SE_SYNCHRO @"Sounds/synchro.wav"
#define SE_EYE_FLASH @"Sounds/eye_flash.mp3"

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		instance = self;

        flagCanTweet = true;
		resultType = None;

        // ask director for the window size
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        float spriteScaleRate = [Utility spriteScaleRate];

        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_BITE_DAMAGE];        
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_BITE_MISS];        
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_BUTTON_CANCEL];        
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_BUTTON_DECIDE];        
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_ROAR_BITE];        
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_ROAR_GRRR];        
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_SLOW_MOTION];  
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_SYNCHRO];
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_EYE_FLASH];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:BGM];        

        background = [CCSprite spriteWithFile:@"Game/background.png"];
        background.position = ccp(winSize.width/2, 0);
        background.scale = spriteScaleRate - fmod(spriteScaleRate, 0.5f);
        background.anchorPoint = ccp(0.5f,0);
        // add the label as a child to this Layer
        [self addChild: background];

        layerUnit = [CCLayer node];
        [layerUnit setAnchorPoint:ccp(0.5,0)];
        [self addChild: layerUnit];

        [self createDogStand];

        cclTitle = [CCLayer node];
        [self addChild:cclTitle z:0];

        cclInfo = [CCLayer node];
        [self addChild:cclInfo z:1];

        [self resetScores];

        IAdLayer *adLayer = [IAdLayer nodeWithOrientation:kAdOrientationPortrait
                                                 position:kAdPositionTop];
        
        [self addChild:adLayer];

        gameCount = 0;
        for(int i = 0; i < NUM_OF_GAMES; ++i) {
            scores[i] = 0;
        }

        [self schedule:@selector(inputUpdate:)];
        self.isTouchEnabled = YES;
	}
	return self;
}

//
-(void) onEnter
{
    [super onEnter];

    ACAccountStore *accountStore = [[ACAccountStore alloc] init]; // 追加
    ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]; // 追加
 
    [accountStore requestAccessToAccountsWithType:twitterAccountType  // 追加
                            withCompletionHandler:^(BOOL granted, NSError *error)  // 追加
     { // 追加
         if (!granted) { // 追加
             NSLog(@"ユーザーがアクセスを拒否しました。"); // 追加
         }else{ // 追加
             NSLog(@"ユーザーがアクセスを許可しました。"); // 追加
         } // 追加
     }]; // 追加
#if 0
    /* iOS5以降の場合にアカウント情報変更通知を受ける。 */
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0f)  {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCheckTweetStatus) name:ACAccountStoreDidChangeNotification object:nil];
        [self performSelector:@selector(onCheckTweetStatus)];
    }    
#endif
    [self dispTitle];
}

-(void) setFlagCanTweet:(BOOL)flag
{
    flagCanTweet = flag;
}

- (void) onCheckTweetStatus
{
    /* ツイート可能かどうかをチェックする。 */
    if ([TWTweetComposeViewController canSendTweet]) {
        /* ここでツイート可能判定時の処理を記述する。ボタンの有効化や可視化など。*/
//        [self setFlagCanTweet:YES];
//        [self.btTweet setAlpha:1.0f];
    }
    else  {
        /* ここでツイート不可判定時の処理を記述する。ボタンの無効化や不可視化など。 */
//         [self setFlagCanTweet:NO];
//         [self.btTweet setAlpha:0.3f];
    }
}

- (void) createDogStand
{
    const UnitPart parts[] = {
    	{1, PartTypeMax, 0, 0, "Dog/dog_body.png", ccp(0, 0), ccp(0.5f,0), 0 },
        {2, PartTypeMax, 1, 0, "Dog/dog_head_rear.png", ccp(32, 120), ccp(0.5f,0.5f), -11.25 },
        {3, PartTypeFace, 2, 0, "Dog/dog_head_top.png", ccp(0, 110), ccp(0.5f,0.5f), 0 },
        {4, PartTypeMax, 3, -1, "Dog/dog_head_chin.png", ccp(0, -160), ccp(0.5f,0.5f), 0 },
        {5, PartTypeMax, 3, -1, "Dog/dog_head_hair.png", ccp(0, 100), ccp(0.9f,0), 0 },
        {6, PartTypeTail, 1, -1, "Dog/dog_tail.png", ccp(-128, -32), ccp(1,0), -11.25 },
        {7, PartTypeEyeL, 3, 0, "Dog/dog_head_eye_l.png", ccp(-74, -32), ccp(0.5f,0.5f), 0 },
        {8, PartTypeEyeR, 3, 0, "Dog/dog_head_eye_r.png", ccp(68, -24), ccp(0.5f,0.5f), 0 },
        {0}
    };

    [self createUnitParts: parts];

    float scaleFactor = [AppController getScaleFactor];

    PartCtrl* ctrl = unitCtrls[1];
    [ctrl.sprite runAction:
    	[CCRepeatForever actionWithAction:
    		[CCSequence actions: 
    			[CCEaseOut actionWithAction: 
    				[CCMoveBy actionWithDuration: 0.2 position:ccp(0,16*scaleFactor)] rate:2
    			],
    			[CCEaseIn actionWithAction: 
    				[CCMoveBy actionWithDuration: 0.2 position:ccp(0,-16*scaleFactor)] rate:2
    			],
    			nil
    		]
    	]
    ];

    ctrl = unitCtrls[3];
    [ctrl.sprite runAction:
    	[CCRepeatForever actionWithAction:
    		[CCSequence actions: 
    			[CCEaseOut actionWithAction:
    				[CCMoveBy actionWithDuration: 0.2 position:ccp(0,8*scaleFactor)] rate:2
    			],
    			[CCEaseIn actionWithAction:
    				[CCMoveBy actionWithDuration: 0.2 position:ccp(0,-8*scaleFactor)] rate:2
    			],
    			nil
    		]
    	]
    ];

    ctrl = unitCtrls[5];
    [ctrl.sprite runAction:
    	[CCRepeatForever actionWithAction:
    		[CCSequence actions: 
				[CCRotateBy actionWithDuration: 0.1 angle:-11.25],
				[CCRotateBy actionWithDuration: 0.1 angle:11.25],
    			nil
    		]
		]
	];

    ctrl = unitCtrls[4];
    [ctrl.sprite runAction:
    	[CCRepeatForever actionWithAction:
    		[CCSequence actions: 
    			[CCEaseInOut actionWithAction:
					[CCRotateBy actionWithDuration: 1 angle:-11.25] rate: 3
				],
    			[CCEaseInOut actionWithAction:
					[CCRotateBy actionWithDuration: 1 angle:11.25] rate: 3
				],
    			nil
    		]
		]
	];
}

- (void) createDogLauph
{
    const UnitPart parts[] = {
    	{1, PartTypeMax, 0, 0, "Dog/dog_body.png", ccp(0, 0), ccp(0.5f,0), 0 },
        {2, PartTypeMax, 1, 0, "Dog/dog_head_rear.png", ccp(32, 120), ccp(0.5f,0.5f), -5.625 },
        {3, PartTypeFace, 2, 0, "Dog/dog_head_lauph.png", ccp(0, 80), ccp(0.5f,0.5f), 0 },
        {5, PartTypeMax, 3, -1, "Dog/dog_head_hair.png", ccp(0, 100), ccp(0.9f,0), 5.625f },
        {6, PartTypeMax, 1, -1, "Dog/dog_tail.png", ccp(-128, -32), ccp(1,0), 5.625 },
        {0}
    };
    
    [self createUnitParts: parts];    
    float scaleFactor = [AppController getScaleFactor];

    PartCtrl* ctrl = unitCtrls[1];
    [ctrl.sprite runAction:
        [CCSequence actions:
            [CCEaseOut actionWithAction:
                [CCMoveBy actionWithDuration:0.25f position:ccp(0,10*scaleFactor)]
                rate:6
            ],
            [CCSpawn actions:
                [CCEaseOut actionWithAction:
                    [CCMoveBy actionWithDuration:5.f position:ccp(0,-50*scaleFactor)] 
                    rate:4
                ],
                [CCEaseOut actionWithAction:
                    [CCRotateBy actionWithDuration:5.f angle:-5.625f]
                    rate:4
                ],
                nil
            ],
            nil
        ]
    ]; 

    ctrl = unitCtrls[3];
    [ctrl.sprite runAction:
        [CCSequence actions:
            [CCDelayTime actionWithDuration:0.25f],
            [CCEaseOut actionWithAction:
                [CCRotateBy actionWithDuration:1.f angle:-45] 
                rate:2
            ],
            nil
        ]
    ];  

    ctrl = unitCtrls[4];
    [ctrl.sprite runAction:
        [CCSequence actions:
            [CCDelayTime actionWithDuration:0.25f],
            [CCEaseOut actionWithAction:
                [CCRotateBy actionWithDuration:0.5f angle:-90] 
                rate:2
            ],
            nil
        ]
    ];  

    CCSprite* sprite = [CCSprite spriteWithFile:@"Dog/dog_breath.png"];
    CCNode* parent = [self findUnitPartSpriteByType:PartTypeFace];
    CGPoint pos = parent.position;
    pos = ccpAdd(pos, ccpMult(ccp(40, -160),scaleFactor));
    pos = [parent.parent convertToWorldSpace:pos];

    [sprite setPosition:pos];
    [sprite setScale: [Utility spriteScaleRate]];
    [sprite setVisible: false];
    
    [sprite runAction:
        [CCSequence actions:
            [CCDelayTime actionWithDuration:0.5f],
            [CCShow action],
            [CCCallFunc actionWithTarget:self selector:@selector(cfPlaySigh)],
            [CCSpawn actions:
                [CCEaseOut actionWithAction:
                    [CCMoveBy actionWithDuration:1 position:ccp(45,-45)]
                    rate:2
                ],
                [CCFadeOut actionWithDuration:1],
                nil
            ],
            [CCCallFuncN actionWithTarget:self selector:@selector(cfnRemove:)],
            nil
        ]
     ];

    [self addChild:sprite];
}

- (void) createDogBite
{
    const UnitPart parts[] = {
        {1, PartTypeMax, 0, 0, "Dog/dog_body.png", ccp(0, 0), ccp(0.5f,0), 0 },
        {2, PartTypeHead, 1, 0, "Dog/dog_head_rear.png", ccp(32, 160), ccp(0.5f,0.5f), -11.25 },
        {3, PartTypeMax, 2, 0, "Dog/dog_head_vite.png", ccp(0, 110), ccp(0.5f,0.5f), 0 },
        {4, PartTypeChin, 3, -1, "Dog/dog_head_chin_vite.png", ccp(0, -180), ccp(0.5f,0.5f), 0 },
        {5, PartTypeMax, 3, -1, "Dog/dog_head_hair.png", ccp(0, 80), ccp(0.9f,0), 22.5 },
        {6, PartTypeTail, 1, -1, "Dog/dog_tail.png", ccp(-128, -32), ccp(1,0), -11.25 },
        {0}
    };

    [self createUnitParts: parts];

    CCSprite* sprite = [self findUnitPartSpriteByType: PartTypeHead];
    [sprite runAction:
        [CCEaseIn actionWithAction:
            [CCRotateBy actionWithDuration:0.1f angle:45.f * CCRANDOM_MINUS1_1()]
            rate:3
        ]
    ];
}

- (CCSprite*) findUnitPartSpriteByType: (PartTypes) type
{
	for(int i = 0; i< unitCtrls.count; ++i) {
		PartCtrl* ctrl = unitCtrls[i];
		if(ctrl.type == type)
			return ctrl.sprite;
	}
	return nil;
}

- (void) createUnitParts: (const UnitPart *) unitParts
{
	[layerUnit removeAllChildrenWithCleanup:YES];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
	float spriteScaleRate = [Utility spriteScaleRate];
    float scaleFactor = [AppController getScaleFactor];

    PartCtrl* ctrl;
/*
	if(unitCtrls != nil) {
        ctrl = unitCtrls[0];
        [ctrl.sprite.parent removeChild: ctrl.sprite cleanup: YES];
		[unitCtrls release];
    }
*/
    unitCtrls = [[NSMutableArray alloc] init];
    for(int i = 0; unitParts[i].identifier > 0; ++i) {
        const UnitPart* part = &unitParts[i];
        NSString *nsFile = [NSString stringWithFormat:@"%s", part->file];
    	CCSprite* sprite = [CCSprite spriteWithFile:nsFile];
        CGPoint position = part->position;
        if(part->parent > 0) {
            position = ccpMult(position, scaleFactor);
        	for(int j = 0; j < [unitCtrls count]; ++j) {
    			if(part->parent == unitParts[j].identifier) {
    				ctrl = unitCtrls[j];
                    CGSize resSize = [ctrl.sprite contentSize];
                    position.x += resSize.width / 2;
                    position.y += resSize.height / 2;
		        	sprite.rotation = part->rotation;
		        	[sprite setAnchorPoint: part->anchor];
        			[ctrl.sprite addChild: sprite z:part->order];
                }
            }
    	}
        else {
        	position.x += winSize.width / 2;
        	sprite.scale = spriteScaleRate;
        	sprite.rotation = part->rotation;
        	[sprite setAnchorPoint: part->anchor];
        	[layerUnit addChild: sprite z:part->order];
        }
    	[sprite setPosition: position];
    	ctrl = [[PartCtrl alloc] initWithParam:sprite Type:part->type];
        [unitCtrls addObject: ctrl];
    }	
}

- (void) createEyeFlash:(CCNode*)parent rotation:(float)angle 
{
    CCSprite* sprite = [CCSprite spriteWithFile:@"Game/flash.png"];
    float spriteScaleRate = [Utility spriteScaleRate];

    CGPoint pos = parent.position;
    pos = [parent.parent convertToWorldSpace:pos];

    pos = ccpSub(pos, layerUnit.position);
    [sprite setPosition:pos];
    [sprite setScaleX:4.f * spriteScaleRate];
    [sprite setScaleY:1.5f * spriteScaleRate];
    [sprite setRotation:angle];
    [self addChild:sprite z:parent.zOrder+1];

    [sprite runAction:
        [CCSequence actions:
            [CCSpawn actions:
                [CCEaseIn actionWithAction:[CCScaleTo actionWithDuration:0.1f scaleX:spriteScaleRate scaleY:spriteScaleRate] rate:4 ],
                [CCEaseOut actionWithAction:[CCFadeOut actionWithDuration:1] rate:4 ],
                nil
            ],
            [CCCallFuncN actionWithTarget:self selector:@selector(cfnRemove:)],
            nil
        ]
    ];    
}

-(void) dispTitle
{
    // ask director for the window size
    CGPoint pos;
    CGSize resSize;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float adHeight = [Utility adBannerHeight];
    float scaleBaseSprite = [Utility spriteScaleRate];

    CCLOG(@"winSize.height %f", winSize.height);
    
    CCSprite* title_logo = [CCSprite spriteWithFile:@"UI/title_logo.png"];

    resSize = title_logo.contentSize;
    pos.x = winSize.width/2;
    pos.y = winSize.height -adHeight -[Utility s2r:resSize.height/2];

    title_logo.position = pos;
    title_logo.scale = scaleBaseSprite;
  
    // add the label as a child to this Layer
    [cclTitle addChild: title_logo];

    
    ccsStartButton = [CCSprite spriteWithFile:@"UI/start_button.png"];
    resSize = ccsStartButton.contentSize;
    pos.x = winSize.width/2;
    pos.y = [Utility s2w:64] + [Utility s2r:resSize.height/2];
    ccsStartButton.position = pos;
    ccsStartButton.scale = scaleBaseSprite;

    [ccsStartButton runAction: 
        [CCRepeatForever actionWithAction: 
            [CCSequence actions: 
                [CCEaseInOut actionWithAction: 
                    [CCScaleTo actionWithDuration:0.5f scale:scaleBaseSprite * 0.9f] 
                    rate:3 
                ], 
                [CCEaseInOut actionWithAction: 
                    [CCScaleTo actionWithDuration:0.5f scale:scaleBaseSprite] 
                    rate:3 
                ], 
                nil
            ] 
        ]
    ];

    // add the label as a child to this Layer
    [cclTitle addChild: ccsStartButton];

    //
    // Leaderboards and Achievements
    //
    ccsTweetButton = [CCSprite spriteWithFile:@"UI/tweet_button.png"];
    resSize = ccsTweetButton.contentSize;
    pos.x = [Utility s2w:16] + [Utility s2r:resSize.width/2];
    pos.y = winSize.height - adHeight - [Utility s2w:16] - [Utility s2r:resSize.height/2];
    [ccsTweetButton setPosition:pos];
    [ccsTweetButton setScale:scaleBaseSprite];
    [cclTitle addChild:ccsTweetButton];
    
    ccsRankingButton = [CCSprite spriteWithFile:@"UI/ranking_button.png"];
    resSize = ccsRankingButton.contentSize;
    pos.x = winSize.width - [Utility s2w:16] - [Utility s2r:resSize.width/2];
    pos.y = winSize.height - adHeight - [Utility s2w:16] - [Utility s2r:resSize.height/2];
    [ccsRankingButton setPosition:pos];
    [ccsRankingButton setScale:scaleBaseSprite];
    [cclTitle addChild:ccsRankingButton];
}

- (void) gameStart
{
    [cclTitle removeAllChildrenWithCleanup:YES];
    ccsStartButton = 
    ccsTweetButton = 
    ccsRankingButton = NULL;
    [cclTitle setPosition:ccp(0,0)];

    // ask director for the window size
    CGSize winSize = [[CCDirector sharedDirector] winSize];
 	float spriteScaleRate = [Utility spriteScaleRate];

 	[self createDogStand];
   
	ccsTutorial = [CCSprite spriteWithFile:@"UI/tutorial.png"];
    CGSize size = [ccsTutorial contentSize];
    ccsTutorial.position = ccp(winSize.width/2, -[Utility s2w:50] + [Utility s2r:size.height/2]);
    ccsTutorial.scale = spriteScaleRate;
    [self addChild:ccsTutorial z:2];

	cclFade = [CCLayerColor layerWithColor:ccc4(0,0,0,128)];
	[self addChild:cclFade z:1];

    [self schedule:@selector(tutorialState:)];
}

- (void) dispIzaTouch 
{
	if(isDispIzaTouch)
		return;

    CGSize winSize = [[CCDirector sharedDirector] winSize];
	float spriteScaleRate = [Utility spriteScaleRate];
    float scaleFactor = [AppController getScaleFactor];

    if(ccsIza == NULL) {
    	ccsIza = [CCSprite spriteWithFile:@"UI/iza.png"];
        ccsIza.position = ccp(winSize.width/2, 320 * spriteScaleRate * scaleFactor);
        [self addChild:ccsIza];
    }
    ccsIza.scale = spriteScaleRate;
    [ccsIza setOpacity:255];
    [ccsIza stopAllActions];
    
	ccsTouch = [CCSprite spriteWithFile:@"UI/touch.png"];
    ccsTouch.position = ccp(ccsIza.position.x, ccsIza.position.y
                        - ([ccsIza contentSize].height / 2 * spriteScaleRate)
                        - ([ccsTouch contentSize].height / 2 * spriteScaleRate));
    ccsTouch.scale = spriteScaleRate;

    [ccsTouch runAction: 
        [CCRepeatForever actionWithAction: 
         [CCSequence actions:
                [CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:0.25 position:ccp(0,-8)] rate:3],
                [CCEaseIn actionWithAction:[CCMoveBy actionWithDuration:0.25 position:ccp(0,8)] rate:3],
                nil
            ]
        ]
    ];
    [self addChild:ccsTouch];
    isDispIzaTouch = TRUE;
}

- (void) hideIzaTouch 
{
    if(isDispIzaTouch) {
        float spriteScaleRate = [Utility spriteScaleRate];
    //	[self removeChild:ccsIza cleanup:YES];
        [ccsIza stopAllActions];
        [ccsIza runAction:
            [CCSequence actions:
                [CCEaseOut actionWithAction:
                    [CCScaleTo actionWithDuration:0.1f scale:spriteScaleRate * 0.8f] rate:4
                ],
             [CCFadeOut actionWithDuration:0.2f],
             nil
            ]
        ];

    	[self removeChild:ccsTouch cleanup:YES];
    //	ccsIza = NULL;
    	ccsTouch = NULL;
    }
	isDispIzaTouch = FALSE;
}

- (void) tutorialState: (ccTime)dt {
	if(isTouchBegan) {

        // 決定音
        [[SimpleAudioEngine sharedEngine] playEffect:SE_BUTTON_DECIDE];

		[self removeChild:ccsTutorial cleanup:YES];
		[self removeChild:cclFade cleanup:YES];

		[self changeReadyState: false];

		isTouchBegan = false;
	}
}

- (void) changeReadyState: (bool) retry
{
    resultType = None;

	[self dispIzaTouch];
	[self createDogStand];   

	[self unschedule:@selector(tutorialState:)];
	[self schedule:@selector(readyState:)];	
}

const CGPoint readyTouchPoint = { 0, -80 };
const float readyTouchRadius = 120;
const float waitForBiteMin = 1;
const float waitForBiteMax = 3;
-(void) readyState: (ccTime)dt {

	if(isTouchBegan && !isDispIzaTouch) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        float spriteScaleRate = [Utility spriteScaleRate];
        float adBannerHeight = [Utility adBannerHeight];

        ccsFight = [CCSprite spriteWithFile:@"UI/fight.png"];
        CGPoint pos;
        pos.x = winSize.width/2;
        pos.y = [Utility s2w:infoHeight];
        ccsFight.position = pos;
        ccsFight.scale = [Utility s2r:4.0f];
        [ccsFight runAction: 
            [CCSequence actions:
                [CCEaseIn actionWithAction:[CCScaleTo actionWithDuration:0.25f scale:spriteScaleRate] rate:2],
                [CCDelayTime actionWithDuration:1],
                [CCSpawn actions:[CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:0.25f scale:spriteScaleRate * 2.f] rate:3],
                                        [CCFadeOut actionWithDuration:0.1f], nil ],
                nil
            ]
        ];
        [self addChild:ccsFight];
        
        waitForBiteTime = CCRANDOM_0_1() * waitForBiteMax - waitForBiteMin;
        waitForBiteTime = waitForBiteMin + waitForBiteTime;

        isTouchBegan = false;
        isTouchMoved = false;
        isTouchEnd = false;

        stateTimeCount = 0;
        isFlash = false;

        [self unschedule:@selector(readyState:)];
        [self schedule:@selector(gameState:) interval:1/60.f];      
    }
}

const float waitForFlash = 1.8f;
const float waitForJudge = 2;
const float warningTouchRadius = 80;
-(void) gameState: (ccTime)dt {
	stateTimeCount += dt;
    
	if(stateTimeCount < waitForJudge) {
		if(isTouchEnd || (isTouchMoved && ccsTouchMoved != ccsIza))
			[self dispIzaTouch];
		if(isTouchBegan && ccsTouchBegan != ccsIza)
			[self hideIzaTouch];
	}
	else if(stateTimeCount < waitForBiteTime + waitForFlash) {
		if(isTouchMoved && ccsTouchMoved != ccsIza) {
           resultType = TooFar;
			[self hideIzaTouch];
			[self removeChild: ccsFight cleanup:YES];
			[self unschedule:@selector(gameState:)];
	   		[self changeResultState:0];
		}
		else if(isTouchEnd || isDispIzaTouch) {
            resultType = TooFast;
			[self removeChild: ccsFight cleanup:YES];
			[self unschedule:@selector(gameState:)];
	   		[self changeResultState:0];
		}
	}
    else if(stateTimeCount < waitForBiteTime + waitForJudge) {
        if(!isFlash) {
            isFlash = true;

        // ピキーン！
        [[SimpleAudioEngine sharedEngine] playEffect:SE_EYE_FLASH];        

            CCSprite* parent = [self findUnitPartSpriteByType:PartTypeEyeL];
            [self createEyeFlash:parent rotation:0];
            [self createEyeFlash:parent rotation:90];

            parent = [self findUnitPartSpriteByType:PartTypeEyeR];
            [self createEyeFlash:parent rotation:0];
            [self createEyeFlash:parent rotation:90];
        }
    }
    else {
       [self createDogBite];

        biteHeadHeightBegin = [self findUnitPartSpriteByType:PartTypeHead].position.y;
        biteChinHeightBegin = [self findUnitPartSpriteByType:PartTypeChin].position.y;

        // 時間計測を開始する
        startTime = [ [NSDate date] retain];

        // 吠え声
        [[SimpleAudioEngine sharedEngine] playEffect:SE_ROAR_BITE];        

	    biteTimeCount = 0;
		[self removeChild: ccsFight cleanup:YES];
	    [self unschedule:@selector(gameState:)];
	    [self schedule:@selector(biteState:)interval:1/60.f];
    }    

    isTouchBegan = false;
    isTouchMoved = false;
    isTouchEnd = false;    
}

const CGPoint dogFacePoint = {-16, 96};
const float biteDogScale = 2.0f;
const float biteDogHeight = -64.0f;
const float biteHeadOpenHeight = 64;
const float biteAgoOpenHeight = -128;
const float biteTimeSec = 0.5f;
const float biteWaitTimeSec = 2.0f;
const float biteZoomTimeRate = 0.1f;
const float bitePlayTimeSec = 0.02f;
const float slowMotionBegin = 0.5f;
const float slowMotionMax = 0.5f;
const float slowMotionMin = 0.01f;

-(void) cfPlaySigh {

    // ため息
    [[SimpleAudioEngine sharedEngine] playEffect:SE_ROAR_GRRR];

}

-(void) cfnRemove:(id)sender {
    [self removeChild:sender cleanup:YES];
}

-(float) calcAvoidTime {
    return max(0, min(biteTimeCount, biteTimeSec) + elapsedTime);
}

-(void) biteState: (ccTime)dt {
	float dtRate = 1;
	float biteTimeBefore = biteTimeCount;
	if(resultType == Success) {
		float score = biteTimeSec+elapsedTime;
		float slowMotionRange = biteTimeSec * slowMotionBegin;
        if(biteTimeCount < biteTimeSec && score < slowMotionRange) {
        	dtRate = score / slowMotionRange;
        	dtRate = slowMotionMin + (slowMotionMax - slowMotionMin) * dtRate;
			dt = dt * dtRate;
		}
	}
	biteTimeCount += dt;

	float rate = min(1, ((bitePlayTimeSec + biteTimeCount) / biteTimeSec));
    rate = 1 - sin(M_PI_2 + M_PI_2 * rate);
    rate = pow(rate, 4);
	rate = min(max(rate, 0), 1);

	float zoomRate = min(1, rate / biteZoomTimeRate);
    float scaleFactor = [AppController getScaleFactor];
    float spriteScaleRate = [Utility spriteScaleRate];
    float screenScaleRate = [Utility screenScaleRate];
    float adBannerHeight = [Utility adBannerHeight];

	[layerUnit setScale: 1 + (biteDogScale - 1) * zoomRate];
    [layerUnit setPosition: ccp(0, biteDogHeight * zoomRate)];

    CCSprite* sprite = [self findUnitPartSpriteByType:PartTypeHead];
	sprite.position = ccp(sprite.position.x, biteHeadHeightBegin - (biteHeadOpenHeight * rate)*scaleFactor);
	
    sprite = [self findUnitPartSpriteByType:PartTypeChin];
    sprite.position = ccp(sprite.position.x, biteChinHeightBegin - (biteAgoOpenHeight * rate)*scaleFactor);

	switch(resultType) {
	case None:
		if(biteTimeCount < biteTimeSec) {
			if(isTouchEnd) {
                CGSize winSize = [[CCDirector sharedDirector] winSize];
                CGPoint pos = CGPointMake(winSize.width/2, [Utility s2w:infoHeight] );
                
                ccsScoreBack = [CCSprite spriteWithFile:@"UI/score_back.png"];
                ccsScoreBack.position = pos;
                [ccsScoreBack setScale:spriteScaleRate];
                [ccsScoreBack setOpacity:196];
                [cclInfo addChild:ccsScoreBack];

                cclLastScore = [CCLabelTTF labelWithString:@"" fontName:@"Arial Rounded MT Bold" fontSize:48];
                cclLastScore.position = pos;
                cclLastScore.scale = screenScaleRate;
                [cclInfo addChild:cclLastScore];

		        elapsedTime = [startTime timeIntervalSinceNow];
		        cclLastScore.string = [NSString stringWithFormat:@"%f sec", [self calcAvoidTime]];
				resultType = Success;

                // スローモーション
                [[SimpleAudioEngine sharedEngine] playEffect:SE_SLOW_MOTION];        
			}
		}
		else if( biteTimeBefore < biteTimeSec) {	

            // ズバシュ！
            [[SimpleAudioEngine sharedEngine] playEffect:SE_BITE_DAMAGE];

			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			cclFade = [CCLayerColor layerWithColor:ccc4(255,0,0,0)];
			[cclFade runAction:[CCFadeOut actionWithDuration:0.2f]];
			[cclInfo addChild:cclFade z:1];

			resultType = TooRate;
		}
		break;

	case Success:
        cclLastScore.string = [NSString stringWithFormat:@"%f sec", [self calcAvoidTime]];
	    if(bitePlayTimeSec + biteTimeCount > biteTimeSec) {
	    	if(cclSpark == NULL) {

                // ガキーン！
                [[SimpleAudioEngine sharedEngine] playEffect:SE_BITE_MISS];

		        CGSize winSize = [[CCDirector sharedDirector] winSize];	        
		        cclSpark = [CCLayer node];
		        [cclSpark runAction: 
		        	[CCSequence actions:
		        		[CCDelayTime actionWithDuration: 1 / dtRate],
		        		[CCCallFuncN actionWithTarget:self selector:@selector(cfnRemove:)],
		        		nil
		        	]
		        ];
		        [self addChild: cclSpark];

                for(int i = 0; i < 3; ++i) {
    		        CCSprite* sprite = [CCSprite spriteWithFile:@"Game/spark01.png"];
    		        sprite.position = ccp(winSize.width/2, winSize.height/2-64);
    		        [sprite setAnchorPoint:ccp(0.5,0.5)];
    				[sprite setScale: spriteScaleRate];
                    [sprite setRotation: 45+ i * 120];
    		        [sprite runAction: 
    		        	[CCSpawn actions:
    						[CCEaseOut actionWithAction:
    							[CCScaleTo actionWithDuration: 0.5/dtRate scale:1.2f* spriteScaleRate] rate:2
    						],
    		        		[CCSequence actions:
    		        			[CCDelayTime actionWithDuration: 0.25/dtRate],
    							[CCFadeOut actionWithDuration: 0.25/dtRate],
                                nil
    						],
    						nil
    					]
    		        ];
    	            [cclSpark addChild: sprite];
                }

		        for(int i = 0; i < 3; ++i) {
                    CCSprite* sprite = [CCSprite spriteWithFile:@"Game/spark00.png"];
    		        sprite.position = ccp(winSize.width/2, winSize.height/2-64);
    		        [sprite setAnchorPoint:ccp(0.5,0.5)];
    				[sprite setScale: 0.9f* spriteScaleRate];
                    [sprite setRotation: i * 120];
    		        [sprite runAction: 
    		        	[CCSpawn actions:
    						[CCEaseIn actionWithAction:
    							[CCScaleTo actionWithDuration: 0.5/dtRate scale:1.1f* spriteScaleRate]
                            rate:2],
    		        		[CCSequence actions:
    		        			[CCDelayTime actionWithDuration: 0.25/dtRate],
    							[CCFadeOut actionWithDuration: 0.25/dtRate],
                    			nil
    						],
    						nil
    					]
    		        ];
    	            [cclSpark addChild: sprite];
                }

                for(int i = 0; i < 1; ++i) {
                    CCSprite* sprite = [CCSprite spriteWithFile:@"Game/spark02.png"];
                    sprite.position = ccp(winSize.width/2, winSize.height/2-64);
                    [sprite setAnchorPoint:ccp(0.5,0.5)];
                    [sprite setScale: 0.75f* spriteScaleRate];
                    [sprite setRotation: 22.5f + i * 120];
                    [sprite runAction: 
                        [CCSpawn actions:
                            [CCEaseOut actionWithAction:
                                [CCScaleTo actionWithDuration: 0.4/dtRate scale:2.f* spriteScaleRate]
                            rate:2],
                            [CCSequence actions:
                                [CCDelayTime actionWithDuration: 0.2/dtRate],
                                [CCFadeOut actionWithDuration: 0.2/dtRate],
                                nil
                            ],
                            nil
                        ]
                    ];
                    [cclSpark addChild: sprite];
                }
			}
		}        
		break;
            
    default:
        break;
	}

	if(biteTimeCount >= biteWaitTimeSec) {
        [startTime release];
        startTime = NULL;        
        
		[cclInfo removeChild:cclFade cleanup:YES];
		[self unschedule:@selector(biteState:)];
		[self scheduleOnce:@selector(changeResultState:)delay:0];//delay:0.6];
	}
}

-(void) changeResultState:(ccTime)dt {
    CGPoint pos;
    CGSize resSize;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float screenScaleRate = [Utility screenScaleRate];
	float spriteScaleRate = [Utility spriteScaleRate];
    float adBannerHeight = [Utility adBannerHeight];

    float sec = [self calcAvoidTime];

    scores[gameCount] = -1;

    if(ccsScoreBack != NULL)
        [cclInfo removeChild:ccsScoreBack cleanup:YES];
    ccsScoreBack = NULL;

    if(cclLastScore != NULL)
        [cclInfo removeChild:cclLastScore cleanup:YES];
    cclLastScore = NULL;
    

    NSString* resultText = NULL; 
    float resultScale = 0.5f * spriteScaleRate;
    id resultActions = NULL;
	switch(resultType) {
	case Success:
		ccsResult = [CCSprite spriteWithFile:@"UI/win.png"];
        resultScale  = [Utility s2r:2.0f];
        resultActions = [CCEaseIn actionWithAction:[CCScaleTo actionWithDuration:0.1f scale:0.5f * spriteScaleRate] rate:2];
        scores[gameCount] = sec;
        resultText = [NSString stringWithFormat:@"「ふっ、やるじゃねぇか」\r\r%f sec", sec];

        gameCount++;
        if(gameCount < NUM_OF_GAMES) {
            ccsNext = [CCSprite spriteWithFile:@"UI/next_button.png"];
            CGSize resSize = [ccsNext contentSize];
            ccsNext.position = ccp(winSize.width/2, [Utility s2w:64] + [Utility s2r:resSize.height/2]);
            ccsNext.scale = spriteScaleRate;

            [ccsNext runAction: 
                [CCRepeatForever actionWithAction: 
                    [CCSequence actions: 
                        [CCEaseInOut actionWithAction: 
                            [CCScaleTo actionWithDuration:0.5f scale:spriteScaleRate * 0.9f] 
                            rate:3 
                        ], 
                        [CCEaseInOut actionWithAction: 
                            [CCScaleTo actionWithDuration:0.5f scale:spriteScaleRate] 
                            rate:3 
                        ], 
                        nil
                    ] 
                ]
            ];        
            [cclInfo addChild:ccsNext];
        }
        else {
            GKScore *scoreReporter = [[GKScore alloc] initWithCategory:@"com.harvest.cr.dog.easy.high.score"];
            float score = 0;
            for(int i = 0; i < NUM_OF_GAMES; ++i)
                if(scores[i] >= 0)
                    score += scores[i];
            scoreReporter.value = score * 1000000;
            [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {}]; 

            NSString *nssTotal = [NSString stringWithFormat:@"トータルスコア\r%f sec", score];
            CCLabelTTF* cclTotal = [CCLabelTTF labelWithString:nssTotal fontName:@"Marker Felt" fontSize:16];
            cclTotal.position = CGPointMake(winSize.width/2, winSize.height/2- 80);
            cclTotal.scale = screenScaleRate;
            cclTotal.color = ccc3(0,0,0);
            [cclInfo addChild:cclTotal];            
        }
		break;
	case TooFar:
		resultText = @"「おいおい、どこへ行こうってんだ」\r\r中心から外れすぎないように！";
        ccsResult = [CCSprite spriteWithFile:@"UI/failed.png"];
	    [self createDogLauph];
	    break;

	case TooFast:
		resultText = @"「このチキン野郎が！」\r\r噛みつかれるまで離しちゃダメだ！";
		ccsResult = [CCSprite spriteWithFile:@"UI/failed.png"];
	    [self createDogLauph];
		break;

	case TooRate:
		resultText = @"「どうした？ブルって動けなかったかい？」\r\r噛みつかれる前に離そう！";
		ccsResult = [CCSprite spriteWithFile:@"UI/failed.png"];
	    break;
    default:
        break;
	}

    resSize = [ccsResult contentSize];
    pos.x = winSize.width/2;
    pos.y = [Utility s2w:320];
    ccsResult.position = pos;
    ccsResult.scale = resultScale;
    if(resultActions)
        [ccsResult runAction: resultActions];
    [cclInfo addChild:ccsResult];

    CCSprite* ccsClowd = [CCSprite spriteWithFile:@"UI/clowd_normal.png"];
    resSize = [ccsClowd contentSize];
    ccsClowd.position = ccp(winSize.width/2, [Utility s2w:480]);
    ccsClowd.anchorPoint = ccp(0.5,0);
    ccsClowd.scale = spriteScaleRate;
//    [ccsClowd setOpacity: 196];
    [cclInfo addChild:ccsClowd];

    cclResult = [CCLabelTTF labelWithString:resultText fontName:@"Arial Rounded MT Bold" fontSize:32];
    cclResult.position = CGPointMake(winSize.width/2, [Utility s2w:infoHeight+50]);
    cclResult.scale = screenScaleRate;
    cclResult.color = ccc3(0,0,0);
    [cclInfo addChild:cclResult];

	ccsHome = [CCSprite spriteWithFile:@"UI/home_button.png"];
    ccsHome.position = ccp(winSize.width - winSize.width/8, winSize.width/8);
    ccsHome.scale = spriteScaleRate;
    [cclInfo addChild:ccsHome]; 

    ccsRetry = [CCSprite spriteWithFile:@"UI/retry_button.png"];
    ccsRetry.position = ccp(winSize.width/8, winSize.width/8);
    ccsRetry.scale = spriteScaleRate;
    [cclInfo addChild:ccsRetry];
    
    [self resetScores];

    for(int i = 0; i < gameCount; ++i) {
        CGPoint pos = CGPointMake(winSize.width/4, winSize.height -adBannerHeight -[Utility s2w:48]);
        if(i % 2) pos.x = pos.x * 3;
        pos.y -= [Utility s2w:48] * (i/2);

        CCSprite* ccsFrame = [CCSprite spriteWithFile:@"UI/score_frame.png"];
        resSize = [ccsFrame contentSize];
        ccsFrame.position = pos;
        ccsFrame.scale = spriteScaleRate;
        [cclScores addChild:ccsFrame];

        NSString* rounds[] = { @"1st", @"2nd", @"3rd", @"4th", @"5th" };
        CCLabelTTF* cclRound = [CCLabelTTF labelWithString:rounds[i] fontName:@"Arial Rounded MT Bold" fontSize:24];
        cclRound.position = CGPointMake(pos.x - [Utility s2r:resSize.width/2] + [Utility s2w:24], pos.y);
        cclRound.scale = screenScaleRate;
        [cclRound setAnchorPoint: ccp(0,0.5f)];
        [cclScores addChild:cclRound];

        NSString *nssScore = [NSString stringWithFormat:@"%f sec", scores[i]];
        CCLabelTTF* cclScore = [CCLabelTTF labelWithString:nssScore fontName:@"Arial Rounded MT Bold" fontSize:24];
        cclScore.position = CGPointMake(pos.x + [Utility s2r:resSize.width/2] - [Utility s2w:24], pos.y);
        cclScore.scale = screenScaleRate;
        [cclScore setAnchorPoint: ccp(1,0.5f)];
        [cclScores addChild:cclScore];
    }

    [self hideIzaTouch];
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
    CGPoint location = [[CCDirector sharedDirector] convertToGL:touchPoint];

    [self touchBeganButton:ccsStartButton touchLocation:location];
    [self touchBeganButton:ccsTweetButton touchLocation:location];
    [self touchBeganButton:ccsRankingButton touchLocation:location];

    [self touchBeganButton:ccsRetry touchLocation:location];
    [self touchBeganButton:ccsHome touchLocation:location];
    [self touchBeganButton:ccsNext touchLocation:location];
    if([self touchBeganButton:ccsIza touchLocation:location scaling:false]) {

        // シンクロ音
        [[SimpleAudioEngine sharedEngine] playEffect:SE_SYNCHRO];

        [self hideIzaTouch];  
    }

	isTouchBegan = true;
	inputCount = inputCancelTime;
    return YES;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	touchPoint = [touch locationInView:[touch view]];
    CGPoint location = [[CCDirector sharedDirector] convertToGL:touchPoint];

	isTouchMoved = true;
    [self touchMovedButton:ccsIza touchLocation:location];
	inputCount = inputCancelTime;
}

-(void) hideResult {
	[cclInfo removeAllChildrenWithCleanup:YES];
	[self removeChild:cclSpark cleanup:YES];
	cclSpark = NULL;
	ccsHome = NULL;
    ccsNext = NULL;
	ccsRetry = NULL;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	touchPoint = [touch locationInView:[touch view]];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGPoint location = [[CCDirector sharedDirector] convertToGL:touchPoint];
    float spriteScaleRate = [Utility spriteScaleRate];

#if DEBUG_FONT_TEST
    if(testTTF) {
        [self removeChild:testTTF cleanup:YES];
        testTTF = NULL;
        int max = sizeof(fonts) / sizeof(fonts[0]);
        if(location.x > winSize.width/2) {
            testIndex++;
            testIndex %= max;
        }
        else {
            testIndex--;
            if(testIndex < 0)
                testIndex += max;               
        }
        CCLOG(@"max %d", max);
    }
    NSString *font = [NSString stringWithFormat:@"%s", fonts[testIndex]];
    testTTF = [CCLabelTTF labelWithString:font fontName:font fontSize:20];
    testTTF.position = CGPointMake(0, winSize.height/4);
    [testTTF setAnchorPoint:CGPointMake(0,0)];
    [self addChild:testTTF];
#endif
    if([self touchEndButton:ccsStartButton touchLocation:location]) {
        
        // スタート音
        [[SimpleAudioEngine sharedEngine] playEffect:SE_BUTTON_START];

        [cclTitle runAction:
            [CCSequence actions: 
                [CCDelayTime actionWithDuration:0.1], 
                [CCEaseIn actionWithAction: [CCMoveBy actionWithDuration:0.5 position:ccp(0, winSize.height*2) ] rate:2 ],
                nil
            ]
        ];

//        [self gameStart];
        [self scheduleOnce:@selector(gameStart)delay:0.6];
        return;
    }

   if([self touchEndButton:ccsTweetButton touchLocation:location isRespawn:true]) {

        // 決定音
        [[SimpleAudioEngine sharedEngine] playEffect:SE_BUTTON_DECIDE];

        /* ツイート可能になっていない場合 */
        if(!flagCanTweet)  {
                /* UIAlertViewなどでアラート表示 */
        }
        /* ツイート可能な状態の場合 */
        else {

            /* ツイート画面のためのビューコントローラインスタンスを生成する。 */
            TWTweetComposeViewController *vcTweet = [[TWTweetComposeViewController alloc] init];

                /* 初期表示文字列の指定 */
            [vcTweet setInitialText:[NSString stringWithFormat:@"いぬ "]];

            /* ツイート結果ハンドラブロック(ツイート送信orキャンセル時の処理をここに記述) */
            [vcTweet setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
                NSString *stringOutPut = nil;
                switch (result) {
                    case TWTweetComposeViewControllerResultCancelled:
                        // The cancel button was tapped.
                        stringOutPut = @"ツイートをキャンセルしました。";
                        break;
                    case TWTweetComposeViewControllerResultDone:
                        // The tweet was sent.
                        stringOutPut = @"ツイートに成功しました。";
                        break;
                    default:
                        break;
                }

                // Dismiss the tweet composition view controller.
                [vcTweet dismissModalViewControllerAnimated:YES];
            }];

            [[CCDirector sharedDirector] presentModalViewController:vcTweet animated:YES];
            [vcTweet release];
        }
    }

   if([self touchEndButton:ccsRankingButton touchLocation:location isRespawn:true]) {

        // 決定音
        [[SimpleAudioEngine sharedEngine] playEffect:SE_BUTTON_DECIDE];

        GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
       leaderboardViewController.leaderboardDelegate = [CCLayerGame get];
    
        AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
        [[app navController] presentModalViewController:leaderboardViewController animated:YES];
        [leaderboardViewController release];
    }


    if([self touchEndButton:ccsNext touchLocation:location]) {

        // スタート音
        [[SimpleAudioEngine sharedEngine] playEffect:SE_BUTTON_START];

        [self hideResult];
        [background setScale:spriteScaleRate];
        [layerUnit setScale:1];
        [layerUnit setPosition: CGPointZero];
        [self changeReadyState: true];      
    }
    if([self touchEndButton:ccsRetry touchLocation:location]) {

        // キャンセル音
        [[SimpleAudioEngine sharedEngine] playEffect:SE_BUTTON_CANCEL];

    	[self hideResult];
        [background setScale:spriteScaleRate];
        [layerUnit setScale:1];
        [layerUnit setPosition: CGPointZero];
		[self changeReadyState: true];    	
        [self resetScores];
        gameCount = 0;
    }
    if([self touchEndButton:ccsHome touchLocation:location]) {

        // キャンセル音
        [[SimpleAudioEngine sharedEngine] playEffect:SE_BUTTON_CANCEL];

    	[self hideResult];
		[self createDogStand];
        [background setScale:spriteScaleRate];
        [layerUnit setScale:1];
        [layerUnit setPosition: CGPointZero];
        [self dispTitle];
        [self resetScores];
            gameCount = 0;
    }

	isTouchEnd = true;
	inputCount = inputCancelTime;
}

- (void) resetScores
{
    if(cclScores != NULL)
        [self removeChild:cclScores cleanup:YES];
    cclScores = [CCLayer node];
    [self addChild:cclScores z:2];    
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
