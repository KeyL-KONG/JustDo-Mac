//
//  StateManager.swift
//  ToDo
//
//  Created by LQ on 2025/3/16.
//

import Foundation

public class StateManager {
    
    public static let shared = StateManager()
    
    private var editStates = [String: Bool]()
    
    public func isEdit(id: String) -> Bool {
        return editStates[id] ?? false
    }
    
    public func markEdit(id: String, edit: Bool) {
        editStates[id] = edit
    }
    
    public func clearEditStates() {
        editStates.removeAll()
    }
    
}
