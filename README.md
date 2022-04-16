# Plaist for iOS
## Requirements
- Swift 5.x and Xcode 13.x
- SwiftUI 
- iOS 13 ~

## Prerequsite 
NaverMapSDK, SwiftUIPager, SDWebImage, BottomSheet

## Installation guide

You should do both installation.

### Pod
Write `Podfile` as below:
```
# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'place-kr-app' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for place-kr-app
  pod 'naveridlogin-sdk-ios'
  pod 'NMapsMap'
	
end
```
In the Podfile directory, type:
```
$ pod install
```

### SPM

In the Xcode, add those packages using Swift Package Manager:
- https://github.com/SDWebImage/SDWebImageSwiftUI
- https://github.com/lucaszischka/BottomSheet
- https://github.com/fermoya/SwiftUIPager




