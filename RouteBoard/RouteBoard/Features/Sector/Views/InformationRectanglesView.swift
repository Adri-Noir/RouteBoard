//
//  InformationRectanglesView.swift
//  RouteBoard
//
//  Created by Adrian Cvijanovic on 03.07.2024..
//

import SwiftUI

struct InformationRectangle<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let isExpanded: Bool
    let shouldDisappear: Bool
    let expandedSize: CGFloat
    @ViewBuilder let content: Content;
    
    
    var body: some View {
        if !shouldDisappear {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 20, style: .circular)
                    .frame(height: isExpanded ? expandedSize : 100)
                
                VStack(alignment: .leading, spacing: 10) {
                    content
                        .foregroundStyle(shouldDisappear ? .white : .black)
                        .animation(.spring, value: isExpanded)
                }
                .padding()
            }
            .animation(.spring, value: isExpanded)
        }
    }
}

struct InformationRectanglesView<AscentsContent: View>: View {
    @State private var selectedBox: Int? = nil
    @State private var showDelayedView: Bool = false
    
    let handleOpenRoutesView: () -> Void;
    let handleLike: () -> Void;
    @ViewBuilder let ascentsGraph: AscentsContent;
    let gradesGraphModel: GradesGraphModel;
    
    func handleToggleSelectedBox(box: Int) {
        if selectedBox == box {
            withAnimation {
                showDelayedView = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation {
                    selectedBox = nil
                }
            }
        } else {
            withAnimation {
                selectedBox = box
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation {
                    showDelayedView = true
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: selectedBox != nil ? 0 : 15) {
            HStack(alignment: .center, spacing: 15) {
                
                InformationRectangle(isExpanded: selectedBox == 1, shouldDisappear: selectedBox != 1 && selectedBox != nil, expandedSize: 200) {
                    Text("15")
                        .bold()
                        .font(.system(size: 24))
                    HStack {
                        Image(systemName: "arrow.up.square")
                        Text("Routes")
                    }
                }
                .onTapGesture {
                    handleOpenRoutesView()
                }
                
                InformationRectangle(isExpanded: selectedBox == 2, shouldDisappear: selectedBox != 2 && selectedBox != nil, expandedSize: 200) {
                    Text("34")
                        .bold()
                        .font(.system(size: 24))
                    HStack {
                        Image(systemName: "hand.thumbsup")
                        Text("Likes")
                    }
                }
                .onTapGesture {
                    handleLike()
                }
            }
            
            
            HStack(alignment: .center, spacing: 15) {
                InformationRectangle(isExpanded: selectedBox == 3, shouldDisappear: selectedBox != 3 && selectedBox != nil, expandedSize: 400) {
                    if selectedBox == 3 && showDelayedView {
                        ascentsGraph
                    }
                    Text("20")
                        .bold()
                        .font(.system(size: 24))
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Ascents")
                    }
                    
                }
                .onTapGesture {
                    handleToggleSelectedBox(box: 3)
                }
                .onTapBackground(enabled: selectedBox == 3) {
                    handleToggleSelectedBox(box: 3)
                }
                
                InformationRectangle(isExpanded: selectedBox == 4, shouldDisappear: selectedBox != 4 && selectedBox != nil, expandedSize: 400) {
                    if selectedBox == 4 && showDelayedView {
                        GradesGraphView(gradesModel: gradesGraphModel)
                    }
                    Text(gradesGraphModel.minGrade + " - " + gradesGraphModel.maxGrade)
                        .bold()
                        .font(.system(size: 24))
                    HStack {
                        Image(systemName: "grid.circle.fill")
                        Text("Grades")
                    }
                    
                }
                .onTapGesture {
                    handleToggleSelectedBox(box: 4)
                }
                .onTapBackground(enabled: selectedBox == 4) {
                    handleToggleSelectedBox(box: 4)
                }
            }
        }
    }
}

extension View {
    @ViewBuilder
    private func onTapBackgroundContent(enabled: Bool, _ action: @escaping () -> Void) -> some View {
        if enabled {
            Color.clear
                .frame(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2)
                .contentShape(Rectangle())
                .onTapGesture(perform: action)
        }
    }

    func onTapBackground(enabled: Bool, _ action: @escaping () -> Void) -> some View {
        background(
            onTapBackgroundContent(enabled: enabled, action)
        )
    }
}
