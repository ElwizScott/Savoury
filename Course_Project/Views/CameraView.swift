//
//  ContentView.swift
//  Savoury
//
//  Created by An Luu on 9/10/24.
//

import SwiftUI
import Vision

struct CameraView: View {
    /// Binding to control the visibility of the screens
    @Binding var showCameraView: Bool
    @State private var showSearchIngredients = false
    @State private var openedFromCameraView = false
    /// State to track whether the image picker sheet is presented (used for photo library or camera)
    @State var isPresenting: Bool = false
    
    /// State to store the selected image from the photo library or camera
    @State var uiImage: UIImage?
    
    /// State to store the selected source type (photo library or camera)
    @State var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    /// Array to store detected ingredients (classification results)
    @State var ingredients: [String]
    
    /// ObservedObject that holds the image classifier (used to classify images)
    @ObservedObject var classifier: ImageClassifier
    
    /// Define a confidence threshold of 10%
    private let confidenceThreshold: VNConfidence = 0.1
    
    var body: some View {
        NavigationView {
            VStack{
                Group {
                    // Filter and display only results with confidence >= threshold
                    let filteredResults = classifier.allImageClasses.filter { $0.confidence >= confidenceThreshold }
                    
                    if !filteredResults.isEmpty {
                        VStack {
                            Text("Detected Objects:")
                                .font(.caption)
                            ForEach(filteredResults, id: \.identifier) { result in
                                HStack {
                                    Text(result.identifier)
                                        .bold()
                                }
                            }
                        }
                    } else {
                        HStack{
                            Text("Image categories: NA")
                                .font(.caption)
                        }
                    }
                }
                .font(.subheadline)
                .padding()
                
                Rectangle()
                    .strokeBorder()
                    .foregroundColor(.yellow)
                    .overlay(
                        Group {
                            if uiImage != nil {
                                Image(uiImage: uiImage!)
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                    )
                
                Spacer()
                
                HStack{
                    Button(action: {
                        showCameraView = false
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 60, height: 60) // Circle size
                                .shadow(radius: 3)
                            
                            Image(systemName: "house")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    Button(action: {
                        isPresenting = true
                        sourceType = .photoLibrary
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 60, height: 60) // Circle size
                                .shadow(radius: 3)
                            
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    Button(action: {
                        isPresenting = true
                        sourceType = .camera
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 60, height: 60) // Circle size
                                .shadow(radius: 3)
                            
                            Image(systemName: "camera")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    
                    // Button to navigate to IngredientSelectionView and pass detected ingredients
                    NavigationLink(
                        destination: IngredientSelectionView(
                            showSearchIngredients: $showSearchIngredients,
                            openedFromCameraView: .constant(true),
                            ingredientsFromPhotos: $ingredients
                        )
                        .navigationBarBackButtonHidden(true)
                        .onAppear {
                            // Clear ingredients before adding new ones
                            ingredients.removeAll()
                            
                            // Filter the results and add to ingredients
                            let filteredResults = classifier.allImageClasses.filter { $0.confidence >= confidenceThreshold }
                            
                            for result in filteredResults {
                                ingredients.append(result.identifier)
                            }
                        }
                    ) {
                        Text("Search")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(width: 80, height: 30)
                            .padding()
                            .foregroundColor(.black)
                            .background(Color.yellow)
                            .cornerRadius(50)
                            .shadow(radius: 3)
                    }
                }
                .padding(.top)
                .font(.title)
                .foregroundColor(.blue)
            }
            
            .padding(.horizontal)
            
            // Present the image picker sheet for photo library or camera
            .sheet(isPresented: $isPresenting){
                ImagePicker(uiImage: $uiImage, isPresenting:  $isPresenting, sourceType: $sourceType)
                    .onDisappear{
                        if uiImage != nil {
                            classifier.detect(uiImage: uiImage!)
                        }
                    }
                }
            }
        }
        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(showCameraView: .constant(true), ingredients: [""], classifier: ImageClassifier())
    }
}

