# GooglePolyline

GooglePolyline is a Swift package that provides functionality for encoding and decoding polylines as per Google's Encoded Polyline Algorithm. It offers the ability to simplify the polyline with a specified simplification factor, which can either be a direct value or automatically calculated based on a desired maximum length.

## Features
- Encodes an array of `CLLocation` instances into a string that represents a Google Encoded Polyline.
- Decodes a string that represents a Google Encoded Polyline into an array of `CLLocation` instances.
- Decodes a string that represents a Google Encoded Polyline into a `MKPolyline`.
- Simplifies the polyline using the Douglas-Peucker algorithm.

## Installation

### Swift Package Manager
Add the following line to your dependencies in your `Package.swift` file:
```swift
.package(url: "https://github.com/nicolaszimmer/GooglePolyline.git", from: "1.0.0"),
```
Then, include `"GooglePolyline"` as a dependency for your target:
```swift
.target(name: "YourTarget", dependencies: ["GooglePolyline"]),
```
## Usage
Import the package in your Swift file:
```swift
import GooglePolyline
```

Create an instance of `GooglePolyline`:
```swift
let googlePolyline = GooglePolyline()
```

You can then encode and decode polylines as follows:
```swift
let locations: [CLLocation] = ...
let encodedPolyline = googlePolyline.encode(locations: locations)

let decodedLocations = googlePolyline.decode(polyline: encodedPolyline)
let decodedMKPolyline = googlePolyline.decodeToMKPolyline(polyline: encodedPolyline)
```

## Implementation Details
The `GooglePolyline` class provides the primary functionality. You can control the simplification of the polyline by specifying a `SimplificationFactor` when initializing the class. This can be set to `.automatic(maxLength: Int)` to automatically calculate the simplification factor based on a maximum length, or `.value(Double)` to directly set the factor.

The `encode(locations:)` function takes an array of `CLLocation` instances and returns a string representing the Google Encoded Polyline. The `decode(polyline:)` function does the reverse, returning an array of `CLLocation` instances from an encoded polyline string. `decodeToMKPolyline(polyline:)` also decodes the polyline but returns a `MKPolyline` instance.

## Legal
Google is a trademark of Google LLC. This software is neither endorsed nor otherwise related to Google LLC apart from being based on Google's polyline encoding algorithm.
