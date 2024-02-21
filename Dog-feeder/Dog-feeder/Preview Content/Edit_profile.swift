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
    private var ageUnitArray = ["year(s)", "month(s)"]
    @State private var selectedIndexAgeUnit = 0
    @State private var ageUnit: String = ""
    @State private var sex: String = ""
    private var genderArray = ["Male", "Female"]
    @State private var selectedIndexGender = 0
    @State private var weight: String = ""
    private var weightUnitArray = ["kg", "lb"]
    @State private var selectedIndexWeightUnit = 0
    @State private var weightUnit: String = ""
    @State private var location: String = ""
    @State private var textField: String = "Edit your pet's info"
    @State private var submit_message: String = ""
    @State private var submit_result: Bool = false
    @State private var existing_profile: Bool = true
    @State private var add_data: Bool = false

    var body: some View {
        ZStack{
            Color("Background").ignoresSafeArea(.all)
            
            VStack{
                Text(textField)
                    .bold()
                    .padding(.top, 120)
                    .font(.system(size: 40))
                
                Text(submit_message)
                    .opacity(submit_result ? 1 : 0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 25)
                    .padding(.top, 10)
                    .foregroundStyle(.red)
                
                Form {
                    Section(){
                        TextField("Name", text: $name)
                            .disableAutocorrection(true)
                        TextField("Breed", text: $breed)
                        HStack{
                            TextField("Age", text: $age)
                                .keyboardType(.numberPad)
                            
                            Picker(selection: $selectedIndexAgeUnit, label: Text("Select Age Unit")) {
                                ForEach(0 ..< ageUnitArray.count) {
                                    Text(self.ageUnitArray[$0])
                                }
                            }.pickerStyle(SegmentedPickerStyle())
                        }
                        
                        HStack{
                            TextField("Weight", text: Binding(
                                get: {
                                    self.weight
                                },
                                set: { newValue in
                                    self.weight = newValue.replacingOccurrences(of: ",", with: ".")
                                }
                            ))
                            .keyboardType(.decimalPad)
                            
                            Picker(selection: $selectedIndexWeightUnit, label: Text("Select Weight Unit")) {
                                ForEach(0 ..< weightUnitArray.count) {
                                    Text(self.weightUnitArray[$0])
                                }
                            }.pickerStyle(SegmentedPickerStyle())
                        }
                        
                        TextField("Location", text: $location)
                        Picker(selection: $selectedIndexGender, label: Text("Select Gender")) {
                            ForEach(0 ..< genderArray.count) {
                                Text(self.genderArray[$0])
                            }
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Button("Submit") {
                        ageUnit = ageUnitArray[selectedIndexAgeUnit]
                        sex = genderArray[selectedIndexGender]
                        weightUnit = weightUnitArray[selectedIndexWeightUnit]
                        
                        if(!existing_profile){
                            if(name == "" || breed == "" || age == "" || sex == "" || weight == "" || location == ""){
                                submit_message = "All fields are mandatory"
                                add_data = false
                            }
                        }
                        
                        if(Int(age) == 0){
                            submit_message = "Age cannot be equal to 0, if your pets is bellow 1 year, use months"
                            add_data = false
                        }
                        
                        if(Int(age) ?? 0 > 1024){
                            submit_message = "Age cannot be bigger than 1024"
                            add_data = false
                        }
                        
                        if(Float(weight) == 0){
                            submit_message = "Weight cannot be equal to 0"
                            add_data = false
                        }
                        
                        if(Float(weight) ?? 0 > 1024){
                            submit_message = "Weight cannot be bigger than 1024"
                            add_data = false
                        }
                        
                        if(add_data){
                            addData(name: name, breed: breed, age: age, ageUnit: ageUnit, sex: sex, weight: weight, weightUnit: weightUnit, location: location, existing_profile: existing_profile) { message in
                                submit_message = message
                            }
                        }
                        
                        add_data = true
                        submit_result = true
                    }

                    .fixedSize()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                }
                .scrollContentBackground(.hidden)
            }
        }
        
        .onAppear{
            fetchData { data, name, breed, age, ageUnit, sex, weight, weightUnit, location, error  in
                if error != nil {
                    existing_profile = false
                    textField = "Add your pet's info"
                } else {
                    self.name = name ?? ""
                    self.breed = breed ?? ""
                    self.age = String(age ?? 0)
                    self.ageUnit = ageUnit ?? ""
                    self.sex = sex ?? ""
                    self.weight = String(weight ?? 0.0)
                    self.weightUnit = weightUnit ?? ""
                    self.location = location ?? ""
                }
            }
        }
    }
}

#Preview {
    Edit_profile()
}
