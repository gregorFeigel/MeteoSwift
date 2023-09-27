//
//  SwiftUIView.swift
//  
//
//  Created by Gregor Feigel on 05.09.23.
//

import SwiftUI
import _Performance
import Charts

@available(macOS 13.0, *)
struct RadialChart: View {
    
    init(data: [[Double]]) { self.data = data   }
    init(data: [Double])   { self.data = [data] }
    
    var data: [[Double]] = []
    
    var body: some View {
        ZStack {
            
            ForEach(Array(["-20°","","0°","","20°","","40°"].enumerated()), id: \.0) { (i, p) in
 
                ZStack {
                    if [3].contains( i + 1) {
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 3, dash: [90 + (250 * CGFloat(i + 1) / 7), 15]))
                            .frame(width: 1800 * CGFloat( i + 1) / 7)
                            .foregroundColor(.gray)

                    }
                    else {
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [90 + (250 * CGFloat(i + 1) / 7), 15]))
                            .frame(width: 1800 * CGFloat( i + 1) / 7)
                            .foregroundColor(.gray)
    //                        .stroke(.gray, lineWidth: 1).frame(width: graphSize * CGFloat(n) / 7)
                    }
                    if !p.isEmpty  {
                        VStack {
//                            Text(p)
//                                .fontWeight(.semibold)
//                                .font(.system(size: 20))
//                                .padding()
//                                .background(.white)
//                                .offset(y: n == 0 ? 0 : -30)
//
//                            Spacer()
//
//                            Text("\(p)")
//                                .fontWeight(.semibold)
//                                .font(.system(size: 20))
//                                .padding()
//                                .background(.white)
//                                .offset(y: n == 0 ? 0 : 30)
                        }
                    }
                }
                .fixedSize()

            }
            .overlay {
//                ForEach(Array(["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug", "Sep", "Oct", "Nov", "Dez"].enumerated()), id: \.1) { (i, n) in
//                    let shift: CGFloat = 180 - 30
//                    let angle = (-CGFloat(i) * (2 * .pi) / CGFloat(12) - .pi / 2)  + (shift * .pi / 180)
//
//                    let xOffset = (largerCircleRadius + 40) * cos(angle)
//                    let yOffset = (largerCircleRadius + 40) * sin(angle)
//
//                    Text(n)
//                        .font(.title)
//                        .offset(x: xOffset, y: yOffset)
//                        .foregroundColor(.gray)
//                }
            }
            
            Canvas { context, size in
                
                // Chart Lable
                let resolved = context.resolve(Text("thomas"))
                context.draw(resolved, at: .init(x: 50, y: 50), anchor: .center)
                
    //            for (i, month) in ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug", "Sep", "Oct", "Nov", "Dez"].enumerated() {
    //                let shift: CGFloat = 180 - 30
    //                let angle = (-CGFloat(i) * (2 * .pi) / CGFloat(12) - .pi / 2)  + (shift * .pi / 180)
    //
    //                let xOffset = (size.height / 2 + 40) * cos(angle)
    //                let yOffset = (size.height / 2 + 40) * sin(angle)
    //
    //                let resolved = context.resolve(Text(month))
    //                context.draw(resolved, at: .init(x: 50, y: 50), anchor: .center)
    //            }
                

                // Chart Axis
    //            for (i, p) in ["-20°","","0°","","20°","","40°"].enumerated() {
    //                let n = i + 1
    //
    //                if n == 3 {
    //                    let diameter: CGFloat = size.width * CGFloat(n) / 7
    //
    //                    let rect = CGRect(origin: .init(x: (size.width / 2) - (diameter / 2), y: size.height / 2 - (diameter / 2)),
    //                                      size: .init(width: diameter, height: diameter))
    //
    //                    let path = Circle().stroke(style: StrokeStyle(lineWidth: 3, dash: [90 + (250 * CGFloat(n) / 7), 15])).path(in: rect)
    //                    context.fill(path, with: .color(.gray))
    //                }
    //                else {
    //                    let diameter: CGFloat = size.width * CGFloat(n) / 7
    //
    //                    let rect = CGRect(origin: .init(x: (size.width / 2) - (diameter / 2), y: size.height / 2 - (diameter / 2)),
    //                                      size: .init(width: diameter, height: diameter))
    //
    //                    let path = Circle().stroke(style: StrokeStyle(lineWidth: 1, dash: [90 + (250 * CGFloat(n) / 7), 15])).path(in: rect)
    //                    context.fill(path, with: .color(.gray))
    //                }
    //            }
                
                // Chart Content
                for row in data {
                    for (i, n) in row.enumerated() {
                        
                        // calculate position in circle
                        let shift: CGFloat = -60
                        var angle = -CGFloat(i) * (2 * .pi) / CGFloat(row.count) - .pi / 2
                        angle = angle + (shift * .pi / 180)
                        
                        let offset = 1 - (n - -30) / (40 - -30)
                        let radius = CGFloat(1.0 - offset) * (size.height / 2)
                        
                        let xOffset = radius * cos(angle)
                        let yOffset = radius * sin(angle)
                        
                        // draw cirlce
                        let centre: CGSize = .init(width: size.width / 2, height: size.height / 2)
                        let rect = CGRect(origin: .init(x: centre.width + xOffset, y: centre.height + yOffset), size: .init(width: 5, height: 5))
                        let path = Circle().path(in: rect)
                        context.fill(path, with: .color(.red))
                    }
                }
            }
        }
     
        .frame(width: 1800, height: 1800)
        .padding()
    }
}

@available(macOS 13.0, *)
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        RadialChart(data: Array(repeating: 20, count: 360) + [10,10,10,10,10] )
    }
}


