//
//  TempContainer.swift
//  NotionStyleMemo
//
//  Created by 이영빈 on 2021/10/18.
//

import SwiftUI

// enum way was really fascinating but as the codes got bigger, Container had to contain more things in it.
// So I adopted a classic Struct way. It seems little bit far from MVVM model but it's pretty convenient.
struct Container: Equatable, Hashable {
    var image: UIImage?
    var text: String?
    
    init(text: String? = nil, image: UIImage? = nil) {
        // Additional bug handling needed
        self.text = text
        self.image = image
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

