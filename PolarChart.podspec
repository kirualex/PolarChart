Pod::Spec.new do |spec|

    spec.name = 'PolarChart'
    spec.version = '0.1'
    spec.summary = 'Interactive and customizable Polar Chart'
    spec.homepage = 'http://github.com/kirualex/PolarChart'
    spec.authors = { 'Alexis Creuzot' => 'alexis@monoqle.fr' }
    spec.license = { :type => 'MIT' }
    spec.source = { :git => 'https://github.com/kirualex/PolarChart.git'}
    spec.platforms = { :ios => '8.0' }
    spec.dependency 'ios-curve-interpolation', 'https://github.com/kirualex/ios-curve-interpolation.git'
    spec.source_files = [ 'PolarView/*.swift' ]

end