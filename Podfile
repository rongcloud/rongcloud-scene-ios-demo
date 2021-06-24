# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
inhibit_all_warnings!

target 'RCE' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
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
  pod 'Pecker'
  pod 'RCVoiceRoomLib'
  pod 'RongCloudIM/IMKit'

  # Pods for RCE

  target 'RCETests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'RCEUITests' do
    inherit! :search_paths
    # Pods for testing
  end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
  end
 end
end
  
end
