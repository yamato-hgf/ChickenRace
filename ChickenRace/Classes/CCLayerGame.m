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

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		instance = self;

		resultType = None;

        // ask director for the window size
        CGSize winSize = [[CCDirector sharedDirector] winSize];
 		float scaleBase = [AppController getScaleBase];

        CCSprite *background;
        
        background = [CCSprite spriteWithFile:@"background.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        background.scale = scaleBase;
        background.color = ccc3(127,127,127);
        // add the label as a child to this Layer
        [self addChild: background];

        layerUnit = [CCLayer node];
        [layerUnit setAnchorPoint:ccp(0.5,0)];
        [self addChild: layerUnit];

        [self createDogStand];

        layerTitle = [CCLayerTitle layerTitle];
        [self addChild:layerTitle z:0];

        cclInfo = [CCLayer node];
        [self addChild:cclInfo z:1];

        [self schedule:@selector(inputUpdate:)];
	}
	return self;
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
    [sprite setScale: [AppController getScaleBase]];
    [sprite setVisible: false];
    
    [sprite runAction:
        [CCSequence actions:
            [CCDelayTime actionWithDuration:0.5f],
            [CCShow action],
            [CCSpawn actions:
                [CCEaseOut actionWithAction:
                    [CCMoveBy actionWithDuration:1 position:ccp(45,-45)]
                    rate:2
                ],
                [CCFadeOut actionWithDuration:1],
                nil
            ],
            nil
        ]
     ];

    [self addChild:sprite];
}

- (void) createDogVite
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
//	[layerUnit removeAllChildrenWithCleanup:YES];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
	float scaleBase = [AppController getScaleBase];
    float scaleFactor = [AppController getScaleFactor];

    PartCtrl* ctrl;
	if(unitCtrls != nil) {
        ctrl = unitCtrls[0];
        [ctrl.sprite.parent removeChild: ctrl.sprite cleanup: YES];
		[unitCtrls release];
    }
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
                    CGSize size = [ctrl.sprite contentSize];
                    position.x += size.width / 2;
                    position.y += size.height / 2;
		        	sprite.rotation = part->rotation;
		        	[sprite setAnchorPoint: part->anchor];
        			[ctrl.sprite addChild: sprite z:part->order];
                }
            }
    	}
        else {
            CGSize size = [sprite contentSize];
        	position.x += winSize.width / 2;
        	sprite.scale = scaleBase;
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
    CCSprite* sprite = [CCSprite spriteWithFile:@"flash.png"];
    float scaleBase = [AppController getScaleBase];

    CGPoint pos = parent.position;
    pos = [parent.parent convertToWorldSpace:pos];

    pos = ccpSub(pos, layerUnit.position);
    [sprite setPosition:pos];
    [sprite setScaleX:4.f * scaleBase];
    [sprite setScaleY:1.5f * scaleBase];
    [sprite setRotation:angle];
    [layerUnit addChild:sprite z:parent.zOrder+1];

    [sprite runAction:
        [CCSpawn actions:
         [CCEaseIn actionWithAction:[CCScaleTo actionWithDuration:0.1f scaleX:scaleBase scaleY:scaleBase] rate:4 ],
            [CCEaseOut actionWithAction:[CCFadeOut actionWithDuration:1] rate:4 ],
            nil
        ]
    ];    
}

- (void) gameStart
{
    // ask director for the window size
    CGSize size = [[CCDirector sharedDirector] winSize];
 	float scaleBase = [AppController getScaleBase];

 	[self createDogStand];
   
	ccsTutorial = [CCSprite spriteWithFile:@"tutorial.png"];
    ccsTutorial.position = ccp(size.width/2, ccsTutorial.contentSize.height * 0.5f * scaleBase);
    ccsTutorial.scale = scaleBase;
    [self addChild:ccsTutorial z:2];

	cclFade = [CCLayerColor layerWithColor:ccc4(0,0,0,128)];
	[self addChild:cclFade z:1];

    [self schedule:@selector(tutorialState:)];	

    self.isTouchEnabled = YES;
}

- (void) dispIzaTouch 
{
	if(isDispIzaTouch)
		return;

    CGSize size = [[CCDirector sharedDirector] winSize];
	float scaleBase = [AppController getScaleBase];

	ccsIza = [CCSprite spriteWithFile:@"iza.png"];
    ccsIza.position = ccp(size.width/2, size.height/2);
    ccsIza.scale = scaleBase;
    [self addChild:ccsIza];

	ccsTouch = [CCSprite spriteWithFile:@"touch.png"];
    ccsTouch.position = ccp(size.width/2, size.height/2);
    ccsTouch.scale = scaleBase;

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
		[self createDogStand];   
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
		float scaleBase = [AppController getScaleBase];
 	    CGPoint vec = ccp(touchPoint.x - size.width/2
	    				, size.height/2 - touchPoint.y );
	   	if(ccpDistance(vec, readyTouchPoint) < readyTouchRadius) {
	   		[self hideIzaTouch];

			ccsFight = [CCSprite spriteWithFile:@"fight.png"];
            ccsFight.position = ccp(size.width/2, size.height/2);
		    ccsFight.scale = scaleBase * 4.0f;
		    id actSclIn = [CCEaseIn actionWithAction:[CCScaleTo actionWithDuration:0.5f scale:scaleBase] rate:2];
		    id actSclOut = [CCSpawn actions:[CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:0.25f scale:scaleBase * 2.f] rate:3],
		    								[CCFadeOut actionWithDuration:0.1f], nil ];
		    id actions = [CCSequence actions: actSclIn, [CCDelayTime actionWithDuration:1], actSclOut, nil ];
		    [ccsFight runAction: actions];
		    [self addChild:ccsFight];
            
            waitForBiteTime = CCRANDOM_0_1() * waitForBiteMax - waitForBiteMin;
            waitForBiteTime = waitForBiteMin + waitForBiteTime;

            isTouchBegan = false;
            isTouchMoved = false;
            isTouchEnd = false;

		   	stateTimeCount = 0;

		    [self unschedule:@selector(readyState:)];
		    [self schedule:@selector(gameState:) interval:1/60.f];
	   	}
	   	isTouchBegan = false;
	}
}

const float waitForJudge = 2;
const float warningTouchRadius = 80;
-(void) gameState: (ccTime)dt {
	stateTimeCount += dt;
    
	if(stateTimeCount < waitForJudge) {
		if(isTouchEnd)
			[self dispIzaTouch];
		if(isTouchBegan)
			[self hideIzaTouch];
		if(isTouchMoved) {
		    CGSize size = [[CCDirector sharedDirector] winSize];
		    CGPoint vec = ccp(touchPoint.x - size.width/2
		    				, size.height/2 - touchPoint.y );
		    float distance = ccpDistance(vec, readyTouchPoint);
		   	if(distance > readyTouchRadius)
				[self dispIzaTouch];
			else [self hideIzaTouch];
		}
	}
	else {
		if(isTouchMoved) {
		    CGSize size = [[CCDirector sharedDirector] winSize];
		    CGPoint vec = ccp(touchPoint.x - size.width/2
		    				, size.height/2 - touchPoint.y );
		    float distance = ccpDistance(vec, readyTouchPoint);
		   	if(distance > readyTouchRadius) {
                resultType = TooFar;
				[self hideIzaTouch];
				[self removeChild: ccsFight cleanup:YES];
				[self unschedule:@selector(gameState:)];
		   		[self changeResultState:0];
			}
		}
		else if(isTouchEnd || isDispIzaTouch) {
            resultType = TooFast;
			[self removeChild: ccsFight cleanup:YES];
			[self unschedule:@selector(gameState:)];
	   		[self changeResultState:0];
		}
	}

	isTouchBegan = false;
	isTouchMoved = false;
	isTouchEnd = false;
    
    if(stateTimeCount > waitForBiteTime + waitForJudge) {
	    float scaleBase = [AppController getScaleBase];

        CCSprite* parent = [self findUnitPartSpriteByType:PartTypeEyeL];
        [self createEyeFlash:parent rotation:0];
        [self createEyeFlash:parent rotation:90];

        parent = [self findUnitPartSpriteByType:PartTypeEyeR];
        [self createEyeFlash:parent rotation:0];
        [self createEyeFlash:parent rotation:90];

        [self createDogVite];

        biteHeadHeightBegin = [self findUnitPartSpriteByType:PartTypeHead].position.y;
        biteChinHeightBegin = [self findUnitPartSpriteByType:PartTypeChin].position.y;

        // 時間計測を開始する
        startTime = [ [NSDate date] retain];

	    biteTimeCount = 0;
		[self removeChild: ccsFight cleanup:YES];
	    [self unschedule:@selector(gameState:)];
	    [self schedule:@selector(biteState:)];		        
    }    
}

const CGPoint dogFacePoint = {-16, 96};
const float biteDogScale = 2.0f;
const float biteHeadOpenHeight = 64;
const float biteAgoOpenHeight = -128;
const float biteTimeSec = 0.5f;
const float biteWaitTimeSec = 2.0f;
const float biteZoomTimeRate = 0.1f;
const float bitePlayTimeSec = 0.02f;
const float slowMotionBegin = 0.5f;
const float slowMotionMax = 0.5f;
const float slowMotionMin = 0.01f;

-(void) cfnRemove:(id)sender {
    [self removeChild:sender cleanup:YES];
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

//	[self createDogVite];

	float zoomRate = min(1, rate / biteZoomTimeRate);
	float scaleBase = 1;
    float scaleFactor = [AppController getScaleFactor];
	float zoom = biteDogScale * 1;
	[layerUnit setScale: scaleBase + (zoom - scaleBase) * zoomRate];

    CCSprite* sprite = [self findUnitPartSpriteByType:PartTypeHead];
	sprite.position = ccp(sprite.position.x, biteHeadHeightBegin - (biteHeadOpenHeight/ scaleBase * rate)*scaleFactor);
	
    sprite = [self findUnitPartSpriteByType:PartTypeChin];
    sprite.position = ccp(sprite.position.x, biteChinHeightBegin - (biteAgoOpenHeight/ scaleBase * rate)*scaleFactor);

	switch(resultType) {
	case None:
		if(biteTimeCount < biteTimeSec) {
			if(isTouchEnd) {
                CGSize size = [[CCDirector sharedDirector] winSize];
                
                cclScore = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
                cclScore.position = CGPointMake(size.width- size.width/2, size.height/2);
                cclScore.color = ccc3(0,0,0);
                [cclInfo addChild:cclScore];

		        elapsedTime = [startTime timeIntervalSinceNow];
		        cclScore.string = [NSString stringWithFormat:@"%07d micro sec", (biteTimeCount+elapsedTime)*1000000];
				resultType = Success;
			}
		}
		else if( biteTimeBefore < biteTimeSec) {	
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			cclFade = [CCLayerColor layerWithColor:ccc4(255,0,0,0)];
			[cclFade runAction:[CCFadeOut actionWithDuration:0.2f]];
			[cclInfo addChild:cclFade z:1];

			resultType = TooRate;
		}
		break;

	case Success:
		if(biteTimeCount < biteTimeSec) {
			float sec = min(biteTimeCount, biteTimeSec);
			int64_t score = (sec+elapsedTime) *1000000;
	        cclScore.string = [NSString stringWithFormat:@"%07d micro sec", score];
	    }
	    if(bitePlayTimeSec + biteTimeCount > biteTimeSec) {
	    	if(cclSpark == NULL) {
		        CGSize size = [[CCDirector sharedDirector] winSize];	        
		        cclSpark = [CCLayer node];
		        [cclSpark runAction: 
		        	[CCSequence actions:
		        		[CCDelayTime actionWithDuration: 1 / dtRate],
		        		[CCCallFuncN actionWithTarget:self selector:@selector(cfnRemove:)],
		        		nil
		        	]
		        ];
		        [self addChild: cclSpark];

		        CCSprite* sprite = [CCSprite spriteWithFile:@"spark.png"];
		        sprite.position = ccp(size.width/2, size.height/2-64);
		        [sprite setAnchorPoint:ccp(0.5,0.5)];
				[sprite setScale: scaleBase];
		        [sprite runAction: 
		        	[CCSpawn actions:
						[CCEaseOut actionWithAction:
							[CCScaleBy actionWithDuration: 0.5/dtRate scale:6* scaleBase] rate:2
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

		        sprite = [CCSprite spriteWithFile:@"spark.png"];
		        sprite.position = ccp(size.width/2, size.height/2-64);
		        [sprite setAnchorPoint:ccp(0.5,0.5)];
				[sprite setScale: 0.75f * scaleBase];
				[sprite setRotation: 45];
		        [sprite runAction: 
		        	[CCSpawn actions:
		        		[CCFadeIn actionWithDuration:0.1/dtRate],
						[CCEaseOut actionWithAction: 
							[CCScaleBy actionWithDuration: 0.5/dtRate scale:4* scaleBase] rate:2
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
		}        
		break;
	}

	if(biteTimeCount >= biteWaitTimeSec) {
        [startTime release];
        startTime = NULL;        
        
		[cclInfo removeChild:cclFade cleanup:YES];
		[self unschedule:@selector(biteState:)];
		[self scheduleOnce:@selector(changeResultState:) delay:0.6];
	}
}

-(void) changeResultState:(ccTime)dt {
    CGSize size = [[CCDirector sharedDirector] winSize];
	float scaleBase = [AppController getScaleBase];

	cclFade = [CCLayerColor layerWithColor:ccc4(255,255,255,0)];
	[cclFade runAction:
		[CCFadeTo actionWithDuration: 0.1 opacity: 127]
	];
	[cclInfo addChild:cclFade z:0];

    cclResult = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:16];
    cclResult.position = CGPointMake(size.width/2, size.height/2- 80);
    cclResult.color = ccc3(0,0,0);
    [cclInfo addChild:cclResult];

    CCLOG(@"home %d", unitCtrls.count);
    PartCtrl* ctrl;
    CCSprite* sprite;
    CCTexture2D* texture;

	switch(resultType) {
	case Success:
		{
			ccsResult = [CCSprite spriteWithFile:@"win.png"];
		    ccsResult.position = ccp(size.width/2, size.height/2);
		    ccsResult.scale = scaleBase;
		    [cclInfo addChild:ccsResult];

		    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:@"com.harvest.cr.dog.easy.high.score"];
		    int64_t score = (biteTimeSec+elapsedTime) *1000000;
		    scoreReporter.value = score;
	    	cclResult.string = [NSString stringWithFormat:@"「ふっ、やるじゃねぇか」\r\r%07d micro sec", score];
		    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {}]; 
	    }		
		break;
	case TooFar:
		cclResult.string = @"「おいおい、どこへ行こうってんだ」\r\r中心から外れすぎないように！";
        ccsResult = [CCSprite spriteWithFile:@"failed.png"];
	    ccsResult.position = ccp(size.width/2, size.height/2);
	    ccsResult.scale = scaleBase;
	    [self createDogLauph];
		[cclInfo addChild:ccsResult];
	    break;

	case TooFast:
		cclResult.string = @"「このチキン野郎が！」\r\r噛みつかれるまで離しちゃダメだ！";
		ccsResult = [CCSprite spriteWithFile:@"failed.png"];
	    ccsResult.position = ccp(size.width/2, size.height/2);
	    ccsResult.scale = scaleBase;
	    [self createDogLauph];
		[cclInfo addChild:ccsResult];
		break;

	case TooRate:
		cclResult.string = @"「どうした？ブルって動けなかったかい？」\r\r噛みつかれる前に離そう！";
		ccsResult = [CCSprite spriteWithFile:@"failed.png"];
	    ccsResult.position = ccp(size.width/2, size.height/2);
	    ccsResult.scale = scaleBase;
	    [cclInfo addChild:ccsResult];
	    break;
    default:
        break;
	}

	ccsRetry = [CCSprite spriteWithFile:@"retry.png"];
    ccsRetry.position = ccp(size.width/8, size.height/8);
    ccsRetry.scale = scaleBase;
    [cclInfo addChild:ccsRetry];

	ccsNext = [CCSprite spriteWithFile:@"next.png"];
    ccsNext.position = ccp(size.width - size.width/8, size.height/8);
    ccsNext.scale = scaleBase;
    [cclInfo addChild:ccsNext]; 

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

    [self touchBeganButton:ccsRetry touchLocation:location];
    [self touchBeganButton:ccsNext touchLocation:location];

	isTouchBegan = true;
	inputCount = inputCancelTime;
    return YES;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	touchPoint = [touch locationInView:[touch view]];
	isTouchMoved = true;
	inputCount = inputCancelTime;
}

-(void) hideResult {
	[cclInfo removeAllChildrenWithCleanup:YES];
	[self removeChild:cclSpark cleanup:YES];
	cclSpark = NULL;
	ccsNext = NULL;
	ccsRetry = NULL;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	touchPoint = [touch locationInView:[touch view]];
    CGPoint location = [[CCDirector sharedDirector] convertToGL:touchPoint];

    if([self touchEndButton:ccsRetry touchLocation:location]) {
    	[self hideResult];
        [layerUnit setScale:1];
		[self changeReadyState: true];    	
    }
    if([self touchEndButton:ccsNext touchLocation:location]) {
    	[self hideResult];
		[self createDogStand];
        [layerUnit setScale:1];
        self.isTouchEnabled = NO;
    	[layerTitle dispTitle];
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
