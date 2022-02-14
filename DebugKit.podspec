#
# Be sure to run `pod lib lint DebugKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'DebugKit'
s.version          = '1.0.0'
s.summary          = 'A simple, flexible way to build a debugging menu inside an application.'

s.description      = <<-DESC
This framework is designed to make the tedious process of building and adding content to a debug menu much quicker. It includes functionality to build simple information and actions into the menu, as well as integrate with several system processes (like notifications and metrics).
DESC

s.homepage          = 'https://github.com/BottleRocketStudios/iOS-DebugKit'
s.license           = { :type => 'Apache 2.0', :file => 'LICENSE' }
s.author            = { 'Bottle Rocket Studios' => 'will.mcginty@bottlerocketstudios.com' }
s.source            = { :git => 'https://github.com/bottlerocketstudios/iOS-DebugKit.git', :tag => s.version.to_s }
s.source_files      = 'Sources/**/*'
s.ios.deployment_target = '14.0'
s.swift_version = '5.5'
s.frameworks = 'SwiftUI', 'UIKit', 'MetricKit', 'UserNotifications', 'CryptoKit'

end
