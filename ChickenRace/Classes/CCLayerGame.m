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
#import "CCActionGrid3D.h"

#import "SimpleAudioEngine.h"

#import "Twitter/Twitter.h"
#import "Accounts/Accounts.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "Utility.h"

#pragma mark - CCLayerGame

@interface ResultData: NSObject {
@public
    NSString* jpMsg;
    NSString* usMsg;
    NSString* cloud;
};
-(NSString*) jpMsg;
-(NSString*) usMsg;
-(NSString*) cloud;
@end

@implementation ResultData

-(id) initWithParam:(NSString *)jpMsg_ us:(NSString*)usMsg_ cloud:(NSString*)cloud_
{
    self = [super init];
    if (self != nil) {
        jpMsg = jpMsg_;
        usMsg = usMsg_;
        cloud = cloud_;
    }
    return self;
}

-(NSString*) jpMsg { return jpMsg; }
-(NSString*) usMsg { return usMsg; }
-(NSString*) cloud { return cloud; }

@end

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

typedef struct {
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
#define SE_JINGLE_OK @"Sounds/se_jingle_ok.mp3"
#define SE_JINGLE_GOOD @"Sounds/se_jingle_good.mp3"
#define SE_JINGLE_MISS @"Sounds/se_jingle_miss.mp3"
#define SE_NEW_RECORDS @"Sounds/new_records.mp3"

const float bgmVolume = 0.5f;

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

        resultMessages[0] = [[NSArray alloc] initWithObjects:
            [[ResultData alloc] initWithParam:@"「ふっ、\nやるじゃねぇか」" us:@"" cloud:@"CLOUD_NORMAL"]
        ,   [[ResultData alloc] initWithParam:@"「オレはまだ３回の\n変身を残している」" us:@"" cloud:@"CLOUD_NORMAL"]
        ,   [[ResultData alloc] initWithParam:@"「避けさせて\nやったんだよ」" us:@"" cloud:@"CLOUD_NORMAL"]
        ,   nil];
        
        resultMessages[1] = [[NSArray alloc] initWithObjects:
            [[ResultData alloc] initWithParam:@"「おい！\nチートするなよ！」" us:@"" cloud:@"CLOUD_SPIKE"]
        ,   [[ResultData alloc] initWithParam:@"「見えぬ！\nこの神の目にも！」" us:@"" cloud:@"CLOUD_SPIKE"]
        ,   [[ResultData alloc] initWithParam:@"「質量を持った\n残像だと・・・！」" us:@"" cloud:@"CLOUD_NORMAL"]
        ,   nil];

        resultMessages[2] = [[NSArray alloc] initWithObjects:
            [[ResultData alloc] initWithParam:@"「負け犬は帰んな」" us:@"" cloud:@"CLOUD_NORMAL"]
        ,   [[ResultData alloc] initWithParam:@"「国へ帰るんだな・・・\nオマエにも家族はいるだろう」" us:@"" cloud:@"CLOUD_NORMAL"]
        ,   nil];

        dogAtlasRects = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSValue valueWithCGRect:CGRectMake(1,1,313,254)], @"DOG_BODY",
            [NSValue valueWithCGRect:CGRectMake(1,257,117,119)], @"DOG_BREATH", 
            [NSValue valueWithCGRect:CGRectMake(129,257,195,124)], @"DOG_HEAD_CHIN_LAUPH", 
            [NSValue valueWithCGRect:CGRectMake(1,385,189,241)], @"DOG_HEAD_CHIN_VITE", 
            [NSValue valueWithCGRect:CGRectMake(257,385,195,124)], @"DOG_HEAD_CHIN", 
            [NSValue valueWithCGRect:CGRectMake(385,257,114,106)], @"DOG_HEAD_EYE_L_LAUPH", 
            [NSValue valueWithCGRect:CGRectMake(257,513,53,54)], @"DOG_HEAD_EYE_L", 
            [NSValue valueWithCGRect:CGRectMake(321,513,109,97)], @"DOG_HEAD_EYE_R_LAUPH", 
            [NSValue valueWithCGRect:CGRectMake(1,641,63,57)], @"DOG_HEAD_EYE_R", 
            [NSValue valueWithCGRect:CGRectMake(1,705,69,117)], @"DOG_HEAD_HAIR", 
            [NSValue valueWithCGRect:CGRectMake(513,1,388,305)], @"DOG_HEAD_LAUPH", 
            [NSValue valueWithCGRect:CGRectMake(513,513,383,219)], @"DOG_HEAD_REAR", 
            [NSValue valueWithCGRect:CGRectMake(1025,1,388,261)], @"DOG_HEAD_TOP", 
            [NSValue valueWithCGRect:CGRectMake(513,769,388,254)], @"DOG_HEAD_VITE", 
            [NSValue valueWithCGRect:CGRectMake(129,641,110,175)], @"DOG_TAIL", 
            [NSValue valueWithCGRect:CGRectMake(1537,1,454,52)], @"FLASH", 
            [NSValue valueWithCGRect:CGRectMake(1025,513,139,257)], @"SPARK01", 
            [NSValue valueWithCGRect:CGRectMake(1281,513,400,400)], @"SPARK02", 
            nil
        ];

        uiAtlasRects = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSValue valueWithCGRect:CGRectMake(1,1,711,356)], @"CLOUD_NORMAL",
            [NSValue valueWithCGRect:CGRectMake(1025,1,702,395)], @"CLOUD_SPIKE",
            [NSValue valueWithCGRect:CGRectMake(1,513,624,237)], @"FAILED",
            [NSValue valueWithCGRect:CGRectMake(1,769,620,346)], @"FIGHT",
            [NSValue valueWithCGRect:CGRectMake(1025,513,104,98)], @"HOME_BUTTON",
            [NSValue valueWithCGRect:CGRectMake(1,1281,320,320)], @"IZA",
            [NSValue valueWithCGRect:CGRectMake(1153,513,327,100)], @"NEXT_BUTTON",
            [NSValue valueWithCGRect:CGRectMake(1025,641,88,88)], @"RANKING_BUTTON",
            [NSValue valueWithCGRect:CGRectMake(1153,641,102,108)], @"RETRY_BUTTON",
            [NSValue valueWithCGRect:CGRectMake(1025,769,768,79)], @"SCORE_BACK",
            [NSValue valueWithCGRect:CGRectMake(1,1793,318,34)], @"SCORE_FRAME",
            [NSValue valueWithCGRect:CGRectMake(1,1857,327,100)], @"START_BUTTON",
            [NSValue valueWithCGRect:CGRectMake(1537,641,88,88)], @"TWEET_BUTTON",
            [NSValue valueWithCGRect:CGRectMake(1025,1409,587,259)], @"WIN",
            [NSValue valueWithCGRect:CGRectMake(1025,897,628,485)], @"TITLE_LOGO",
            [NSValue valueWithCGRect:CGRectMake(1281,641,240,110)], @"TOUCH",
            nil
        ];

        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_BITE_DAMAGE];        
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_BITE_MISS];        
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_BUTTON_CANCEL];        
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_BUTTON_DECIDE];        
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_ROAR_BITE];        
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_ROAR_GRRR];        
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_SLOW_MOTION];  
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_SYNCHRO];
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_EYE_FLASH];
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_JINGLE_OK];
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_JINGLE_GOOD];
        [[SimpleAudioEngine sharedEngine] preloadEffect:SE_JINGLE_MISS];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:BGM];  
        [[SimpleAudioEngine sharedEngine]setBackgroundMusicVolume:0.5];      

        background = [CCSprite spriteWithFile:@"Game/background.png"];
        background.position = ccp(winSize.width/2, 0);
        background.scale = spriteScaleRate - fmod(spriteScaleRate, bgmVolume);
        background.anchorPoint = ccp(0.5f,0);
        // add the label as a child to this Layer
        [self addChild: background];

        layerUnitRoot = [CCLayer node];
        layerUnitRoot.anchorPoint = ccp(0.5f,0);
        [self addChild: layerUnitRoot];

        layerUnit = [CCSpriteBatchNode batchNodeWithFile:@"Dog/dogAtlas.png"];
        [layerUnitRoot addChild: layerUnit];

        [self createDogStand];

        layerEffect = [CCSpriteBatchNode batchNodeWithFile:@"Dog/dogAtlas.png"];
        [self addChild: layerEffect];

        cclInfoBatch = [CCSpriteBatchNode batchNodeWithFile:@"UI/uiAtlas.png"];
        [self addChild:cclInfoBatch];

        cclInfo = [CCLayer node];
        [self addChild:cclInfo];

        [self clearScoreLogs];

        cclSpark = [CCSpriteBatchNode batchNodeWithFile:@"Dog/dogAtlas.png"];
        [self addChild: cclSpark z:5];

        IAdLayer *adLayer = [IAdLayer nodeWithOrientation:kAdOrientationPortrait
                                                 position:kAdPositionTop];
        
        [self addChild:adLayer z:20];

        gameCount = 0;
        for(int i = 0; i < NUM_OF_GAMES; ++i) {
            scores[i] = 0;
        }

        [self schedule:@selector(inputUpdate:)];
        self.isTouchEnabled = YES;
	}
	return self;
}

-(CGRect) getAtlasRect: (NSDictionary*)dictionary sprite:(NSString*)key
{
    CGRect result = [[dictionary valueForKey:key] CGRectValue];
    result.origin.x = result.origin.x / 2;
    result.origin.y = result.origin.y / 2;
    result.size.width = result.size.width / 2;
    result.size.height = result.size.height / 2;
    return result;
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
    	{1, PartTypeMax, 0, 0, "DOG_BODY", ccp(0, 0), ccp(0.5f,0), 0 },
        {2, PartTypeMax, 1, 0, "DOG_HEAD_REAR", ccp(32, 120), ccp(0.5f,0.5f), -11.25 },
        {3, PartTypeFace, 2, 0, "DOG_HEAD_TOP", ccp(0, 110), ccp(0.5f,0.5f), 0 },
        {4, PartTypeMax, 3, -1, "DOG_HEAD_CHIN", ccp(0, -160), ccp(0.5f,0.5f), 0 },
        {5, PartTypeMax, 3, -1, "DOG_HEAD_HAIR", ccp(0, 100), ccp(0.9f,0), 0 },
        {6, PartTypeTail, 1, -1, "DOG_TAIL", ccp(-128, -32), ccp(1,0), -11.25 },
        {7, PartTypeEyeL, 3, 0, "DOG_HEAD_EYE_L", ccp(-74, -32), ccp(0.5f,0.5f), 0 },
        {8, PartTypeEyeR, 3, 0, "DOG_HEAD_EYE_R", ccp(68, -24), ccp(0.5f,0.5f), 0 },
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
    	{1, PartTypeMax, 0, 0, "DOG_BODY", ccp(0, 0), ccp(0.5f,0), 0 },
        {2, PartTypeMax, 1, 0, "DOG_HEAD_REAR", ccp(32, 120), ccp(0.5f,0.5f), -5.625 },
        {3, PartTypeFace, 2, 0, "DOG_HEAD_LAUPH", ccp(0, 80), ccp(0.5f,0.5f), 0 },
        {5, PartTypeMax, 3, -1, "DOG_HEAD_HAIR", ccp(0, 100), ccp(0.9f,0), 5.625f },
        {6, PartTypeMax, 1, -1, "DOG_TAIL", ccp(-128, -32), ccp(1,0), 5.625 },
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

    CCSprite* sprite = [CCSprite spriteWithFile:@"Dog/dogAtlas.png"];
    CCNode* parent = [self findUnitPartSpriteByType:PartTypeFace];
    CGPoint pos = parent.position;
    pos = ccpAdd(pos, ccpMult(ccp(40, -160),scaleFactor));
    pos = [parent.parent convertToWorldSpace:pos];

    [sprite setTextureRect: [self getAtlasRect:dogAtlasRects sprite:@"DOG_BREATH"]];
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

    [layerEffect addChild:sprite];
}

- (float) createDogBite
{
    const UnitPart parts[] = {
        {1, PartTypeMax, 0, 0, "DOG_BODY", ccp(0, 0), ccp(0.5f,0), 0 },
        {2, PartTypeHead, 1, 0, "DOG_HEAD_REAR", ccp(32, 160), ccp(0.5f,0.5f), -11.25 },
        {3, PartTypeMax, 2, 0, "DOG_HEAD_VITE", ccp(0, 110), ccp(0.5f,0.5f), 0 },
        {4, PartTypeChin, 3, -1, "DOG_HEAD_CHIN_VITE", ccp(0, -180), ccp(0.5f,0.5f), 0 },
        {5, PartTypeMax, 3, -1, "DOG_HEAD_HAIR", ccp(0, 80), ccp(0.9f,0), 22.5 },
        {6, PartTypeTail, 1, -1, "DOG_TAIL", ccp(-128, -32), ccp(1,0), -11.25 },
        {0}
    };

    float angle = 45.f * CCRANDOM_MINUS1_1();
    [self createUnitParts: parts];

    CCSprite* sprite = [self findUnitPartSpriteByType: PartTypeHead];
    [sprite runAction:
        [CCEaseIn actionWithAction:
            [CCRotateBy actionWithDuration:0.1f angle:angle]
            rate:3
        ]
    ];
    return angle;
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

    unitCtrls = [[NSMutableArray alloc] init];
    for(int i = 0; unitParts[i].identifier > 0; ++i) {
        const UnitPart* part = &unitParts[i];
        NSString *nsFile = @"Dog/dogAtlas.png";//[NSString stringWithFormat:@"%s", part->file];
    	CCSprite* sprite = [CCSprite spriteWithFile:nsFile];
        NSString* atlasNode = [NSString stringWithFormat:@"%s", part->file];
        [sprite setTextureRect:[self getAtlasRect:dogAtlasRects sprite:atlasNode]];
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
    CCSprite* sprite = [CCSprite spriteWithFile:@"Dog/dogAtlas.png"];
    float spriteScaleRate = [Utility spriteScaleRate];

    CGPoint pos = parent.position;
    pos = [parent.parent convertToWorldSpace:pos];

    pos = ccpSub(pos, layerUnitRoot.position);
    [sprite setPosition:pos];
    [sprite setScaleX:4.f * spriteScaleRate];
    [sprite setScaleY:1.5f * spriteScaleRate];
    [sprite setRotation:angle];
    [sprite setTextureRect: [self getAtlasRect:dogAtlasRects sprite:@"FLASH"]];
    [layerEffect addChild:sprite z:parent.zOrder+1];

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
    CGRect resRect;
    CGSize resSize;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float adHeight = [Utility adBannerHeight];
    float scaleBaseSprite = [Utility spriteScaleRate];

    CCSprite* title_logo = [CCSprite spriteWithFile:@"UI/uiAtlas.png"];

    resRect = [self getAtlasRect:uiAtlasRects sprite:@"TITLE_LOGO"];
    resSize = resRect.size;
    pos.x = winSize.width/2;
    pos.y = winSize.height -adHeight -[Utility s2r:resSize.height/2];

    title_logo.position = pos;
    title_logo.scale = scaleBaseSprite;
    [title_logo setTextureRect:resRect];

    // add the label as a child to this Layer
    [cclInfoBatch addChild: title_logo];

    
    ccsStartButton = [CCSprite spriteWithFile:@"UI/uiAtlas.png"];
    resRect = [self getAtlasRect:uiAtlasRects sprite:@"START_BUTTON"];
    resSize = resRect.size;
    pos.x = winSize.width/2;
    pos.y = [Utility s2w:64] + [Utility s2r:resSize.height/2];
    ccsStartButton.position = pos;
    ccsStartButton.scale = scaleBaseSprite;

    [ccsStartButton setTextureRect:resRect];
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
    [cclInfoBatch addChild: ccsStartButton];
    [self dispTweetRank];
}

-(void) dispTweetRank
{
    //
    // Leaderboards and Achievements
    //
    CGPoint pos;
    CGRect resRect;
    CGSize resSize;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float adHeight = [Utility adBannerHeight];
    float scaleBaseSprite = [Utility spriteScaleRate];

    ccsTweetButton = [CCSprite spriteWithFile:@"UI/uiAtlas.png"];
    resRect = [self getAtlasRect:uiAtlasRects sprite:@"TWEET_BUTTON"];
    resSize = resRect.size;
    pos.x = [Utility s2w:16] + [Utility s2r:resSize.width/2];
    pos.y = [Utility s2w:240];
    [ccsTweetButton setPosition:pos];
    [ccsTweetButton setScale:scaleBaseSprite];
    [ccsTweetButton setTextureRect:resRect];
    [cclInfoBatch addChild:ccsTweetButton z:1];
    
    ccsRankingButton = [CCSprite spriteWithFile:@"UI/uiAtlas.png"];
    resRect = [self getAtlasRect:uiAtlasRects sprite:@"RANKING_BUTTON"];
    resSize = resRect.size;
    pos.x = winSize.width - [Utility s2w:16] - [Utility s2r:resSize.width/2];
    pos.y = [Utility s2w:240];
    [ccsRankingButton setPosition:pos];
    [ccsRankingButton setScale:scaleBaseSprite];
    [ccsRankingButton setTextureRect:resRect];
    [cclInfoBatch addChild:ccsRankingButton z:1];    
}

- (void) gameStart
{
    ccsStartButton = 
    ccsTweetButton = 
    ccsRankingButton = NULL;
    [self unschedule:@selector(playResultFailed:)];
    [cclInfo removeAllChildrenWithCleanup:YES];
    [cclInfoBatch removeAllChildrenWithCleanup:YES];
    [cclInfoBatch setPosition:ccp(0,0)];
    ccsIza = nil;

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

    isDispSpark = false;

    if(ccsIza == NULL) {
    	ccsIza = [CCSprite spriteWithFile:@"UI/uiAtlas.png"];
        ccsIza.position = ccp(winSize.width/2, 320 * spriteScaleRate * scaleFactor);
        [ccsIza setTextureRect:[self getAtlasRect:uiAtlasRects sprite:@"IZA"]];
        [cclInfoBatch addChild:ccsIza];
    }
    ccsIza.scale = spriteScaleRate;
    [ccsIza setOpacity:255];
    [ccsIza stopAllActions];
    
	ccsTouch = [CCSprite spriteWithFile:@"UI/uiAtlas.png"];
    [ccsTouch setTextureRect: [self getAtlasRect:uiAtlasRects sprite:@"TOUCH" ]];
    ccsTouch.position = ccp(ccsIza.position.x, ccsIza.position.y
                        - (ccsIza.textureRect.size.height / 2 * spriteScaleRate)
                        - (ccsTouch.textureRect.size.height / 2 * spriteScaleRate));
    ccsTouch.scale = spriteScaleRate;

    [ccsTouch setTextureRect:[self getAtlasRect:uiAtlasRects sprite:@"TOUCH"]];
    [ccsTouch runAction: 
        [CCRepeatForever actionWithAction: 
         [CCSequence actions:
                [CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:0.25 position:ccp(0,-8)] rate:3],
                [CCEaseIn actionWithAction:[CCMoveBy actionWithDuration:0.25 position:ccp(0,8)] rate:3],
                nil
            ]
        ]
    ];
    [cclInfoBatch addChild:ccsTouch];
    isDispIzaTouch = TRUE;
}

- (void) hideIzaTouch 
{
    if(isDispIzaTouch) {
        float spriteScaleRate = [Utility spriteScaleRate];
//    	[cclInfoBatch removeChild:ccsIza cleanup:YES];
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

    	[cclInfoBatch removeChild:ccsTouch cleanup:YES];
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

		[self changeReadyState];

		isTouchBegan = false;
	}
}

- (void) changeReadyState
{
    resultType = None;

    ccsTweetButton =
    ccsRankingButton = nil;

    [self clearScoreLogs];
	[self dispIzaTouch];
	[self createDogStand];   

	[self unschedule:@selector(tutorialState:)];
	[self schedule:@selector(readyState:)];	
}

// これまでのスコアの表示をクリア
- (void) clearScoreLogs
{
    if(cclScores != NULL)
        [self removeChild:cclScores cleanup:YES];
    cclScores = [CCLayer node];
    [self addChild:cclScores z:15];    
    cclScoresBatch = [CCSpriteBatchNode batchNodeWithFile:@"UI/uiAtlas.png"];
    [cclScores addChild:cclScoresBatch];
}

// これまでのスコアの表示
const float dispScoreLogsDelay = 2;
-(void) dispScoreLogs: (float)height 
{
    [self clearScoreLogs];

    CGRect resRect;
    CGSize resSize;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float screenScaleRate = [Utility screenScaleRate];
    float spriteScaleRate = [Utility spriteScaleRate];
//    float adBannerHeight = [Utility adBannerHeight];

    for(int i = 0; i < gameCount; ++i) {
        CGPoint pos = CGPointMake(winSize.width/2, [Utility s2w:height]);
        pos.y += [Utility s2w:48] * (gameCount-i);

        CCSprite* ccsFrame = [CCSprite spriteWithFile:@"UI/uiAtlas.png"];
        resRect = [self getAtlasRect:uiAtlasRects sprite:@"SCORE_FRAME"];
        resSize = resRect.size;
        ccsFrame.position = pos;
        ccsFrame.scale = spriteScaleRate;
        ccsFrame.opacity = 0;
        [ccsFrame setTextureRect: resRect];
        [ccsFrame runAction:
            [CCFadeIn actionWithDuration:dispScoreLogsDelay/NUM_OF_GAMES*i]
        ];
        [cclScoresBatch addChild:ccsFrame];        

        NSString* rounds[] = { @"1st", @"2nd", @"3rd", @"4th", @"5th" };
        CCLabelTTF* cclRound = [CCLabelTTF labelWithString:rounds[i] fontName:@"Arial Rounded MT Bold" fontSize:24];
        cclRound.position = CGPointMake(pos.x - [Utility s2r:resSize.width/2] + [Utility s2w:24], pos.y);
        cclRound.scale = screenScaleRate;
        cclRound.opacity = 0;
        [cclRound setAnchorPoint: ccp(0,0.5f)];
        [cclRound runAction:
            [CCFadeIn actionWithDuration:dispScoreLogsDelay/NUM_OF_GAMES*i]
        ];
        [cclScores addChild:cclRound];

        NSString *nssScore = [NSString stringWithFormat:@"%f sec", scores[i]];
        CCLabelTTF* cclScore = [CCLabelTTF labelWithString:nssScore fontName:@"Arial Rounded MT Bold" fontSize:24];
        cclScore.position = CGPointMake(pos.x + [Utility s2r:resSize.width/2] - [Utility s2w:24], pos.y);
        cclScore.scale = screenScaleRate;
        cclScore.opacity = 0;
        [cclScore setAnchorPoint: ccp(1,0.5f)];
        [cclScore runAction:
            [CCFadeIn actionWithDuration:dispScoreLogsDelay/NUM_OF_GAMES*i]
        ];
        [cclScores addChild:cclScore];
    }
}

const CGPoint readyTouchPoint = { 0, -80 };
const float readyTouchRadius = 120;
const float waitForBiteMin = 1;
const float waitForBiteMax = 3;
-(void) readyState: (ccTime)dt {

	if(isTouchBegan && !isDispIzaTouch) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        float spriteScaleRate = [Utility spriteScaleRate];

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
		if(isTouchEnd) {
			[self dispIzaTouch];
        }
        else if(isTouchMoved) {   
            if(ccsTouchMoved == ccsIza)
                [self hideIzaTouch];
            else [self dispIzaTouch];
        }
		else if(isTouchBegan) {
            if(ccsTouchBegan == ccsIza)
			     [self hideIzaTouch];
        }
	}
	else if(stateTimeCount < waitForBiteTime + waitForFlash) {
		if((isTouchMoved && ccsTouchMoved != ccsIza)|| isDispIzaTouch) {
           resultType = TooFar;
			[self hideIzaTouch];
			[self removeChild: ccsFight cleanup:YES];
			[self unschedule:@selector(gameState:)];
            [self dispResultCaption:resultType resultTime:[self calcAvoidTime]];
            [self scheduleOnce:@selector(changeResultState)delay:1];
            [self createDogLauph];
		}
		else if(isTouchEnd) {
            resultType = TooFast;
			[self removeChild: ccsFight cleanup:YES];
			[self unschedule:@selector(gameState:)];
            [self dispResultCaption:resultType resultTime:[self calcAvoidTime]];
            [self scheduleOnce:@selector(changeResultState)delay:1];
            [self createDogLauph];
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
        biteAngle = [self createDogBite];

        biteHeadHeightBegin = [self findUnitPartSpriteByType:PartTypeHead].position.y;
        biteChinHeightBegin = [self findUnitPartSpriteByType:PartTypeChin].position.y;

        // 時間計測を開始する
        startTime = [ [NSDate date] retain];

        // 吠え声
        [[SimpleAudioEngine sharedEngine] playEffect:SE_ROAR_BITE];        

	    biteTimeCount = 0;
        timeScale = 1;
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
const float biteSparkSec = 0.45f;
const float biteWaitTimeSec = 1.5f;
const float biteZoomTimeRate = 0.1f;
const float bitePlayTimeSec = 0.49f;
const float biteReactionRate = -0.01f;

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
	float biteTimeBefore = biteTimeCount;
	if(resultType == Success) {
		float score = max(0, biteTimeSec+elapsedTime);
		float slowMotionRange = biteTimeSec * slowMotionBegin;
        if(biteTimeCount < biteTimeSec && score < slowMotionRange) {
        	timeScale = score / slowMotionRange;
        	timeScale = slowMotionMin + (slowMotionMax - slowMotionMin) * timeScale;
			dt = dt * timeScale;
		}
	}

	biteTimeCount += dt;

	float rate = 0;
    if(biteTimeCount < bitePlayTimeSec) {
        rate = (biteTimeCount / bitePlayTimeSec);
    }
    else {
        rate = (biteTimeCount - bitePlayTimeSec) / (biteWaitTimeSec - bitePlayTimeSec);
        rate = 1 + (biteReactionRate * sinf(M_PI_2 * rate));
    }
    rate = 1 - sin(M_PI_2 + M_PI_2 * rate);
    rate = pow(rate, 4);
	rate = min(max(rate, 0), 1);

	float zoomRate = min(1, rate / biteZoomTimeRate);
    float scaleFactor = [AppController getScaleFactor];
    float spriteScaleRate = [Utility spriteScaleRate];
    float screenScaleRate = [Utility screenScaleRate];

	[layerUnitRoot setScale: 1 + ((biteDogScale) - 1) * zoomRate];
    [layerUnitRoot setPosition: ccp(0, (biteDogHeight) * zoomRate)];

    CCSprite* sprite = [self findUnitPartSpriteByType:PartTypeHead];
	sprite.position = ccp(sprite.position.x, biteHeadHeightBegin - (biteHeadOpenHeight * rate)*scaleFactor);
	
    sprite = [self findUnitPartSpriteByType:PartTypeChin];
    sprite.position = ccp(sprite.position.x, biteChinHeightBegin - (biteAgoOpenHeight * rate)*scaleFactor);

	switch(resultType) {
	case None:
		if(biteTimeCount < biteTimeSec) {
			if(isTouchEnd) {
                CGSize winSize = [[CCDirector sharedDirector] winSize];
                CGPoint pos = CGPointMake(winSize.width/2, [Utility s2w:240] );
                
                ccsScoreBack = [CCSprite spriteWithFile:@"UI/uiAtlas.png"];
                ccsScoreBack.position = pos;
                [ccsScoreBack setScale:spriteScaleRate];
                [ccsScoreBack setOpacity:196];
                [ccsScoreBack setTextureRect: [self getAtlasRect:uiAtlasRects sprite:@"SCORE_BACK"]];
                [cclInfoBatch addChild:ccsScoreBack];

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
	    if(biteTimeCount > bitePlayTimeSec) {
	    	if(isDispSpark == false) {
                isDispSpark = true;

                [self dispBiteEffect];

                ccGridSize size = { 32, 32 };
                CGSize winSize = [[CCDirector sharedDirector] winSize];
                [self runAction:[CCRipple3D actionWithPosition:ccp(winSize.width/2, winSize.height/2)
                                radius:130 waves:4 amplitude:1 grid:size duration:5]];
                // ガキーン！
                [[SimpleAudioEngine sharedEngine] playEffect:SE_BITE_MISS];
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
        [self dispResultCaption:resultType resultTime:[self calcAvoidTime]];
        [self scheduleOnce:@selector(changeResultState)delay:1];
	}
}

// 
-(void) dispResultCaption: (id) resultType resultTime:(float)sec {
    float spriteScaleRate = [Utility spriteScaleRate];

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // 成功
    if(resultType == Success) {

        ccsResultCaption = [CCSprite spriteWithFile:@"UI/uiAtlas.png"];
        ccsResultCaption.position = ccp(winSize.width/2, [Utility s2w:520]);
        ccsResultCaption.scale = spriteScaleRate * 4;
        [ccsResultCaption setTextureRect: [self getAtlasRect:uiAtlasRects sprite:@"WIN"]];
        [ccsResultCaption runAction:
            [CCSequence actions:
                [CCEaseIn actionWithAction:
                    [CCScaleTo actionWithDuration:0.1f scale:spriteScaleRate] 
                    rate:2
                ],
                [CCDelayTime actionWithDuration:1],
                [CCSpawn actions:
                    [CCScaleTo actionWithDuration:0.2f scaleX:spriteScaleRate * 2 scaleY: 0],
                    [CCFadeOut actionWithDuration: 0.2f],
                    nil
                ],
                nil
            ]
        ];
        [cclInfoBatch addChild:ccsResultCaption];        

        // OK
        if(sec > 0.02)
            [[SimpleAudioEngine sharedEngine] playEffect:SE_JINGLE_OK];        
        else [[SimpleAudioEngine sharedEngine] playEffect:SE_JINGLE_GOOD];        
    }
    // ミス
    else {
        [[SimpleAudioEngine sharedEngine] playEffect:SE_JINGLE_MISS];        

        ccsResultCaption = [CCSprite spriteWithFile:@"UI/uiAtlas.png"];
        ccsResultCaption.position = ccp(winSize.width/2, [Utility s2w:520]);
        ccsResultCaption.scale = spriteScaleRate;
        ccsResultCaption.opacity = 0;
        [ccsResultCaption runAction:
            [CCSequence actions:
                [CCFadeIn actionWithDuration:0.5f],
                [CCDelayTime actionWithDuration:2],
                [CCFadeOut actionWithDuration:0.5f],
             nil
            ]
        ];
        [ccsResultCaption setTextureRect: [self getAtlasRect:uiAtlasRects sprite:@"FAILED"]];
        [cclInfoBatch addChild:ccsResultCaption];        

        resultCaptionSec = 0;
        [self schedule:@selector(playResultFailed:)];
    }
}

-(void) playResultFailed: (float)dt {
    if(resultCaptionSec < 3) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        float rate = sin(M_PI * resultCaptionSec);
        CGPoint pos = ccsResultCaption.position;
        pos.x = winSize.width/2 + [Utility s2w:32] * rate;
        ccsResultCaption.position = pos;
        resultCaptionSec += dt;
    }
    else {
        [self unschedule:@selector(playResultFailed:)];
    }
}

-(void) dispBiteEffect {
    float spriteScaleRate = [Utility spriteScaleRate];
    
    CCSprite* parent = [self findUnitPartSpriteByType:PartTypeChin];
    CGPoint pos = parent.position;
    pos = [parent.parent convertToWorldSpace:pos];
    
    float radian = biteAngle / 180 * M_PI;
    float offset = -48;
    pos = ccpAdd(pos, ccp(offset*sin(radian), offset*cos(radian)));

    cclSpark.position = pos;
    cclSpark.anchorPoint = ccp(0,0);
    cclSpark.rotation = biteAngle;
    cclSpark.scale = spriteScaleRate;

    biteEffSec = 0;
    biteEffRealSec = 0;

    for(int i = 0; i < 2; ++i) {
        CCSprite* sprite = [CCSprite spriteWithFile:@"Dog/dogAtlas.png"];
        sprite.position = ccp([Utility s2r:i == 0 ? 32:-32], 0);
        [sprite setAnchorPoint:ccp(0,0.5)];
        [sprite setRotation: 180 * i];
        [sprite setTextureRect: [self getAtlasRect:dogAtlasRects sprite:@"SPARK01"]];
        [cclSpark addChild: sprite];
        biteEff[i] = sprite;
    }

    CCSprite* sprite = [CCSprite spriteWithFile:@"Dog/dogAtlas.png"];
    [sprite setTextureRect: [self getAtlasRect:dogAtlasRects sprite:@"SPARK02"]];
    [cclSpark addChild: sprite];
    effBiteSplash = sprite;

    [self schedule:@selector(playBiteEffect:)];
}

-(void) playBiteEffect:(float)dt {
    float spriteScaleRate = [Utility spriteScaleRate];
    
    [SimpleAudioEngine sharedEngine].backgroundMusicVolume = bgmVolume * timeScale;
    biteEffSec += dt * timeScale;
    if(biteEffSec < 1.f) {
        float rate = (biteEffSec / 1.f);
        float rateEaseOut = 1 - sin(M_PI * (0.5f + 0.5f * rate));
        effBiteSplash.scale = spriteScaleRate * (1+rateEaseOut);
        effBiteSplash.opacity = min((int)(255 * (1-rate)), 255);

        rate = min(1, biteEffSec / 0.25f);
        rateEaseOut = 1 - sin(M_PI * (0.5f + 0.5f * rate));
        for(int i = 0; i < 2; ++i) {

            biteEff[i].scaleX = spriteScaleRate * (1 + (4 - 1) * rateEaseOut);
            biteEff[i].scaleY = spriteScaleRate * (1 + (0 - 1) * rate);
            biteEff[i].opacity = min((int)(255 * ((1-rate) * 2)), 255);
        }
    }
    else {
        [cclSpark removeAllChildrenWithCleanup:YES];
        [self unschedule:@selector(updateBiteEffect:)];
    }

    biteEffRealSec += dt;
    if(biteEffRealSec > 1) {
        timeScale = 1;
    }
}

-(void) changeResultState {
    CGRect resRect;
    CGSize resSize;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float screenScaleRate = [Utility screenScaleRate];
	float spriteScaleRate = [Utility spriteScaleRate];

    float sec = [self calcAvoidTime];

    timeScale = 1;
    scores[gameCount] = -1;

    NSArray* resultMessage = NULL;
    NSString* resultSubMessage = NULL;
    
	switch(resultType) {
    case Success:
        [self dispScoreLogs:280];
        scores[gameCount] = sec;
        
        // OK
        if(sec > 0.02)
            resultMessage = resultMessages[0];
        else resultMessage = resultMessages[1];

        [self dispNextButton];
        gameCount++;
        break;

	case TooFar:
        resultMessage = resultMessages[2];
        resultSubMessage = @"円から離れてはいけない！";
	    break;

	case TooFast:
        resultMessage = resultMessages[2];
        resultSubMessage = @"ギリギリまで引きつけよう！";
		break;

	case TooRate:
        resultMessage = resultMessages[2];
        resultSubMessage = @"噛まれる直前で離そう！";
	    break;
    default:
        break;
	}

    int resMsgSize = [resultMessage count];
    int index = (int)(CCRANDOM_0_1()* resMsgSize)% resMsgSize;
    ResultData* resData = resultMessage[index];

    float cloudHeight = 600;
    CCSprite* ccsCloud = [CCSprite spriteWithFile:@"UI/uiAtlas.png"];
    resRect = [self getAtlasRect:uiAtlasRects sprite:resData->cloud];
    resSize = resRect.size;
    ccsCloud.position = ccp(winSize.width/2, [Utility s2w:cloudHeight]);
    ccsCloud.anchorPoint = ccp(0.5,0);
    ccsCloud.opacity = 0;
    ccsCloud.scale = spriteScaleRate * 1.5f;
    [ccsCloud setTextureRect: resRect];
    [ccsCloud runAction: 
        [CCSpawn actions:
            [CCFadeIn actionWithDuration:0.25],
            [CCEaseOut actionWithAction:
                [CCScaleTo actionWithDuration:0.25 scale:spriteScaleRate]
                rate: 4
            ],
            nil
        ]        
    ];
    [cclInfoBatch addChild:ccsCloud];

    NSString* resultText = resData->jpMsg;
    CCLabelTTF* cclMsg = [CCLabelTTF labelWithString:resultText fontName:@"HiraKakuProN-W6" fontSize:40];
    cclMsg.position = CGPointMake(winSize.width/2, [Utility s2w:cloudHeight+200]);
    cclMsg.scale = 2 * screenScaleRate;
    cclMsg.color = ccc3(0,0,0);
    [cclMsg runAction:
        [CCEaseOut actionWithAction:
            [CCScaleTo actionWithDuration:0.25 scale:screenScaleRate]
            rate: 4
        ]
    ];    
    [cclInfo addChild:cclMsg];

    if(resultSubMessage != NULL) {
        CCLabelTTF* cclSubMsg = [CCLabelTTF labelWithString:resultSubMessage fontName:@"HiraKakuProN-W6" fontSize:24];
        cclSubMsg.position = CGPointMake(winSize.width-[Utility s2w:64],[Utility s2w:cloudHeight+130]);
        cclSubMsg.scale = screenScaleRate;
        cclSubMsg.anchorPoint = ccp(1,0.5f);
        cclSubMsg.color = ccc3(0,0,0);
        [cclInfo addChild:cclSubMsg];
    }

    [self hideIzaTouch];
    [self dispRetryHome];
}

-(void) dispRetryHome {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float spriteScaleRate = [Utility spriteScaleRate];

    ccsHome = [CCSprite spriteWithFile:@"UI/uiAtlas.png"];
    ccsHome.position = ccp(winSize.width - winSize.width/8, winSize.width/8);
    ccsHome.scale = spriteScaleRate;
    [ccsHome setTextureRect: [self getAtlasRect:uiAtlasRects sprite:@"HOME_BUTTON"]];
    [cclInfoBatch addChild:ccsHome]; 

    ccsRetry = [CCSprite spriteWithFile:@"UI/uiAtlas.png"];
    ccsRetry.position = ccp(winSize.width/8, winSize.width/8);
    ccsRetry.scale = spriteScaleRate;
    [ccsRetry setTextureRect: [self getAtlasRect:uiAtlasRects sprite:@"RETRY_BUTTON"]];
    [cclInfoBatch addChild:ccsRetry];
}

-(void) changeTotalResultState {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float screenScaleRate = [Utility screenScaleRate];

    [self dispScoreLogs:560];
    [self dispRetryHome];
    [self dispTweetRank];

    // 記録更新
    [[SimpleAudioEngine sharedEngine] playEffect:SE_NEW_RECORDS];

    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:@"com.harvest.cr.dog.easy.high.score"];

    float score = 0;
    for(int i = 0; i < NUM_OF_GAMES; ++i)
        if(scores[i] >= 0)
            score += scores[i];
    scoreReporter.value = score * 1000000;
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {}]; 

    CGPoint pos = CGPointMake(winSize.width/2, [Utility s2w:480] );

    ccsScoreBack = [CCSprite spriteWithFile:@"UI/uiAtlas.png"];
    ccsScoreBack.position = pos;
    [ccsScoreBack setScale:[Utility s2r:2]];
    [ccsScoreBack setOpacity:196];
    [ccsScoreBack setTextureRect: [self getAtlasRect:uiAtlasRects sprite:@"SCORE_BACK"]];
    [cclInfoBatch addChild:ccsScoreBack];
    
    CCLabelTTF* cclTotal = [CCLabelTTF labelWithString:@"トータルスコア" fontName:@"HiraKakuProN-W6" fontSize:48];
    cclTotal.position = ccpAdd(pos, ccp(0,[Utility s2w:32]));
    cclTotal.scale = screenScaleRate;
    [cclInfo addChild:cclTotal];    

    cclLastScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%f sec", score] fontName:@"Arial Rounded MT Bold" fontSize:64];
    cclLastScore.position = ccpAdd(pos, ccp(0,[Utility s2w:-32]));
    cclLastScore.scale = screenScaleRate;
    [cclInfo addChild:cclLastScore];
    gameCount = 0;   
}

// 次へボタンを表示する
-(void) dispNextButton
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];        
    CGRect resRect = [self getAtlasRect:uiAtlasRects sprite:@"NEXT_BUTTON"];
    CGSize resSize = resRect.size;
    ccsNext = [CCSprite spriteWithFile:@"UI/uiAtlas.png"];
    ccsNext.position = ccp(winSize.width/2, [Utility s2w:64] + [Utility s2r:resSize.height/2]);
    ccsNext.scale = [Utility s2r:1];

    [ccsNext setTextureRect: resRect];
    [ccsNext runAction: 
        [CCRepeatForever actionWithAction: 
            [CCSequence actions: 
                [CCEaseInOut actionWithAction: 
                    [CCScaleTo actionWithDuration:0.5f scale:[Utility s2r:0.9f]] 
                    rate:3 
                ], 
                [CCEaseInOut actionWithAction: 
                    [CCScaleTo actionWithDuration:0.5f scale:[Utility s2r:1]] 
                    rate:3 
                ], 
                nil
            ] 
        ]
    ];        
    [cclInfoBatch addChild:ccsNext]; 
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
    [self unschedule:@selector(playResultFailed:)];
	[cclInfoBatch removeAllChildrenWithCleanup:YES];
    [cclInfo removeAllChildrenWithCleanup:YES];
    ccsIza = nil;
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

        [cclInfoBatch runAction:
            [CCSequence actions: 
                [CCDelayTime actionWithDuration:0.1], 
                [CCEaseIn actionWithAction: [CCMoveBy actionWithDuration:0.5 position:ccp(0, winSize.height*2) ] rate:2 ],
                nil
            ]
        ];

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
        if(gameCount < NUM_OF_GAMES) {
            [background setScale:spriteScaleRate];
            [layerUnitRoot setScale:1];
            [layerUnitRoot setPosition: CGPointZero];            
            [self changeReadyState];  
        }    
        else [self changeTotalResultState];
    }
    if([self touchEndButton:ccsRetry touchLocation:location]) {

        // キャンセル音
        [[SimpleAudioEngine sharedEngine] playEffect:SE_BUTTON_CANCEL];

    	[self hideResult];
        [background setScale:spriteScaleRate];
        [layerUnitRoot setScale:1];
        [layerUnitRoot setPosition: CGPointZero];
		[self changeReadyState];    	
        [self clearScoreLogs];
        gameCount = 0;
    }
    if([self touchEndButton:ccsHome touchLocation:location]) {

        // キャンセル音
        [[SimpleAudioEngine sharedEngine] playEffect:SE_BUTTON_CANCEL];

    	[self hideResult];
		[self createDogStand];
        [background setScale:spriteScaleRate];
        [layerUnitRoot setScale:1];
        [layerUnitRoot setPosition: CGPointZero];
        [self dispTitle];
        [self clearScoreLogs];
        gameCount = 0;
    }

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
