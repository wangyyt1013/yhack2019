platform :ios, '9.0'

target 'yhack2019' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for yhack2019
  pod 'MessageKit'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'Firebase/Firestore'
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          if target.name == 'MessageKit'
              target.build_configurations.each do |config|
                  config.build_settings['SWIFT_VERSION'] = '4.0'
              end
          end
      end
  end

  target 'yhack2019Tests' do
    inherit! :search_paths
    # Pods for testing
  end

end
