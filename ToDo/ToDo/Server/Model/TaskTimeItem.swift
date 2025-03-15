import Foundation
import LeanCloud

class TaskTimeItem: BaseModel, Identifiable, Codable {
    var startTime: Date = .now
    var endTime: Date = .now
    var content: String = ""
    var eventId: String = ""
    
    enum TaskTimeKeys: String {
        case startTime
        case endTime
        case content
        case eventId
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
    }
    
    override func convert(to cloudObj: LCObject) throws {
        try super.convert(to: cloudObj)
        try cloudObj.set(TaskTimeKeys.startTime.rawValue, value: startTime.lcDate)
        try cloudObj.set(TaskTimeKeys.endTime.rawValue, value: endTime.lcDate)
        try cloudObj.set(TaskTimeKeys.content.rawValue, value: content.lcString)
        try cloudObj.set(TaskTimeKeys.eventId.rawValue, value: eventId.lcString)
    }
    
    private enum CodingKeys: String, CodingKey {
        case startTime, endTime, content, eventId
    }
    
    
    
    
    
    
}
