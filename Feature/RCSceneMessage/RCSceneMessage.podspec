#
# Be sure to run `pod lib lint RCSceneMessage.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RCSceneMessage'
  s.version          = '0.0.1'
  s.summary          = 'Scene Messages'

  s.description      = <<-DESC
Scene Messages: enter, leave, gift, kick, manager etc.
                       DESC

  s.homepage         = 'https://github.com/rongcloud'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'shaoshuai' => 'shaoshuai@rongcloud.cn' }
  s.source           = { :git => 'https://github.com/rongcloud/rongcloud-scenemessage-ios-sdk.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.static_framework = true
  s.swift_version = '5.0'
  
  s.ios.deployment_target = '11.0'
  
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'VALID_ARCHS' => 'arm64 x86_64',
  }

  s.source_files = 'RCSceneMessage/Classes/**/*'
  
  s.dependency 'RongCloudIM/IMLib'
  
end
