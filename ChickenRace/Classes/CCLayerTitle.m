//
//  CCLayerTitle.m
//  ChickenRace
//
//  Created by 小川 穣 on 2013/04/14.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "CCLayerTitle.h"
#import "CCLayerGame.h"
#import "AppDelegate.h"

#pragma mark - CCLayerTitle

CCSprite *title_logo;
CCSprite *title_buttons;

@implementation CCLayerTitle

// Helper class method that creates a Scene with the CCLayerGame as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CCLayerTitle *layer = [CCLayerTitle node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)init {
	self = [super init];

	return self;
}

+(id)layerTitle{
    return  [[[self alloc] init] autorelease];
}
//
-(void) onEnter
{
	[super onEnter];
	[self dispTitle];
}

-(void) dispTitle
{
	// ask director for the window size
	CGSize size = [[CCDirector sharedDirector] winSize];
	float scale = [AppController getScaleBase];
    
    title_logo = [CCSprite spriteWithFile:@"title_logo.png"];
	title_logo.position = ccp(size.width/2, size.height - title_logo.contentSize.height * (0.5f * scale));
    title_logo.scale = scale;
  
	// add the label as a child to this Layer
	[self addChild: title_logo];
    
    start_button = [CCSprite spriteWithFile:@"start_button.png"];
	start_button.position = ccp(size.width/2, 88);
    start_button.scale = scale;

    id sclMin = [CCEaseInOut actionWithAction: [CCScaleTo actionWithDuration:0.5f scale:scale * 0.9f] rate:3 ];
    id sclMax = [CCEaseInOut actionWithAction: [CCScaleTo actionWithDuration:0.5f scale:scale] rate:3 ];
	[start_button runAction:[CCRepeatForever actionWithAction: [CCSequence actions: sclMin, sclMax, nil] ] ];

	// add the label as a child to this Layer
	[self addChild: start_button];
    
    title_buttons = [CCSprite spriteWithFile:@"title_buttons.png"];
	title_buttons.position = ccp(size.width/2, size.height/2 + 16);
    title_buttons.scale = scale;

	// add the label as a child to this Layer
	[self addChild: title_buttons];

	self.isTouchEnabled = YES;		
}

// スプライトのタッチ判定用メソッド
-(CGRect)rectForSprite:(CCSprite *)sprite {
    float h = [sprite contentSize].height/2;
    float w = [sprite contentSize].width/2;
    float x = sprite.position.x - w/2;
    float y = sprite.position.y - h/2;
    CGRect rect = CGRectMake(x,y,w,h);return rect; 
}

// スプライトがタッチされた場合の処理
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch =[touches anyObject];
    CGPoint location =[touch locationInView:[touch view]];
    location =[[CCDirector sharedDirector] convertToGL:location];

    CGRect obj01Rect = [self rectForSprite:start_button];
    if(CGRectContainsPoint(obj01Rect, location)) {
	    //スプライト（obj01）がタッチされた場合の処理を書く
	    start_button.visible = false;
	    self.isTouchEnabled = NO;
        CGSize size = [[CCDirector sharedDirector] winSize];
        id riseUp = [CCEaseIn actionWithAction: [CCMoveTo actionWithDuration:0.5 position:ccp(size.width/ 2, size.height*2) ] rate:2 ];
	    [title_logo runAction:riseUp];
	    [title_buttons runAction:[ [riseUp copy] autorelease] ];
	    [self scheduleOnce:@selector(startGameScene:) delay:0.5];
    }
}

-(void)startGameScene:(ccTime)dt {
    [[CCLayerGame get] gameStart];
}

@end
