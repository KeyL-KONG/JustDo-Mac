//
//  iOSReviewNoteView.swift
//  ToDo
//
//  Created by ByteDance on 8/11/25.
//

import SwiftUI

struct ReviewNoteItem {
    let question: String
    let answer: String
    let score: Int
    let id: String
}

struct iOSReviewNoteView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    @State var noteItems: [ReviewNoteItem] = []
    @State private var isFlipped = false
    @State private var currentIndex = 0
    
    var body: some View {
        VStack {
            if noteItems.isEmpty {
                Text("Empty")
                    .font(.title3)
                    .foregroundColor(.gray)
            } else {
                Text("Index: \(currentIndex) Score: \(noteItems[currentIndex].score)").font(.title)
                ScrollView {
                    FlashCardView(
                        noteItem: noteItems[currentIndex],
                        isFlipped: $isFlipped,
                        onSwipe: { direction in
                            withAnimation {
                                switch direction {
                                case .left:
                                    currentIndex = min(currentIndex + 1, noteItems.count - 1)
                                case .right:
                                    currentIndex = max(currentIndex - 1, 0)
                                }
                                isFlipped = false
                            }
                        }
                    )
                }
                
                
                ControlButtons(
                    isFlipped: $isFlipped,
                    onAnswer: { updateScore(0) },
                    onShowAnswer: { isFlipped.toggle() },
                    onRemember: { updateScore(2) }
                )
            }
        }
        .onAppear {
            self.noteItems = modelData.noteItemList.filter { $0.title.count > 0 && $0.content.count > 0 }.compactMap({ item in
                return ReviewNoteItem(question: item.title, answer: item.content, score: item.score, id: item.id)
            }) + modelData.noteList.compactMap({ item in
                let desc = item.overview.count > 0 ? item.overview : item.title
                return ReviewNoteItem(question: desc, answer: item.content, score: item.score, id: item.id)
            }).sorted(by: { $0.score < $1.score })
        }
        
    }
        
    private func updateScore(_ level: Int) {
        guard !noteItems.isEmpty else { return }
        
        let currentNote = noteItems[currentIndex]
        
        if var noteModel = modelData.noteList.first(where: {  $0.id == currentNote.id
        }) {
            if level == 0 {
                noteModel.stTimes.append(Date())
            } else if level == 2 {
                noteModel.faTimes.append(Date())
            }
            modelData.updateNote(noteModel)
        } else if var noteItem = modelData.noteItemList.first(where: { $0.id == currentNote.id
        }) {
            if level == 0 {
                noteItem.stTimes.append(Date())
            } else if level == 2 {
                noteItem.faTimes.append(Date())
            }
            modelData.updateNoteItem(noteItem)
        }
        
        // 自动切换下个条目
        if currentIndex < noteItems.count - 1 {
            currentIndex += 1
        }
        isFlipped = false
    }
        
    private func calculateNewScore(level: Int) -> Int {
        switch level {
        case 0: // 陌生
            return max(noteItems[currentIndex].score - 2, 0)
        case 2: // 熟悉
            return noteItems[currentIndex].score + 3
        default: // 答案（不改变分数）
            return noteItems[currentIndex].score
        }
    }
        
}

// 按钮样式
struct ScoreButtonStyle: ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(color.opacity(0.3))
            .foregroundColor(color)
            .cornerRadius(10)
    }
}

// 提取子视图
struct FlashCardView: View {
    let noteItem: ReviewNoteItem
    @Binding var isFlipped: Bool
    var onSwipe: (SwipeDirection) -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(isFlipped ? Color.gray.opacity(0.2) : Color.blue.opacity(0.2))
            
            ScrollView {
                VStack {
                    if isFlipped {
                        MarkdownWebView(noteItem.answer, itemId: noteItem.id)
                            .padding()
                    } else {
                        MarkdownWebView(noteItem.question, itemId: noteItem.id)
                            .font(.title)
                            .padding()
                    }
                    
                }
            }
            
        }
        .frame(minHeight: 400)
//        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
//        .animation(.easeInOut(duration: 0.3), value: isFlipped)
//        .gesture(DragGesture()
//            .onEnded { value in
//                if value.translation.width < -100 {
//                    onSwipe(.left)
//                } else if value.translation.width > 100 {
//                    onSwipe(.right)
//                }
//            })
    }
}

struct ControlButtons: View {
    @Binding var isFlipped: Bool
    var onAnswer: () -> Void
    var onShowAnswer: () -> Void
    var onRemember: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onAnswer) {
                VStack {
                    Image(systemName: "xmark.circle")
                    Text("陌生")
                }
            }
            
            Button(action: onShowAnswer) {
                VStack {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text(isFlipped ? "隐藏答案" : "显示答案")
                }
            }
            
            Button(action: onRemember) {
                VStack {
                    Image(systemName: "checkmark.circle")
                    Text("熟悉")
                }
            }
        }
        .buttonStyle(ScoreButtonStyle(color: .blue))
    }
}

enum SwipeDirection {
    case left
    case right
}
