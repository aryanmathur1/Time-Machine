//
//  randomContentView.swift
//  Time Machine
//
//  Created by Aryan Mathur on 5/17/25.
//

import SwiftUI

struct randomContentView: View {
    @State private var trigger: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing:12) {
            HackerTextView(
                text: "Hello Aryan, Hello Daniel!",
                trigger: trigger,
                transition: .interpolate,
                duration: 0.5,
                speed: 0.01
            )
                .font(.largeTitle.bold())
                .lineLimit(2)
                .onAppear {
                    trigger.toggle()
                }
            
            Button(action: { trigger.toggle() }, label: {
                Text("Trigger")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 2)
            
            })
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .frame(maxWidth: .infinity)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    randomContentView()
}
