platform :ios, '10.0'
workspace 'githot'

use_frameworks!

target 'githot' do    
	pod 'ReactiveCocoa', '~> 7.0'
    pod 'MarkdownView'
    pod 'WebLinking'
end

target 'githotTests' do
	pod 'ReactiveCocoa', '~> 7.0'
    pod 'Quick', :git => 'https://github.com/Quick/Quick.git', :branch => 'master'
    pod 'Nimble', :git => 'https://github.com/Quick/Nimble.git', :branch => 'master'
end

# Manually making Quick and Nimble compiler version be swift 3.2
post_install do |installer|
    print "Quick and Nimble workarounds:\n"
    print "Changing swift version to 3.2\n"
    print "Setting ONLY_ACTIVE_ARCH = NO and DEFINES_MODULE = YES\n"
    installer.pods_project.targets.each do |target|
        if target.name == 'Quick' || target.name == 'Nimble'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
                config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
                config.build_settings['DEFINES_MODULE'] = 'YES'
            end
        end
    end
end

