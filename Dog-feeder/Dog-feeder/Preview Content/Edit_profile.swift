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
    private var ageUnitArray = ["years", "months"]
    @State private var selectedIndexAgeUnit = 0
    @State private var ageUnit: String = ""
    
    @State private var sex: String = ""
    private var genderArray = ["Male", "Female"]
    @State private var selectedIndexGender = 0
    
    @State private var weight: String = ""
    private var weightUnitArray = ["kg", "lbs"]
    @State private var selectedIndexWeightUnit = 0
    @State private var weightUnit: String = ""
    
    @State private var location: String = ""
    @State private var submit_message: String = ""
    @State private var submit_result: Bool = false
    @State private var existing_profile: Bool = true

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
                        addData(name: name, breed: breed, age: Int(age) ?? 0, ageUnit: ageUnit, sex: sex, weight: Float(weight) ?? 0.0, location: location) { message in
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
