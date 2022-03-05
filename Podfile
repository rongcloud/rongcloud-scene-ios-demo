# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
inhibit_all_warnings!

install! 'cocoapods', :disable_input_output_paths => true

def commonPods
  pod 'IQKeyboardManager'
  pod 'RxViewController'
  pod 'ReactorKit'
  pod 'Moya'
  pod 'R.swift'
  pod 'Kingfisher'
  pod 'RxDataSources'
  pod 'SnapKit'
  pod 'Reusable'
  pod 'SVProgressHUD'
  pod 'UMCommon'
  pod 'Bugly'
  pod 'Pulsator'
  pod 'MJRefresh'
  pod 'GrowingTextView', '0.7.2'
  pod 'ISEmojiView'
  pod 'RxGesture'
  pod "ViewAnimator"
  pod 'SDWebImage'
  pod 'XCoordinator'
  pod 'SwiftyBeaver'
  pod 'ReachabilitySwift'
  
  # RC Core
  pod 'RongCloudIM/IMKit'
  pod 'RCMusicControlKit'
  pod 'RongCloudRTC/RongRTCPlayer'
  
  # Scene
  pod 'RCVoiceRoomLib', '2.0.8.2'
  pod 'RCLiveVideoLib', '2.1.0.2'
  pod 'RCChatroomSceneKit'
  
  # Local Pod
  pod 'RCVoiceRoomCallKit', :path => 'Lib/RCVoiceRoomCallKit'
  pod 'RCSceneRoomSetting', :path => 'Feature/RCSceneRoomSetting'
  pod 'RCSceneMessage', :path => 'Feature/RCSceneMessage'
  
end

target 'RCE' do
  use_frameworks!
  commonPods
  
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

