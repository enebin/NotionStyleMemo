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
        let decodeContainer = try decoder.container(keyedBy: CondingKeys.self)
        
        if let text = try decodeContainer.decodeIfPresent(String.self, forKey: .text) {
            self.text = text
        }

        if let base64 = try decodeContainer.decodeIfPresent(String.self, forKey: .image) {
            if let data = Data(base64Encoded: base64) {
                self.image = UIImage(data: data)
            }
        }
        
        id = try decodeContainer.decode(UUID.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var encodeContainer = encoder.container(keyedBy: CondingKeys.self)
        
        try encodeContainer.encode(text, forKey: .text)
        if let image = image, let data = convertImageToBase64String(from: image) {
            try encodeContainer.encode(data, forKey: .image)
        }
        try encodeContainer.encode(id, forKey: .id)
    }
    
    private func convertImageToBase64String (from img: UIImage?) -> String? {
        if let image = img {
            return image.jpegData(compressionQuality: 1)?.base64EncodedString()
        }
        return nil
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

