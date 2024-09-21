//
//  OSCManager.swift
//  MotionSensor_POC
//
//  Created by apple  on 21/09/24.
//

import Foundation
import SwiftOSC

let serverIP = "192.168.178.116"

class OSCManager {

    private var client: OSCClient
//    var server: OSCServer
    private let port: Int

    init(port: Int) {
        self.port = port
        
        // Initialize OSC Client with localhost (127.0.0.1) and port
        self.client = OSCClient(address: serverIP, port: port)
        
        // test on local app
//        // Initialize OSC Server and listen on the same port
//        self.server = OSCServer(address: "", port: port)
//
//        // Start the server
//        startServer()
    }

    // test on local app
//    func startServer() {
//        server.start()
//        server.delegate = self
//        print("OSC Server started on port \(port)")
//    }

    func sendOSCMessage(address: OSCAddressPattern, arguments: [OSCType]) {
        // Create OSC message with the given address and arguments
        let message = OSCMessage(address, arguments)
        
        // Send the OSC message using the client
        client.send(message)
//        print("\nOSC Message sent to address  ::\n\(address) with arguments: \(arguments)")
    }
}

// // Test on local app
//extension OSCManager: OSCServerDelegate {
//
//    func didReceive(_ message: OSCMessage) {
//        // Handle the incoming OSC message here
//        print("\nOSC Message received at address::\n \(message.address) with arguments: \(message.arguments)")
//    }
//}
