//
//  ContentView.swift
//  NotionStyleMemo
//
//  Created by 이영빈 on 2021/10/11.
//

import SwiftUI

class DocumentListViewModel: ObservableObject {
    @Published var docList = [Document]()

    func addDocument() {
        docList.append(Document())
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = DocumentListViewModel()
    @State var showSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.docList.indices, id: \.self) { index in
                    let doc = viewModel.docList[index]
                    
                    NavigationLink(destination: DocumentView(containers: doc.containers)) {
                        Text(doc.title)
                    }
                }
            }
            .navigationTitle(Text("My memo"))
            .toolbar {
                Button(action: {viewModel.addDocument()}) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

enum Container {
   case Text(TextContainer)
   case Image(ImageContainer)

   var textContainer: TextContainer? {
       guard case let .Text(container) = self else { return nil }
       return container
   }

   var imageContainer: ImageContainer? {
       guard case let .Image(container) = self else { return nil }
       return container
   }
}

struct Document {
    var title: String = "No title"
    var containers: [Container] = [.Text(TextContainer()), .Image(ImageContainer())]
}

struct TextContainer {
    let text: String

    init(_ text: String = "Hello, Wolrd!") {
        self.text = text
    }
    
}

struct ImageContainer {
    let image: Image
    
    init(_ image: Image = Image(systemName: "sparkles")) {
        self.image = image
    }
}


struct DocumentView: View {
    @State var text: String = ""
    @State var images: [UIImage] = [UIImage]()
    
    @State var isTyping = false
    @State var showPicker = false
    @State var isReturnPressed = false
    @State var containers: [Container]
    
    let placeholder = "Type here"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                ForEach(containers.indices, id: \.self) { index in
                    self.view(for: containers[index])
                }
                .padding(.horizontal, 25)
                newContainer
            }
            .padding()
        }
        .sheet(isPresented: $showPicker) {
            ImagePickerView(images: $images, showPicker: $showPicker, selectionLimit: 1)
        }
    }
    
    var newContainer: some View {
        HStack {
            Button(action: { showPicker = true }) {
                Image(systemName: "plus")
                    .foregroundColor(isTyping ? .gray.opacity(0) : .gray.opacity(1))
            }
            TextField(placeholder, text: $text,
                      onEditingChanged: { changed in isTyping = changed },
                      onCommit: {
                containers.append(.Text(TextContainer(text)))
                text = ""
                images.removeAll()
            }
            )
        }
        .onChange(of: images) { newValue in
            guard let image = newValue.first else { return }
            containers.append(.Image(ImageContainer(Image(uiImage: image))))
            images.removeAll()
        }
    }
    
    func view(for container: Container) -> some View {
        return Group {
            if container.textContainer != nil {
                TextContainerView(texts: container.textContainer!)
            } else {
                ImageContainerView(image: container.imageContainer!)
            }
        }
    }
}

struct TextContainerView: View {
    @State var isModifying = false
    @State var newText = ""
    var texts: TextContainer
    
    var body: some View {
        HStack {
            Text(texts.text)
            Spacer()
        }
    }
}

struct ImageContainerView: View {
    var image: ImageContainer
    
    var body: some View {
        HStack {
            Spacer()
            self.image.image
                .resizable()
                .scaledToFit()
                .frame(width: 200)
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
