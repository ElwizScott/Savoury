//
//  TimerScreen.swift
//  Savoury
//
//  Created by Kien Le on 29/8/24.
//

import SwiftUI

/// This view make use of the custom layout provided in the lectorial code example in example 9, week 4 to resemble the twist timer appears in most of the kitchen ware.
struct TimerView: View {
    
    /// Track where the TimerScreen was launched from
    @Binding var isTimerViewVisible: Bool
    
    /// Controls when the alert is shown
    @State private var showAlert = false
    
    /// Detect light or dark mode
    @Environment(\.colorScheme) var colorScheme

    /// Default to seconds, can change as needed
    @State private var selectedTimeUnit: TimeUnit = .sec
    @State private var currentAngle: Angle = .degrees(0)
    @State private var finalAngle: Angle = .degrees(0)
    @State private var isTimerRunning: Bool = false
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var totalTimeInSeconds: Int = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    /// New state to track if the timer has started
    @State private var hasTimerStarted: Bool = false
    
    /// Gesture state to track the state of the long press and drag gesture for rotating the timer needle.
    @GestureState private var rotateState = RotateState.inactive
    
    /// Minimum and maximum rotation angles for the timer needle.
    let minRotation: Angle = .degrees(0)
    let maxRotation: Angle = .degrees(270)
    
    var body: some View {
        ZStack {
            /// Adapt the background color based on the system's color scheme
            (colorScheme == .dark ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                // Top navigation bar
                HStack {
                    Button(action: {
                        isTimerViewVisible = false  // Hide TimerScreen
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.black)
                            .bold()
                            .padding()
                            .background(Circle()
                                .fill(Color.yellow)
                                .shadow(radius: 4))
                    }
                    Spacer()
                }
                
                Text(timeString())  // Use the combined time
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)  // Dynamically change based on mode
                    .padding(30)
                
                ZStack {
                    //Rotating Circle
                    ZStack {
                        Circle()
                            .stroke(Color.black, lineWidth: 3)
                            .frame(width: 160, height: 160)
                            .background(Circle().fill(Color.yellow))
                            .shadow(radius: 5)
                        // Timer needle
                        VStack {
                            Rectangle()
                                .fill(colorScheme == .dark ? Color.white : Color.black)
                                .frame(width: 8, height: 25)
                                .cornerRadius(4.0)
                            Spacer()
                        }
                        .frame(height: 140)
                    }
                    .opacity(rotateState.isPressing ? 0.5 : 1.0)
                    .rotationEffect(currentAngle + finalAngle)
                    .gesture(
                        LongPressGesture(minimumDuration: 0.5)  // Long press for 0.5 seconds
                            .sequenced(before: DragGesture())   // Sequence: First long press, then drag
                            .updating($rotateState) { value, state, _ in
                                switch value {
                                case .first(true):   // Detect long press
                                    state = .pressing  // Update the state to pressing
                                case .second(true, let dragValue):
                                    if let dragValue = dragValue {
                                        let center = CGPoint(x: 80, y: 80)  // Assuming the circle's center is at (80, 80)
                                        let vector = CGVector(dx: dragValue.location.x - center.x, dy: dragValue.location.y - center.y)
                                        var angle = atan2(vector.dy, vector.dx) * 180 / .pi  // Get the angle in degrees
                                        
                                        if angle < 0 {
                                            angle += 360  // Normalize the angle
                                        }
                                        
                                        DispatchQueue.main.async {
                                            currentAngle = .degrees(angle)
                                            convertRotationToTime(currentAngle)
                                        }
                                    }
                                default:
                                    break
                                }
                            }
                            .onEnded { value in
                                if case .second(true, _) = value {
                                    finalAngle += currentAngle
                                    DispatchQueue.main.async {
                                        currentAngle = .degrees(0)  // Reset the angle after dragging ends
                                    }
                                }
                            }
                    )

       
                    RadialLayout {
                        ForEach(0..<7, id: \.self) { index in
                            VStack {
                                Text("\(index * 10)")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Spacer()
                            }
                             // Adjusts the spacing from the center
                        }
                    }
                    .frame(width: 340, height: 280)
                    .padding(.top, 10)
                    
                    RadialLayout {
                        ForEach(0..<7, id: \.self) {_ in
                            Circle()
                                .frame(width: 9, height: 10)
                                .shadow(radius: 5)
                        }
                    }
                    .frame(width: 260)
                    
                    
                }
                
                Spacer()
                
                VStack {
                    TimeSelection(selectedTimeUnit: $selectedTimeUnit)
                    
                    Spacer()
                    
                    // Reset and Start buttons
                    HStack {
                        Button(action: {
                            resetTimer() // Action for Reset button
                        }) {
                            Text("Reset")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 10)
                                .background(Capsule()
                                    .fill(Color.yellow)
                                    .frame(height: 50)
                                    .shadow(radius: 4))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            startTimer() // Action for Start button
                        }) {
                            Text("Start")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 10)
                                .background(Capsule()
                                    .fill(Color.yellow)
                                    .frame(height: 50)
                                    .shadow(radius: 4))
                        }
                    }

                }
                .frame(width: 320)
            }
            .padding()
            // Show alert when time reaches zero
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Time's Up!"),
                    message: Text("The countdown has reached 00:00:00."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onReceive(timer) { _ in
                if isTimerRunning && totalTimeInSeconds > 0 {
                    totalTimeInSeconds -= 1
                    
                    // Update the hours, minutes, and seconds
                    hours = totalTimeInSeconds / 3600
                    minutes = (totalTimeInSeconds % 3600) / 60
                    seconds = totalTimeInSeconds % 60
                } else if totalTimeInSeconds == 0 && hasTimerStarted {
                    // Only show the alert if the timer has started and finished counting down
                    isTimerRunning = false
                    showAlert = true  // Trigger the alert when the timer reaches 0
                    hasTimerStarted = false  // Reset the flag
                }
            }
        }
    }
    
    /// Helper to convert an angle to time in seconds
    func convertRotationToTime(_ angle: Angle) {
        let totalDegrees = maxRotation.degrees - minRotation.degrees
        let rotationDegrees = (finalAngle.degrees + angle.degrees).truncatingRemainder(dividingBy: 360)
        
        // Reset to 0 if it's between 270 and 360 degrees
        if rotationDegrees > 270 {
            updateSelectedTimeUnit(with: 0)
            return
        }
        
        let percentageRotation = max(0, min(rotationDegrees / totalDegrees, 1))
        
        let timeValue = Int(percentageRotation * 60)  // Based on a 60-second rotation
        
        // Update the selected time unit
        updateSelectedTimeUnit(with: timeValue)
    }

    /// Helper method to update the selected time unit (hours, minutes, or seconds). The time is updated based on the selected unit.
    func updateSelectedTimeUnit(with value: Int) {
        switch selectedTimeUnit {
        case .hour:
            hours = value
        case .min:
            minutes = value
        case .sec:
            seconds = value
        }
    }
    
    /// Helper to format the time in HH:MM:SS format
    func timeString() -> String {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    /// Method to start the timer countdown. This function initializes the timer with the selected time (hours, minutes, seconds) and starts the countdown.
    func startTimer() {
        currentAngle = .degrees(0)
        finalAngle = .degrees(0)
        
        // Only start the timer if there's a non-zero time set
        if hours > 0 || minutes > 0 || seconds > 0 {
            isTimerRunning = true
            hasTimerStarted = true  // Mark that the timer has started
            
            // Combine hours, minutes, and seconds into total seconds
            totalTimeInSeconds = (hours * 3600) + (minutes * 60) + seconds
            
            // Start the countdown using TimerPublisher
            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        }
    }


    /// Method to reset the timer to its initial state. This function stops the timer and resets the hours, minutes, seconds, and rotation angles.
    func resetTimer() {
        isTimerRunning = false
        hours = 0
        minutes = 0
        seconds = 0
        currentAngle = .degrees(0)
        finalAngle = .degrees(0)
    }
}

/// Enum to track the state of the rotation gesture (inactive, pressing, or rotating). This enum is used to handle different states of user interaction with the timer's rotating gesture.
enum RotateState {
    case inactive
    case pressing
    case rotating(angle: Angle)
    
    var isPressing: Bool {
        switch self {
        case .pressing, .rotating:
            return true
        case .inactive:
            return false
        }
    }
    
    var angle: Angle {
        switch self {
        case .rotating(let angle):
            return angle
        default:
            return .degrees(0)
        }
    }
}


struct TimerScreen_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(isTimerViewVisible: .constant(true))
    }
}

// MARK: Modified RadialLayout
struct RadialLayout: Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()) -> CGSize {
            proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()) {
        
        let radius = bounds.width / 2.5 // Adjusted radius to fit the design better
        let angle = Angle.degrees(315.0 / Double(subviews.count)).radians
        
        for (index, subview) in subviews.enumerated() {
            var point = CGPoint(x: 0, y: -radius).applying(CGAffineTransform(rotationAngle: angle * Double(index)))
            point.x += bounds.midX
            point.y += bounds.midY
            
            subview.place(at: point, anchor: .center, proposal: .unspecified)
        }
    }
}

