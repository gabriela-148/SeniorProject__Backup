//
//  InfoScreen.swift
//  SeniorProjectTest
//
//  Created by Gabriella Huegel on 3/24/24.
//

import SwiftUI

struct InfoScreen: View {
    
    let item: Food_Item
    
    var body: some View {
        Text("\(item.name) info")
    }
}

