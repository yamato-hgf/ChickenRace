//
//  CCLayerLogo.m
//  ChickenRace
//
//  Created by 小川 穣 on 2013/04/15.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "CCLayerLogo.h"
#import "CCLayerGame.h"
#import "CCLayerTitle.h"

#pragma mark - CCLayerLogo

@implementation CCLayerLogo

// Helper class method that creates a Scene with the CCLayerGame as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CCLayerLogo *layer = [CCLayerLogo node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//
-(void) onEnter
{
	[super onEnter];
    
	// ask director for the window size
	CGSize size = [[CCDirector sharedDirector] winSize];
    
	CCSprite *background;
	
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
		background = [CCSprite spriteWithFile:@"Default.png"];
		background.rotation = 90;
	} else {
		background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
	}
	background.position = ccp(size.width/2, size.height/2);
    
	// add the label as a child to this Layer
	[self addChild: background];
    
	// In one second transition to the new scene
	[self scheduleOnce:@selector(makeTransition:) delay:1];
}
-(void) makeTransition:(ccTime)dt
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[CCLayerGame scene] withColor:ccWHITE]];
}

@end
