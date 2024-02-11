//
//  Main.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 11.01.24.
//

import SwiftUI
import FirebaseAuth
import CocoaMQTT
import UserNotifications

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
            mqtt.subscribe("/test_1")
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



struct Main: View {
    @State private var showProfile = false
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color("Background").ignoresSafeArea(.all)
                VStack {
                    HStack{
                        MQTT_connection()
                        ProfileButton(showProfile: $showProfile)
                    }
                    Spacer()
                    BatteryView(battery: 80)
                    FoodWaterView(percentageFood: 60, percentageWater: 100)
                    Spacer()
                    NotificationListView()
                }
            }
            
            .navigationDestination(isPresented: $showProfile) {
                Profile()
            }
        }
    }
}

struct MQTT_connection: View {
    @ObservedObject var mqttManager = MQTTManager()
    
    var body: some View{
        HStack{
            if !mqttManager.isConnected{
                Text("No connection")
                    .foregroundStyle(.red)
                    .bold()
                    .padding(.leading, 25)
                
                Button(action: {
                    mqttManager.connect()
                }) {
                    Image("Refresh")
                        .resizable()
                        .frame(width: 15.0, height: 15.0)
                }
            }
        }
        
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error {
                    print(error.localizedDescription)
                }
            }
            
            mqttManager.connect()
        }
    }
}

struct ProfileButton: View {
    @Binding var showProfile: Bool
    @State private var notification_title: String = "Hello"
    
    var body: some View {
        HStack{
            Spacer()
            Button(action: {
                showProfile = true
                
                let content = UNMutableNotificationContent()
                content.title = notification_title
                content.subtitle = "It looks hungry"
                content.sound = UNNotificationSound.default

                // show this notification five seconds from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                // choose a random identifier
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                // add our notification request
                UNUserNotificationCenter.current().add(request)
            }) {
                Image("Profile")
                    .resizable()
                    .frame(width: 95.0, height: 75.0)
                    .padding(.top, 10)
            }
        }
    }
}

struct BatteryView: View {
    var battery: Int
    var body: some View {
        let first_color = Color(#colorLiteral(red: 0.54299438, green: 0.9728057981, blue: 0.4297943115, alpha: 1))
        let second_color = Color(#colorLiteral(red: 0.399361372, green: 0.9747387767, blue: 0.2709077001, alpha: 1))
        var battery = 80
        ZStack{
            Circle()
                .stroke(lineWidth: 20)
                .foregroundColor(.gray)
                .opacity(0.1)
                .frame(width: 160, height: 160)
            
            Circle()
                .trim(from: 0.0, to: min(CGFloat(battery)/100, 1.0))
                .stroke(
                    style: StrokeStyle(lineWidth: 15.0,
                            lineCap: .round,
                            lineJoin: .round))
                .foregroundStyle(LinearGradient(gradient: Gradient (colors: [Color(first_color), Color(second_color)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing))
                .rotationEffect((Angle(degrees: 270)))
                .frame(width: 160, height: 160)
                
            
            Text(String(battery) + "%")
                .bold()
                .font(.system(size: 40))
        }
        .padding(.bottom, 30)
        .padding(.top, 20)
    }
}

struct FoodWaterView: View {
    var percentageFood: CGFloat
    var percentageWater: CGFloat
    var firstFoodColor = Color(#colorLiteral(red: 0.6998714805, green: 0.5057218075, blue: 0.358222723, alpha: 1))
    var secondFoodColor = Color(#colorLiteral(red: 0.4907110929, green: 0.3262205422, blue: 0.2176229954, alpha: 1))
    var firstWaterColor = Color(#colorLiteral(red: 0.813916862, green: 0.9451536536, blue: 0.9344380498, alpha: 1))
    var secondWaterColor = Color(#colorLiteral(red: 0.6889745593, green: 0.9041253924, blue: 0.8708049655, alpha: 1))
    
    var body: some View {
        VStack(spacing: 15) {
            LevelView(imageName: "Food-bowl", percentage: percentageFood, firstColor: firstFoodColor, secondColor: secondFoodColor)
            LevelView(imageName: "Water-bowl", percentage: percentageWater, firstColor: firstWaterColor, secondColor: secondWaterColor)
        }
        .padding(.bottom, 15)
    }
}

struct LevelView: View {
    var imageName: String
    var percentage: CGFloat
    let width: CGFloat = 200
    let height: CGFloat = 20
    var firstColor: Color
    var secondColor: Color
    
    init(imageName: String, percentage: CGFloat, firstColor: Color, secondColor: Color) {
        self.imageName = imageName
        self.percentage = percentage
        self.firstColor = firstColor
        self.secondColor = secondColor
    }
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .frame(width: 75.0, height: 50.0)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height, style: .continuous)
                    .frame(width: width, height: height)
                    .foregroundColor(Color.black.opacity(0.1))
                RoundedRectangle(cornerRadius: height, style: .continuous)
                    .frame(width: percentage * width / 100, height: height)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [firstColor, secondColor]), startPoint: .leading, endPoint: .trailing)
                            .clipShape(RoundedRectangle(cornerRadius: height, style: .continuous))
                    )
                    .foregroundColor(.clear)
            }
        }
    }
}

struct NotificationListView: View {
    var body: some View {
        List {
            Section(header: Text("Notifications")) {
                ForEach(1..<6) { index in
                    Text("Notification \(index)")
                }
            }
        }
        .frame(height: 270)
        .scrollContentBackground(.hidden)
    }
}

struct Main_Previews: PreviewProvider {
    static var previews: some View {
        Main()
    }
}

#Preview {
    Main()
}
