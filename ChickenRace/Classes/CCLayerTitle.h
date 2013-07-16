//
//  CCLayerTitle.h
//  ChickenRace
//
//  Created by 小川 穣 on 2013/04/14.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCLayerExtension.h"
#import "cocos2d.h"

@interface CCLayerTitle : CCLayerExtension {
	CCSprite *ccsStartButton;
	CCSprite *ccsTweetButton;
	CCSprite *ccsRankingButton;
	BOOL flagCanTweet;
}
+(id)layerTitle;
// returns a CCScene that contains the HelloWorldLayer as the only child
-(void) dispTitle;

@end
