//
//  Main.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 11.01.24.
//

import SwiftUI

struct Main:View {
    @State private var showProfile = false
    var width: CGFloat = 200
    var height: CGFloat = 20
    var percentage_food: CGFloat = 60
    var percentage_water: CGFloat = 100
    var color1_food = Color(#colorLiteral(red: 0.6998714805, green: 0.5057218075, blue: 0.358222723, alpha: 1))
    var color2_food = Color(#colorLiteral(red: 0.4907110929, green: 0.3262205422, blue: 0.2176229954, alpha: 1))
    var color1_water = Color(#colorLiteral(red: 0.813916862, green: 0.9451536536, blue: 0.9344380498, alpha: 1))
    var color2_water = Color(#colorLiteral(red: 0.6889745593, green: 0.9041253924, blue: 0.8708049655, alpha: 1))
    var color1_battery = Color(#colorLiteral(red: 0.54299438, green: 0.9728057981, blue: 0.4297943115, alpha: 1))
    var color2_battery = Color(#colorLiteral(red: 0.399361372, green: 0.9747387767, blue: 0.2709077001, alpha: 1))
    var battery = 80
    
    var body: some View {
        let multiplier = width / 100
        ZStack{
            Color("Background").ignoresSafeArea(.all)
            VStack{
                HStack{
                    Spacer()
                    Button{
                        showProfile = true
                    } label: {
                        Image("Profile")
                            .resizable()
                            .frame(width: 95.0, height: 75.0)
                            .padding(.top, 10)
                    }
                   
                }
                Spacer()
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
                        .foregroundStyle(LinearGradient(gradient: Gradient (colors: [Color(color1_battery), Color(color2_battery)]),
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
                HStack{
                    Image("Food-bowl")
                        .resizable()
                        .frame(width: 75.0, height: 50.0)
                    ZStack(alignment: .leading){
                        RoundedRectangle(cornerRadius: height, style: .continuous)
                            .frame (width: width, height: height)
                            .foregroundColor (Color.black.opacity(0.1))
                        
                        RoundedRectangle(cornerRadius: height, style: .continuous)
                            .frame (width: percentage_food * multiplier, height: height)
                            .background (
                                LinearGradient (gradient: Gradient(colors: [color1_food, color2_food]), startPoint: .leading, endPoint: .trailing)
                                    .clipShape (RoundedRectangle (cornerRadius: height, style: .continuous))
                            )
                            .foregroundColor(.clear)
                    }
                }
                .padding(.bottom, 15)
                
                HStack{
                    Image("Water-bowl")
                        .resizable()
                        .frame(width: 75.0, height: 50.0)
                    ZStack(alignment: .leading){
                        RoundedRectangle(cornerRadius: height, style: .continuous)
                            .frame (width: width, height: height)
                            .foregroundColor (Color.black.opacity(0.1) )
                        
                        RoundedRectangle(cornerRadius: height, style: .continuous)
                            .frame (width: percentage_water * multiplier, height: height)
                            .background (
                                LinearGradient (gradient: Gradient(colors: [color1_water, color2_water]), startPoint: .leading, endPoint: .trailing)
                                    .clipShape(RoundedRectangle (cornerRadius: height, style: .continuous))
                            )
                            .foregroundColor(.clear)
                    }
                }
                Spacer()
                
                List {
                    Section {
                        Text("First Row")
                        Text("Second Row")
                        Text("Third Row")
                    } header: {
                        Text("Notifications")
                    }
                }
                    .frame(height: 240)
                    .scrollContentBackground(.hidden)
            }
            .navigationDestination(
                isPresented: $showProfile) {
                    Profile()
                }
        }
    }
}


#Preview {
    Main()
}
