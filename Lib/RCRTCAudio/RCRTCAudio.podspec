#
# Be sure to run `pod lib lint RCRTCAudio.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RCRTCAudio'
  s.version          = '0.0.1'
  s.summary          = 'Audio record and play.'

  s.description      = <<-DESC
  Audio record and play for RCRTC voice message.
                       DESC

  s.homepage         = 'https://github.com/a1252425/RCRTCAudio'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'a1252425' => 'shaoshuai@rongcloud.cn' }
  s.source           = { :git => 'https://github.com/a1252425/RCRTCAudio.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  
  s.source_files = 'RCRTCAudio/Classes/**/*'
  
end
