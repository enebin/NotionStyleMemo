//
//  DocumentView.swift
//  NotionStyleMemo
//
//  Created by 이영빈 on 2021/10/17.
//


import SwiftUI

struct DocumentView: View {
    @State var containers: [Container]
    @FocusState  var isFocused: Bool
    
    var body: some View {
        List {
            ForEach(containers, id: \.self) { container in
                container.view
            }
            .onMove(perform: moveArray)
            .onDelete(perform: deleteRow)
            .listRowSeparator(.hidden) // for iOS 15
            NewContainer(containers: $containers, isFocused: $isFocused)
        }
        .listStyle(PlainListStyle())
        .toolbar { EditButton() }
        .onTapGesture { // Thanks to https://stackoverflow.com/a/60349748/11768262
            self.endTextEditing()
        }
    }
    
    private func moveArray(from source: IndexSet, to destination: Int) {
        self.containers.move(fromOffsets: source, toOffset: destination)
    }
    
    private func deleteRow(at indexSet: IndexSet) {
        self.containers.remove(atOffsets: indexSet)
    }

    // Make newContainer as a struct to use @FocusState
    private struct NewContainer: View {
        @Binding var containers: [Container]
        var isFocused: FocusState<Bool>.Binding
        
        @State var isTyping = false
        @State var text: String = ""
        @State var imageData: UIImage = UIImage()
        @State var showPicker = false

        var body: some View {
            HStack(spacing: 2) {
                Button(action: { showPicker = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(isTyping ? .gray.opacity(0) : .gray.opacity(1))
                        .disabled(isTyping ? true : false)
                }
                
                TextField("Type here", text: $text,
                          onEditingChanged: { changed in isTyping = changed },
                          onCommit: {
                    containers.append(Container(text: text))
                    text = ""
                    isFocused.wrappedValue = true
                })
                    .focused(isFocused)
                    .padding(.leading, 5)
            }
            .onChange(of: imageData) { newValue in
                let imageData = newValue
                containers.append(Container(image: imageData))
            }
            .sheet(isPresented: $showPicker) {
                ImagePickerView(image: $imageData, showPicker: $showPicker)
            }
        }
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView(containers: [])
    }
}
