//
//  ADSmaxCN.m
//  AdsYield MAX Custom Network Adapter
//

#import "ADSmaxCN.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#define ADAPTER_VERSION @"1.0.1"
static NSString *const kAdaptiveBannerTypeInline = @"inline";

#pragma mark - Forward delegate class declarations

@interface ADSmaxCNInterstitialDelegate : NSObject <GADFullScreenContentDelegate>
@property (nonatomic, weak) ADSmaxCN *parentAdapter;
@property (nonatomic, strong) NSString *placementIdentifier;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ADSmaxCN *)parent
                  placementIdentifier:(NSString *)placementId
                            andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ADSmaxCNRewardedDelegate : NSObject <GADFullScreenContentDelegate>
@property (nonatomic, weak) ADSmaxCN *parentAdapter;
@property (nonatomic, strong) NSString *placementIdentifier;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ADSmaxCN *)parent
                  placementIdentifier:(NSString *)placementId
                            andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ADSmaxCNAdViewDelegate : NSObject <GADBannerViewDelegate>
@property (nonatomic, weak) ADSmaxCN *parentAdapter;
@property (nonatomic, weak) MAAdFormat *adFormat;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ADSmaxCN *)parent
                             adFormat:(MAAdFormat *)adFormat
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

#pragma mark - ADSmaxCN

@interface ADSmaxCN ()
@property (nonatomic, strong, nullable) GADInterstitialAd *interstitialAd;
@property (nonatomic, strong, nullable) GADRewardedAd     *rewardedAd;
@property (nonatomic, strong, nullable) GADBannerView     *adView;

@property (nonatomic, strong, nullable) ADSmaxCNInterstitialDelegate *interstitialAdapterDelegate;
@property (nonatomic, strong, nullable) ADSmaxCNRewardedDelegate     *rewardedAdapterDelegate;
@property (nonatomic, strong, nullable) ADSmaxCNAdViewDelegate       *adViewAdapterDelegate;
@end

@implementation ADSmaxCN

#pragma mark - MAAdapter lifecycle

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters
               completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    [self log: @"Initializing AdsYield MAX adapter (ADSmaxCN)..."];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[GADMobileAds sharedInstance] startWithCompletionHandler: nil];
    });
    completionHandler(MAAdapterInitializationStatusDoesNotApply, nil);
}

- (NSString *)SDKVersion
{
    return GADGetStringFromVersionNumber([GADMobileAds sharedInstance].versionNumber);
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self log: @"Destroy called for ADSmaxCN %@", self];

    self.interstitialAd.fullScreenContentDelegate = nil;
    self.interstitialAd = nil;
    self.interstitialAdapterDelegate.delegate = nil;
    self.interstitialAdapterDelegate = nil;

    self.rewardedAd.fullScreenContentDelegate = nil;
    self.rewardedAd = nil;
    self.rewardedAdapterDelegate.delegate = nil;
    self.rewardedAdapterDelegate = nil;

    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewAdapterDelegate.delegate = nil;
    self.adViewAdapterDelegate = nil;
}

#pragma mark - MAInterstitialAdapter

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters
                              andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading interstitial ad: %@...", placementId];

    if ( placementId.length == 0 )
    {
        [delegate didFailToLoadInterstitialAdWithError: [ADSmaxCN missingPlacementIdError]];
        return;
    }

    [GADInterstitialAd loadWithAdUnitID: placementId
                                request: [GADRequest request]
                      completionHandler:^(GADInterstitialAd * _Nullable ad, NSError * _Nullable error) {

        if ( error )
        {
            MAAdapterError *adapterError = [ADSmaxCN toMaxError: error];
            [self log: @"Interstitial (%@) failed to load: %@", placementId, adapterError];
            [delegate didFailToLoadInterstitialAdWithError: adapterError];
            return;
        }

        if ( !ad )
        {
            [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.adNotReady];
            return;
        }

        [self log: @"Interstitial ad loaded: %@", placementId];
        self.interstitialAd = ad;
        self.interstitialAdapterDelegate = [[ADSmaxCNInterstitialDelegate alloc] initWithParentAdapter: self
                                                                                   placementIdentifier: placementId
                                                                                             andNotify: delegate];
        self.interstitialAd.fullScreenContentDelegate = self.interstitialAdapterDelegate;
        [delegate didLoadInterstitialAd];
    }];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters
                              andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing interstitial ad: %@...", placementId];

    if ( self.interstitialAd )
    {
        UIViewController *vc = [self presentingViewControllerForParameters: parameters];
        [self.interstitialAd presentFromRootViewController: vc];
    }
    else
    {
        [self log: @"Interstitial ad not ready: %@", placementId];
        MAAdapterError *error = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                             mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                          mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message];
        [delegate didFailToDisplayInterstitialAdWithError: error];
    }
}

#pragma mark - MARewardedAdapter

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters
                          andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading rewarded ad: %@...", placementId];

    if ( placementId.length == 0 )
    {
        [delegate didFailToLoadRewardedAdWithError: [ADSmaxCN missingPlacementIdError]];
        return;
    }

    [GADRewardedAd loadWithAdUnitID: placementId
                            request: [GADRequest request]
                  completionHandler:^(GADRewardedAd * _Nullable ad, NSError * _Nullable error) {

        if ( error )
        {
            MAAdapterError *adapterError = [ADSmaxCN toMaxError: error];
            [self log: @"Rewarded (%@) failed to load: %@", placementId, adapterError];
            [delegate didFailToLoadRewardedAdWithError: adapterError];
            return;
        }

        if ( !ad )
        {
            [delegate didFailToLoadRewardedAdWithError: MAAdapterError.adNotReady];
            return;
        }

        [self log: @"Rewarded ad loaded: %@", placementId];
        self.rewardedAd = ad;
        self.rewardedAdapterDelegate = [[ADSmaxCNRewardedDelegate alloc] initWithParentAdapter: self
                                                                           placementIdentifier: placementId
                                                                                     andNotify: delegate];
        self.rewardedAd.fullScreenContentDelegate = self.rewardedAdapterDelegate;
        [delegate didLoadRewardedAd];
    }];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters
                          andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing rewarded ad: %@...", placementId];

    if ( self.rewardedAd )
    {
        [self configureRewardForParameters: parameters];
        UIViewController *vc = [self presentingViewControllerForParameters: parameters];
        [self.rewardedAd presentFromRootViewController: vc
                              userDidEarnRewardHandler:^{
            [self log: @"User earned reward: %@", placementId];
            self.rewardedAdapterDelegate.grantedReward = YES;
        }];
    }
    else
    {
        [self log: @"Rewarded ad not ready: %@", placementId];
        MAAdapterError *error = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                             mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                          mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message];
        [delegate didFailToDisplayRewardedAdWithError: error];
    }
}

#pragma mark - MAAdViewAdapter

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *placementId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@ ad: %@...", adFormat.label, placementId];

    if ( placementId.length == 0 )
    {
        [delegate didFailToLoadAdViewAdWithError: [ADSmaxCN missingPlacementIdError]];
        return;
    }

    BOOL isAdaptive = [parameters.serverParameters al_boolForKey: @"adaptive_banner" defaultValue: NO];
    GADAdSize adSize = [self adSizeFromAdFormat: adFormat
                               isAdaptiveBanner: isAdaptive
                                     parameters: parameters];

    self.adView = [[GADBannerView alloc] initWithAdSize: adSize];
    self.adView.frame = CGRectMake(0, 0, adSize.size.width, adSize.size.height);
    self.adView.adUnitID = placementId;
    self.adView.rootViewController = [self presentingViewControllerForParameters: parameters];
    self.adViewAdapterDelegate = [[ADSmaxCNAdViewDelegate alloc] initWithParentAdapter: self
                                                                              adFormat: adFormat
                                                                             andNotify: delegate];
    self.adView.delegate = self.adViewAdapterDelegate;
    [self.adView loadRequest: [GADRequest request]];
}

#pragma mark - Helpers

- (UIViewController *)presentingViewControllerForParameters:(id<MAAdapterResponseParameters>)parameters
{
    return parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
}

+ (MAAdapterError *)missingPlacementIdError
{
    return [MAAdapterError errorWithAdapterError: MAAdapterError.invalidConfiguration
                        mediatedNetworkErrorCode: 0
                     mediatedNetworkErrorMessage: @"Missing Placement ID (GAM ad unit) in MAX custom network configuration."];
}

+ (MAAdapterError *)toMaxError:(NSError *)gmaError
{
    GADErrorCode code = gmaError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( code )
    {
        case GADErrorInvalidRequest:
        case GADErrorInvalidArgument:
            adapterError = MAAdapterError.badRequest;
            break;
        case GADErrorNoFill:
        case GADErrorMediationAdapterError:
            adapterError = MAAdapterError.noFill;
            break;
        case GADErrorNetworkError:
            adapterError = MAAdapterError.noConnection;
            break;
        case GADErrorServerError:
        case GADErrorMediationDataError:
        case GADErrorReceivedInvalidAdString:
            adapterError = MAAdapterError.serverError;
            break;
        case GADErrorOSVersionTooLow:
        case GADErrorApplicationIdentifierMissing:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case GADErrorTimeout:
            adapterError = MAAdapterError.timeout;
            break;
        case GADErrorInternalError:
            adapterError = MAAdapterError.internalError;
            break;
        case GADErrorAdAlreadyUsed:
            adapterError = MAAdapterError.invalidLoadState;
            break;
        default:
            break;
    }
    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: code
                     mediatedNetworkErrorMessage: gmaError.localizedDescription];
}

- (GADAdSize)adSizeFromAdFormat:(MAAdFormat *)adFormat
               isAdaptiveBanner:(BOOL)isAdaptive
                     parameters:(id<MAAdapterParameters>)parameters
{
    if ( isAdaptive && [self isAdaptiveAdFormat: adFormat parameters: parameters] )
    {
        return [self adaptiveAdSizeFromParameters: parameters];
    }
    if ( adFormat == MAAdFormat.banner ) return GADAdSizeBanner;
    if ( adFormat == MAAdFormat.leader ) return GADAdSizeLeaderboard;
    if ( adFormat == MAAdFormat.mrec )   return GADAdSizeMediumRectangle;
    [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
    return GADAdSizeBanner;
}

- (BOOL)isAdaptiveAdFormat:(MAAdFormat *)adFormat parameters:(id<MAAdapterParameters>)parameters
{
    BOOL isInlineMrec = (adFormat == MAAdFormat.mrec) && [self isInlineAdaptiveBanner: parameters];
    return isInlineMrec || adFormat == MAAdFormat.banner || adFormat == MAAdFormat.leader;
}

- (BOOL)isInlineAdaptiveBanner:(id<MAAdapterParameters>)parameters
{
    id type = parameters.localExtraParameters[@"adaptive_banner_type"];
    return [type isKindOfClass: NSString.class] &&
           [kAdaptiveBannerTypeInline caseInsensitiveCompare: (NSString *) type] == NSOrderedSame;
}

- (CGFloat)inlineAdaptiveBannerMaxHeightFromParameters:(id<MAAdapterParameters>)parameters
{
    id value = parameters.localExtraParameters[@"inline_adaptive_banner_max_height"];
    if ( [value isKindOfClass: NSNumber.class] )
    {
        return [(NSNumber *) value doubleValue];
    }
    return 0;
}

- (CGFloat)adaptiveBannerWidthFromParameters:(id<MAAdapterParameters>)parameters
{
    id widthValue = parameters.localExtraParameters[@"adaptive_banner_width"];
    if ( [widthValue isKindOfClass: NSNumber.class] )
    {
        return [(NSNumber *) widthValue doubleValue];
    }
    return UIScreen.mainScreen.bounds.size.width;
}

- (GADAdSize)adaptiveAdSizeFromParameters:(id<MAAdapterParameters>)parameters
{
    CGFloat width = [self adaptiveBannerWidthFromParameters: parameters];

    if ( [self isInlineAdaptiveBanner: parameters] )
    {
        CGFloat maxHeight = [self inlineAdaptiveBannerMaxHeightFromParameters: parameters];
        if ( maxHeight > 0 )
        {
            return GADInlineAdaptiveBannerAdSizeWithWidthAndMaxHeight(width, maxHeight);
        }
        return GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(width);
    }
    return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width);
}

@end

#pragma mark - Interstitial delegate

@implementation ADSmaxCNInterstitialDelegate

- (instancetype)initWithParentAdapter:(ADSmaxCN *)parent
                  placementIdentifier:(NSString *)placementId
                            andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    if ( (self = [super init]) )
    {
        self.parentAdapter = parent;
        self.placementIdentifier = placementId;
        self.delegate = delegate;
    }
    return self;
}

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Interstitial ad shown: %@", self.placementIdentifier];
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                mediatedNetworkErrorCode: error.code
                                             mediatedNetworkErrorMessage: error.localizedDescription];
    [self.parentAdapter log: @"Interstitial (%@) failed to show: %@", self.placementIdentifier, adapterError];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Interstitial impression: %@", self.placementIdentifier];
    [self.delegate didDisplayInterstitialAd];
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Interstitial clicked: %@", self.placementIdentifier];
    [self.delegate didClickInterstitialAd];
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Interstitial hidden: %@", self.placementIdentifier];
    [self.delegate didHideInterstitialAd];
}

@end

#pragma mark - Rewarded delegate

@implementation ADSmaxCNRewardedDelegate

- (instancetype)initWithParentAdapter:(ADSmaxCN *)parent
                  placementIdentifier:(NSString *)placementId
                            andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    if ( (self = [super init]) )
    {
        self.parentAdapter = parent;
        self.placementIdentifier = placementId;
        self.delegate = delegate;
    }
    return self;
}

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Rewarded ad shown: %@", self.placementIdentifier];
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
    MAAdapterError *adapterError = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                mediatedNetworkErrorCode: error.code
                                             mediatedNetworkErrorMessage: error.localizedDescription];
    [self.parentAdapter log: @"Rewarded (%@) failed to show: %@", self.placementIdentifier, adapterError];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Rewarded impression: %@", self.placementIdentifier];
    [self.delegate didDisplayRewardedAd];
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"Rewarded clicked: %@", self.placementIdentifier];
    [self.delegate didClickRewardedAd];
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarding user: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    [self.parentAdapter log: @"Rewarded hidden: %@", self.placementIdentifier];
    [self.delegate didHideRewardedAd];
}

@end

#pragma mark - AdView (banner) delegate

@implementation ADSmaxCNAdViewDelegate

- (instancetype)initWithParentAdapter:(ADSmaxCN *)parent
                             adFormat:(MAAdFormat *)adFormat
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    if ( (self = [super init]) )
    {
        self.parentAdapter = parent;
        self.adFormat = adFormat;
        self.delegate = delegate;
    }
    return self;
}

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad loaded: %@", self.adFormat.label, bannerView.adUnitID];
    [self.delegate didLoadAdForAdView: bannerView];
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ADSmaxCN toMaxError: error];
    [self.parentAdapter log: @"%@ ad (%@) failed to load: %@", self.adFormat.label, bannerView.adUnitID, adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad impression: %@", self.adFormat.label, bannerView.adUnitID];
    [self.delegate didDisplayAdViewAd];
}

- (void)bannerViewDidRecordClick:(GADBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad clicked: %@", self.adFormat.label, bannerView.adUnitID];
    [self.delegate didClickAdViewAd];
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad expanded: %@", self.adFormat.label, bannerView.adUnitID];
    [self.delegate didExpandAdViewAd];
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad collapsed: %@", self.adFormat.label, bannerView.adUnitID];
    [self.delegate didCollapseAdViewAd];
}

@end
