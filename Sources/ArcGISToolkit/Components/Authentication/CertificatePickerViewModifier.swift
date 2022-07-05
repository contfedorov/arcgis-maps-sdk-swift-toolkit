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
import UniformTypeIdentifiers

final private class CertificatePickerViewModel: ObservableObject {
    let challengingHost: String
    let challenge: QueuedNetworkChallenge
    
    @Published var certificateURL: URL?
    @Published var password: String = ""
    @Published var certificateImportFailed = false
    
    init(challenge: QueuedNetworkChallenge) {
        self.challenge = challenge
        challengingHost = challenge.networkChallenge.host
    }
    
    @MainActor
    func signIn() {
        guard let certificateURL = certificateURL else {
            preconditionFailure()
        }
        
        Task {
            do {
                challenge.resume(with: .useCredential(try .certificate(at: certificateURL, password: password)))
            } catch {
                // TODO: Why is this required?
                try await Task.sleep(nanoseconds: 1_000_000_000)
                certificateImportFailed = true
                certificateURL = nil
                password = ""
            }
        }
    }
    
    func cancel() {
        challenge.resume(with: .cancelAuthenticationChallenge)
    }
}

struct CertificatePickerViewModifier: ViewModifier {
    init(challenge: QueuedNetworkChallenge) {
        viewModel = CertificatePickerViewModel(challenge: challenge)
    }
    
    @ObservedObject private var viewModel: CertificatePickerViewModel
    
    // TODO: These should be in the view model?
    @State var showPrompt: Bool = true
    @State var showPicker: Bool = false
    @State var showPassword: Bool = false

    func body(content: Content) -> some View {
        content
            .alert("Error importing certificate", isPresented: $viewModel.certificateImportFailed) {
                Button("Try Again") {
                    showPicker = true
                }
                Button("Cancel", role: .cancel) {
                    viewModel.cancel()
                }
            } message: {
                Text("The certificate file or password was invalid.")
            }
            .promptBrowseCertificate(
                isPresented: $showPrompt,
                host: viewModel.challengingHost,
                onContinue: {
                    showPrompt = false
                    showPicker = true
                }, onCancel: {
                    showPrompt = false
                    viewModel.cancel()
                }
            )
            .sheet(isPresented: $showPicker) {
                DocumentPickerView(contentTypes: [.pfx]) {
                    viewModel.certificateURL = $0
                    showPicker = false
                    showPassword = true
                } onCancel: {
                    showPicker = false
                    viewModel.cancel()
                }
                .edgesIgnoringSafeArea(.bottom)
                .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showPassword) {
                EnterPasswordView(password: $viewModel.password) {
                    showPassword = false
                    viewModel.signIn()
                } onCancel: {
                    showPassword = false
                    viewModel.cancel()
                }
                .edgesIgnoringSafeArea(.bottom)
                .interactiveDismissDisabled()
            }
//            .sheet(isPresented: $viewModel.showError) {
//                Text("Error importing certificate. The certificate file or password was invalid.")
//            }

    }
}

private extension UTType {
    static let pfx = UTType(filenameExtension: "pfx")!
}

private extension View {
    @ViewBuilder
    func promptBrowseCertificate(
        isPresented: Binding<Bool>,
        host: String,
        onContinue: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        alert("Certificate Required", isPresented: isPresented, presenting: host) { _ in
            Button("Browse For Certificate") {
                onContinue()
            }
            Button("Cancel", role: .cancel) {
                onCancel()
            }
        } message: { _ in
            Text("A certificate is required to access content on \(host).")
        }
    }
}

struct EnterPasswordView: View {
    @Binding var password: String
    var onContinue: () -> Void
    var onCancel: () -> Void
    @FocusState var isPasswordFocused: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack {
                        //person
                        Text("Please enter a password for the chosen certificate.")
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }

                Section {
                    SecureField("Password", text: $password)
                        .focused($isPasswordFocused)
                        .textContentType(.password)
                        .submitLabel(.go)
                        .onSubmit { onContinue() }
                }
                .autocapitalization(.none)
                .disableAutocorrection(true)

                Section {
                    okButton
                }
            }
            .navigationTitle("Certificate")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
            }
            .onAppear {
                // Workaround for Apple bug - FB9676178.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isPasswordFocused = true
                }
            }
        }
    }
    
    private var okButton: some View {
        Button(action: {
            onContinue()
        }, label: {
            Text("OK")
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.white)
        })
        .disabled(password.isEmpty)
        .listRowBackground(!password.isEmpty ? Color.accentColor : Color.gray)
    }
}
