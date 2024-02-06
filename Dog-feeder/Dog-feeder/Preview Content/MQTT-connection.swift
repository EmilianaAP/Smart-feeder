//
//  MQTT-connection.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 6.02.24.
//

import SwiftUI
import CocoaMQTT

class MQTTManager: ObservableObject {
    private var mqtt: CocoaMQTT?
    
    @Published var isConnected: Bool = false
    @Published var message: String = ""
    
    init() {
        mqtt = CocoaMQTT(clientID: "SwiftUIApp", host: "34.122.107.45", port: 1883)
        mqtt?.username = "Erix"
        mqtt?.password = "!!SmartPet!!"
        mqtt?.delegate = self
    }
    
    func connect() -> Bool {
        mqtt?.connect()
        return mqtt?.connState == .connected
    }
    
    func disconnect() {
        mqtt?.disconnect()
    }
    
    func subscribe(topic: String) {
        mqtt?.subscribe(topic)
    }
    
    func unsubscribe(topic: String) {
        mqtt?.unsubscribe(topic)
    }
    
    func publish(topic: String, message: String) {
        mqtt?.publish(topic, withString: message)
    }
}

extension MQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            isConnected = true
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        // Handle published message if needed
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        // Handle published acknowledgment if needed
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        self.message = message.string ?? ""
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        // Handle subscription success or failure if needed
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        // Handle unsubscription if needed
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        // Handle ping event if needed
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        // Handle pong event if needed
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        isConnected = false
    }
}

struct MQTT_connection: View {
    @ObservedObject var mqttManager = MQTTManager()
    
    var body: some View {
        VStack {
            if mqttManager.isConnected {
                Text("Connected to MQTT Broker")
            } else {
                Text("Disconnected from MQTT Broker")
            }
            
            Text("Received Message: \(mqttManager.message)")
            
            Button(action: {
                if mqttManager.connect() {
                    print("Connected successfully")
                } else {
                    print("Failed to connect")
                }
            }) {
                Text("Connect")
            }
            
            Button(action: {
                mqttManager.subscribe(topic: "/test_1")
            }) {
                Text("Subscribe")
            }
            
            Button(action: {
                mqttManager.unsubscribe(topic: "/test_1")
            }) {
                Text("Unsubscribe")
            }
        }
    }
}

#Preview {
    MQTT_connection()
}
