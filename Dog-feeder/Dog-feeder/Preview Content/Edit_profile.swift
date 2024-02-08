//
//  Edit_profile.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 8.02.24.
//

import SwiftUI

struct Edit_profile: View {
    @State private var name: String = ""
    @State private var bread: String = ""
    @State private var age: String = ""
    @State private var sex: String = ""
    @State private var weight: String = ""
    @State private var location: String = ""
    @State private var submit_message: String = "Ok bro"
    @State private var submit_result: Bool = false

    var body: some View {
        ZStack{
            Color("Background").ignoresSafeArea(.all)
            
            VStack{
                Text("Edit your pet's info")
                    .bold()
                    .padding(.top, 120)
                    .font(.system(size: 40))
                
                Text(submit_message)
                    .opacity(submit_result ? 1 : 0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 25)
                    .padding(.bottom, -20)
                    .foregroundStyle(.red)
                
                Form {
                    Section(){
                        TextField("Name", text: $name)
                            .disableAutocorrection(true)
                        TextField("Bread", text: $bread)
                        TextField("Age", text: $age)
                        TextField("Sex", text: $sex)
                        TextField("Weight", text: $weight)
                        TextField("Location", text: $location)
                    }
                    
                    Button("Submit") {
                        print("Okay so this is " + name + " it is " + sex + " and it's " + bread + " bread. It's this " + age + " old, he weights " + weight + "kg and his current location is " + location)
                        
                        submit_result = true
                    }
                    .fixedSize()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
}

#Preview {
    Edit_profile()
}
