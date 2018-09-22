Pod::Spec.new do |s|
  s.name         = "Livr"
  s.version      = "0.0.1"
  s.summary      = "Lightweight validator supporting Language Independent Validation Rules Specification"

  s.homepage     = "https://github.com/marinofelipe/swift-validator-livr"
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "Felipe Lefèvre Marino" => "felipemarino91@gmail.com" }

  s.source       = { :git => "https://github.com/marinofelipe/swift-validator-livr.git", :tag => "#{s.version}" }

  s.ios.deployment_target = '9.0'

  s.swift_version = "4.1"
  s.source_files  = "Livr/**/*.swift"
end
