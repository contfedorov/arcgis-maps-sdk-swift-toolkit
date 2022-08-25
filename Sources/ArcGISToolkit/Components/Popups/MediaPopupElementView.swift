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

import SwiftUI
import ArcGIS

/// A view displaying a `MediaPopupElement`.
struct MediaPopupElementView: View {
    /// The `PopupElement` to display.
    var popupElement: MediaPopupElement
    
    var body: some View {
        PopupElementHeader(
            title: popupElement.title,
            description: popupElement.description
        )
        .padding([.bottom], 4)
        PopupMediaView(popupMedia: popupElement.media)
    }
    
    /// A view displaying an array of `PopupMedia`.
    struct PopupMediaView: View {
        /// The popup media to display.
        let popupMedia: [PopupMedia]
        
        /// The width of the view content.
        @State private var viewWidth: CGFloat = .zero
        
        var body: some View {
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 8) {
                    ForEach(popupMedia) { media in
                        Group {
                            switch media.kind {
                            case .image:
                                ImageMediaView(popupMedia: media)
                            case .barChart, .columnChart, .lineChart, .pieChart:
                                ChartMediaView(popupMedia: media)
                            default:
                                EmptyView()
                            }
                        }
                        .frame(width: viewWidth * widthScaleFactor)
                        .clipped()
                    }
                }
            }
            .onSizeChange {
                viewWidth = $0.width
            }
        }
        
        /// The scale factor for specifying the width of popup media.  If there is only one popup media,
        /// the scale is 1.0 (full width); if there is more than one, the scale is 0.85, which allows for
        /// second and subsequent media to be partially visible, to indicate there is more than one.
        var widthScaleFactor: Double {
            get {
                popupMedia.count > 1 ? 0.85 : 1
            }
        }
    }
}

extension PopupMedia: Identifiable {}
