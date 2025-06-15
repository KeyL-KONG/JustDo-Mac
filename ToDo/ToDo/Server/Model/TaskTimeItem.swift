import Foundation
import LeanCloud

enum TaskItemResultState: Int {
    case none = 0
    case good
    case bad
}

class TaskTimeItem: BaseModel, Identifiable, Codable {
    var startTime: Date = .now
    var endTime: Date = .now
    var content: String = ""
    var eventId: String = ""
    var state: TaskItemResultState = .none
    var isPlan: Bool = false
    var isRepeat: Bool = false
    var stateTagId: String = ""
    
    var interval: Int {
        Int(endTime.timeIntervalSince1970 - startTime.timeIntervalSince1970)
    }
    
    enum TaskTimeKeys: String {
        case startTime
        case endTime
        case content
        case eventId
        case state
        case isPlan
        case isRepeat
        case stateTagId
    }
    
    required init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date.self, forKey: .endTime)
        content = try container.decode(String.self, forKey: .content)
        eventId = try container.decode(String.self, forKey: .eventId)
        state = TaskItemResultState(rawValue: try container.decode(Int.self, forKey: .state)) ?? .none
        isPlan = try container.decodeIfPresent(Bool.self, forKey: .isPlan) ?? false
        isRepeat = try container.decodeIfPresent(Bool.self, forKey: .isRepeat) ?? false
        stateTagId = try container.decodeIfPresent(String.self, forKey: .stateTagId) ?? ""
    }
    
    init(startTime: Date, endTime: Date, content: String) {
        super.init()
        self.startTime = startTime
        self.endTime = endTime
        self.content = content
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(content, forKey: .content)
        try container.encode(eventId, forKey: .eventId)
        try container.encode(state.rawValue, forKey: .state)
        try container.encode(isPlan, forKey: .isPlan)
        try container.encode(isRepeat, forKey: .isRepeat)
        try container.encode(stateTagId, forKey: .stateTagId)
    }
    
    override class func modelClassName() -> String {
        return "TaskTimeItem"
    }
    
    override func modelClassName() -> String {
        return "TaskTimeItem"
    }
    
    override func fillModel(with cloudObj: LCObject) {
        super.fillModel(with: cloudObj)
        startTime = cloudObj.get(TaskTimeKeys.startTime.rawValue)?.dateValue ?? Date()
        endTime = cloudObj.get(TaskTimeKeys.endTime.rawValue)?.dateValue ?? Date()
        content = cloudObj.get(TaskTimeKeys.content.rawValue)?.stringValue ?? ""
        eventId = cloudObj.get(TaskTimeKeys.eventId.rawValue)?.stringValue ?? ""
        state = TaskItemResultState(rawValue: (cloudObj.get(TaskTimeKeys.state.rawValue)?.intValue ?? 0)) ?? .none
        isPlan = cloudObj.get(TaskTimeKeys.isPlan.rawValue)?.boolValue ?? false
        isRepeat = cloudObj.get(TaskTimeKeys.isRepeat.rawValue)?.boolValue ?? false
        stateTagId = cloudObj.get(TaskTimeKeys.stateTagId.rawValue)?.stringValue ?? ""
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(TaskTimeKeys.startTime.rawValue, value: startTime.lcDate)
        try cloudObj.set(TaskTimeKeys.endTime.rawValue, value: endTime.lcDate)
        try cloudObj.set(TaskTimeKeys.content.rawValue, value: content.lcString)
        try cloudObj.set(TaskTimeKeys.eventId.rawValue, value: eventId.lcString)
        try cloudObj.set(TaskTimeKeys.state.rawValue, value: state.rawValue.lcNumber)
        try cloudObj.set(TaskTimeKeys.isPlan.rawValue, value: isPlan)
        try cloudObj.set(TaskTimeKeys.isRepeat.rawValue, value: isRepeat)
        try cloudObj.set(TaskTimeKeys.stateTagId.rawValue, value: stateTagId)
    }
    
    private enum CodingKeys: String, CodingKey {
        case startTime, endTime, content, eventId, state, isPlan,isRepeat, stateTagId
    }
    
    
    
    
    
    
}
