//
//  DocumentView+Extension.swift
//  NotionStyleMemo
//
//  Created by 이영빈 on 2021/10/19.
//

import SwiftUI


extension View {
    func endTextEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
