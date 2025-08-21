//
//  ImagePicker.swift
//  Savoury
//
//  Created by An Luu on 9/10/24.
//

import SwiftUI
import UIKit


struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var uiImage: UIImage?
    @Binding var isPresenting: Bool
    @Binding var sourceType: UIImagePickerController.SourceType
    
    /*
        The provided Swift function, makeUIViewController(context: Context) -> UIImagePickerController, is part of SwiftUI's integration with UIKit through the UIViewControllerRepresentable protocol. It initializes and configures an instance of UIImagePickerController, setting its source type for picking media and assigning a delegate from the SwiftUI context to manage user interactions like image selection or cancellation.
     */
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
    
    /*
     It defines UIImagePickerController as the type of UIKit view controller being managed. The makeCoordinator() function creates a coordinator object, which serves as an intermediary handling interactions and delegate callbacks between the UIKit component and the SwiftUI environment.
     */
    
    typealias UIViewControllerType = UIImagePickerController
        
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /*
      The class handles image selection and cancellation actions within the picker. The coordinator uses callback functions to update the state of the ImagePicker view based on user actions: when an image is selected, it stores the image in the view and dismisses the picker; when the picker is canceled, it simply dismisses the picker. The Coordinator is initialised with a reference to its parent ImagePicker view, allowing it to modify the view's properties directly.
     */
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        let parent: ImagePicker
                
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.uiImage = info[.originalImage] as? UIImage
            parent.isPresenting = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresenting = false
        }
        
        init(_ imagePicker: ImagePicker) {
            self.parent = imagePicker
        }
        
    }
    
    
}
