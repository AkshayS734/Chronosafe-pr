//
//  ImagePicker.swift
//  Chronosafe
//
//  Created by Akshay Shukla on 24/07/25.
//

import UIKit
import SwiftUI
struct ImageVideoPicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let mediaType: CapsuleMediaType 
    let completion: (URL?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.mediaTypes = mediaType == .image ? ["public.image"] : ["public.movie"]
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImageVideoPicker
        
        init(_ parent: ImageVideoPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if parent.mediaType == .image {
                if let imageURL = info[.imageURL] as? URL {
                    // Works for images picked from photo library
                    parent.completion(imageURL)
                } else if let image = info[.originalImage] as? UIImage {
                    // Fallback for camera captures (no imageURL)
                    if let data = image.jpegData(compressionQuality: 0.9) {
                        let filename = UUID().uuidString + ".jpg"
                        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
                        do {
                            try data.write(to: fileURL)
                            print("Saved captured image to temp: \(fileURL.path)")
                            parent.completion(fileURL)
                        } catch {
                            print("Failed to save captured image: \(error)")
                            parent.completion(nil)
                        }
                    } else {
                        print("Failed to convert image to JPEG")
                        parent.completion(nil)
                    }
                } else {
                    print("No image found")
                    parent.completion(nil)
                }
            } else if parent.mediaType == .video, let videoURL = info[.mediaURL] as? URL {
                parent.completion(videoURL)
            } else {
                parent.completion(nil)
            }
            
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.completion(nil)
            picker.dismiss(animated: true)
        }
    }
}
