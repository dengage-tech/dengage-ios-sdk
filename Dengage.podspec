Pod::Spec.new do |s|
  s.name             = 'Dengage'
  s.version          = '5.13.2'
  s.summary          = 'Dengage SDK'
  s.description      = 'Customer Driven Marketing with built-in Customer Data Platform powered by full marketing automation capabilities'
  s.homepage         = 'https://github.com/dengage-tech/dengage-ios-sdk'
  s.license          = 'Dengage'
  s.author           = { 'development@dengage.com' => 'development@dengage.com' }
  s.source           = { :git => 'https://github.com/dengage-tech/dengage-ios-sdk.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/Dengage/**/*'
  s.pod_target_xcconfig = { 'PRODUCT_BUNDLE_IDENTIFIER': 'com.dengage.dengageFramework' }
  s.requires_arc     = true
end
