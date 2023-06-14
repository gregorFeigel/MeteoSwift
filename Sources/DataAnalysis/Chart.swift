
//===----------------------------------------------------------------------===//
//
// This source file is part of the uniWeather project
//
// Copyright (c) 2022 Gregor Feigel.
//
// See LICENSE.txt for license information
// See README.md for more information
//
//===----------------------------------------------------------------------===//

import Foundation
import SwiftUI
 

@available(macOS 12.15, *)
struct Line_trimed: View {
    var body: some View {
        VStack {
            
            
            Advanced_Chart(values: [.init(values:  [1, 0, 2, 3, 1, 2, 3, 4, 3, 4, 3, 2, 1.5, 1], //[1, 0, 2, 3, 1, 2, 3, 4, 3, 4, 3, 2, 1.5, 1], // [1, 0,  -9999, -9999, 1, 2, 3, -9999, -9999, 4, 3, 2, 1.5, 1], [-9999.0 ,1,  -9999.0, 1, 1, -9999, 0, 0, -9999, 1, 2, 3, -9999, -9999, 4, 3, 2, 1.5, -9999, 1, 1, -9999, 6, 6, -9999, 1, -9999.0, 1],
                                          color: .orange,
                                          filled: true,
                                          lineWidth: 2,
                                          gradient: [.blue, .red], max_min: [.blue, .red])],
                           xAxis:  [.init(lable: "a"), .init(lable: "b"), .init(lable: "c"), .init(lable: "d")],
                           yAxis:  [.init(lable: "1"), .init(lable: "2"), .init(lable: "3"), .init(lable: "4")],
                           min: -2,
                           max: 6,
                           selectedIndex: .constant(0),
                           error_value: -9999.0)
            
            .frame(height: 220)
        }
        .padding()
    }
}

@available(macOS 12.15, *)
struct Line_trimed_Previews: PreviewProvider {
    static var previews: some View {
        Line_trimed()
    }
}

@available(macOS 12.15, *)
struct Advanced_Chart : View {
    
    public init(values: [ChartData],
                xAxis: [ChartLable],
                yAxis: [ChartLable],
                min: Double,
                max: Double,
                enableDrag: Bool = false,
                show_X_Axis: Bool,
                show_Y_Axis: Bool,
                selectedIndex: Binding<Int>,
                error_value: Double
    ) {
        self.values = values
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.min = min
        self.max = max
        self.enableDrag = enableDrag
        self.show_X_Axis = show_X_Axis
        self.show_Y_Axis = show_Y_Axis
        self._selectedIndex = selectedIndex
        self.error = error_value
    }
    
    init(values: [ChartData],
         xAxis: [ChartLable],
         yAxis: [ChartLable],
         min: Double,
         max: Double,
         selectedIndex: Binding<Int>,
         error_value: Double)
    {
        self.init(values: values,
                  xAxis: xAxis,
                  yAxis: yAxis,
                  min: min,
                  max: max,
                  show_X_Axis: true,
                  show_Y_Axis: true,
                  selectedIndex: selectedIndex,
                  error_value: error_value)
    }
    
    
    var values : [ChartData]
    var xAxis  : [ChartLable]
    var yAxis  : [ChartLable]
    
    var min: Double
    var max: Double
    var error: Double
    
    public var show_X_Axis: Bool = true
    public var show_Y_Axis: Bool = true
    
    var enableDrag: Bool = false
    @Binding var selectedIndex : Int
    
    
    // Slider Stuff
    @State private var showSlider   : Bool = false
    @State private var sliderOffset : Double = 0
    
    @State private var index : Int = 0
    
    var body: some View {
        VStack {
            HStack {
                
                // Chart lable y
                
                if show_Y_Axis { chart_Y_Lable }
                
                GeometryReader { reader in
                    ZStack {
                        chartBackground
                        
                        // Charts
                        ForEach(values, id: \.id) { data in
                            Advanced_Curved_Chart_View(data: data.values,
                                                       frame:  CGRect(x: 0, y: 0, width: reader.frame(in: .local).width, height: reader.frame(in: .local).height),
                                                       visualType: data.visualType,
                                                       globalMax: max,
                                                       globalMin: min,
                                                       selected_index: $selectedIndex,
                                                       error_value: error)
                            
                        }
                    }
                }
            }
            
            if show_X_Axis { chart_X_Lable }
            
        }
        
        .font(.system(size: 10))
    }
    
    var chartBackground : some View {
        
        ZStack {
            // horizontal Bars
            VStack {
                ForEach(1...yAxis.count, id: \.self) { i in
                    Divider()
                    if i != yAxis.count  { Spacer() }
                }
            }
            
            // vertical Bars
            HStack {
                ForEach(1...xAxis.count, id: \.self) { i in
                    Divider()
                    if i != xAxis.count  { Spacer() }
                }
            }
            
        }
    }
    
    var chart_X_Lable : some View {
        HStack(spacing: 0) {
            ForEach(Array(xAxis.enumerated()), id: \.offset) { index, observation in
                Text(verbatim: observation.lable)
                if index + 1 != xAxis.count  { Spacer() }
            }
        }
        .padding(.leading, 30) // 14
    }
    
    var chart_Y_Lable : some View {
        VStack(spacing: 0) {
            ForEach(Array(yAxis.enumerated()), id: \.offset) { index, observation in
                Text(verbatim: observation.lable)
                if index + 1 != yAxis.count  { Spacer() }
            }
        }
    }
    
}

@available(macOS 12.15, *)
public struct Advanced_Curved_Chart_View: View, CDataRepresentable {
    
    private let data: [Double]
    private let frame: CGRect
    private let offset: Double
    private let type: CChartVisualType
    private let currentValueLineType: CCurrentValueLineType
    private var points: [[CGPoint]] = []
    private var points_x: [CGPoint] = []
    
    private let error_value: Double
    
    @Binding var selected_index: Int
    
    private var color: Color = .red
    /// Creates a new `CurvedChart`
    ///
    /// - Parameters:
    ///     - data: A data set that should be presented on the chart
    ///     - frame: A frame from the parent view
    ///     - visualType: A type of chart, `.outline` by default
    ///     - offset: An offset for the chart, a space below the chart in percentage (0 - 1)
    ///               For example `offset: 0.2` means that the chart will occupy 80% of the upper
    ///               part of the view
    ///     - currentValueLineType: A type of current value line (`none` for no line on chart)
    public init(data: [Double],
                frame: CGRect,
                visualType: CChartVisualType = .outline(color: .red, lineWidth: 2),
                offset: Double = 0,
                currentValueLineType: CCurrentValueLineType = .none,
                globalMax: Double,
                globalMin: Double,
                selected_index: Binding<Int>,
                error_value: Double)
    {
        self.data = data
        self.frame = frame
        self.type = visualType
        self.offset = offset
        self.currentValueLineType = currentValueLineType
        self._selected_index = selected_index
        self.error_value = error_value
        self.points = advanced_points(forData: data,
                                      frame: frame,
                                      offset: offset,
                                      lineWidth: lineWidth(visualType: visualType),
                                      max: globalMax,
                                      min: globalMin,
                                      error_value: error_value)
        
        self.points_x = points(forData: data,
                               frame: frame,
                               offset: offset,
                               lineWidth: lineWidth(visualType: visualType),
                               max: globalMax,
                               min: globalMin)
        
        switch type {
            case .outline(let color, _):
                self.color = color
            case .filled(let color, _):
                self.color = color
            case .customFilled(let color, _, _, _):
                self.color = color
        }
    }
    
    @State private var showSlider: Bool = false
    @State private var sliderOffset: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme
    
    public var body: some View {
        GeometryReader { reader in
            ZStack {
                chart
                    .drawingGroup()
                
                line
                
                // Max point
                if let p = maxPoint() {
                    // Max
                    VStack(spacing: 0)  {
                        
                        Text(verbatim: "H")
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .font(.system(size: 9))
                        
                        Circle()
                            .foregroundColor(max_color())
                            .overlay {
                                if colorScheme == .dark {
                                    Circle().stroke(style: .init(lineWidth: 2))
                                        .foregroundStyle(.regularMaterial)
                                }
                                else {
                                    Circle().stroke(style: .init(lineWidth: 2))
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(height: 6)
                    }
                    .offset(y: -5)
                    .position(p)
                    .drawingGroup()
                }
                
                // Low point
                if let p = lowPoint() {
                    // Max
                    VStack(spacing: 0)  {
                        Text(verbatim: "L")
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .font(.system(size: 9))
                        
                        Circle()
                            .foregroundColor(min_color())
                            .overlay {
                                if colorScheme == .dark {
                                    Circle().stroke(style: .init(lineWidth: 2))
                                        .foregroundStyle(.regularMaterial)
                                }
                                else {
                                    Circle().stroke(style: .init(lineWidth: 2))
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(height: 6)
                    }
                    .offset(y: -6)
                    .position(p)
                    .drawingGroup()
                }
            }
            .overlay (
                ZStack {
                    Rectangle().frame(width: 1.2).foregroundColor(.gray)
                        .opacity(showSlider == true ? 1 : 0)
                }
                    .offset(x: sliderOffset),
                alignment: .bottomLeading
            )
            .contentShape(Rectangle())
            .gesture(DragGesture().onChanged({ value in
                // show slider
                withAnimation { showSlider = true  }
                
                // change slider position, prevent from sliding out of box
                if value.location.x < 0 || value.location.x > reader.size.width {}
                else {
                    let stepsize = (reader.size.width - 1)  / CGFloat(points_x.count - 1)
                    let index = Int((value.location.x / stepsize).rounded(.down))
                    
                    if points_x.count >= index {
                        if selected_index != index {
                         }
                        withAnimation(.linear(duration: 0.1)) {
                            sliderOffset = points_x[index].x; selected_index = index
                        }
                    }
                    else { sliderOffset = value.location.x }
                }
                
            }).onEnded({ value in
                withAnimation { showSlider = false
                    if points_x.count - 1 >= 0 { selected_index = points_x.count - 1 }
                }
            }))
        }
    }
    
    func maxPoint() -> CGPoint?  {
        var max: CGPoint? = nil
        for n in points {
            if let lmax = n.max(by: { $0.y > $1.y }) {
                if max == nil { max = lmax }
                else {
                    if lmax.y < max!.y { max = lmax }
                }
            }
        }
        return max
    }
    
    func lowPoint() -> CGPoint?  {
        var min: CGPoint? = nil
        for n in points {
            if let lmin = n.max(by: { $0.y < $1.y }) {
                if min == nil { min = lmin }
                else {
                    if lmin.y > min!.y { min = lmin }
                }
            }
        }
        return min
    }
    
    func min_color() -> Color {
        var color: Color = .red
        switch type {
            case .customFilled(color: _, lineWidth: _, fillGradient: _, max_min: let cc): color = cc.last ?? .orange
            case .outline(color: let color_, lineWidth: _): color = color_
            case .filled(color: let color_, lineWidth: _): color = color_
                 
        }
        return color
    }
    
    func max_color() -> Color {
        var color: Color = .red
        switch type {
            case .customFilled(color: _, lineWidth: _, fillGradient: _, max_min: let cc): color = cc.first ?? .red
            case .outline(color: let color_, lineWidth: _): color = color_
            case .filled(color: let color_, lineWidth: _): color = color_
                 
        }
        return color
    }
    
    private var chart: some View {
        
        switch type {
                
            case .outline(let color, let lineWidth):
                return AnyView( curvedPath(points: points)
                    .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round)) )
                
            case .filled(let color, let lineWidth):
                return AnyView(ZStack {
                    curvedPathGradient(points: points)
                        .fill(LinearGradient(
                            gradient: .init(colors: [color.opacity(0.2), color.opacity(0.02)]),
                            startPoint: .init(x: 0.5, y: 1),
                            endPoint: .init(x: 0.5, y: 0)
                        ))
                    
                    
                    curvedPath(points: points)
                        .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round))
                })
                
            case .customFilled(_, let lineWidth, let fillGradient, _):
                return AnyView(ZStack {
                    curvedPathGradient(points: points)
                        .fill(LinearGradient(
                            gradient: .init(colors: fillGradient.reduce_opacity(to: 0.2)),
                            startPoint: .init(x: 0.5, y: 0),
                            endPoint:   .init(x: 0.5, y: 1)))
                    
                    
                    LinearGradient(
                        gradient: .init(colors: fillGradient),
                        startPoint: .init(x: 0.5, y: 0),
                        endPoint:   .init(x: 0.5, y: 1))
                        .mask {
                            curvedPath(points: points)
                                .stroke(.white, style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round))
                        }
                    
                })
        }
    }
    
    private var line: some View {
        switch currentValueLineType {
            case .none:
                return AnyView(EmptyView())
            case .line(let color, let lineWidth):
                return AnyView(
                    currentValueLinePath(points: points)
                        .stroke(color, style: StrokeStyle(lineWidth: lineWidth))
                )
            case .dash(let color, let lineWidth, let dash):
                return AnyView(
                    currentValueLinePath(points: points)
                        .stroke(color, style: StrokeStyle(lineWidth: lineWidth, dash: dash))
                )
        }
    }
    
    // MARK: private functions
    private func curvedPath(points: [[CGPoint]]) -> Path {
        
        func mid(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
            return CGPoint(x: (point1.x + point2.x) / 2, y:(point1.y + point2.y) / 2)
        }
        
        func control(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
            
            var controlPoint = mid(point1, point2)
            let delta = abs(point2.y - controlPoint.y)
            
            if point1.y < point2.y { controlPoint.y += delta }
            else if point1.y > point2.y { controlPoint.y -= delta  }
            
            return controlPoint
        }
        
        var path = Path()
        //guard points[0].count > 1 else {  return path  }
        
        for n in points {
            
            var startPoint = n[0]
            path.move(to: startPoint)
            
            // Do if count is smaller than two
            if n.count < 2 {
                path.addLine(to: .init(x: (n[0].x) - 2, y: n[0].y))
                path.addLine(to: .init(x: (n[0].x) + 2, y: n[0].y))
            }
            else {
                for i in 0...n.count - 1   {
                    let currentPoint = n[i]
                    let midPoint = mid(startPoint, currentPoint)
                    
                    path.addQuadCurve(to: midPoint, control: control(midPoint, startPoint))
                    path.addQuadCurve(to: currentPoint, control: control(midPoint, currentPoint))
                    
                    startPoint = currentPoint
                }
            }
        }
        
        return path
    }
    
    private func curvedPathGradient(points: [[CGPoint]]) -> Path {
        
        var path = Path()
        
        for n in points {
            if n.count > 1 {
                var new_path = curvedPath(points: [n])
                new_path.addLine(to: .init(x: n.last!.x, y: frame.maxY))
                new_path.addLine(to: .init(x: n.first!.x,  y: frame.maxY))
                new_path.addLine(to: .init(x: n.first!.x,  y: n.last!.y))
                path.addPath(new_path)
            }
            else {
                var new_path = curvedPath(points: [n])
                new_path.addLine(to: .init(x: n[0].x + 2,  y: frame.maxY))
                new_path.addLine(to: .init(x: n[0].x - 2,  y: frame.maxY))
                new_path.addLine(to: .init(x: n[0].x - 2,      y: n[0].y))
                path.addPath(new_path)
            }
        }
        
        // print("curvedPathGradient - called")
        
        return path
    }
    
    private func currentValueLinePath(points: [[CGPoint]]) -> Path {
        var path = Path()
        
        for n in points {
            guard let lastPoint = n.last else {
                return path
            }
            path.move(to: CGPoint(x: 0, y: lastPoint.y))
            path.addLine(to: lastPoint)
        }
        
        return path
    }
    
}

@available(macOS 12.15, *)
extension Collection where Element == Color {
    
    func reduce_opacity(to: Double) -> [Color] {
        return self.map({ $0.opacity(to) })
    }
    
}

struct ChartLable : Hashable, Identifiable, Codable {
    var id: UUID = UUID()
    var lable: String
}


// MARK: - Line Chart
@available(macOS 12.15, *)
struct Chart : View {
    
    public init(values: [ChartData],
                xAxis: [ChartLable],
                yAxis: [ChartLable],
                min: Double,
                max: Double,
                enableDrag: Bool = false,
                selectedValue: Binding<Double>,
                show_X_Axis: Bool,
                show_Y_Axis: Bool,
                selectedIndex: Binding<Int>
    ) {
        self.values = values
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.min = min
        self.max = max
        self.enableDrag = enableDrag
        self._selectedValue = selectedValue
        self.show_X_Axis = show_X_Axis
        self.show_Y_Axis = show_Y_Axis
        self._selectedIndex = selectedIndex
    }
    
    init(values: [ChartData],
         xAxis: [ChartLable],
         yAxis: [ChartLable],
         min: Double,
         max: Double,
         selectedValue: Binding<Double>,
         selectedIndex: Binding<Int>) {
         self.init(values: values, xAxis: xAxis, yAxis: yAxis, min: min, max: max, selectedValue: selectedValue, show_X_Axis: true, show_Y_Axis: true, selectedIndex: selectedIndex)
    }

    
    var values : [ChartData]
    var xAxis  : [ChartLable]
    var yAxis  : [ChartLable]
    
    var min: Double
    var max: Double
 
    public var show_X_Axis: Bool = true
    public var show_Y_Axis: Bool = true
    
    var enableDrag: Bool = false
    @Binding var selectedValue: Double
    @Binding var selectedIndex : Int

    
    // Slider Stuff
    @State private var showSlider   : Bool = false
    @State private var sliderOffset : Double = 0
    
    @State private var index : Int = 0
 
    var body: some View {
        VStack {
            HStack {
                
                // Chart lable y
                
                if show_Y_Axis { chart_Y_Lable }
                
                GeometryReader { reader in
                    ZStack {
                        chartBackground
                        
                        // Charts
                            ForEach(values, id: \.id) { data in
                                CurvedChartView(data: data.values,
                                                frame:  CGRect(x: 0, y: 0, width: reader.frame(in: .local).width, height: reader.frame(in: .local).height),
                                                visualType: data.visualType,
                                                globalMax: max,
                                                globalMin: min,
                                                selected_index: $selectedIndex)
                               
                            }
                    }
                }
            }
            
            if show_X_Axis { chart_X_Lable }
            
        }
     
        .font(.system(size: 10))
    }
    
    var chartBackground : some View {
        
        ZStack {
            // horizontal Bars
            VStack {
                ForEach(1...yAxis.count, id: \.self) { i in
                    Divider()
                    if i != yAxis.count  { Spacer() }
                }
            }
            
            // vertical Bars
            HStack {
                ForEach(1...xAxis.count, id: \.self) { i in
                    Divider()
                    if i != xAxis.count  { Spacer() }
                }
            }
            
        }
    }
    
    var chart_X_Lable : some View {
        HStack(spacing: 0) {
            ForEach(Array(xAxis.enumerated()), id: \.offset) { index, observation in
                Text(verbatim: observation.lable)
                if index + 1 != xAxis.count  { Spacer() }
            }
        }
        .padding(.leading, 30) // 14
    }
    
    var chart_Y_Lable : some View {
        VStack(spacing: 0) {
            ForEach(Array(yAxis.enumerated()), id: \.offset) { index, observation in
                Text(verbatim: observation.lable)
                if index + 1 != yAxis.count  { Spacer() }
            }
        }
    }
    
//    func getExtrema(_ dataSet: [ChartData]) -> (Double, Double) {
//        print("finding extrema")
//        var min : [Double] = []
//        var max : [Double] = []
//
//        for n in dataSet {
//            min.append(n.values.min() ?? 0)
//            max.append(n.values.max() ?? 10)
//        }
//
//        if min.isEmpty || max.isEmpty {
//            return (0,1)
//        }
//        else { return (min.min()!, max.max()!) }
//    }

}

@available(macOS 12.15, *)
struct ChartData : Identifiable, Hashable {
    
    let id : UUID = UUID()
    
    let values : [Double]
    var color: Color
    let filled: Bool
    let lineWidth: CGFloat
    var gradient: [Color]? = nil
    var max_min: [Color]? = nil

    var visualType: CChartVisualType {
        if filled && gradient == nil {
            return .filled(color: color, lineWidth: lineWidth)
        }
        else if filled, let grad = gradient, let cc = max_min { return .customFilled(color: color,
                                                                                     lineWidth: lineWidth,
                                                                                     fillGradient: grad,
                                                                                     max_min: cc) }
        return .outline(color: color, lineWidth: lineWidth)
    }
}

@available(macOS 12.15, *)
public struct CurvedChartView: View, CDataRepresentable {
    
    private let data: [Double]
    private let frame: CGRect
    private let offset: Double
    private let type: CChartVisualType
    private let currentValueLineType: CCurrentValueLineType
    private var points: [CGPoint] = []
    
    @Binding var selected_index: Int
    
    private var color: Color = .red
    /// Creates a new `CurvedChart`
    ///
    /// - Parameters:
    ///     - data: A data set that should be presented on the chart
    ///     - frame: A frame from the parent view
    ///     - visualType: A type of chart, `.outline` by default
    ///     - offset: An offset for the chart, a space below the chart in percentage (0 - 1)
    ///               For example `offset: 0.2` means that the chart will occupy 80% of the upper
    ///               part of the view
    ///     - currentValueLineType: A type of current value line (`none` for no line on chart)
    public init(data: [Double],
                frame: CGRect,
                visualType: CChartVisualType = .outline(color: .red, lineWidth: 2),
                offset: Double = 0,
                currentValueLineType: CCurrentValueLineType = .none,
                globalMax: Double,
                globalMin: Double,
                selected_index: Binding<Int>)
    {
        self.data = data
        self.frame = frame
        self.type = visualType
        self.offset = offset
        self.currentValueLineType = currentValueLineType
        self._selected_index = selected_index
        
        self.points = points(forData: data,
                             frame: frame,
                             offset: offset,
                             lineWidth: lineWidth(visualType: visualType),
                             max: globalMax,
                             min: globalMin)
        
        switch type {
            case .outline(let color, _):
                self.color = color
            case .filled(let color, _):
                self.color = color
            case .customFilled(let color, _, _, _):
                self.color = color
        }
    }
    
    @State private var showSlider: Bool = false
    @State private var sliderOffset: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme

    public var body: some View {
        GeometryReader { reader in
            ZStack {
                chart
                      .rotationEffect(.degrees(180), anchor: .center)
                      .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                      .drawingGroup()
                
                line
                      .rotationEffect(.degrees(180), anchor: .center)
                      .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                      .drawingGroup()
                
                
              }
                .overlay (
                    ZStack {
                        Rectangle().frame(width: 1.2).foregroundColor(.gray)
                            .opacity(showSlider == true ? 1 : 0)
                    }
                    .offset(x: sliderOffset),
                    alignment: .bottomLeading
                )
                .contentShape(Rectangle())
                .gesture(DragGesture().onChanged({ value in
                    // show slider
                    withAnimation { showSlider = true  }
    
                    // change slider position, prevent from sliding out of box
                    if value.location.x < 0 || value.location.x > reader.size.width {}
                    else {
                        let stepsize = (reader.size.width - 1)  / CGFloat(points.count - 1)
                        let index = Int((value.location.x / stepsize).rounded(.down))
                        
                        if points.count >= index {
                            if selected_index != index {
                                
                            }
                            withAnimation(.linear(duration: 0.1)) {
                                sliderOffset = points[index].x; selected_index = index
                            }
                        }
                        else { sliderOffset = value.location.x }
                    }

                }).onEnded({ value in
                    withAnimation { showSlider = false  }
                    // selectedValue = values[0].values.last ?? -9999
                }))
        }
                            
            
    }
    
    func maxPoint() -> CGPoint? {
        return points.max(by: { $0.y < $1.y })
    }
    
    func lowPoint() -> CGPoint? {
        return points.max(by: { $0.y > $1.y })
    }
    
    private var chart: some View {
        
        switch type {
                
            case .outline(let color, let lineWidth):
                return AnyView(curvedPath(points: points)
                    .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round)))
                
                
            case .filled(let color, let lineWidth):
                return AnyView(ZStack {
                    curvedPathGradient(points: points)
                        .fill(LinearGradient(
                            gradient: .init(colors: [color.opacity(0.2), color.opacity(0.02)]),
                            startPoint: .init(x: 0.5, y: 1),
                            endPoint: .init(x: 0.5, y: 0)
                        ))
                    curvedPath(points: points)
                        .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round))
                })
                
                
            case .customFilled(let color, let lineWidth, let fillGradient, _):
                return AnyView(ZStack {
                    curvedPathGradient(points: points)
                        .fill(LinearGradient(
                            gradient: .init(colors: [fillGradient.first?.opacity(0.2) ?? .red,
                                                     fillGradient.last?.opacity(0.02) ?? .orange]),
                            startPoint: .init(x: 0.5, y: 1),
                            endPoint: .init(x: 0.5, y: 0)
                        ))
                    
                    curvedPath(points: points)
                        .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round))
                })
        }
    }
    
    private var line: some View {
        switch currentValueLineType {
            case .none:
                return AnyView(EmptyView())
            case .line(let color, let lineWidth):
                return AnyView(
                    currentValueLinePath(points: points)
                        .stroke(color, style: StrokeStyle(lineWidth: lineWidth))
                )
            case .dash(let color, let lineWidth, let dash):
                return AnyView(
                    currentValueLinePath(points: points)
                        .stroke(color, style: StrokeStyle(lineWidth: lineWidth, dash: dash))
                )
        }
    }
    
    
    // MARK: private functions
    
    private func curvedPath(points: [CGPoint]) -> Path {
        
        func mid(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
            return CGPoint(x: (point1.x + point2.x) / 2, y:(point1.y + point2.y) / 2)
        }
        
        func control(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
            
            var controlPoint = mid(point1, point2)
            let delta = abs(point2.y - controlPoint.y)
            
            if point1.y < point2.y { controlPoint.y += delta }
            else if point1.y > point2.y { controlPoint.y -= delta  }
            
            return controlPoint
        }
        
        var path = Path()
        guard points.count > 1 else {  return path  }
        
        var startPoint = points[0]
        path.move(to: startPoint)
        
        guard points.count > 2 else {
            path.addLine(to: points[1])
            return path
        }
        
        for i in 1..<points.count {
            let currentPoint = points[i]
            let midPoint = mid(startPoint, currentPoint)
            
            path.addQuadCurve(to: midPoint, control: control(midPoint, startPoint))
            path.addQuadCurve(to: currentPoint, control: control(midPoint, currentPoint))
            
            startPoint = currentPoint
        }
        return path
    }
    
    private func curvedPathGradient(points: [CGPoint]) -> Path {
        var path = curvedPath(points: points)
        guard let lastPoint = points.last else {  return path  }
        path.addLine(to: CGPoint(x: lastPoint.x, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: points[0].y))
        
        return path
    }
    
    private func currentValueLinePath(points: [CGPoint]) -> Path {
        var path = Path()
        guard let lastPoint = points.last else {
            return path
        }
        path.move(to: CGPoint(x: 0, y: lastPoint.y))
        path.addLine(to: lastPoint)
        
        return path
    }
}


@available(macOS 12.15, *)
protocol CDataRepresentable {
    func points(forData data: [Double], frame: CGRect, offset: Double, lineWidth: CGFloat, max: Double, min: Double) -> [CGPoint]
    func lineWidth(visualType: CChartVisualType) -> CGFloat
}

@available(macOS 12.15, *)
extension CDataRepresentable {
    
    func points(forData data: [Double], frame: CGRect, offset: Double, lineWidth: CGFloat, max: Double, min: Double) -> [CGPoint] {
        let vector = CMath.norm(data, min: min, max: max)
        
        var points: [CGPoint] = []
        //let isSame = sameValues(in: vector)
        for i in 0..<vector.count {
            let x = frame.size.width / CGFloat(vector.count - 1) * CGFloat(i)
            let y = (frame.size.height - lineWidth) * CGFloat(vector[i]) + lineWidth / 2
            points.append(CGPoint(x: x, y: y))
        }
        return points
    }
    
    
    func advanced_points(forData data: [Double], frame: CGRect, offset: Double, lineWidth: CGFloat, max: Double, min: Double, error_value: Double) -> [[CGPoint]] {
        let vector = CMath.advanced_norm(data, min: min, max: max, error_value: error_value)
        let vector_count = vector.count
 
        var points: [[CGPoint]] = []
        let splited_vector: [[Double]] = vector.create_subs(for: error_value)
        var index: Int = 0
        
        for n in splited_vector {
            if n.contains(where: { $0 <= error_value }) {
                for _ in n { index += 1 }
            }
            else {
                var container: [CGPoint] = []
                for i in n {
                    let x = frame.size.width / CGFloat(vector_count - 1) * CGFloat(index)
                    let y = (frame.size.height - lineWidth) * CGFloat(i) + lineWidth / 2
                    container.append(CGPoint(x: x, y: y))
                    index += 1
                }
                points.append(container)
            }
        }

        return points
    }
    
    func lineWidth(visualType: CChartVisualType) -> CGFloat {
        switch visualType {
            case .outline(_, let lineWidth):
                return lineWidth
            case .filled(_, let lineWidth):
                return lineWidth
            case .customFilled(_, let lineWidth, _, _):
                return lineWidth
        }
    }
    
    private func sameValues(in vector: [Double]) -> Bool {
        guard let prev = vector.first else {
            return true
        }
        for value in vector {
            if value != prev {
                return false
            }
        }
        return true
    }
}

@available(macOS 12.15, *)
extension Collection where Element == Double {
    
    func create_subs(for error: Double) -> [[Double]] {
        var container: [[Double]] = []
        var last_is_error: Bool = false
        var index: Int? = nil
        
        for n in self {
            // Do if value is error
            if n == error {
                if let i = index {
                    if last_is_error == true {
                        container[i].append(n)
                    }
                    else {
                        container.append([n])
                        last_is_error = true
                        index! += 1
                    }
                }
                else { container.append([n]); index = 0; last_is_error = true } // create first element in container and set it to be an error container
            }
            
            // Do if value is not error
            else {
                if let i = index {
                    if last_is_error == true {
                        container.append([n])
                        last_is_error = false
                        index! += 1
                    }
                    else { container[i].append(n) }
                }
                else { container.append([n]); index = 0 } // create first element in container and set leave it on default container
            }
        }
        
        return container
    }
    
}

public enum CChartType {
    case line
    case curved
}

@available(macOS 12.15, *)
public enum CChartVisualType {
    case outline(color: Color, lineWidth: CGFloat)
    case filled(color: Color, lineWidth: CGFloat)
    case customFilled(color: Color, lineWidth: CGFloat, fillGradient: [Color], max_min: [Color])
}

@available(macOS 12.15, *)
public enum CCurrentValueLineType {
    case none
    case line(color: Color, lineWidth: CGFloat)
    case dash(color: Color, lineWidth: CGFloat, dash: [CGFloat])
}

struct CMath {
    
//    static func norm(_ vector: [Double], min: Double, max: Double) -> [Double] {
//        let norm = sqrt(Double(vector.reduce(0) { $0 + $1 * $1 }))
//        return norm == 0 ? vector : vector.map { $0 / norm }
//        //   return vector.map { ($0 - min) / (max - min)  }
//    }
    
    static func norm(_ vector: [Double], min: Double, max: Double) -> [Double] {
        return vector.map { ($0 - min) / (max - min)  }
    }
    
    static func advanced_norm(_ vector: [Double], min: Double, max: Double, error_value: Double) -> [Double] {
        return vector.map { n in
            if n <= error_value { return error_value }
            else {
                return (1 - (n - min) / (max - min))
            }
        }
    }
    
    static func stretchOut(_ vector: [Double], min: Double, max rawMax: Double) -> [Double] {
        guard let min = vector.min(),
            let rawMax = vector.max() else {
            return vector
        }
        let max = rawMax - min
//        return vector // vector.map { ($0 - min) / (max != 0 ? max : 1) }
        return vector.map { ($0 - min) / (max != 0 ? max : 1) }

    }
    
    static func stretchIn(_ vector: [Double], offset: Double) -> [Double] {
        guard let max = vector.max() else {
            return vector
        }
        let newMax = max - offset
        return vector.map { $0 * newMax + offset }
    }
}


// MARK: Radar Chart
@available(macOS 12.15, *)
struct RadarChart: View {
    var data: [Double]
    let gridColor: Color
    let dataColor: Color
    
    init(data: [Double], gridColor: Color = .gray, dataColor: Color = .blue) {
        self.data = data
        self.gridColor = gridColor
        self.dataColor = dataColor
    }
    
    var body: some View {
        ZStack {
            RadarChartGrid(categories: data.count, divisions: 4)
                .stroke(gridColor, lineWidth: 0.5)
            
            RadarChartPath(data: data)
                .fill(dataColor.opacity(0.3))
            
            RadarChartPath(data: data)
                .stroke(dataColor, lineWidth: 2.0)
        }
    }
}

@available(macOS 12.15, *)
struct RadarChartPath: Shape {
    let data: [Double]
    
    func path(in rect: CGRect) -> Path {
        guard
            3 <= data.count,
            let minimum = data.min(),
            0 <= minimum,
            let maximum = data.max()
        else { return Path() }
        
        let radius = min(rect.maxX - rect.midX, rect.maxY - rect.midY)
        var path = Path()
        
        for (index, entry) in data.enumerated() {
            switch index {
                case 0:
                    path.move(to: CGPoint(x: rect.midX + CGFloat(entry / maximum) * cos(CGFloat(index) * 2 * .pi / CGFloat(data.count) - .pi / 2) * radius,
                                          y: rect.midY + CGFloat(entry / maximum) * sin(CGFloat(index) * 2 * .pi / CGFloat(data.count) - .pi / 2) * radius))
                    
                default:
                    path.addLine(to: CGPoint(x: rect.midX + CGFloat(entry / maximum) * cos(CGFloat(index) * 2 * .pi / CGFloat(data.count) - .pi / 2) * radius,
                                             y: rect.midY + CGFloat(entry / maximum) * sin(CGFloat(index) * 2 * .pi / CGFloat(data.count) - .pi / 2) * radius))
            }
        }
        path.closeSubpath()
        return path
    }
}

@available(macOS 12.15, *)
struct RadarChartGrid: Shape {
    let categories: Int
    let divisions: Int
    
    func path(in rect: CGRect) -> Path {
        let radius = min(rect.maxX - rect.midX, rect.maxY - rect.midY)
        let stride = radius / CGFloat(divisions)
        var path = Path()
        
        for category in 1 ... categories {
            path.move(to: CGPoint(x: rect.midX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX + cos(CGFloat(category) * 2 * .pi / CGFloat(categories) - .pi / 2) * radius,
                                     y: rect.midY + sin(CGFloat(category) * 2 * .pi / CGFloat(categories) - .pi / 2) * radius))
        }
        
        for step in 1 ... divisions {
            let rad = CGFloat(step) * stride
            path.move(to: CGPoint(x: rect.midX + cos(-.pi / 2) * rad,
                                  y: rect.midY + sin(-.pi / 2) * rad))
            
            for category in 1 ... categories {
                path.addLine(to: CGPoint(x: rect.midX + cos(CGFloat(category) * 2 * .pi / CGFloat(categories) - .pi / 2) * rad,
                                         y: rect.midY + sin(CGFloat(category) * 2 * .pi / CGFloat(categories) - .pi / 2) * rad))
            }
        }
        
        return path
    }
}

