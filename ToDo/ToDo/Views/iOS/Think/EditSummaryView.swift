//
//  EditSummaryView.swift
//  Summary
//
//  Created by LQ on 2024/5/5.
//

import SwiftUI

struct EditSummaryView: View {
    
    enum FocusedField {
        case title
        case review
    }
    
    @EnvironmentObject var modelData: ModelData
    @Binding var showSheetView: Bool
    @Binding var showEditTagView: Bool
    
    @State private var reviewText: String = ""
    @State private var improveText: String = ""
    @State var taskType: String = ""
    @State var selectedTag: String = ""
    @State var selectTask: String = ""
    
    var summaryItem: SummaryItem?
    
    var task: (any BasicTaskProtocol)?
    
    private static var selectTags: [String] = [] {
        didSet {
            print("select tags: \(selectTags)")
        }
    }
    
    var tag: ItemTag {
        guard let task else { return .work }
        return modelData.tagList.first { $0.id == task.tag } ?? .work
    }
    
    var taskList: [any BasicTaskProtocol] {
        return modelData.rewardList + modelData.itemList
    }
    
    var tagList: [SummaryTag] {
        modelData.summaryTagList
    }
    
    var tags: [String] {
        var tags: [String] = tagList.compactMap { $0.content }
        tags.append("")
        return tags
    }
    
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        NavigationView {
            VStack {
#if os(iOS)
                Text("")
                    .navigationBarTitle(Text("复盘"), displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {
                        self.showSheetView = false
                    }, label: {
                        Text("取消").bold()
                    }), trailing: Button(action: {
                        self.updateSummaryItem()
                        self.showSheetView = false
                    }, label: {
                        Text("保存").bold()
                    }))
#endif
                
                List {
                    
                    Section {
                        TextEditor(text: $reviewText).font(.system(size: 16))
                            .focused($focusedField, equals: .review)
                            .frame(minHeight: 80, maxHeight: 200)
                    }
#if os(iOS)
                    TagList(tags: tags) { tag in
                        let tagModel = modelData.summaryTagList.first { $0.content == tag }
                        if tag == "" {
                            Button {
                                showEditTagView.toggle()
                            } label: {
                                Label("", systemImage: "plus.circle")
                                    .font(.system(size: 14))
                            }
                        } else {
                            let tagColor = Self.selectTags.contains { $0 == tagModel?.id } ? (tagModel?.titleColor ?? .gray.opacity(0.2)) : .gray.opacity(0.2)
                            Text(tag)
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(tagColor)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .onTapGesture {
                                    guard let tagId = tagModel?.id else {
                                        return
                                    }
                                    if Self.selectTags.contains(where: {$0 == tagId }) {
                                        Self.selectTags.removeAll { $0 == tagId }
                                    } else {
                                        Self.selectTags.append(tagId)
                                    }
                                    updateSummaryItem()
                                }
                        }
                    }
                    #endif
                }
                
                
            }
        }
        .onAppear {
            focusedField = .review
            if let summaryItem {
                reviewText = summaryItem.content
                summaryItem.tags.forEach { tag in
                    Self.selectTags.append(tag)
                }
            } else {
                Self.selectTags = []
            }
            if let task = task {
                let tag = modelData.tagList.first(where: { $0.id == task.tag }) ?? .work
                selectedTag = tag.title
                taskType = task.type == .reward ? SummaryTaskType.reward.typeTitle : SummaryTaskType.event.typeTitle
                selectTask = task.title
            } else {
                let tag = modelData.tagList.first ?? .work
                selectedTag = tag.title
                taskType = SummaryTaskType.reward.typeTitle
                selectTask = taskList.filter { $0.tag == tag.id }.first?.title ?? ""
            }
        }
        .onDisappear {
            Self.selectTags.removeAll()
        }
    }
}

extension EditSummaryView {
    
    func updateSummaryItem() {
        if let summaryItem {
            summaryItem.content = reviewText
            summaryItem.tags = Self.selectTags
            modelData.updateSummaryItem(summaryItem)
        } else {
            let summaryItem = SummaryItem()
            summaryItem.generateId = UUID().uuidString
            summaryItem.content = reviewText
            summaryItem.tags = Self.selectTags
            modelData.updateSummaryItem(summaryItem)
        }
    }
    
    func saveSummaryItem() {
        if let summaryItem {
            summaryItem.content = reviewText
            modelData.updateSummaryItem(summaryItem)
        } else {
            let summaryItem = SummaryItem()
            summaryItem.generateId = UUID().uuidString
            summaryItem.content = reviewText
            modelData.updateSummaryItem(summaryItem)
        }
        return
        
        let taskId: String
        if let task {
            taskId = task.id
        } else {
            var tasks: [any BasicTaskProtocol] = taskType == SummaryTaskType.event.typeTitle ? modelData.itemList : modelData.rewardList
            taskId = tasks.first(where: { $0.title == selectTask })?.id ?? ""
        }
        
        var summaryModel: SummaryModel
        if let model = modelData.summaryModelList.first(where: { $0.taskId == taskId }) {
            summaryModel = model
        } else {
            summaryModel = SummaryModel(generateId: UUID().uuidString, taskId: taskId, taskType: .event, items: [])
        }
        let summaryItem = SummaryItem(generateId: UUID().uuidString, summaryId: summaryModel.generateId, content: reviewText, improve: improveText)
        summaryModel.items.append(summaryItem.generateId)
        modelData.updateSummaryModel(summaryModel)
        modelData.updateSummaryItem(summaryItem)
    }
    
}

#Preview(body: {
    EditSummaryView(showSheetView: .constant(true), showEditTagView: .constant(true))
})

struct ChatView: View {
    
    @State var txt = ""
    @State var height: CGFloat = 0.0
    @State var keyboardHeight: CGFloat = 0.0 {
        didSet {
            print("keyboard height: \(keyboardHeight)")
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
//            HStack {
//                Text("Chats")
//                    .font(.title)
//                    .fontWeight(.bold)
//                
//                Spacer()
//            }
//            .padding()
//            .background(Color.white)
            
            
//            ScrollView(.vertical, showsIndicators: false) {
//                Text("")
//            }
            
            HStack(spacing: 8, content: {
#if os(iOS)
                ResizableTF(txt: $txt, height: $height).frame(height: self.height < 150 ? self.height : 150)
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(15)
#endif
                
                Button(action: {
                    
                }, label: {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(10)
                })
            })
            .padding(.horizontal)
        }
        //.padding(.bottom, self.keyboardHeight)
        .background(Color.black.opacity(0.06))
        .onTapGesture {
#if os(iOS)
            UIApplication.shared.windows.first?.rootViewController?.view.endEditing(true)
#endif
        }
        .onAppear(perform: {
#if os(iOS)
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main) { data in
                let height = data.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
                self.keyboardHeight = height.cgRectValue.height - 20
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { data in
                self.keyboardHeight = 0
            }
#endif
        })
        
        
    }
}

#if os(iOS)
struct ResizableTF: UIViewRepresentable {
    
    @Binding var txt: String {
        didSet {
            if oldValue != txt {
                coordinator?.textView?.text = txt
            }
        }
    }
    @Binding var height: CGFloat
    @State var coordinator: Coordinator?
    
    init(txt: Binding<String>, height: Binding<CGFloat>) {
        _txt = txt
        _height = height
    }
    
    func makeCoordinator() -> Coordinator {
        let coordinator = ResizableTF.Coordinator(parent: self)
        self.coordinator = coordinator
        return coordinator
        //return ResizableTF.Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isEditable = true
        view.isScrollEnabled = true
        view.text = "Enter Message"
        view.font = .systemFont(ofSize: 15)
        view.textColor = .gray
        view.delegate = context.coordinator
        view.backgroundColor = .clear
        context.coordinator.textView = view
        return view
    }
    func updateUIView(_ uiView: UITextView, context: Context) {
        DispatchQueue.main.async {
            self.height = uiView.contentSize.height
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: ResizableTF
        var textView: UITextView?
        
        init(parent: ResizableTF) {
            self.parent = parent
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if self.parent.txt == "" {
                textView.text = ""
                textView.textColor = .black
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if self.parent.txt == "" {
                textView.text = "Enter Message"
                textView.textColor = .gray
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.height = textView.contentSize.height
                self.parent.txt = textView.text
            }
        }
    }
}

#endif

//#Preview(body: {
//    ChatView()
//})
