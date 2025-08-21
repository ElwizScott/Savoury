//
//  Classifier.swift
//  Savoury
//
//  Created by Kien Le on 10/10/24.
//

/*
    Code inspired from:
    https://developer.apple.com/documentation/coreml/model_integration_samples/classifying_images_with_vision_and_core_ml
    
    EXPLANATION:
 
    The Classifier uses a ML model, specifically MobileNetV2, to analyse images represented as CIImage objects. When the detect method is called with an image, it attempts to load the MobileNetV2 model and create a request for it. This request is then handled by a VNImageRequestHandler, which performs the classification on the image. The results of the classification are stored in an array of VNClassificationObservation, from which the identifier of the highest-ranked classification (i.e., the most likely category the image belongs to) is stored in the results property of the Classifier.
 
 */

import CoreML
import Vision
import CoreImage

struct Classifier {
    
    /// Store all classification results as an array of tuples (label, confidence)
        private(set) var allResults: [(identifier: String, confidence: VNConfidence)] = []
    
    
    mutating func detect(ciImage: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: MobileNetV2(configuration: MLModelConfiguration()).model)
        else {
            return
        }
        
        let request = VNCoreMLRequest(model: model)
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        try? handler.perform([request])
        
        guard let results = request.results as? [VNClassificationObservation] else {
            return
        }
        
        /// Store all classification results
        self.allResults = results.map { (identifier: $0.identifier, confidence: $0.confidence) }
    }
    
}

