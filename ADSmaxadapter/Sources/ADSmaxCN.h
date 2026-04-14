//
//  ADSmaxCN.h
//  AdsYield MAX Custom Network Adapter
//
//  AdsYield MAX mediation adapter (custom network). Loads ads from AdsYield's
//  GAM/MCM ad units via the Google Mobile Ads SDK and forwards the lifecycle
//  events back to AppLovin MAX.
//
//  Register in MAX dashboard with:
//    iOS Adapter Class Name: ADSmaxCN
//    Android Adapter Class Name: com.adsyield.mediation.max.ADSmaxCN
//    Placement ID: <GAM ad unit ID provided by AdsYield>
//

#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADSmaxCN : ALMediationAdapter <MAAdViewAdapter,
                                          MAInterstitialAdapter,
                                          MARewardedAdapter>
@end

NS_ASSUME_NONNULL_END
