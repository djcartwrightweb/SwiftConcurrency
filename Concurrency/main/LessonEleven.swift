//
//  LessonEleven.swift
//  Concurrency
//
//  Created by David Cartwright on 2025-04-24.
//

import SwiftUI

actor CurrentUserManager {
    
    func updateDatabase(userInfo: MyUserInfo2) {
        
    }
    
}

final class MyUserInfo2: @unchecked Sendable {
    private var name: String
    
    let lock = DispatchQueue(label: "com.example.CurrentUserManager")
    
    init(name: String) {
        self.name = name
    }
    
    func updateName(_ newName: String) {
        lock.async {
            self.name = newName
        }
    }
}

struct MyUserInfo: Sendable {
    var name: String
}

@Observable class LessonElevenViewModel {
    
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        
        let info = MyUserInfo2(name: "USER INFO")
        
        await manager.updateDatabase(userInfo: info)
    }
    
}

struct LessonEleven: View {
    
    @State private var viewModel = LessonElevenViewModel()
    @State private var text: String = ""
    
    var body: some View {
        Text(text)
            .task {
                await viewModel.updateCurrentUserInfo()
            }
    }
}

#Preview {
    LessonEleven()
}
