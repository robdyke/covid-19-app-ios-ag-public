//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI

public struct ToggleButton: View {
    @Binding private var isToggledOn: Bool
    var imageName: ImageName
    var text: String
    
    public init(isToggledOn: Binding<Bool>, imageName: ImageName, text: String) {
        self.imageName = imageName
        self.text = text
        _isToggledOn = isToggledOn
    }
    
    public var body: some View {
        ZStack {
            Color(.surface)
                .clipShape(RoundedRectangle(cornerRadius: .menuButtonCornerRadius))
                .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.04), radius: .stripeWidth, x: 0, y: 0)
            HStack(spacing: .standardSpacing) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color(.nhsBlue))
                    .frame(width: 30)
                    .accessibility(hidden: true)
                Toggle(text, isOn: $isToggledOn)
                    .font(.body)
                    .foregroundColor(Color(.primaryText))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.standardSpacing)
        }
    }
}
