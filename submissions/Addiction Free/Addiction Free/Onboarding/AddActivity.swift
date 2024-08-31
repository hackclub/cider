//
//  AddActivity.swift
//  Addiction Free
//
//  Created by ScriptKid on 27/08/2024.
//

import SwiftUI
import SwiftData

struct AddActivity: View {
    @Binding var selected: Bool
    @Environment(\.modelContext) private var modelContext
    @State var text = ""

        let addictions = [
            ("Smoking", "🚬"),
            ("Alcohol", "🍺"),
            ("Gambling", "🎰"),
            ("Overeating", "🍔"),
            ("Social Media", "📱")
        ]
        
        var body: some View {
            VStack() {
                Text("Choose Your Addiction")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                Spacer()
                ForEach(addictions, id: \.0) { addiction, emoji in
                    Button(action: {
                        let fetchDescriptor = FetchDescriptor<Activity>()
                        
                        let activities = try? modelContext.fetch(fetchDescriptor)
                        let newActivity: Activity

                        if let activity = activities?.first {
                            newActivity = activity
                        } else {
                            newActivity = Activity(name: "\(emoji) \(addiction)", hexColor: "FFC0CB")
                            modelContext.insert(newActivity)
                        }

                        try? modelContext.save()
                        selected = true
                    }) {
                        HStack {
                            Text(emoji)
                                .font(.largeTitle)
                            Text(addiction)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.leading, 10)
                        }
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .foregroundColor(Color.secondary)
                        .background(Color.primary)
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                }
                Text("or")
                    .font(.title3)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .foregroundColor(Color.primary)
                    .cornerRadius(15)
                    .padding(.horizontal)
                HStack {
                    TextField("Your addiction", text: $text)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.leading, 10)
                }
                .frame(maxWidth: .infinity, minHeight: 60)
                .foregroundColor(Color.primary)
                .cornerRadius(15)
                .padding(.horizontal)
                Button {
                    if text == "" {} else{
                        let fetchDescriptor = FetchDescriptor<Activity>()
                        
                        let activities = try? modelContext.fetch(fetchDescriptor)
                        let newActivity: Activity

                        if let activity = activities?.first {
                            newActivity = activity
                        } else {
                            newActivity = Activity(name: text, hexColor: "FFC0CB")
                            modelContext.insert(newActivity)
                        }

                        try? modelContext.save()
                        selected = true
                    }
                } label: {
                    Text("Add your addiction")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.leading, 10)
                }
                .frame(maxWidth: .infinity, minHeight: 60)
                .foregroundColor(Color.secondary)
                .background(Color.primary)
                .cornerRadius(15)
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }

#Preview {
    AddActivity(selected: .constant(false))
}
