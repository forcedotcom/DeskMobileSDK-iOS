Pod::Spec.new do |s|
  s.name         = "DeskKit"
  s.version      = "1.2.3"
  s.summary      = "A framework that makes it easy to incorporate your Desk site’s support portal into your iOS app."
  s.license      = { :type => 'BSD 3-Clause', :file => 'DeskKit/LICENSE.txt' }
  s.homepage     = "https://github.com/forcedotcom/DeskMobileSDK-iOS"
  s.author       = { 'Salesforce, Inc.' => 'mobile@desk.com' }
  s.source       = { :git => "https://github.com/forcedotcom/DeskMobileSDK-iOS.git", :tag => '1.2.3' }
  s.platform     = :ios, '8.0'
  s.source_files = 'DeskKit/DeskKit/*.{h,m}', 'DeskKit/DeskKit/**/*.{h,m}'
  s.resources 	 = 'DeskKit/DeskKit/**/*.{png,storyboard}'
  s.requires_arc = true
  s.dependency 'DeskAPIClient', '~> 1.1.4'
end
