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
    
    public func updateNote(_ note: NoteModel) {
        if let index = noteList.firstIndex(where: { $0.id == note.id }) {
            self.noteList[index] = note
        } else {
            self.noteList.append(note)
        }
        DataManager.shared.save(with: NoteModel.modelClassName(), models: [note]) { error in
            if let error {
                print(error)
            } else {
                self.asyncUpdateCache(type: .note)
            }
        }
    }
    
    public func updateTagNote(_ tag: TagModel) {
        if let index = noteTagList.firstIndex(where: { $0.id == tag.id }) {
            self.noteTagList[index] = tag
        } else {
            self.noteTagList.append(tag)
        }
        DataManager.shared.save(with: TagModel.modelClassName(), models: [tag]) { error in
            if let error {
                print(error)
            } else {
                self.asyncUpdateCache(type: .noteTag)
            }
        }
    }
    
    public func deleteTag(_ tag: TagModel) {
        guard let index = noteTagList.firstIndex(where: { $0.id == tag.id }) else {
            return
        }
        noteTagList.remove(at: index)
        DataManager.shared.delete(models: [tag]) { error in
            if let error = error {
                print(error)
            } else {
                self.asyncUpdateCache(type: .noteTag)
            }
        }
    }
    
    public func deleteNote(_ note: NoteModel) {
        guard let index = noteList.firstIndex(where: { $0.id == note.id }) else {
            return
        }
        noteList.remove(at: index)
        DataManager.shared.delete(models: [note]) { error in
            if let error = error {
                print(error)
            } else {
                self.asyncUpdateCache(type: .note)
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
