//
//  CompletedView.swift
//  TestApp
//
//  Created by Daniel Guo on 10/11/23.
//

import SwiftUI

struct CompletedView: View {
    
    var body: some View {
        Spacer()
        
        Image(systemName: "checkmark.circle")
            .font(.system(size: 100))
        
        Spacer()
        
        Text("Completed Timed Walk!")
            .font(.title)
            .navigationBarBackButtonHidden(true)
        
        Spacer()
    }
    
}

#Preview {
    CompletedView()
}
