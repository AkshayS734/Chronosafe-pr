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
        init(_ parent: ImageVideoPicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if parent.mediaType == .image, let imageURL = info[.imageURL] as? URL {
                parent.completion(imageURL)
            } else if parent.mediaType == .video, let videoURL = info[.mediaURL] as? URL {
                parent.completion(videoURL)
            } else {
                parent.completion(nil)
            }
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.completion(nil)
        }
    }
}
