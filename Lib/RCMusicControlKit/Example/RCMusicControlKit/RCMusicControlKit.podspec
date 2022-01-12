#
#  Be sure to run `pod spec lint RCMusicControlKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name             = 'RCMusicControlKit'
  s.version          = '0.0.1'
  s.summary          = 'RCMusicControlKit for Music.'

  s.description      = <<-DESC
Music Control  Kit.
                       DESC

  s.homepage         = 'https://github.com/rongcloud'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'suixuefeng' => 'suixuefeng@rongcloud.cn' }
  s.source           = { :git => 'https://github.com/rongcloud/rongcloud-livevideo-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'VALID_ARCHS' => 'arm64 x86_64 armv7',
    'ENABLE_BITCODE' => 'NO'
  }

  s.source_files = 'RCMusicControlKit/Classes/**/*'
  
  s.dependency 'Masonry'
  s.dependency 'SDWebImage'
  s.dependency 'YYModel'
  s.dependency 'SVProgressHUD'
  
end
