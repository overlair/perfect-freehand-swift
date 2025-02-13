//
//  ContentView.swift
//  PerfectFreehandExample
//
//  Created by John Knowles on 2/13/25.
//

import SwiftUI
import Combine
import PerfectFreehand

struct InProgressStroke: Hashable {
    let path: CGPath?
    let isFinished: Bool
}

struct Stroke: Identifiable, Hashable {
    let id = UUID()
    let path: CGPath
}


struct ContentView: View {
    @State var strokes = [Stroke]()
    @State var inProgressPath = CGPath?.none
    
    let inProgressStroke = PassthroughSubject<InProgressStroke, Never>()
    var body: some View {
        ZStack {
            Color.clear
                .overlay(touchesView)
                .contentShape(Rectangle())
            
            Group {
                ForEach(strokes) { stroke in
                    Path(stroke.path)
                        .fill(.blue)
                }
                
                if let path = inProgressPath {
                    Path(path)
                        .fill(.blue)
                }
            }
            .allowsHitTesting(false)
        }
        .overlay(alignment: .topTrailing, content: closeButton)
        .onReceive(inProgressStroke, perform: handleInProgressStroke)
    }
    
    
    @ViewBuilder var closeButton: some View {
        Button(action: clearStrokes) {
            Image(systemName: "xmark.circle.fill")
                .font(Font.system(size: 35, weight: .bold))
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.hierarchical)
        }
        .padding(10)
    }
    
    @ViewBuilder var touchesView: some View {
        TouchesRepresentable(inProgressStroke: inProgressStroke)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func handleInProgressStroke(_ stroke: InProgressStroke) {
        if stroke.isFinished {
            if let path = stroke.path {
                strokes.append(.init(path: path))
            }
            inProgressPath = nil
        } else {
            inProgressPath = stroke.path
        }
    }
    
    func clearStrokes() {
        strokes = []
        inProgressPath = nil
    }
}

struct TouchesRepresentable: UIViewRepresentable {
    let inProgressStroke: PassthroughSubject<InProgressStroke, Never>

    func makeUIView(context: Context) -> some UIView {
        let v = TouchesView(inProgressStroke: inProgressStroke)
        return v
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

class TouchesView: UIView {
    let inProgressStroke: PassthroughSubject<InProgressStroke, Never>

    init(inProgressStroke: PassthroughSubject<InProgressStroke, Never>) {
        self.inProgressStroke = inProgressStroke
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var currentTouch:  UITouch? = nil
    
    var inProgressStrokePoints: [FreehandPoint] = []
    let strokeOptions = FreehandOptions(size: 24,
                                    simulatePressure: true,
                                  start: .init(cap: true, taper: nil, easing:  { t in t }),
                                  end: .init(cap: true, taper: nil, easing:  { t in t }))
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first
        else {
            return
        }
        
        currentTouch = touch
        
        if !inProgressStrokePoints.isEmpty {
            inProgressStrokePoints = []
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first(where: { touch in
            touch == currentTouch
        })
        else {
            return
        }
        
        let location = touch.location(in: touch.view)
        
        
        let pPoint = FreehandPoint(point: location, pressure: nil)
        
        inProgressStrokePoints.append(pPoint)
        let path = inProgressStrokePoints.getPath(options: strokeOptions)
     
        inProgressStroke.send(.init(path: path, isFinished: false))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first(where: { touch in
            touch == currentTouch
        })
        else {
            return
        }
        
        let path = inProgressStrokePoints.getPath(options: strokeOptions)

        inProgressStroke.send(.init(path: path, isFinished: true))

        resetInProgressStroke()
 
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first(where: { touch in
            touch == currentTouch
        })
        else {
            return
        }
        
        resetInProgressStroke()

        inProgressStroke.send(.init(path: nil, isFinished: true))
    }
    
    func resetInProgressStroke() {
        inProgressStrokePoints = []
        currentTouch = nil
    }
}


#Preview {
    ContentView()
}
