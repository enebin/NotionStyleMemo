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
    let image: Image = Image(systemName: "person")
}


struct DocumentView: View {
    @State var text: String = ""
    @State var isTyping = false
    @State var isReturnPressed = false
    
    var containers: [Container]
    
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
    }
    
    var newContainer: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "plus")
                    .foregroundColor(isTyping ? .gray.opacity(0) : .gray.opacity(1))
            }
            TextField("Type here", text: $text,
                      onEditingChanged: { changed in isTyping = changed }
                      //                      onCommit: { containers.append(.Text(TextContainer(text)))}
                      
            )
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
    let texts: TextContainer
    
    var body: some View {
        VStack {
            Text(texts.text)
        }
    }
}

struct ImageContainerView: View {
    let image: ImageContainer
    
    var body: some View {
        VStack {
            image.image
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
