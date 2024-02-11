//
//  Edit_profile.swift
//  Dog-feeder
//
//  Created by Emiliana Petrenko on 8.02.24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct Edit_profile: View {
    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var age: String = ""
    @State private var sex: String = ""
    @State private var weight: String = ""
    @State private var location: String = ""
    @State private var submit_message: String = ""
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
                    .padding(.top, 10)
                    .padding(.bottom, -20)
                    .foregroundStyle(.red)
                
                Form {
                    Section(){
                        TextField("Name", text: $name)
                            .disableAutocorrection(true)
                        TextField("Breed", text: $breed)
                        TextField("Age", text: $age)
                        TextField("Sex", text: $sex)
                        TextField("Weight", text: $weight)
                        TextField("Location", text: $location)
                    }
                    
                    Button("Submit") {
                        addData(name: name, breed: breed, age: Int(age) ?? 0, sex: sex, weight: Float(weight) ?? 0.0, location: location) { message in
                            submit_message = message
                        }
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
