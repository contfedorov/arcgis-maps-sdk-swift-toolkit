// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import SwiftUI

/// A `Compass` (alias North arrow) shows where north is in a `MapView` or
/// `SceneView`.
public struct Compass: View {
    /// The last time the compass was tapped.
    @State private var lastTapTime: Date?
    
    /// The opacity of the compass.
    @State private var opacity: Double = .zero
    
    /// An action to perform when the compass is tapped.
    private let action: (() async -> Void)?
    
    /// A Boolean value indicating whether  the compass should automatically
    /// hide/show itself when the heading is `0`.
    private let autoHide: Bool
    
    /// A Boolean value indicating whether the compass should hide based on the
    ///  current heading and whether the compass automatically hides.
    private var shouldHide: Bool {
        (heading.isZero || heading.isNaN) && autoHide
    }
    
    /// The width and height of the compass.
    private var size: CGFloat = 44
    
    /// The heading of the compass in degrees.
    @Binding private var heading: Double
    
    /// Creates a compass with a binding to a heading based on compass
    /// directions (0° indicates a direction toward true North, 90° indicates a
    /// direction toward true East, etc.).
    /// - Parameters:
    ///   - heading: The heading of the compass.
    ///   - action: An action to perform when the compass is tapped.
    ///   - autoHide: A Boolean value that determines whether the compass
    ///   automatically hides itself when the heading is `0`.
    public init(
        heading: Binding<Double>,
        action: (() async -> Void)? = nil,
        autoHide: Bool = true
    ) {
        _heading = heading
        self.action = action
        self.autoHide = autoHide
    }
    
    public var body: some View {
        if !heading.isNaN {
            CompassBody()
                .overlay {
                    Needle()
                        .rotationEffect(.degrees(heading))
                }
                .aspectRatio(1, contentMode: .fit)
                .opacity(opacity)
                .frame(width: size, height: size)
                .onAppear { opacity = shouldHide ? 0 : 1 }
                .onChange(of: heading) { _ in
                    let newOpacity: Double = shouldHide ? .zero : 1
                    guard opacity != newOpacity else { return }
                    withAnimation(.default.delay(shouldHide ? 0.25 : 0)) {
                        opacity = newOpacity
                    }
                }
                .onTapGesture { lastTapTime = .now }
                .accessibilityLabel("Compass, heading \(Int(heading.rounded())) degrees \(CompassDirection(heading).rawValue)")
                .task(id: lastTapTime) {
                    if let action {
                        await action()
                    } else {
                        heading = .zero
                    }
                }
        }
    }
}

public extension Compass {
    /// Creates a compass with a binding to a viewpoint rotation (0° indicates
    /// a direction toward true North, 90° indicates a direction toward true
    /// West, etc.).
    /// - Parameters:
    ///   - viewpointRotation: The viewpoint rotation whose value determines the
    ///   heading of the compass.
    ///   - action: An action to perform when the compass is tapped.
    ///   - autoHide: A Boolean value that determines whether the compass
    ///   automatically hides itself when the viewpoint rotation is 0 degrees.
    init(
        viewpointRotation: Binding<Double>,
        action: (() async -> Void)? = nil,
        autoHide: Bool = true
    ) {
        let heading = Binding(get: {
            viewpointRotation.wrappedValue.isZero ? .zero : 360 - viewpointRotation.wrappedValue
        }, set: { newHeading in
            viewpointRotation.wrappedValue = newHeading.isZero ? .zero : 360 - newHeading
        })
        self.init(heading: heading, action: action, autoHide: autoHide)
    }
    
    /// Creates a compass with a binding to an optional viewpoint.
    /// - Parameters:
    ///   - viewpoint: The viewpoint whose rotation determines the heading of the compass.
    ///   - action: An action to perform when the compass is tapped.
    ///   - autoHide: A Boolean value that determines whether the compass automatically hides itself
    ///   when the viewpoint's rotation is 0 degrees.
    init(
        viewpoint: Binding<Viewpoint?>,
        action: (() async -> Void)? = nil,
        autoHide: Bool = true
    ) {
        let viewpointRotation = Binding {
            viewpoint.wrappedValue?.rotation ?? .nan
        } set: { newViewpointRotation in
            guard let oldViewpoint = viewpoint.wrappedValue else { return }
            viewpoint.wrappedValue = Viewpoint(
                center: oldViewpoint.targetGeometry.extent.center,
                scale: oldViewpoint.targetScale,
                rotation: newViewpointRotation
            )
        }
        self.init(viewpointRotation: viewpointRotation, action: action, autoHide: autoHide)
    }
    
    /// Define a custom size for the compass.
    /// - Parameter size: The width and height of the compass.
    func compassSize(size: CGFloat) -> Self {
        var copy = self
        copy.size = size
        return copy
    }
}
