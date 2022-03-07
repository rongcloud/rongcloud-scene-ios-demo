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
  pod 'RxGesture'
  pod "ViewAnimator"
  pod 'SDWebImage'
  pod 'XCoordinator'
  pod 'SwiftyBeaver'
  pod 'ReachabilitySwift'
  
  # RC Core
  pod 'RongCloudIM/IMKit'
  pod 'RCMusicControlKit'
  
  pod 'RongCloudRTC/RongRTCLib'
  pod 'RongCloudRTC/RongRTCPlayer'
  
  # Local Pod
  
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

target 'RCSceneFoundation' do
  use_frameworks!
  pod 'SwiftyBeaver'
end

target 'RCSceneModular' do
  use_frameworks!
  pod 'RongCloudIM/IMLib'
  pod 'RCChatroomSceneKit'
end

target 'RCSceneService' do
  use_frameworks!
  pod 'Moya'
  pod 'ReachabilitySwift'
end

target 'RCSceneMusic' do
  use_frameworks!
  pod 'RCMusicControlKit'
  pod 'SVProgressHUD'
  pod 'Alamofire'
  pod 'RongCloudRTC/RongRTCLib'
end

target 'RCSceneChat' do
  use_frameworks!
  pod 'SVProgressHUD'
  pod 'RongCloudIM/IMKit'
end

target 'RCSceneMessage' do
  use_frameworks!
  pod 'RongCloudIM/IMLib'
end

target 'RCSceneRoomSetting' do
  use_frameworks!
  pod 'SnapKit'
  pod 'Reusable'
  pod 'R.swift'
end

target 'RCSceneGift' do
  use_frameworks!
  pod 'Moya'
  pod 'SnapKit'
  pod 'R.swift'
  pod 'Reusable'
  pod 'Kingfisher'
  pod 'SVProgressHUD'
  
  pod 'RongCloudIM/IMLib'
end

target 'RCSceneCall' do
  use_frameworks!
  pod 'ReactorKit'
  pod 'Reusable'
  pod 'RxDataSources'
  pod 'SVProgressHUD'
  pod 'SnapKit'
  pod 'R.swift'
  pod 'Kingfisher'
  pod 'Moya'
  pod 'RCVoiceRoomCallKit',
#    :git => 'ssh://gerrit.rongcloud.net:29418/rcvoiceroomcallkit-ios'
    :path => 'Lib/RCVoiceRoomCallKit'
end

target 'RCSceneVideoRoom' do
  use_frameworks!
  pod 'IQKeyboardManager'
  pod 'Moya'
  pod 'R.swift'
  pod 'Kingfisher'
  pod 'SnapKit'
  pod 'Reusable'
  pod 'SVProgressHUD'
  pod 'UMCommon'
  pod 'Bugly'
  pod 'Pulsator'
  pod 'MJRefresh'
  pod "ViewAnimator"
  pod 'SDWebImage'
  pod 'XCoordinator'
  pod 'ReachabilitySwift'
  
  # RC Core
  pod 'RongCloudIM/IMKit'
  pod 'RCMusicControlKit'
  
  pod 'RongCloudRTC/RongRTCLib'
  pod 'RongCloudRTC/RongRTCPlayer'
  
  pod 'RCChatroomSceneKit'
  pod 'RCLiveVideoLib', '2.1.0.2'
end

target 'RCSceneVoiceRoom' do
  use_frameworks!
  pod 'IQKeyboardManager'
  pod 'Moya'
  pod 'R.swift'
  pod 'Kingfisher'
  pod 'SnapKit'
  pod 'Reusable'
  pod 'SVProgressHUD'
  pod 'Pulsator'
  pod 'MJRefresh'
  pod 'XCoordinator'
  pod 'ReachabilitySwift'
  
  # RC Core
  pod 'RongCloudIM/IMKit'
  pod 'RCMusicControlKit'
  pod 'RCChatroomSceneKit'
  
  pod 'RCVoiceRoomLib',
    :git => 'ssh://gerrit.rongcloud.net:29418/rcvoiceroomlib-ios'
    
end

target 'RCSceneRadioRoom' do
  use_frameworks!
  pod 'IQKeyboardManager'
  pod 'Moya'
  pod 'R.swift'
  pod 'Kingfisher'
  pod 'SnapKit'
  pod 'Reusable'
  pod 'SVProgressHUD'
  pod 'UMCommon'
  pod 'Bugly'
  pod 'Pulsator'
  pod 'MJRefresh'
  pod "ViewAnimator"
  pod 'SDWebImage'
  pod 'XCoordinator'
  pod 'SwiftyBeaver'
  pod 'ReachabilitySwift'
  pod 'XCoordinator'
  
  # RC Core
  pod 'RongCloudIM/IMKit'
  pod 'RCMusicControlKit'
  pod 'RCChatroomSceneKit'
  
  pod 'RongCloudRTC/RongRTCPlayer'
  
  pod 'RCVoiceRoomLib',
    :git => 'ssh://gerrit.rongcloud.net:29418/rcvoiceroomlib-ios'
  
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
  end
 end
end
