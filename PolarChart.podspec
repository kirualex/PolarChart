Pod::Spec.new do |spec|

    spec.name = 'PolarChart'
    spec.version = '1.0.0'
    spec.requires_arc = true
    spec.summary = 'Interactive and customizable Polar Chart'
    spec.homepage = 'http://github.com/kirualex/PolarChart'
    spec.authors = { 'Alexis Creuzot' => 'alexis@monoqle.fr' }
    spec.license = { :type => 'MIT' , :file => "LICENSE"}
    spec.source = { :git => 'https://github.com/kirualex/PolarChart.git', :tag => spec.version}
    spec.platforms = { :ios => '8.0' }
    spec.framework = 'UIKit'
    spec.dependency 'ios-curve-interpolation', '1.0.0'
    spec.source_files = [ 'polarchart/PolarView/*.swift' ]

end