#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
# Run `pod lib lint flutter_bucketeer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'bucketeer_flutter_client_sdk'
  s.version          = '0.0.1' # x-release-please-version
  s.summary          = 'Bucketeer Feature Flag & A/B Testing Service for Flutter'
  s.homepage         = 'https://bucketeer.io/'
  s.license          = { :type => "Apache License, Version 2.0", :file => '../LICENSE' }
  s.author           = { 'Bucketeer team' => 'bucketeer@cyberagent.co.jp' }
  s.source           = { :http => "https://github.com/bucketeer-io/flutter-client-sdk", }

  s.source_files      = 'Classes/**/*.{h,m,swift}'
  s.dependency 'Flutter'
  s.dependency 'Bucketeer', '2.1.4'
  s.platform = :ios, '11.0'

  s.ios.deployment_target = "11.0"
  s.tvos.deployment_target = "11.0"
  s.swift_version = "5.0"

  s.requires_arc = false
end
