# Uncomment the next line to define a global platform for your project
#source "https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git"
platform :ios, '13.0'
inhibit_all_warnings!

target 'RCRTC' do
  use_frameworks!
  
  # Resources
  pod 'R.swift'
  
  # Crash
  pod 'Bugly'
  
  # Event
  pod 'UMCommon'
  
  # Reactor
  pod 'RxGesture'
  pod 'ReactorKit'
  pod 'RxDataSources'
  pod 'RxViewController'
  pod 'IQKeyboardManager'
  
  pod 'RCSceneCall'
  pod 'RCSceneGameRoom'
  pod 'RCSceneVoiceRoom'
  pod 'RCSceneVideoRoom'
  pod 'RCSceneFaceBeautyKit', :git => 'git@gitlab2.rongcloud.net:scene/ios/rongcloud-scene-beauty-kit-ios.git'
  pod 'RCSceneRadioRoom'

  # OC Component
  pod 'RCSceneLoginKit'
  
  # 融云内置 CDN 播放器
  pod 'RongCloudRTC/RongRTCPlayer'
  # 三方 CDN，demo 中用开源的七牛播放器演示
  pod 'PLPlayerKit'
  
  # RCSceneCommunity
  pod 'SwiftGen', '~> 6.0'
  pod 'RCSceneCommunity'

  pod 'lottie-ios'
  
  # 临时使用修改过的代码。下个版本实时社区会替换此库
  pod 'KNPhotoBrowser', :git => 'https://github.com/coood/KNPhotoBrowser.git', :commit => '7a0619a7ebdfe8979dbe6c3f1e335e7e772be9e9'
  
  target 'RCRTCTests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'RCRTCUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
   config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
   config.build_settings['ENABLE_BITCODE'] = 'NO'
  end
 end
end
