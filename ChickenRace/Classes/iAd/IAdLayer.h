//
//  IAdLayer.h
//
//  Created by masanorythm
//

#import "cocos2d.h"
#import <iAd/iAd.h>

// 広告のタイプ定義
typedef enum {
    kAdOrientationPortrait,
    kAdOrientationLandscape,
} AdOrientation;

// 広告の位置定義
typedef enum {
    kAdPositionTop,
    kAdPositionBottom,
} AdPosition;

@interface IAdLayer : CCNode <ADBannerViewDelegate> {
}

@property (nonatomic, assign) BOOL isShow;

+ (id)nodeWithOrientation:(AdOrientation)orientation
                 position:(AdPosition)position;

@end
