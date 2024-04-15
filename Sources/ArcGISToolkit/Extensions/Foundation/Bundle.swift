// Copyright 2023 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

private class BundleFinder {}

extension Bundle {
    /// The identifier for the ArcGISToolkit module.
    static var toolkitIdentifier: String { "com.esri.ArcGISToolkit" }

    #if SWIFT_PACKAGE
    /// The toolkit module, which is either the resource bundle or the
    /// ArcGISToolkit framework, depending on how the toolkit was built.
    static let toolkitModule = Bundle(identifier: toolkitIdentifier) ?? .module
    #else
    static let toolkitModule = Bundle(for: BundleFinder.self).path(forResource: "ArcGISToolkitResources-2", ofType: "bundle").flatMap(Bundle.init(path:))
    #endif
}
