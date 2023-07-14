// Copyright 2023 Esri.

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
import FormsPlugin
import SwiftUI

public class FormViewModel: ObservableObject {
    /// The geodatabase which holds the table and feature being edited in the form.
    @Published private(set) var database: ServiceGeodatabase?
    
    /// The featured being edited in the form.
    @Published private(set) var feature: ArcGISFeature?
    
    /// The structure of the form.
    @Published var formDefinition: FeatureFormDefinition?
    
    /// The service feature table which holds the feature being edited in the form.
    @Published private(set) var table: ServiceFeatureTable?
    
    /// Initializes a form view model.
    public init() {}
    
    /// Prepares the feature for editing in the form.
    /// - Parameter feature: The feature to be edited in the form.
    public func startEditing(_ feature: ArcGISFeature) {
        self.feature = feature
        if let table = feature.table as? ServiceFeatureTable {
            self.database = table.serviceGeodatabase
            self.table = table
        }
    }
    
    /// Undos any local edits that haven't yet been saved to service geodatabase.
    public func undoEdits() {
        Task {
            try? await database?.undoLocalEdits()
        }
    }
    
    /// Submit the changes made to the form.
    public func submitChanges() async {
        print(#function)
    }
}
