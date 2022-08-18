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

struct AttachmentsPopupElementView: View {
    typealias AttachmentImage = (attachment:PopupAttachment, image:UIImage?)

    var popupElement: AttachmentsPopupElement

    @State var attachmentImages = [AttachmentImage]()
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    /// If `true`, the gallery will display as if the device is in a regular-width orientation.
    /// If `false`, the gallery will display as if the device is in a compact-width orientation.
    var isRegularWidth: Bool {
        !(horizontalSizeClass == .compact && verticalSizeClass == .regular)
    }
    
    @State var loadingAttachments = true
    
    init(
        popupElement: AttachmentsPopupElement,
        popup: Popup
    ) {
        self.popupElement = popupElement
        //        self.popup = popup
        //        _attachmentHelper = StateObject(wrappedValue: AttachmentHelper(feature: popup.geoElement as? ArcGISFeature))
    }
    
    var body: some View {
        VStack {
            PopupElementHeader(
                title: popupElement.title,
                description: popupElement.description
            )
            Spacer()
            if loadingAttachments {
                ProgressView()
            } else if popupElement.attachments.count == 0 {
                Text("No attachments.")
            }
            else {
                switch popupElement.displayType {
                case .list:
                    //                    AttachmentPreview(attachments: attachmentHelper.attachments, images: attachmentHelper.attachmentImages)
                    AttachmentList(attachmentImages: attachmentImages)
                case.preview:
                    //                    AttachmentPreview(attachments: attachmentHelper.attachments, images: attachmentHelper.attachmentImages)
                    AttachmentList(attachmentImages: attachmentImages)
                case .auto:
                    if isRegularWidth {
                        AttachmentPreview(attachmentImages: attachmentImages)
                    } else {
                        AttachmentList(attachmentImages: attachmentImages)
                    }
                }
            }
        }
        .task {
            try? await popupElement.fetchAttachments()
            
            await withTaskGroup(of: AttachmentImage.self) { group in
                for attachment in popupElement.attachments {
                    group.addTask {
                        if attachment.kind == .image {
                            let image = try? await attachment.makeFullImage()
                            return (attachment,image)
                        }
                        else {
                            
                        }
//                        let data = try? await attachment.fetchData()
//                        if let data = data, let image = UIImage(data: data) {
//                            return (attachment,image)
//                        }
                        return (attachment, nil)
                    }
                }
                for await pair in group {
                    attachmentImages.append(pair)
                }
            }
            
            loadingAttachments = false
            
            
            //            attachments.forEach { attachment in
            //                Task {
            //                    let data = try? await attachment.fetchData()
            //                    if let data = data, let image = UIImage(data: data) {
            //                        attachmentImages.append(image)
            //                    }
            //                }
            //            }
            //            loadingAttachments = false
        }
    }
    
    struct AttachmentList: View {
        var attachmentImages: [AttachmentImage]
        //        let attachments: [Attachment]
        //        let images: [UIImage]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                //                if images.count != 2 {
                //                    EmptyView()
                //                }
                //                else {
                //                    ForEach(0..<2) { i in
                //                    ForEach(attachmentImages) { attachmentImage in
                //                        HStack {
                //                            Image(uiImage: attachmentImage.image)
                //                                .resizable()
                //                                .aspectRatio(contentMode: .fit)
                //                                .clipShape(RoundedRectangle(cornerRadius: 8))
                //                                .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                //                                .frame(width: 75, height: 75, alignment: .center)
                //                            Text(attachmentImage.attachment.name)
                //                        }
                //                    }
                //                }
            }
        }
    }
    
    struct AttachmentPreview: View {
        var attachmentImages: [AttachmentImage]
        
        var body: some View {
            VStack(alignment: .center) {
                //                ForEach(0..<attachments.count) { i in
                ////                ForEach(attachments) { attachment in
                //                    HStack {
                //                        Spacer()
                //                        VStack {
                //                            if i < images.count {
                //                                Image(uiImage: images[i])
                //                                    .resizable()
                //                                    .aspectRatio(contentMode: .fit)
                //                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                ////                                    .frame(width: 75, height: 75, alignment: .center)
                //                            }
                //                            Text(attachments[i].name)
                //                        }
                //                        Spacer()
                //                    }
                //                }
            }
        }
    }
}

extension Attachment: Identifiable {}

@MainActor class AttachmentHelper: ObservableObject {
    var feature: ArcGISFeature?
    @Published var attachments = [Attachment]()
    @Published var attachmentImages = [UIImage]()
    
    init(feature: ArcGISFeature?) {
        self.feature = feature
        if let feature = feature {
            Task {
                try await fetchAttachments(for: feature)
                attachments.forEach { attachment in
                    Task {
                        let data = try? await attachment.fetchData()
                        if let data = data, let image = UIImage(data: data) {
                            attachmentImages.append(image)
                        }
                    }
                }
            }
        }
    }
    
    // TODO: taking info from Ryan and come up with API for fetching attachment file urls
    // TODO: update Visual Code tooling from README and generate stuff for all but attachments(?)
    // TODO: look at notes and follow up
    // TODO: look at prototype implementations and update if necessary
    // TODO: Goal is to have all done on Monday (or at least all but attachments).
    
    func fetchAttachments(for feature: ArcGISFeature) async throws {
        print("fetching attachments")
        attachments = try await feature.fetchAttachments()
    }
}
