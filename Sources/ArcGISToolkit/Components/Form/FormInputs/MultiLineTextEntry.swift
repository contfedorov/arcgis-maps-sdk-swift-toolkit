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

import FormsPlugin
import SwiftUI

/// A view for text entry spanning multiple lines.
struct MultiLineTextEntry: View {
    /// The current text value.
    @State private var text: String
    
    /// A `TextAreaFeatureFormInput` which acts as a configuration.
    let input: TextAreaFeatureFormInput
    
    /// Creates a view for text entry spanning multiple lines.
    /// - Parameters:
    ///   - text: The current text value.
    ///   - input: A `TextAreaFeatureFormInput` which acts as a configuration.
    init(text: String, input: TextAreaFeatureFormInput) {
        self.text = text
        self.input = input
    }
    
    public var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
            } else {
                TextEditor(text: $text)
            }
        }
        .background(.clear)
        .frame(minHeight: 100, maxHeight: 200)
        .formTextEntryBorder()
        TextEntryProgress(current: text.count, max: input.maxLength)
    }
}
