//
//  SwiftUIView.swift
//  
//
//  Created by Gregor Feigel on 13.06.23.
//

import SwiftUI

@available(macOS 12.15, *)
struct SwiftUIView: View {
    let air_temp: [Float]
    
    var body: some View {
        VStack {
            Advanced_Chart(values: [.init(values: air_temp.map({ Double($0) }), color: .pink, filled: false, lineWidth: 3)],
                           xAxis: [.init(lable: "x"), .init(lable: "x")],
                           yAxis: [.init(lable: "y"), .init(lable: "y")],
                           min: Double(air_temp.filter({ $0 != -9999.000 }).min()!),
                           max: Double(air_temp.filter({ $0 != -9999.000 }).max()!),
                           selectedIndex: .constant(0),
                           error_value: -9999.00)
        }
        .frame(width: 1400, height: 500)
    }
}

 
