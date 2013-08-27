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
#import "GameKit/GameKit.h"
#import "Twitter/Twitter.h"
#import "Accounts/Accounts.h"

#pragma mark - CCLayerTitle

CCSprite *title_logo;
CCSprite *title_buttons;

@implementation CCLayerTitle

-(id)init {
	self = [super init];
    flagCanTweet = true;
	return self;
}

+(id)layerTitle{
    return  [[[self alloc] init] autorelease];
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
// 	      [self setFlagCanTweet:YES];
// 	      [self.btTweet setAlpha:1.0f];
    }
    else  {
        /* ここでツイート不可判定時の処理を記述する。ボタンの無効化や不可視化など。 */
//	       [self setFlagCanTweet:NO];
//	       [self.btTweet setAlpha:0.3f];
    }
}

-(void) dispTitle
{
	// ask director for the window size
	CGSize size = [[CCDirector sharedDirector] winSize];
	float scaleBase = [AppController getScaleBase];
    
    title_logo = [CCSprite spriteWithFile:@"UI/title_logo.png"];
	title_logo.position = ccp(size.width/2, size.height - 20 - title_logo.contentSize.height / 2 * scaleBase);
    title_logo.scale = scaleBase;
  
	// add the label as a child to this Layer
	[self addChild: title_logo];
    
    ccsStartButton = [CCSprite spriteWithFile:@"UI/start_button.png"];
	ccsStartButton.position = ccp(size.width/2, 128 * scaleBase);
    ccsStartButton.scale = scaleBase;

	[ccsStartButton runAction: 
		[CCRepeatForever actionWithAction: 
			[CCSequence actions: 
				[CCEaseInOut actionWithAction: 
					[CCScaleTo actionWithDuration:0.5f scale:scaleBase * 0.9f] 
					rate:3 
				], 
				[CCEaseInOut actionWithAction: 
					[CCScaleTo actionWithDuration:0.5f scale:scaleBase] 
					rate:3 
				], 
				nil
			] 
		]
	];

	// add the label as a child to this Layer
	[self addChild: ccsStartButton];

	//
	// Leaderboards and Achievements
	//
	ccsTweetButton = [CCSprite spriteWithFile:@"UI/tweet_button.png"];
    [ccsTweetButton setPosition:ccp(16 + ccsTweetButton.contentSize.width / 2 * scaleBase, 
    								size.height - (100 + ccsTweetButton.contentSize.height / 2) * scaleBase )];
    [ccsTweetButton setScale:scaleBase];
	[self addChild:ccsTweetButton];
    
	ccsRankingButton = [CCSprite spriteWithFile:@"UI/ranking_button.png"];
    [ccsRankingButton setPosition:ccp(size.width - (16 + ccsTweetButton.contentSize.width / 2 * scaleBase),
    								size.height - (100 + ccsRankingButton.contentSize.height / 2) * scaleBase )];
    [ccsRankingButton setScale:scaleBase];
	[self addChild:ccsRankingButton];
    
	self.isTouchEnabled = YES;		
}

-(void) registerWithTouchDispatcher
{
    CCDirector *director = [CCDirector sharedDirector];
    [[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

// スプライトがタッチされた場合の処理
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location =[touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];

    [self touchBeganButton:ccsStartButton touchLocation:location];
    [self touchBeganButton:ccsTweetButton touchLocation:location];
    [self touchBeganButton:ccsRankingButton touchLocation:location];
    return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location =[touch locationInView:[touch view]];
    location =[[CCDirector sharedDirector] convertToGL:location];

    if([self touchEndButton:ccsStartButton touchLocation:location]) {
		self.isTouchEnabled = NO;		

        CGSize size = [[CCDirector sharedDirector] winSize];
        id riseUp = [CCEaseIn actionWithAction: [CCMoveBy actionWithDuration:0.5 position:ccp(0, size.height*2) ] rate:2 ];
	    [self runAction: [CCSequence actions: [CCDelayTime actionWithDuration:0.1], riseUp, nil]];
	    [self scheduleOnce:@selector(startGameScene:) delay:0.6];
    }

   if([self touchEndButton:ccsTweetButton touchLocation:location isRespawn:true]) {

		/* ツイート可能になっていない場合 */
		if(!flagCanTweet)  {
				/* UIAlertViewなどでアラート表示 */
		}
		/* ツイート可能な状態の場合 */
		else {

			/* ツイート画面のためのビューコントローラインスタンスを生成する。 */
			TWTweetComposeViewController *vcTweet = [[TWTweetComposeViewController alloc] init];

		        /* 初期表示文字列の指定 */
			[vcTweet setInitialText:[NSString stringWithFormat:@"いぬ	"]];

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
        GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
       leaderboardViewController.leaderboardDelegate = [CCLayerGame get];
	
        AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
        [[app navController] presentModalViewController:leaderboardViewController animated:YES];
        [leaderboardViewController release];
    }
}

-(void)startGameScene:(ccTime)dt {
	CCLOG(@"startGameScene");
	[self removeAllChildrenWithCleanup:YES];
    [self setPosition:ccp(0,0)];
    [[CCLayerGame get] gameStart];
}

@end
