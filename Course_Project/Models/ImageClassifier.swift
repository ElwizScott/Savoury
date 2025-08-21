//
//  ImageClassifier.swift
//  Savoury
//
//  Created by Kien Le on 10/10/24.
//

import SwiftUI
import Vision

/// The ImageClassifier class is an ObservableObject, meaning it can be observed by SwiftUI views to automatically update the UI when the data changes.
class ImageClassifier: ObservableObject {
    
    /// Published property that stores an instance of the Classifier struct. Since this is marked as @Published, SwiftUI views will automatically update when this property changes.
    @Published private var classifier = Classifier()
    
    /// Expose all classification results
    var allImageClasses: [(identifier: String, confidence: VNConfidence)] {
        classifier.allResults
    }
        
    // MARK: Intent(s)
    func detect(uiImage: UIImage) {
        guard let ciImage = CIImage (image: uiImage) else { return }
        classifier.detect(ciImage: ciImage)
        
    }
        
}
