# Uncomment the next line to define a global platform for your project
#source "https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git"
platform :ios, '13.0'
inhibit_all_warnings!

target 'RCE' do
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
  
  # Modular
  pod 'RCSceneCall'
  pod 'RCSceneVoiceRoom'
  pod 'RCSceneVideoRoom'
  pod 'RCSceneRadioRoom'
  
  # OC Component
  pod 'RCSceneLoginKit', '0.1.0'
  
  # IM
  pod 'RongCloudIM/IMLib'  # , '~> 5.2.0'
  
  # RTC
  pod 'RongCloudRTC/RongRTCLib'   # , '5.1.16'
  pod 'RongCloudRTC/RongRTCPlayer' # , '5.1.16'
  
  # RCSceneCommunity
  pod 'SwiftGen', '~> 6.0'
  pod 'RCSceneCommunity' 
  
  pod 'lottie-ios'
  
  # 临时使用修改过的代码。下个版本实时社区会替换此库
  pod 'KNPhotoBrowser', :git => 'https://github.com/coood/KNPhotoBrowser.git'
  
  target 'RCETests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'RCEUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
  end
 end
end
