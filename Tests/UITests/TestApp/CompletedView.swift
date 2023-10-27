//
//  CompletedView.swift
//  TestApp
//
//  Created by Daniel Guo on 10/11/23.
//

import SwiftUI

struct CompletedView: View {
    @Environment(\.dismiss) private var dismiss
    var stepCount: Int
    var distance: Int
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "checkmark.circle")
                .font(.system(size: 100))
                .accessibilityHidden(true)
            
            Spacer()
            
            Text("Completed Timed Walk!")
                .font(.title)
            
            Text("Steps: \(stepCount)")
            Text("Distance: \(distance)")
            
            Button(
                action: {
                    dismiss()
                },
                label: {
                    Text("Restart")
                        .frame(maxWidth: .infinity, minHeight: 38)
                }
            )
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CompletedView(stepCount: 0, distance: 0)
}
