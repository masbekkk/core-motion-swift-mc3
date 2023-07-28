//
//  ContentView.swift
//  Soccer Shake
//
//  Created by masbek mbp-m2 on 27/07/23.
//

import SwiftUI
import CoreMotion
import AudioToolbox

struct ContentView: View {
    @State private var gyroData: CMRotationRate? = nil // Use optional for gyroData
    @State private var objPosition : CGPoint = CGPoint(x: 150, y: 150)
    
    @State var widthGoal: CGFloat = 0
    
    let motionManager = CMMotionManager()
    
    var body: some View {
        NavigationStack{
//            Rectangle()
//                .fill(.black)
//                .frame(width: widthGoal, height: 50)
            
            GeometryReader { geometry in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 50, height: 50)
                    .position(objPosition)
                    .onAppear {
                        startMotionUpdates()
                    }
            }
        }
        .background(Color.green)
    }
    
    private var gyroDataText: String {
        guard let data = gyroData else {
            return "Not available"
        }
        return String(format: "x: %.2f, y: %.2f, z: %.2f", data.x, data.y, data.z)
    }
    
    private func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable{
            motionManager.deviceMotionUpdateInterval = 0.01 // Set the update interval as needed
            motionManager.startDeviceMotionUpdates(to: .main) { (data, error) in
                if let motion = data {
                    updateObjPosition(with: motion)
                    self.gyroData = motion.rotationRate
                } else {
                    self.gyroData = nil
                }
            }
        }
    }
    
    func triggerVibration() {
        // Check if the device supports haptic feedback (iOS 10+)
        if #available(iOS 10.0, *) {
            // Create a haptic feedback generator
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success) // You can choose different feedback types like .success, .warning, .error
        } else {
            // Fallback to simple vibration (not recommended for iOS 10 and later)
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    private func updateObjPosition(with motion: CMDeviceMotion) {
        let gravity = motion.gravity
        
        // You can adjust these multipliers to change the sensitivity of the movement
        let xMultiplier: CGFloat = 12
        let yMultiplier: CGFloat = 12
        
        let newX = objPosition.x + CGFloat(gravity.x) * xMultiplier
        let newY = objPosition.y - CGFloat(gravity.y) * yMultiplier // Invert the y-axis for correct movement
        
        let frameWidth = UIScreen.main.bounds.width
        let frameHeight = UIScreen.main.bounds.height * 0.9
        
        // Ensure the new position is within the frame's bounds
        let circleSize: CGFloat = 50
        let minX = circleSize / 2
        let maxX = frameWidth - circleSize / 2
        let minY = circleSize / 2
        let maxY = frameHeight - circleSize / 2
        
        objPosition.x = min(max(newX, minX), maxX)
        objPosition.y = min(max(newY, minY), maxY)
        widthGoal += maxX.truncatingRemainder(dividingBy : 3)

        if(objPosition.x == minX || objPosition.x == maxX || objPosition.y == minY || objPosition.y == maxY) {
            print("kenak edges")
            print(objPosition.x, objPosition.y)
            if(objPosition.x == widthGoal)
            {
                print("goal")
            }
//            triggerVibration()
        }
        
               
//        print(widthGoal)
        //        print(objPosition.x, objPosition.y)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
