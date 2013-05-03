//
//  AdViewController.h
//  SeesawBall
//
//  Created by Kasajima Yasuo on 11/08/08.
//  Copyright 2011 kyoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdMakerView.h"
#import <iAd/iAd.h>

@interface AdViewController : UIViewController <ADBannerViewDelegate>{
    AdMakerView *AdMaker;
    ADBannerView *vAds;
	Boolean bannerIsVisible;
    
    int topMargin;
    int bannerOffSetHeight;
}
@property (retain) ADBannerView *vAds;
- (void)startAds;
@end
