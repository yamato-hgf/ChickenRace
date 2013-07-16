//
//  CCLayerExtension.m
//  ChickenRace
//
//  Created by 小川 穣 on 2013/04/14.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "CCLayerExtension.h"
#import "AppDelegate.h"

#pragma mark - CCLayerExtension

@implementation CCLayerExtension

-(id)init {
	ccsTouchBegan = NULL;
	return [super init];
}

// スプライトのタッチ判定用メソッド
-(CGRect)rectForSprite:(CCSprite *)sprite {
    CGRect rect;
    if(sprite != NULL) {
    	float h = [sprite contentSize].height/2;
    	float w = [sprite contentSize].width/2;
    	float x = sprite.position.x - w/2;
    	float y = sprite.position.y - h/2;
    	rect = CGRectMake(x,y,w,h);
    }
    return rect;
}

-(bool)touchBeganButton:(CCSprite *)sprite touchLocation:(CGPoint)location {
    if(CGRectContainsPoint([self rectForSprite:sprite], location)) {
    	[sprite setScale:0.75f * [AppController getScaleBase]];
    	[sprite pauseSchedulerAndActions];
        ccsTouchBegan = sprite;
    	return true;
	}	
	return false;
}

-(bool)touchEndButton:(CCSprite *)sprite touchLocation:(CGPoint)location {
	return [self touchEndButton:sprite touchLocation:location isRespawn:false];
}

-(bool)touchEndButton:(CCSprite *)sprite touchLocation:(CGPoint)location isRespawn:(bool)respawn {
    if(CGRectContainsPoint([self rectForSprite:sprite], location)) {
        [sprite resumeSchedulerAndActions];
        id scaleOut = [CCSpawn actions:
    		[CCEaseIn actionWithAction: 
    			[CCScaleBy actionWithDuration:0.1 scale:2 ] rate:2
    		],
    		[CCEaseIn actionWithAction:
    			[CCFadeTo actionWithDuration:0.1 opacity:0 ] rate:2
    		],
    		nil
    	];
        id scaleIn = [CCSpawn actions:
			[CCEaseBounceOut actionWithAction:
				[CCScaleTo actionWithDuration:0.5f 
					scale:[AppController getScaleBase]
                ]
			],
			[CCFadeTo actionWithDuration:0.0 opacity:255 ],
			nil
        ];
    	if(respawn) {
			[sprite runAction: 
				[CCSequence actions:
					scaleOut,
					[CCScaleTo actionWithDuration:0.5 scale:0],
					scaleIn,
					nil
				]
			];
		}
		else {
		    [sprite runAction: scaleOut];
	    }
	    return true;
	}
    else if(ccsTouchBegan == sprite) {
    	[ccsTouchBegan resumeSchedulerAndActions];
    	[ccsTouchBegan setScale: [AppController getScaleBase]];
    	ccsTouchBegan = NULL;
    }
	return false;
}

@end
