# AdsYield MAX iOS Adapter — Integration Guide

This guide walks you through integrating AdsYield into an iOS app that already uses AppLovin MAX mediation.

## 1. Requirements

| Requirement | Minimum |
|---|---|
| iOS | 12.0+ |
| Xcode | 15.0+ |
| AppLovin MAX SDK | 13.0.0+ |
| Google Mobile Ads SDK | 12.5+ |

The AppLovin MAX SDK must already be installed. See: https://support.axon.ai/en/max/ios

## 2. CocoaPods Setup

`Podfile`:

```ruby
platform :ios, '12.0'
use_frameworks!

target 'YourApp' do
  pod 'AppLovinSDK'
  pod 'ADSmaxadapter', '~> 1.0'
end
```

```bash
pod install
```

> Open the project via `.xcworkspace`.

## 3. Info.plist

Add the `GADApplicationIdentifier` provided by AdsYield:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXX~YYYYY</string>
```

SKAdNetwork list: https://developers.google.com/admob/ios/ios14#skadnetwork

## 4. MAX Dashboard — Custom Network

### Step 1: Add Network

1. MAX Dashboard → **Mediation > Networks**
2. Bottom of page → **"Click here to add a Custom Network"**
3. Enter:

| Field | Value |
|---|---|
| **Network Type** | SDK |
| **Name** | AdsYield |
| **iOS Adapter Class Name** | `ADSmaxCN` |
| **Android Adapter Class Name** | `com.adsyield.mediation.max.ADSmaxCN` |

4. Save.

### Step 2: Enable on Ad Unit

| Field | Value |
|---|---|
| **App ID** | Leave empty |
| **Placement ID** | GAM ad unit ID provided by AdsYield |
| **CPM** | eCPM recommended by AdsYield |

## 5. Supported Formats

| Format | Description |
|---|---|
| Banner | 320x50 |
| Adaptive Banner | Anchored or Inline |
| Leaderboard | 728x90 |
| MREC | 300x250 |
| Interstitial | Full-screen interstitial |
| Rewarded | Rewarded video |

No app code changes needed.

## 6. Testing

### Mediation Debugger

```objc
[[ALSdk shared] showMediationDebugger];
```

ADSmaxCN should appear as `Initialized`.

### Console Log

Filter `ADSmaxCN` in Xcode Console:

```
ADSmaxCN: Initializing AdsYield MAX adapter (ADSmaxCN)...
ADSmaxCN: Loading interstitial ad: ca-app-pub-XXX/YYY...
ADSmaxCN: Interstitial ad loaded: ...
```

## 7. Troubleshooting

| Issue | Fix |
|---|---|
| "Adapter not found" | Class name: `ADSmaxCN` (exact, no namespace) |
| "No fill" | Ensure AdsYield MCM ad unit is active with demand |
| "Missing Placement ID" | Fill the Placement ID field in MAX UI |
| Banner invisible | Ensure MAAdView is attached to parent view |
| Crash `@rpath/GoogleMobileAds` | Re-run `pod install`, open `.xcworkspace` |

## 8. Version Compatibility

| Adapter | AppLovin SDK | Google Mobile Ads SDK |
|---|---|---|
| 1.0.1 | 13.0.0+ | 12.5+ |

## 9. Support

- GitHub Issues: https://github.com/bugranalci/AdsyieldMaxAdapter-iOS/issues
- Email: info@adsyield.com
