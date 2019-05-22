Pod::Spec.new do |s|
	s.name = "KMSXmlProcessor"
	s.version = "2.0.0"
	s.summary = "A simple model used to parse and serialize simple XMLs."
	s.homepage = "https://github.com/Azureblade3808/KMSXmlProcessor"
	s.license = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
	s.author = { "Azureblade3808" => "17433201@qq.com" }
	s.platform = :ios, :osx
	s.ios.deployment_target = "8.0"
	s.osx.deployment_target = "10.9"
	s.source = { :git => "https://github.com/Azureblade3808/KMSXmlProcessor.git", :tag => "v2.0.0" }
	s.source_files = "main*/code/**/*"
end
