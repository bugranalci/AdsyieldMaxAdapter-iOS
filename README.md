# AdsYield MAX Mediation Adapter for iOS

AdsYield MAX Mediation Adapter, AppLovin MAX mediation kullanan yayıncıların AdsYield demand'ini GAM/MCM altyapısı üzerinden sunmasını sağlar.

AdsYield MAX Mediation Adapter enables publishers using AppLovin MAX mediation to serve AdsYield demand through the underlying GAM/MCM inventory.

---

## 🇹🇷 Kurulum

### CocoaPods

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

### Desteklenen Formatlar

- Banner (320x50) + Adaptive Banner (anchored & inline) + Leaderboard (728x90)
- MREC (300x250)
- Interstitial
- Rewarded

### MAX Dashboard Ayarı

| Alan | Değer |
|---|---|
| **Class Name (iOS)** | `ADSmaxCN` |
| **Placement ID** | AdsYield'ın verdiği GAM ad unit ID (örn: `ca-app-pub-XXXXX/YYYYYY`) |

Detaylı rehber: [docs/ENTEGRASYON_REHBERI.md](docs/ENTEGRASYON_REHBERI.md)

---

## 🇬🇧 Installation

### CocoaPods

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

### Supported Formats

- Banner (320x50) + Adaptive Banner (anchored & inline) + Leaderboard (728x90)
- MREC (300x250)
- Interstitial
- Rewarded

### MAX Dashboard Setup

| Field | Value |
|---|---|
| **Class Name (iOS)** | `ADSmaxCN` |
| **Placement ID** | GAM ad unit ID provided by AdsYield (e.g., `ca-app-pub-XXXXX/YYYYYY`) |

Full guide: [docs/INTEGRATION_GUIDE.md](docs/INTEGRATION_GUIDE.md)

---

## Requirements

- iOS 12.0+
- AppLovin MAX SDK 13.0.0+
- Google Mobile Ads SDK 12.5+ (transitively provided)

## License

Apache License 2.0
