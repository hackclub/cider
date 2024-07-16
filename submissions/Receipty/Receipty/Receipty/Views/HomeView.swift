//
//  HomeView.swift
//  Receipty
//
//  Created by Muhammad Anas on 12/07/2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedReceipt: ReceiptItem?
    @AppStorage("viewStyle") private var viewStyle: ViewStyle = .list
    @State private var isCreatingNewReceipt = false
    @Environment(\.colorScheme) var colorScheme
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? "User"

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Welcome, \(username)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading)
                        .foregroundColor(colorScheme == .dark ? .secondaryText : .black)
                    Spacer()
                    HStack(spacing: 15) {
                        NavigationLink(destination: SettingsView()) {
                            Circle()
                                .fill(colorScheme == .dark ? Color.secondaryText : Color.black)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "gearshape")
                                        .foregroundColor(colorScheme == .dark ? .black : .white)
                                )
                        }

                        Button(action: {
                            isCreatingNewReceipt = true
                        }) {
                            Circle()
                                .fill(colorScheme == .dark ? Color.secondaryText : Color.black)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "plus")
                                        .foregroundColor(colorScheme == .dark ? .black : .white)
                                )
                        }
                    }
                    .padding(.trailing)
                }
                .padding(.top)
                .background(colorScheme == .dark ? Color.primaryBackground : Color.white)

                // Search bar
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)

                if viewModel.receipts.isEmpty {
                    EmptyStateView(imageName: "doc.text.fill", message: "No receipts yet...")
                        .transition(.opacity)
                } else {
                    if viewStyle == .list {
                        List {
                            ForEach(viewModel.receipts) { receipt in
                                ReceiptRowView(receipt: receipt)
                                    .onTapGesture {
                                        selectedReceipt = receipt
                                    }
                            }
                            .onDelete(perform: deleteReceipt)
                        }
                        .transition(.opacity)
                    } else {
                        GridView(receipts: viewModel.receipts) { receipt in
                            selectedReceipt = receipt
                        }
                        .transition(.opacity)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true) // Hide the default navigation bar
            .background(
                NavigationLink(destination: NoteDetailView(receipt: nil, receipts: $viewModel.receipts), isActive: $isCreatingNewReceipt) {
                    EmptyView()
                }
            )
            .sheet(item: $selectedReceipt) { receipt in
                NavigationView {
                    NoteDetailView(receipt: receipt, receipts: $viewModel.receipts)
                        .onDisappear {
                            selectedReceipt = nil // Clear selectedReceipt when NoteDetailView is dismissed
                        }
                }
                .onAppear {
                    setNavigationBarAppearance()
                }
            }
        }
        .onAppear {
            setNavigationBarAppearance()
        }
    }

    private func deleteReceipt(at offsets: IndexSet) {
        withAnimation {
            viewModel.deleteReceipt(at: offsets)
        }
    }


    private func setNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(colorScheme == .dark ? .primaryBackground : .white)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(colorScheme == .dark ? .white : .black)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(colorScheme == .dark ? .white : .black)]
        appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(colorScheme == .dark ? .white : .black)]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.light) // Preview in light mode
        HomeView()
            .preferredColorScheme(.dark) // Preview in dark mode
    }
}

// Custom Search Bar
struct SearchBar: UIViewRepresentable {
    @Binding var text: String

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.placeholder = "Search" // Set the placeholder text here
        searchBar.delegate = context.coordinator
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}
