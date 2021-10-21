//
//  ContentView.swift
//  NotionStyleMemo
//
//  Created by 이영빈 on 2021/10/11.
//

import SwiftUI


// To save document in local stroage, Document should observe codable.
// However Container type is not codable for now. Let's make it work.
struct Document: Codable {
    var title: String = "No title"
    var containers = [Container(text: "Hello, world!")]
}

class DocumentListViewModel: ObservableObject {
    @Published var docList: [Document] {
        didSet {
            autoSave()
        }
    }
    
    private struct Autosave {
        static let filename = "Autosaved.Documents"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(filename)
        }
        static let coalescingInterval = 1.0
    }
    
    func autoSave() {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    private func save(to url: URL) {
        do {
            let data: Data = try docList.json()
            try data.write(to: url)
            print("save: success!")
        } catch {
            print("Error happend: \(error)")
        }
    }
    
    private func load(from url: URL) -> [Document] {
        do {
            let data = try Data(contentsOf: url)
            let loaded = try JSONDecoder().decode([Document].self, from: data)
            print("load: Success!")
            return loaded
        }
        catch {
            print("Error happend: \(error)")
            return [Document]()
        }
    }
    
    init() {
        docList = [Document]()
        if let url = Autosave.url {
            docList = load(from: url)
        }
    }

    // MARK: -Intents
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
                    NavigationLink(destination: DocumentView(containers: $viewModel.docList[index].containers)) {
                        Text(viewModel.docList[index].title)
                    }
                }
            }
            .navigationTitle(Text("My memo"))
            .toolbar {
                Button(action: { viewModel.addDocument() }) {
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
