Pod::Spec.new do |s|
s.name         = 'Ease'
s.version      = '3.1.0'
s.ios.deployment_target = '9.0'
s.summary      = 'Its magic'
s.description  = <<-DESC
Ease is an event driven animation system that combines the observer pattern with custom spring animations as observers.
DESC
s.homepage           = 'https://github.com/roberthein/Ease'
s.license            = { :type => 'MIT', :file => 'LICENSE' }
s.author             = { 'Robert-Hein Hooijmans' => 'rh.hooijmans@gmail.com' }
s.social_media_url   = 'https://twitter.com/roberthein'
s.source             = { :git => 'https://github.com/roberthein/Ease.git', :tag => s.version.to_s }
s.source_files       = 'Ease/Classes/**/*.{swift}'
end
