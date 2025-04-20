//
//  ModelData+NoteList.swift
//  Summary
//
//  Created by LQ on 2024/5/4.
//

import Foundation

extension ModelData {
    
    public func loadNoteList(completion: @escaping (() -> ())) {
        queryNoteTags {
            self.queryNoteList(completion: completion)
        }
    }
    
    public func queryNoteTags(completion: @escaping (() -> ())) {
        DataManager.shared.query(type: TagModel.self) { [weak self] tags, error in
            guard let self = self else { return }
            if let tags = tags, tags.count > 0 {
                self.noteTagList = tags
                self.tryLoadNoteTagTimes = 0
                print("load note tags: \(tags.count)")
                completion()
            } else if self.tryLoadNoteTagTimes < 3 {
                loadNoteList(completion: completion)
                self.tryLoadNoteTagTimes += 1
            }
        }
    }
    
    public func queryNoteList(completion: @escaping (() -> ())) {
        DataManager.shared.query(type: NoteModel.self) { [weak self] notes, error in
            if let notes = notes {
                self?.noteList = notes
                print("load note notes: \(notes.count)")
            }
            completion()
        }
    }
    
}
