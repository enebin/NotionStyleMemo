//
//  ImagePicker.swift
//  NotionStyleMemo
//
//  Created by 이영빈 on 2021/10/14.
// Thanks to https://stackoverflow.com/a/63974045/11768262

import SwiftUI
import PhotosUI

struct ImagePickerView: UIViewControllerRepresentable {
    
    @Binding var image: UIImage
    @Binding var showPicker: Bool
    
    func makeUIViewController(context: Context) -> some UIViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {

        var parent: ImagePickerView
        
        init(parent: ImagePickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.showPicker.toggle()
            
            for img in results {
                if img.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    img.itemProvider.loadObject(ofClass: UIImage.self) { (image, err) in
                        guard let image1 = image else { return }
                        
                        DispatchQueue.main.async {
                            self.parent.image = image1 as! UIImage
                        }
                    }
                } else {
                    // Handle Error
                    parent.showPicker.toggle()
                }
            }
        }
    }
}
