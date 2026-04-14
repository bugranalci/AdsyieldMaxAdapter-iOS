Pod::Spec.new do |s|
  s.name             = 'ADSmaxadapter'
  s.version          = '1.0.0'
  s.summary          = 'AdsYield MAX custom network adapter for iOS.'
  s.description      = <<-DESC
    AdsYield MAX Mediation Adapter enables publishers using AppLovin MAX mediation
    to serve AdsYield demand through their GAM/MCM inventory via the Google Mobile Ads SDK.
    Supports Banner, Adaptive Banner, Leaderboard, MREC, Interstitial, and Rewarded formats.
  DESC

  s.homepage         = 'https://github.com/bugranalci/AdsyieldMaxAdapter-iOS'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'AdsYield' => 'info@adsyield.com' }
  s.source           = { :git => 'https://github.com/bugranalci/AdsyieldMaxAdapter-iOS.git',
                          :tag => s.version.to_s }

  s.platform              = :ios
  s.ios.deployment_target = '12.0'
  s.swift_versions        = ['5.0']
  s.static_framework      = true

  s.source_files        = 'ADSmaxadapter/Sources/**/*.{h,m}'
  s.public_header_files = 'ADSmaxadapter/Sources/ADSmaxCN.h'

  s.resource_bundles = {
    'ADSmaxadapter' => ['ADSmaxadapter/Sources/PrivacyInfo.xcprivacy']
  }

  s.dependency 'AppLovinSDK', '>= 13.0.0'
  s.dependency 'Google-Mobile-Ads-SDK', '~> 12.5'

  s.frameworks = 'Foundation', 'UIKit'
end
