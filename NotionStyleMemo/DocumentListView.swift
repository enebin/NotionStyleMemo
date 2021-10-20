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
            print("SET!!!!!!!!")
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
        let thisFucntion = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try docList.json()
            print("\(thisFucntion) json = \(String(data: data, encoding: .utf8) ?? "nil")")
            try data.write(to: url)
            print("\(thisFucntion) success!")
        } catch let encodingError where encodingError is EncodingError {
            print("Error in \(thisFucntion). Couldn't encode Document as JSON because \(encodingError.localizedDescription)")
        } catch {
            print("Error in \(thisFucntion): \(error)")
        }
    }
    
    private func load(from url: URL) -> [Document] {
        do {
            let data = try Data(contentsOf: url)
            print("Loading... = \(String(data: data, encoding: .utf8) ?? "nil")")
            let loaded = try JSONDecoder().decode([Document].self, from: data)
            print("Success!")
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
