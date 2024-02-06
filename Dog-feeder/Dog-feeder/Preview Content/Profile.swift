//
//  Profile.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 11.01.24.
//

import SwiftUI

struct Profile:View {
    var name: String = "Erix"
    var bread: String = "Snauchzer"
    var age: String = "3"
    var sex: String = "♂︎"
    var weight: String = "20.5"
    var location: String = "Sofia, Bulgaria"
    
    var body: some View {
        ZStack{
            Color("Background").ignoresSafeArea(.all)
            VStack{
                Text(name + " " + sex) //switch to dog name from firebase
                    .bold()
                    .font(.system(size: 36))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                
                Text("📍" + location)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .bottom], 10)
                
                HStack(spacing: 20) {
                    Text("Age: \n" + age + " years")
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], 20)
                        .padding([.top, .bottom], 40)
                        .background(Color("Buttons.Login-Register"))
                        .foregroundColor(.white)
                        .cornerRadius(22)
                    
                    Text("Bread: \n" + bread)
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], 20)
                        .padding([.top, .bottom], 40)
                        .background(Color("Buttons.Login-Register"))
                        .foregroundColor(.white)
                        .cornerRadius(22)
                    
                    Text("Weight: \n" + weight + " kg")
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], 20)
                        .padding([.top, .bottom], 40)
                        .background(Color("Buttons.Login-Register"))
                        .foregroundColor(.white)
                        .cornerRadius(22)
                }
            }
        }
    }
}

#Preview {
    Profile()
}
