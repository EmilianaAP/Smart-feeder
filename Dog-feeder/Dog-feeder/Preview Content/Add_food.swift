//
//  Add_food.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 14.02.24.
//

import SwiftUI

struct Add_food: View {
    @State private var picked_time = Date()
    
    var body: some View {
        ZStack{
            Color("Background").ignoresSafeArea(.all)
            VStack{
                Text("Select time for your pet's next meal")
                    .bold()
                    .padding(.bottom, 40)
                    .font(.system(size: 20))
                
                DatePicker("Please enter a date", selection: $picked_time, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                Button("Add feeding") {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "hh:mm"
                    let formatted_time = formatter.string(from: picked_time)
                    print(formatted_time)
                }
                .padding([.leading, .trailing], 38)
                .padding([.top, .bottom], 5)
                .background(Color("Buttons.Login-Register"))
                .foregroundColor(.white)
                .cornerRadius(22)
                .font(.system(size: 20))
            }
        }
    }
}

#Preview {
    Add_food()
}
