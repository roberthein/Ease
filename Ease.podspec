Pod::Spec.new do |s|
s.name         = 'Ease'
s.version      = '1.0.0'
s.ios.deployment_target = '9.0'
s.summary      = 'Animate everything with Ease'
s.description  = <<-DESC
Ease is a event driven animation system.
DESC
s.homepage           = 'https://github.com/roberthein/Ease'
s.license            = { :type => 'MIT', :file => 'LICENSE' }
s.author             = { 'Robert-Hein Hooijmans' => 'rh.hooijmans@gmail.com' }
s.social_media_url   = 'https://twitter.com/roberthein'
s.source             = { :git => 'https://github.com/roberthein/Ease.git', :tag => s.version.to_s }
s.source_files       = 'Ease/Classes/**/*.{swift}'
end
