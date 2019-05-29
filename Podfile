# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'CWall' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CWall
  pod 'SwiftyJSON', '~>4.x'
  pod 'Alamofire'
  pod 'Alamofire-SwiftyJSON', '~>3.x'
  pod 'SVProgressHUD'
  pod 'MapboxNavigation', '~> 0.32.0'
  pod 'Mapbox-iOS-SDK', '~> 4.10'
  pod 'MapboxGeocoder.swift', '~> 0.10'
  pod 'SwiftValidator', :git => 'https://github.com/jpotts18/SwiftValidator.git', :tag => '4.2.0'

end

# Workaround for Cocoapods issue #7606
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end