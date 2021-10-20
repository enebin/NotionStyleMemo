//
//  TempContainer.swift
//  NotionStyleMemo
//
//  Created by 이영빈 on 2021/10/18.
//

import SwiftUI


// enum way was really fascinating but as the codes got bigger, Container had to contain more things in it.
// So I adopted a classic Struct way. It seems little bit far from MVVM model but it's pretty convenient.

// Actually UIImage is not codable, let's make some stuffs to solve it.
struct Container: Identifiable, Equatable, Hashable, Codable {
    var text: String?
    var image: UIImage?
    var id: UUID
    
    init(text: String? = nil, image: UIImage? = nil) {
        // Additional bug handling needed
        self.text = text
        self.image = image
        self.id = UUID()
    }
    
    enum CondingKeys: CodingKey {
        case text
        case image
        case id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CondingKeys.self)
        
        text = try container.decode(String.self, forKey: .text)
        if let text = try container.decodeIfPresent(String.self, forKey: .image) {
            if let data = Data(base64Encoded: text) {
                image = UIImage(data: data)
            }
        }
        id = try container.decode(UUID.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CondingKeys.self)
        
        try container.encode(text, forKey: .text)
        if let image = image, let data = image.pngData() {
            try container.encode(data, forKey: .image)
        }
        try container.encode(id, forKey: .id)
    }
    
    
    func type<MetaType>() -> MetaType? {
        if text != nil {
            return Text.self as? MetaType
        }
        if image != nil {
            return UIImage.self as? MetaType
        }
        return nil
    }
    

    var view: some View {
        return Group {
            if let image = image {
                ImageContainerView(image: image)
            }
            if let text = text {
                TextContainerView(text: text)
            }
            if image == nil && text == nil {
                EmptyView()
            }
        }
    }
    
    private struct TextContainerView: View {
        @State var text: String
        @State var isModifying = false
        @State var isFirstResponder = false
        
        var body: some View {
            HStack {
                TextField("Type here", text: $text)
                Spacer()
            }
        }
    }
    
    private struct ImageContainerView: View {
        @State var image: UIImage
        @State var showPicker = false
        
        var body: some View {
            HStack(alignment: .center) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
            }
            .onTapGesture {
                showPicker = true
            }
            .sheet(isPresented: $showPicker) {
                ImagePickerView(image: $image, showPicker: $showPicker)
            }
        }
    }
}

