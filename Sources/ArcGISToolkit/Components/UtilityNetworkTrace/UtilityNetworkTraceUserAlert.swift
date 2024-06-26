// Copyright 2022 Esri
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

import SwiftUI

/// A user presentable alert.
struct UtilityNetworkTraceUserAlert {
    /// Title of the alert.
    var title: String = String(
        localized: "Error",
        bundle: .toolkitModule,
        comment: "A label in reference to an error that occurred during a utility network trace."
    )
    
    /// Description of the alert.
    var description: String
    
    /// An additional action to be taken on the alert.
    var button: Button<Text>?
}

extension UtilityNetworkTraceUserAlert {
    static var startingLocationNotDefined: Self {
        .init(
            description: String(
                localized: "Please set at least 1 starting location.",
                bundle: .toolkitModule,
                comment: """
                         A label indicating that at least one starting location is required for the
                         chosen utility network trace configuration.
                         """
            )
        )
    }
    
    static var startingLocationsNotDefined: Self {
        .init(
            description: String(
                localized: "Please set at least 2 starting locations.",
                bundle: .toolkitModule,
                comment: """
                         A label indicating that at least two starting locations are required for the
                         chosen utility network trace configuration.
                         """
            )
        )
    }
    
    static var duplicateStartingPoint: Self {
        .init(
            title: String(
                localized: "Failed to set starting point",
                bundle: .toolkitModule,
                comment: """
                         A message indicating that the chosen utility network element wasn't able
                         to be used as a trace starting point.
                         """
            ),
            description: String(
                localized: "Duplicate starting points cannot be added.",
                bundle: .toolkitModule,
                comment: """
                         A message indicating that the user attempted to use a single utility
                         network element for more than one trace starting point.
                         """
            )
        )
    }
    
    static var noTraceTypesFound: Self {
        .init(
            description: String(
                localized: "No trace types found.",
                bundle: .toolkitModule,
                comment: "A label indicating that no utility named trace configurations are available."
            )
        )
    }
    
    static var noUtilityNetworksFound: Self {
        .init(
            description: String(
                localized: "No utility networks found.",
                bundle: .toolkitModule,
                comment: "A label indicating that no utility networks are available."
            )
        )
    }
    
    static var unableToIdentifyElement: Self {
        .init(
            description: String(
                localized: "Element could not be identified.",
                bundle: .toolkitModule,
                comment: """
                         A label indicating an element could not be identified as a starting point
                         for a utility network trace.
                         """
            )
        )
    }
}
