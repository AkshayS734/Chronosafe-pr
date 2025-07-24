import SwiftUI
import PhotosUI
import AVFoundation
import AVKit

struct NewCapsuleView: View {
    var onSave: ((Capsule) -> Void)? = nil
    @Environment(\.presentationMode) private var presentationMode
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var unlockDate: Date = Date().addingTimeInterval(3600)
    @State private var media: [CapsuleMedia] = []
    @State private var showImagePicker = false
    @State private var showVideoPicker = false
    @State private var showAudioRecorder = false
    @State private var showTextInputBar = false
    @State private var newText: String = ""
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var selectedVideo: PhotosPickerItem? = nil
    @State private var isSaving = false
    @State private var showValidation: Bool = false
    @State private var showImageActionSheet = false
    @State private var showVideoActionSheet = false
    @State private var showAudioActionSheet = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var videoPickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showUIKitImagePicker = false
    @State private var showUIKitVideoPicker = false
    @State private var pickedMediaType: CapsuleMediaType? = nil
    @State private var pickedSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var pickedMediaURL: URL? = nil
    @State private var showAudioRecorderBar = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var isRecording = false
    @State private var audioRecordingURL: URL? = nil
    @State private var audioRecordingError: String? = nil
    // For demo, audio recording is not implemented
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Capsule Info Section as native Form (full width, no background)
                Form {
                    Section(header: Text("Capsule Info")) {
                        TextField("Title", text: $title)
                            .font(.headline)
                        if showValidation && title.isEmpty {
                            Text("Title is required").foregroundColor(.red).font(.caption)
                        }
                        TextField("Description", text: $description)
                        DatePicker("Unlock Date", selection: $unlockDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    }
                    Section(header: Text("Add Media")) {
                        HStack(spacing: 16) {
                            CapsuleMediaButton(title: "Image", systemImage: "photo", color: .blue) {
                                showImageActionSheet = true
                            }
                            .actionSheet(isPresented: $showImageActionSheet) {
                                ActionSheet(title: Text("Add Image"), buttons: [
                                    .default(Text("Take Photo")) { pickedSourceType = .camera; showUIKitImagePicker = true },
                                    .default(Text("Choose from Library")) { pickedSourceType = .photoLibrary; showUIKitImagePicker = true },
                                    .cancel()
                                ])
                            }
                            CapsuleMediaButton(title: "Video", systemImage: "video", color: .purple) {
                                showVideoActionSheet = true
                            }
                            .actionSheet(isPresented: $showVideoActionSheet) {
                                ActionSheet(title: Text("Add Video"), buttons: [
                                    .default(Text("Record Video")) { pickedSourceType = .camera; showUIKitVideoPicker = true },
                                    .default(Text("Choose from Library")) { pickedSourceType = .photoLibrary; showUIKitVideoPicker = true },
                                    .cancel()
                                ])
                            }
                            CapsuleMediaButton(title: "Audio", systemImage: "mic", color: .orange) {
                                showAudioRecorderBar = true
                            }
                            CapsuleMediaButton(title: "Text", systemImage: "text.bubble", color: .green) {
                                showTextInputBar = true
                            }
                        }
                        // Inline text input bar for text
                        if showTextInputBar {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Enter Text Message")
                                    .font(.headline)
                                TextEditor(text: $newText)
                                    .frame(height: 100)
                                    .border(Color.gray)
                                HStack {
                                    Button("Add") {
                                        let textMedia = CapsuleMedia(type: .text, url: nil, text: newText)
                                        media.append(textMedia)
                                        newText = ""
                                        showTextInputBar = false
                                    }
                                    .disabled(newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                    Button("Cancel") {
                                        showTextInputBar = false
                                        newText = ""
                                    }
                                    .foregroundColor(.red)
                                }
                            }
                            .padding(.top, 8)
                        }
                        // Inline audio recorder bar
                        if showAudioRecorderBar {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Record Audio")
                                    .font(.headline)
                                if let error = audioRecordingError {
                                    Text(error).foregroundColor(.red).font(.caption)
                                }
                                HStack(spacing: 16) {
                                    Button(action: {
                                        if isRecording {
                                            stopRecording()
                                        } else {
                                            startRecording()
                                        }
                                    }) {
                                        Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(isRecording ? .red : .orange)
                                    }
                                    if let url = audioRecordingURL, !isRecording {
                                        Button("Add") {
                                            let audioMedia = CapsuleMedia(type: .audio, url: url, text: nil)
                                            media.append(audioMedia)
                                            audioRecordingURL = nil
                                            showAudioRecorderBar = false
                                        }
                                        Button("Cancel") {
                                            audioRecordingURL = nil
                                            showAudioRecorderBar = false
                                        }
                                        .foregroundColor(.red)
                                    } else {
                                        Button("Cancel") {
                                            audioRecordingURL = nil
                                            showAudioRecorderBar = false
                                            if isRecording { stopRecording() }
                                        }
                                        .foregroundColor(.red)
                                    }
                                }
                                if isRecording {
                                    Text("Recording...").foregroundColor(.orange).font(.caption)
                                } else if audioRecordingURL != nil {
                                    Text("Ready to add recording").foregroundColor(.green).font(.caption)
                                }
                            }
                        }
                    }
                    if !media.isEmpty {
                        Section(header: Text("Attached Media")) {
                            ForEach(media) { item in
                                CapsuleMediaPreview(media: item, onDelete: { media.removeAll { $0.id == item.id } }).listRowInsets(EdgeInsets())
                            }
                        }
                    }
                    // Inline validation for media
                    if showValidation && media.isEmpty {
                        Text("At least one media is required").foregroundColor(.red).font(.caption)
                    }
                }.padding(0)
            }
            .navigationTitle("New Capsule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if onSave != nil {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: saveCapsule) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                                .fontWeight(.bold)
                        }
                    }
                    .disabled(title.isEmpty || media.isEmpty)
                }
            }
            // Image Picker
            .fullScreenCover(isPresented: $showUIKitImagePicker) {
                ImageVideoPicker(sourceType: pickedSourceType, mediaType: .image) { url in
                    if let url = url {
                        let mediaItem = CapsuleMedia(type: .image, url: url, text: nil)
                        media.append(mediaItem)
                    }
                    showUIKitImagePicker = false
                }
            }
            // Video Picker
            .fullScreenCover(isPresented: $showUIKitVideoPicker) {
                ImageVideoPicker(sourceType: pickedSourceType, mediaType: .video) { url in
                    if let url = url {
                        let mediaItem = CapsuleMedia(type: .video, url: url, text: nil)
                        media.append(mediaItem)
                    }
                    showUIKitVideoPicker = false
                }
            }
        }
    }
    
    private func saveCapsule() {
        showValidation = true
        guard !title.isEmpty, !media.isEmpty else { return }
        isSaving = true
        let newCapsule = Capsule(title: title, description: description, unlockDate: unlockDate, media: media)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onSave?(newCapsule)
            title = ""
            description = ""
            unlockDate = Date().addingTimeInterval(3600)
            media = []
            isSaving = false
            showValidation = false
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    // Audio recording helpers
    private func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
            isRecording = true
            audioRecordingURL = nil
            audioRecordingError = nil
        } catch {
            audioRecordingError = "Failed to start recording: \(error.localizedDescription)"
        }
    }
    private func stopRecording() {
        audioRecorder?.stop()
        audioRecordingURL = audioRecorder?.url
        isRecording = false
        audioRecorder = nil
    }
}

struct CapsuleMediaButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(18)
                    .background(color)
                    .clipShape(Circle())
                    .shadow(radius: 2)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
