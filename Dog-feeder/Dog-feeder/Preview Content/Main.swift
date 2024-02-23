//
//  Main.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 11.01.24.
//

import SwiftUI
import FirebaseAuth

struct Main: View {
    @StateObject private var mqttManager = MQTTManager()
    @State private var showProfile = false
    @State private var showAddFood = false
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea(.all)
            VStack {
                HStack{
                    MQTT_connection(mqttManager: mqttManager)
                    ProfileButton(showProfile: $showProfile)
                }
                Spacer()
                AddFoodView(showAddFood: $showAddFood)
                FoodWaterView(percentageFood: 60, percentageWater: 100)
                Spacer()
                NotificationListView()
            }
        }
        
        .navigationDestination(isPresented: $showProfile) {
            Profile()
        }
        .navigationDestination(isPresented: $showAddFood) {
            AddFood()
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
    
    var body: some View {
        HStack{
            Spacer()
            Button(action: {
                showProfile = true
            }) {
                Image("Profile")
                    .resizable()
                    .frame(width: 95.0, height: 75.0)
                    .padding(.top, 10)
            }
        }
    }
}

struct AddFoodView: View {
    @Binding var showAddFood: Bool
    let first_color = Color(#colorLiteral(red: 0.54299438, green: 0.9728057981, blue: 0.4297943115, alpha: 1))
    let second_color = Color(#colorLiteral(red: 0.399361372, green: 0.9747387767, blue: 0.2709077001, alpha: 1))
    
    var body: some View {
        ZStack{
            Circle()
                .stroke(lineWidth: 20)
                .foregroundColor(.gray)
                .opacity(0.1)
                .frame(width: 160, height: 160)
            
            Circle()
                .stroke(
                    style: StrokeStyle(lineWidth: 15.0,
                            lineCap: .round,
                            lineJoin: .round))
                .foregroundStyle(LinearGradient(gradient: Gradient (colors: [Color(first_color), Color(second_color)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing))
                .rotationEffect((Angle(degrees: 270)))
                .frame(width: 160, height: 160)
                
            
            Button("schedule" + "\n" + "next meal"){
                showAddFood = true
            }
            .bold()
            .foregroundColor(Color("Text"))
            .multilineTextAlignment(.center)
            .font(.system(size: 25))
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
    @State var notifications: [String] = []

    var body: some View {
        List {
            Section(header: Text("Notifications")) {
                ForEach(notifications, id: \.self) { message in
                    Text(message)
                }
            }
        }
        .frame(height: 270)
        .scrollContentBackground(.hidden)
        .onAppear {
            fetchNotifications { fetchedNotifications, error in
                if let fetchedNotifications = fetchedNotifications {
                    self.notifications = fetchedNotifications
                } else if let error = error {
                    // Handle error
                    print("Error fetching notifications: \(error.localizedDescription)")
                }
            }
        }
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
