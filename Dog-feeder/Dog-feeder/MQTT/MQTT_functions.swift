//
//  MQTT_functions.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 15.02.24.
//

import Foundation
import CocoaMQTT
import UserNotifications
import FirebaseAuth

class MQTTManager: ObservableObject {
    private var mqtt: CocoaMQTT?
    private var userID = Auth.auth().currentUser!.uid
    @Published var isConnected: Bool = false
    @Published var message: String = ""
    @Published var new_message: [String] = []
    
    init() {
        mqtt = CocoaMQTT(clientID: userID, host: "34.122.107.45", port: 1883)
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
    
    func addMessageToHistory(_ message: String) {
        new_message.append(message)
        print(new_message)
        addNotification(new_message: new_message)
        new_message.removeAll()
    }
}

extension MQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            isConnected = true
            mqtt.subscribe("notifications")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {}
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {}
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        self.message = message.string ?? ""
        addMessageToHistory(self.message)
        
        let content = UNMutableNotificationContent()
        content.title = message.topic
        content.subtitle = message.string ?? ""
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {}
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {}
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {}
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {}
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {isConnected = false}
}
