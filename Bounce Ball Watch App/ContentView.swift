//
//  ContentView.swift
//  Bounce Ball Watch App
//
//  Created by masbek mbp-m2 on 28/07/23.
//

import SwiftUI
import CoreMotion
import WatchKit

struct ContentView: View {
    @State private var gyroData: CMRotationRate? = nil // Use optional for gyroData
    @State private var objPosition : CGPoint = CGPoint(x: 150, y: 150)
    
    let motionManager = CMMotionManager()
    
    var body: some View {
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
    private func updateFrameSize(with size: CGSize) {
        let frameWidth = size.width
        let frameHeight = size.height
        
        let newX = min(max(objPosition.x, 0), frameWidth)
        let newY = min(max(objPosition.y, 0), frameHeight)
        
        objPosition = CGPoint(x: newX, y: newY)
    }
    
    private func updateObjPosition(with motion: CMDeviceMotion) {
        let gravity = motion.gravity
        
        // You can adjust these multipliers to change the sensitivity of the movement
        let xMultiplier: CGFloat = 12
        let yMultiplier: CGFloat = 12
        
        let newX = objPosition.x + CGFloat(gravity.x) * xMultiplier
        let newY = objPosition.y - CGFloat(gravity.y) * yMultiplier // Invert the y-axis for correct movement
        
        let screenBounds = WKInterfaceDevice.current().screenBounds
        let frameWidth = screenBounds.width
        let frameHeight = screenBounds.height
        // Ensure the new position is within the frame's bounds
        let circleSize: CGFloat = 50
        let minX = circleSize / 2
        let maxX = frameWidth - circleSize / 2
        let minY = circleSize / 2
        let maxY = frameHeight - circleSize / 2
        
        objPosition.x = min(max(newX, minX), maxX)
        objPosition.y = min(max(newY, minY), maxY)
        if(objPosition.x == minX || objPosition.x == maxX || objPosition.y == minY || objPosition.y == maxY) {
            print("kenak edges")
            WKInterfaceDevice.current().play(.click)
        }
        //        print(objPosition.x, objPosition.y)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
