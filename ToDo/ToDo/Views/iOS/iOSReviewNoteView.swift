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
    let createTime: Date
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
                
                HStack {
                    Text("Index: \(currentIndex) Score: \(noteItems[currentIndex].score)").font(.title2)
                    
                    Spacer()
                    
                    Button {
                        self.removeItem()
                    } label: {
                        Image(systemName: "trash.circle.fill").font(.title)
                    }

                }.padding()
                
                
                List {
                    
                    Section {
                            FlashCardView(content: noteItems[currentIndex].question, color: Color.gray.opacity(0.2))
                            .listRowSeparator(.hidden)
                    } header: {
                        Text("Q:").font(.title).bold()
                    }

                    if isFlipped {
                        Section {
                                FlashCardView(content: noteItems[currentIndex].answer, color: Color.blue.opacity(0.2))
                                .listRowSeparator(.hidden)
                        } header: {
                            Text("A:").font(.title).bold().foregroundStyle(.blue)
                        }
                    }
                }
                .listStyle(.plain)
                
                
                ControlButtons(
                    isFlipped: $isFlipped,
                    onAnswer: { updateScore(0) },
                    onShowAnswer: { isFlipped.toggle() },
                    onRemember: { updateScore(2) }, changeIndex: { index in
                        self.isFlipped = false
                        self.currentIndex = min(max(self.currentIndex + index, 0), self.noteItems.count-1)
                    }
                )
            }
        }
        .onAppear {
            self.noteItems = modelData.noteItemList.filter { $0.title.count > 0 && $0.content.count > 0 && !$0.hasReview(date: .now) && $0.needReview }.compactMap({ item in
                return ReviewNoteItem(question: item.title, answer: item.content, score: item.score, id: item.id, createTime: (item.createTime ?? Date()))
            }) + modelData.noteList.filter({ $0.title.count > 0 && $0.content.count > 0 && !$0.hasReview(date: .now) && $0.needReview
            }).compactMap({ item in
                let desc = item.overview.count > 0 ? item.overview : item.title
                return ReviewNoteItem(question: desc, answer: item.content, score: item.score, id: item.id, createTime: (item.createTime ?? Date()))
            })
            .sorted(by: { first, second in
                if first.score != second.score {
                    return first.score < second.score
                }
                return first.createTime > second.createTime
            })
            self.currentIndex = 0
            self.isFlipped = false
        }
        
    }
    
    private func removeItem() {
        guard currentIndex >= 0  && currentIndex < noteItems.count else {
            return
        }
        let removeItem = noteItem(with: noteItems[currentIndex])
        if let noteItem = removeItem as? NoteItem {
            noteItem.needReview = false
            modelData.updateNoteItem(noteItem)
        } else if let noteModel = removeItem as? NoteModel {
            noteModel.needReview = false
            modelData.updateNote(noteModel)
        }
        
        noteItems.remove(at: currentIndex)
    }
    
    func noteItem(with item: ReviewNoteItem) -> BaseModel? {
        if let noteModel = modelData.noteList.first(where: {  $0.id == item.id
        }) {
            return noteModel
        } else if let noteItem = modelData.noteItemList.first(where: { $0.id == item.id
        }) {
            return noteItem
        }
        return nil
    }
        
    private func updateScore(_ level: Int) {
        guard !noteItems.isEmpty else { return }
        
        let currentNote = noteItems[currentIndex]
        
        if let noteModel = modelData.noteList.first(where: {  $0.id == currentNote.id
        }) {
            if level == 0 {
                noteModel.stTimes.append(Date())
            } else if level == 2 {
                noteModel.faTimes.append(Date())
            }
            modelData.updateNote(noteModel)
        } else if let noteItem = modelData.noteItemList.first(where: { $0.id == currentNote.id
        }) {
            if level == 0 {
                noteItem.stTimes.append(Date())
            } else if level == 2 {
                noteItem.faTimes.append(Date())
            }
            modelData.updateNoteItem(noteItem)
        }
        isFlipped = true
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
    var horizonPadding: CGFloat = 15
    var verticalPadding: CGFloat = 8
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, horizonPadding)
            .padding(.vertical, verticalPadding)
            .background(color.opacity(0.3))
            .foregroundColor(color)
            .cornerRadius(10)
    }
}

// 提取子视图
struct FlashCardView: View {
    let content: String
    let color: Color
    
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(color)
            
            MarkdownWebView(content)
                        .padding()
        }
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
    var changeIndex:(Int) -> Void
    
    var body: some View {
        HStack {
            Button {
                changeIndex(-1)
            } label: {
                Image(systemName: "arrowshape.left")
            }.buttonStyle(ScoreButtonStyle(color: .red))

            Button(action: onAnswer) {
                Text("陌生")
            }.buttonStyle(ScoreButtonStyle(color: .red))
            
            Button(action: onShowAnswer) {
                Text(isFlipped ? "隐藏答案" : "显示答案")
            }.buttonStyle(ScoreButtonStyle(color: .blue))
            
            Button(action: onRemember) {
                Text("熟悉")
            }.buttonStyle(ScoreButtonStyle(color: .green))
            
            Button {
                changeIndex(1)
            } label: {
                Image(systemName: "arrowshape.right")
            }.buttonStyle(ScoreButtonStyle(color: .green))
        }
    }
}

enum SwipeDirection {
    case left
    case right
}
