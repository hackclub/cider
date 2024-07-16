//
//  NoteDetailView.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//

import SwiftUI

struct NoteDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel: NoteDetailViewModel

    init(receipt: ReceiptItem? = nil, receipts: Binding<[ReceiptItem]>) {
        _viewModel = StateObject(wrappedValue: NoteDetailViewModel(receipt: receipt, receipts: receipts))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Receipt Image
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.bottom)
                } else {
                    HStack {
                        Button(action: {
                            viewModel.imagePickerSourceType = .photoLibrary
                            viewModel.showImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title)
                                Text("Select")
                                    .font(.headline)
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.15))
                            .cornerRadius(10)
                        }
                        .padding(.bottom)

                        Button(action: {
                            viewModel.imagePickerSourceType = .camera
                            viewModel.showImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "camera")
                                    .font(.title)
                                Text("Capture Image")
                                    .font(.headline)
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.15))
                            .cornerRadius(10)
                        }
                        .padding(.bottom)
                    }
                }

                // Title
                Text("Title")
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .secondaryText : .black)
                TextField("Enter title", text: $viewModel.title)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.bottom)

                // Date and Total Bill Side by Side
                HStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Date")
                            .font(.caption)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .black)
                        DatePicker("", selection: $viewModel.date, in: ...Date(), displayedComponents: .date)
                            .labelsHidden()
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(10)
                    }

                    VStack(alignment: .leading) {
                        Text("Total Bill")
                            .font(.caption)
                            .foregroundColor(colorScheme == .dark ? .secondaryText : .black)
                        TextField("Enter total bill", text: $viewModel.totalBill)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom)

                // Split Percentage
                Text("Split Percentage")
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .secondaryText : .black)
                VStack {
                    Slider(value: $viewModel.splitPercentage, in: 0...100, step: 1) {
                        Text("Split Percentage")
                    }
                    .accentColor(.secondaryText)
                    Text("\(Int(viewModel.splitPercentage))%")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color.secondary.opacity(0.15))
                .cornerRadius(10)
                .padding(.bottom)

                // Tags
                Text("Tags")
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .secondaryText : .black)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.tags, id: \.self) { tag in
                            TagView(tag: tag, isSelected: viewModel.selectedTags.contains(tag)) {
                                if viewModel.selectedTags.contains(tag) {
                                    viewModel.selectedTags.removeAll { $0 == tag }
                                } else {
                                    viewModel.selectedTags.append(tag)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom)

                // Description
                HStack {
                    Text("Description")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? .secondaryText : .black)
                    Spacer()
                    Toggle("", isOn: $viewModel.descriptionEnabled)
                }
                if viewModel.descriptionEnabled {
                    TextField("Enter description", text: $viewModel.description.bound)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.bottom)
                }

                Spacer()
            }
            .padding()
            .background(colorScheme == .dark ? Color.primaryBackground : Color(UIColor.systemBackground))
            .foregroundColor(colorScheme == .dark ? Color.secondaryText : Color.primary)
            .cornerRadius(10)
            .navigationBarItems(trailing: saveButton)
            .sheet(isPresented: $viewModel.showImagePicker) {
                ReceiptImagePicker(sourceType: viewModel.imagePickerSourceType) { image in
                    viewModel.image = image
                }
            }
            .navigationBarTitle(viewModel.isEditing ? "Edit Receipt" : "New Receipt", displayMode: .inline)
            .onAppear {
                setNavigationBarAppearance()
            }
        }
    }

    // Custom Save Button
    private var saveButton: some View {
        Button(action: {
            print("Save button pressed") // Debug print
            viewModel.save()
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Save")
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }

    private func setNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(colorScheme == .dark ? .primaryBackground : .white)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(colorScheme == .dark ? .white : .black)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(colorScheme == .dark ? .white : .black)]
        
        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(colorScheme == .dark ? .white : .black)]
        appearance.backButtonAppearance = backButtonAppearance

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        // Ensure the back button arrow is correctly colored
        UINavigationBar.appearance().tintColor = UIColor(colorScheme == .dark ? .white : .black)
    }
}

// Extend String to conform to Identifiable and Hashable
extension String: Identifiable {
    public var id: String { self }
}

// TagView
struct TagView: View {
    var tag: String
    var isSelected: Bool
    var action: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Text(tag)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.secondaryText : Color.secondary.opacity(0.1))
            .foregroundColor(isSelected ? (colorScheme == .dark ? .black : .white) : (colorScheme == .dark ? .secondaryText : .black))
            .cornerRadius(20)
            .onTapGesture {
                action()
            }
    }
}
