//
//  TabBarView.swift
//  Savoury
//
//  Created by Kien Le on 27/8/24.
//

// Checked by An 1/9/24

import SwiftUI

/// A SwiftUI view representing a custom tab bar for the application.
/// The tab bar allows navigation between different sections of the app, including special handling for the camera and timer tabs for now and will be update soon.
struct TabBar: View {
    
    /// Binding to control the visibility of the screens.
    @Binding var showTimerScreen: Bool
    @Binding var showSearchIngredients: Bool
    @Binding var showFavoriteView: Bool
    @Binding var showCameraView: Bool
    
    /// State variable to track the currently selected tab, defaulting to the home tab.
    @State var selectedTab: Tab = .home
    
    /// Detect light or dark mode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack {
                Spacer()
                
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button(action: {
                        if tab == .bookmark {
                            showFavoriteView = true
                        }
                        else if tab == .camera {
                            showCameraView = true
                        }
                        else if tab == .cooking {
                            showSearchIngredients = true
                        }
                        else if tab == .timer {
                            showTimerScreen = true
                        } else {
                            selectedTab = tab
                        }
                    }) {
                        Image(systemName: tab.iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 26, height: 26)
                            .padding()
                            .background(
                                Circle()
                                    .fill(selectedTab == tab ? Color.yellow : Color.clear)
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                
                Spacer()
                
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 0)
            .background(
                RoundedRectangle(cornerRadius: 40)
                    .fill(colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.1)) // Brighter background in dark mode
                    .frame(height: 60)
                    .padding(.horizontal, 20)
            )
            .padding(.bottom, -10)
        }
    }
}

struct CustomTabView_Previews: PreviewProvider {
    static var previews: some View {
        TabBar(showTimerScreen: .constant(false), showSearchIngredients: .constant(false),
               showFavoriteView: .constant(false), showCameraView: .constant(false))
    }
}
