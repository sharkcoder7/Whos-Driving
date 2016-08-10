platform :ios, "8.0"
use_frameworks!
link_with 'whos-driving-staging', 'whos-driving-production'

pod 'Analytics'
pod 'Segment-Mixpanel'

def testing_pods
    pod 'Quick', '~> 0.8.0'
    pod 'Nimble', '4.0.1'
end

target 'whos-drivingTests' do
    testing_pods
end
