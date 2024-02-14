//
//  Add_food.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 14.02.24.
//

import SwiftUI

struct Add_food: View {
    @ObservedObject var mqttManager = MQTTManager()
    @State private var picked_time = Date()
    
    var body: some View {
        ZStack{
            Color("Background").ignoresSafeArea(.all)
            VStack{
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
                
                Text("Select time for your pet's next meal")
                    .bold()
                    .padding(.bottom, 40)
                    .font(.system(size: 20))
                
                DatePicker("Please enter a date", selection: $picked_time, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                Button("Add feeding") {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    let formatted_time = formatter.string(from: picked_time)
                    print(formatted_time)
                    
                    mqttManager.publish(topic: "/test_3", message: formatted_time)
                }
                .padding([.leading, .trailing], 38)
                .padding([.top, .bottom], 5)
                .background(Color("Buttons.Login-Register"))
                .foregroundColor(.white)
                .cornerRadius(22)
                .font(.system(size: 20))
            }
        }
        .onAppear{
            mqttManager.connect()
        }
    }
}

#Preview {
    Add_food()
}
