# Uncomment the next line to define a global platform for your project
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
#  pod 'RCSceneCommunity'
  
  # IM
  pod 'RongCloudIM/IMLib', '5.1.8'
  pod 'RongCloudIM/IMKit', '5.1.8'
  
  # RTC
  pod 'RongCloudRTC/RongRTCLib', '5.1.16.1'
  pod 'RongCloudRTC/RongRTCPlayer', '5.1.16.1'
  
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
