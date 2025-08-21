//
//  CulinaryPreferencesView.swift
//  Savoury
//
//  Created by An Luu on 23/9/24.
//

import SwiftUI

/// This SwiftUI view is designed to guide users through setting up their dietary preferences and allergen alerts.
/// It features an introductory screen that leads to the SetupPreferencesView for detailed preference configuration.
struct CulinaryPreferencesView: View {
    
    /// Binding to control the visibility of this view from the home view.
    @Binding var showCulinaryPreferencesView: Bool
    
    /// Binding to pass the user's name across views.
    @Binding var userName_homeview: String

    /// State variable to manage the display of the next screen, which is the SetupPreferencesView.
    @State var showSetUp = false

    var body: some View {
        NavigationView{
            VStack{
                HStack{
                    Text("Help Savoury understand your culinary preferences")
                        .font(.title)
                        .fontWeight(.heavy)
                        .frame(width: 300)
                        .padding(.leading)
                        .padding(.top)
                    Spacer()
                }
                HStack{
                    Text("Complete these steps to set up your dietary and allergies")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .frame(width: 200)
                        .padding(.horizontal,25)
                    Spacer()
                }
                Spacer()
                Image("guyCooking")
                    .padding()
                Spacer()
                NavigationLink(destination: SetupPreferencesView(username: $userName_homeview, showSetUp: $showSetUp)){
                    Text("Next")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 200, height: 20)
                        .padding()
                        .foregroundColor(.black)
                        .background(Color.yellow)
                        .cornerRadius(10.0)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    CulinaryPreferencesView(showCulinaryPreferencesView: .constant(true), userName_homeview: .constant("Dummy"))
}
