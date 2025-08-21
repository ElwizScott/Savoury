import SwiftUI
import Auth0


/// This view to create attractive login screen only, most of the logic inside are for animation and the authentication code is from:
///https://auth0.com/blog/get-started-ios-authentication-swift-swiftui-part-1-login-logout/#Install--Auth0-swift
struct UserAuthenticationView: View {
    
    /// Icons array holding system names for images used in the view
    var icons = ["frying.pan", "carrot", "fork.knife", "camera", "fish", "fossil.shell"]
    
    /// State variable to manage authentication status
    @State private var isAuthenticated = false
    
    /// State variable to hold user profile data
    @State var userProfile = Profile.empty
    
    /// State variable for controlling the rotation of icons
    @State private var rotationDegrees = 0.0
    
    /// State variable for dynamic y-offset to animate the icons vertically
    @State private var yOffset: CGFloat = -100
    
    /// Timer to periodically change the yOffset for animation
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        // Display content based on authentication status
        if isAuthenticated {
            // Shows user profile if authenticated
            VStack {
                HomeView(username: userProfile.name)
            }
        } else {
            // Layout for login and registration if not authenticated
            VStack {
                Spacer()
                ZStack {
                    // Loop through the icons for animation
                    ForEach(icons.indices, id: \.self) { index in
                        Image(systemName: icons[index])
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .background(Circle().fill(Color.yellow))
                            .foregroundColor(.black)
                            .offset(x: 0, y: yOffset)  // Apply dynamic y-offset
                            // Apply rotation effect based on index and rotationDegrees
                            .rotationEffect(.degrees(Double(index) * (360 / Double(icons.count)) + rotationDegrees))
                            .onAppear {
                                // Animation for rotation
                                withAnimation(Animation.linear(duration: 4).repeatForever(autoreverses: false)) {
                                    rotationDegrees = 360
                                }
                            }
                    }
                    // Image for the login art
                    Image("loginArt")
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 300, height: 300)
                // Receive timer updates to toggle yOffset for vertical animation
                .onReceive(timer) { _ in
                    withAnimation(.easeInOut(duration: 1)) {
                        yOffset = yOffset == -100 ? -150 : -100
                    }
                }
                Spacer()
                // Branding text
                Text("Savoury")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                Text("Snap and Cook.")
                    .font(.subheadline)
                    .fontWeight(.thin)
                    .foregroundColor(.black)
                Spacer()
                // Login button
                Button("Log in") {
                    login()
                }
                .font(.title2)
                .fontWeight(.medium)
                .padding()
                .background(Color.yellow)
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                Spacer()
            }
        }
    }

    /// Function to handle login using Auth0
    func login() {
        Auth0
            .webAuth()
            .start { result in
                switch result {
                case .failure(let error):
                    print("Failed with: \(error)")
                case .success(let credentials):
                    self.isAuthenticated = true
                    self.userProfile = Profile.from(credentials.idToken)
                    print("Credentials: \(credentials)")
                    print("ID token: \(credentials.idToken)")
                }
            }
    }

    /// Function to handle logout using Auth0
    func logout() {
        Auth0
            .webAuth()
            .clearSession { result in
                switch result {
                case .success:
                    self.isAuthenticated = false
                    self.userProfile = Profile.empty
                case .failure(let error):
                    print("Failed with: \(error)")
                }
            }
    }
}

struct UserAuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        UserAuthenticationView()
    }
}
