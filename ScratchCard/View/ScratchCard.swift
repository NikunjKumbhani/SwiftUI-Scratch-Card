//
//  Home.swift
//  ScratchCard
//
//  Created by Nik Kumbhani on 02/08/21.
//

import SwiftUI

struct ScratchCard: View {
    @State var onFinish : Bool = false
    var body: some View {
        VStack{
            // Scratch Card View...
            ScratchCardView(cursorSize:45,onFinish: $onFinish){
                // Body View
                VStack {
                    Image("trophy")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(10)
                    
                    Text("You've Won")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("$999.99")
                        .font(.title)
                        .foregroundColor(.gray)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top,5)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                
                
            } overlayView: {
                // Overlay View
                Image("scratch")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .overlay(
            HStack{
                
                Button {
                    
                } label:{
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                Text("Scratch Card".uppercased())
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer(minLength: 0)
                Button (action: {
                    onFinish = false
                },label:{
                    Image("pic")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 55, height: 55)
                        .clipShape(Circle())
                })
            }
            .padding()
            ,alignment: .top
            
        )
    }
}

struct ScratchCard_Previews: PreviewProvider {
    static var previews: some View {
        ScratchCard()
    }
}

// Custom View...
struct ScratchCardView<Content:View,OverlayView: View>: View {
    var content: Content
    var overlayView:OverlayView
    
    init(cursorSize: CGFloat,onFinish:Binding<Bool>,@ViewBuilder content: @escaping ()->Content,@ViewBuilder overlayView: @escaping ()->OverlayView) {
        self.content = content()
        self.overlayView = overlayView()
        self.cursorSize = cursorSize
        self._onFinish = onFinish
    }
    
    // For Scratch Effect...
    @State var startingPoint : CGPoint = .zero
    @State var points : [CGPoint] = []
    
    // For Gesture Update...
    @GestureState var gestureLocation: CGPoint = .zero
    
    // Customisation and on finish....
    var cursorSize: CGFloat
    @Binding var onFinish: Bool
    
    var body: some View{
        ZStack{
            
            overlayView
                .opacity(onFinish ? 0 : 1)
            // Logic is when user start scratching the main content will be visible based on user drag location...
            // and display full content when the user release the drag....
            content
                .mask(
                    ZStack{
                        if !onFinish{
                            ScratchMask(points: points, startingPoint: startingPoint)
                                    .stroke(style: StrokeStyle(lineWidth: cursorSize, lineCap: .round, lineJoin: .round))
                        }else{
                            // Show Full Content
                            Rectangle()
                        }
                    }
                )
                .animation(.easeInOut)
                .gesture(
                    DragGesture()
                        .updating($gestureLocation, body: { value, out, _ in
                        out = value.location
                        DispatchQueue.main.async {
                            if startingPoint == .zero{
                                startingPoint = value.location
                            }
                            points.append(value.location)
                            print(points)
                        }
                    })
                        .onEnded({ value in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.easeInOut){
                                onFinish = true
                                }
                            }
                        })
                )
                
        }
        .frame(width: 300, height: 300)
        .cornerRadius(20)
        .onChange(of: onFinish, perform: { value in
            if !onFinish && !points.isEmpty{
                withAnimation(.easeInOut){
                    resetView()
                }
            }
        })
    }
    
    func resetView(){
        points.removeAll()
        startingPoint = .zero
    }
}

// Scratch Mask Shape..
struct ScratchMask: Shape {
    var points: [CGPoint]
    var startingPoint: CGPoint
    
    func path(in rect: CGRect) -> Path {
        return Path{ path in
            path.move(to: startingPoint)
            path.addLines(points)
        }
    }
    
}
