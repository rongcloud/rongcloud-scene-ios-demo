# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
inhibit_all_warnings!

target 'RCE' do
  use_frameworks!
  # Pods for RCE
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
  pod 'SwiftyBeaver'
  pod 'RxGesture'
  pod "ViewAnimator"
  pod 'SwiftyBeaver'
  
  pod 'RongCloudIM/IMKit'
  pod 'RongCloudRTC/RongRTCLib'
  pod 'RongCloudRTC/RongRTCPlayer'
  
  pod 'RCVoiceRoomCallKit', :path => 'Lib/RCVoiceRoomCallKit'
  pod 'RCVoiceRoomLib'
  pod 'RCRTCAudio', :path => 'Lib/RCRTCAudio'
  
  target 'RCETests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'RCEUITests' do
    inherit! :search_paths
    # Pods for testing
  end
  
end

target 'RCVoiceRoomMessage' do
  use_frameworks!
  pod 'RongCloudIM/IMKit'
  pod 'RCRTCAudio', :path => 'Lib/RCRTCAudio'
#  pod 'ChatRoomScene', :path => 'Lib/ChatRoomScene'
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
  end
 end
end

