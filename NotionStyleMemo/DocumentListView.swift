//
//  ContentView.swift
//  NotionStyleMemo
//
//  Created by 이영빈 on 2021/10/11.
//

import SwiftUI


struct Document {
    var title: String = "No title"
    var containers: [Container] = [Container(text: "Hello, World!"),
                                   Container(image: UIImage(systemName: ""))]
}

class DocumentListViewModel: ObservableObject {
    @Published var docList = [Document]()

    func addDocument() {
        docList.append(Document())
    }
}

struct DocumentListView: View {
    @ObservedObject var viewModel = DocumentListViewModel()
    
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentListView()
    }
}
