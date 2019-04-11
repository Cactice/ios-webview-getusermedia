# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'


pre_install do |installer|
    # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
    Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end

target 'webview-getusermedia' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  # Pods for webview-getusermedia
  pod 'AppRTC'
end
