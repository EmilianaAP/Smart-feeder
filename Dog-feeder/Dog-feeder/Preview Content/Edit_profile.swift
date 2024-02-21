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
    @State private var nameField: String = "Name"
    
    @State private var breed: String = ""
    @State private var breedField: String = "Breed"

    
    @State private var age: String = ""
    private var ageUnitArray = ["years", "months"]
    @State private var selectedIndexAgeUnit = 0
    @State private var ageUnit: String = ""
    @State private var ageField: String = "Age"

    
    @State private var sex: String = ""
    private var genderArray = ["Male", "Female"]
    @State private var selectedIndexGender = 0
    
    @State private var weight: String = ""
    private var weightUnitArray = ["kg", "lbs"]
    @State private var selectedIndexWeightUnit = 0
    @State private var weightUnit: String = ""
    @State private var weightField: String = "Weight"
    
    @State private var location: String = ""
    @State private var locationField: String = "Location"

    @State private var textField: String = "Edit your pet's info"
    
    @State private var submit_message: String = ""
    @State private var submit_result: Bool = false
    @State private var existing_profile: Bool = true

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
                        TextField(nameField, text: $name)
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
                        
                        addData(name: name, breed: breed, age: Int(age) ?? 0, ageUnit: ageUnit, sex: sex, weight: Float(weight) ?? 0.0, weightUnit: weightUnit, location: location) { message in
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
            
            if(existing_profile){
                nameField = name
                breedField = breed
                ageField = age
                weightField = weight
                locationField = location
            }
        }
    }
}

#Preview {
    Edit_profile()
}
