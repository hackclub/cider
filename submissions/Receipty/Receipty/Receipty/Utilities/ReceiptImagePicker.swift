//
//  ReceiptImagePicker.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//

import SwiftUI
import UIKit

// A SwiftUI wrapper for UIImagePickerController
struct ReceiptImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var completion: (UIImage) -> Void

    @Environment(\.presentationMode) private var presentationMode

    // Create a coordinator to handle the image picker events
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Create the UIImagePickerController and set its delegate
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    // Required method, but no update logic is needed
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    // Coordinator class to handle UIImagePickerController delegate methods
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ReceiptImagePicker

        init(_ parent: ReceiptImagePicker) {
            self.parent = parent
        }

        // Called when an image is picked
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.completion(uiImage)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        // Called when the picker is cancelled
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
