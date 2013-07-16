//
//  IAdLayer.m
//
//  Created by masanorythm
//

#import "IAdLayer.h"

// バナー移動速度
#define BANNER_ANIMATION_SPEED  0.3f

@interface IAdLayer () {
    
    ADBannerView*       _adView;            // iAdインスタンス
    
    AdOrientation       _adOrientation;     // 広告タイプ
    AdPosition          _adPosition;        // 広告位置
    
    float               _bannerMovePx;      // バナー移動量
}

@end
@implementation IAdLayer

+ (id)nodeWithOrientation:(AdOrientation)orientation position:(AdPosition)position
{
    return [[[self alloc] initWithOrientation:orientation position:position] autorelease];
}

#pragma mark -
#pragma mark 初期化
- (id)initWithOrientation:(AdOrientation)orientation position:(AdPosition)position
{
	if ((self = [super init]))
    {
        _adOrientation  = orientation;  // バナー向きセット
        _adPosition     = position;     // バナー位置セット
        _isShow = NO;                   // バナーフラグOFF
	}
	return self;
}

#pragma mark 解放
- (void)dealloc
{
    _adView.delegate = nil;
    
    [_adView removeFromSuperview];
    [_adView release];
	
	[super dealloc];
}

#pragma mark 画面遷移開始時
- (void)onExitTransitionDidStart
{
    [super onExitTransitionDidStart];
    
    // バナー非表示アクションを実行
    [self hideBanner];
}

#pragma mark -
#pragma mark 広告を作成
- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    // バナービューを初期化
	_adView = [[ADBannerView alloc] init];
    
    // バナーの向きを指定
    switch (_adOrientation) {
        // 縦向き
        case kAdOrientationPortrait:
            _adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];
            _adView.currentContentSizeIdentifier   = ADBannerContentSizeIdentifierPortrait;
            
            break;
            
        // 横向き
        case kAdOrientationLandscape:
            _adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierLandscape];
            _adView.currentContentSizeIdentifier   = ADBannerContentSizeIdentifierLandscape;
            
            break;
    }
    
    // バナーの移動距離を取得
    if (_adPosition == kAdPositionBottom) {
        _bannerMovePx = - _adView.frame.size.height;
    } else {
        _bannerMovePx = _adView.frame.size.height;
    }
    
    // バナーの初期位置を指定
    float posY;
    
    if (_adPosition == kAdPositionBottom) {
        // 画面下
        posY = [[CCDirector sharedDirector] winSize].height;
    } else {
        // 画面上
        posY = -_bannerMovePx;
    }
    
    // 広告の位置を調整
    _adView.frame = CGRectMake(0, posY, _adView.frame.size.width, _adView.frame.size.height);
    
    // デリゲート指定
    _adView.delegate = self;
    
    // 広告をGLViewに貼付ける
    [[[CCDirector sharedDirector] view] addSubview:_adView];
}

#pragma mark 広告読み込み成功
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    CCLOG(@"広告読み込み成功");
    
    // バナー表示アクションを実行
    [self showBanner];
}

#pragma mark 広告読み込み失敗
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    CCLOG(@"広告読み込み失敗");
    
    // バナー非表示アクションを実行
    [self hideBanner];
}

#pragma mark -
#pragma mark バナー移動アクション
- (void)showBanner
{
    // |* * * バナー表示 * * *|
    
    // バナー表示フラグOFFの場合、バナーアクションを実行
    if (!self.isShow)
    {
        [UIView animateWithDuration:BANNER_ANIMATION_SPEED
                         animations:^{
                             _adView.frame = CGRectOffset(_adView.frame, 0, _bannerMovePx);
                         }
                         completion:^(BOOL finished) {
                             self.isShow = YES;
                             
                             // アニメーション終了後の処理があればココに追加
                         }];
    }
}

- (void)hideBanner
{
    // |* * * バナー非表示 * * *|
    
    // バナー表示フラグONの場合、バナーアクションを実行(非表示)
    if (self.isShow)
    {
        [UIView animateWithDuration:BANNER_ANIMATION_SPEED
                         animations:^{
                             _adView.frame = CGRectOffset(_adView.frame, 0, -_bannerMovePx);
                         }
                         completion:^(BOOL finished) {
                             self.isShow = NO;
                             
                             // アニメーション終了後の処理があればココに追加
                         }];
    }
}


#pragma mark -
#pragma mark バナーがクリックされた際の処理
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    // 一時停止呼び出し
    [self pauseActionsForAd];
    
    return YES;
}

#pragma mark 全面広告をキャンセルした際の処理
- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    // 再開呼び出し
    [self resumeActionsForAd];
}

#pragma mark 全面広告表示中後の 一時停止 & 再開
// 一時停止
- (void)resumeActionsForAd
{
    [[CCDirector sharedDirector] startAnimation];
    
    [[CCDirector sharedDirector] resume];
}

// 再開
- (void)pauseActionsForAd
{
    [[CCDirector sharedDirector] stopAnimation];
    
    [[CCDirector sharedDirector] pause];
}

@end
