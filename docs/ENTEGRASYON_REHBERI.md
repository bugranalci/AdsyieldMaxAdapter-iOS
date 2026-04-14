# AdsYield MAX iOS Adapter — Entegrasyon Rehberi

Bu rehber, AppLovin MAX mediation kullanan iOS uygulamalarına AdsYield'in entegre edilmesini anlatır.

## 1. Gereksinimler

| Gereksinim | Minimum |
|---|---|
| iOS | 12.0+ |
| Xcode | 15.0+ |
| AppLovin MAX SDK | 13.0.0+ |
| Google Mobile Ads SDK | 12.5+ |

AppLovin MAX SDK zaten kurulu olmalıdır. Kurulum için: https://support.axon.ai/en/max/ios

## 2. CocoaPods Kurulumu

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

> Projeyi `.xcworkspace` üzerinden açın.

## 3. Info.plist Ayarları

AdsYield'ın verdiği `GADApplicationIdentifier`'ı ekleyin:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXX~YYYYY</string>
```

SKAdNetwork ID listesi: https://developers.google.com/admob/ios/ios14#skadnetwork

## 4. MAX Dashboard — Custom Network

### Adım 1: Network Ekle

1. MAX Dashboard → **Mediation > Networks**
2. En altta **"Click here to add a Custom Network"**
3. Değerleri girin:

| Alan | Değer |
|---|---|
| **Network Type** | SDK |
| **Name** | AdsYield |
| **iOS Adapter Class Name** | `ADSmaxCN` |
| **Android Adapter Class Name** | `com.adsyield.mediation.max.ADSmaxCN` |

4. Kaydedin.

### Adım 2: Ad Unit'e Ekle

| Alan | Değer |
|---|---|
| **App ID** | Boş |
| **Placement ID** | AdsYield'ın verdiği GAM ad unit ID |
| **CPM** | AdsYield tavsiye eCPM |

## 5. Desteklenen Formatlar

| Format | Açıklama |
|---|---|
| Banner | 320x50 |
| Adaptive Banner | Anchored veya Inline |
| Leaderboard | 728x90 |
| MREC | 300x250 |
| Interstitial | Tam ekran geçiş |
| Rewarded | Ödüllü video |

Uygulama kodunuzda değişiklik gerekmez.

## 6. Test Etme

### Mediation Debugger

```objc
[[ALSdk shared] showMediationDebugger];
```

ADSmaxCN `Initialized` olarak görünmelidir.

### Console Log

Xcode Console'da `ADSmaxCN` filtreleyin:

```
ADSmaxCN: Initializing AdsYield MAX adapter (ADSmaxCN)...
ADSmaxCN: Loading interstitial ad: ca-app-pub-XXX/YYY...
ADSmaxCN: Interstitial ad loaded: ...
```

## 7. Sorun Giderme

| Sorun | Çözüm |
|---|---|
| "Adapter not found" | Class name: `ADSmaxCN` (tam bu, namespace yok) |
| "No fill" | AdsYield MCM ad unit aktif mi, demand var mı? |
| "Missing Placement ID" | MAX UI'da Placement ID alanını doldurun |
| Banner görünmüyor | `MAAdView`'in parent view'a add edildiğinden emin olun |
| Crash `@rpath/GoogleMobileAds` | Pod install tekrar çalıştırın, `.xcworkspace` kullanın |

## 8. Versiyon Uyumluluğu

| Adapter | AppLovin SDK | Google Mobile Ads SDK |
|---|---|---|
| 1.0.0 | 13.0.0+ | 12.5+ |

## 9. Destek

- GitHub Issues: https://github.com/bugranalci/AdsyieldMaxAdapter-iOS/issues
- E-posta: info@adsyield.com
