// Generated using Sourcery 0.13.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT








// MARK: - AccessControlLevel Codable
extension AccessControlLevel {
    enum CodingKeys: String, CodingKey {
        case key
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case .private:
                try container.encode("`private`", forKey: .key)
            case .fileprivate:
                try container.encode("`fileprivate`", forKey: .key)
            case .internal:
                try container.encode("`internal`", forKey: .key)
            case .public:
                try container.encode("`public`", forKey: .key)
            case .open:
                try container.encode("`open`", forKey: .key)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = try container.decode(String.self, forKey: .key)
        switch key {
        case "`private`":
            self = .`private`
        case "`fileprivate`":
            self = .`fileprivate`
        case "`internal`":
            self = .`internal`
        case "`public`":
            self = .`public`
        default:
            self = .`open`
        }
    }
}

// MARK: - ClassNode Codable
extension ClassNode {
    enum CodingKeys: String, CodingKey {
        case isSwift 
        case superCls 
        case className 
        case protocols 
        case methods 
        case accessControl 
    }

}

// MARK: - ExtensionNode Codable
extension ExtensionNode {
    enum CodingKeys: String, CodingKey {
        case name 
        case protocols 
        case methods 
        case accessControl 
    }

}

// MARK: - FileNode Codable
extension FileNode {
    enum CodingKeys: String, CodingKey {
        case md5 
        case drafterVersion 
        case path 
        case type 
        case swiftTypes 
        case objcTypes 
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        md5 = try container.decode(String.self, forKey: .md5)
        drafterVersion = try container.decode(String.self, forKey: .drafterVersion)
        path = try container.decode(String.self, forKey: .path)
        type = try container.decode(FileType.self, forKey: .type)
        swiftTypes = try container.decode([SwiftTypeNode].self, forKey: .swiftTypes)
        objcTypes = try container.decode([ObjcTypeNode].self, forKey: .objcTypes)
    }
}

// MARK: - FileType Codable
extension FileType {
    enum CodingKeys: String, CodingKey {
        case key
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case .h:
                try container.encode("h", forKey: .key)
            case .m:
                try container.encode("m", forKey: .key)
            case .swift:
                try container.encode("swift", forKey: .key)
            case .unknown:
                try container.encode("unknown", forKey: .key)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = try container.decode(String.self, forKey: .key)
        switch key {
        case "h":
            self = .h
        case "m":
            self = .m
        case "swift":
            self = .swift
        default:
            self = .unknown
        }
    }
}

// MARK: - ImplementationNode Codable
extension ImplementationNode {
    enum CodingKeys: String, CodingKey {
        case className 
        case methods 
    }

}

// MARK: - InterfaceNode Codable
extension InterfaceNode {
    enum CodingKeys: String, CodingKey {
        case superCls 
        case className 
        case protocols 
        case methods 
    }

}

// MARK: - InvokeParam Codable
extension InvokeParam {
    enum CodingKeys: String, CodingKey {
        case name 
        case invokes 
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        invokes = try container.decode([MethodInvokeNode].self, forKey: .invokes)
    }
}

// MARK: - MethodInvokeNode Codable
extension MethodInvokeNode {
    enum CodingKeys: String, CodingKey {
        case isSwift 
        case invoker 
        case methodName 
        case params 
    }

}

// MARK: - MethodInvoker Codable
extension MethodInvoker {
    enum CodingKeys: String, CodingKey {
        case key
        case name_0
        case method_0
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case .name(let val0):
                try container.encode("name", forKey: .key)
                try container.encode(val0, forKey: .name_0)
            case .method(let val0):
                try container.encode("method", forKey: .key)
                try container.encode(val0, forKey: .method_0)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = try container.decode(String.self, forKey: .key)
        switch key {
        case "name":
            self = .name(
                try container.decode(String.self, forKey: .name_0)
            )
        default:
            self = .method(
                try container.decode(MethodInvokeNode.self, forKey: .method_0)
            )
        }
    }
}

// MARK: - MethodNode Codable
extension MethodNode {
    enum CodingKeys: String, CodingKey {
        case isSwift 
        case isStatic 
        case accessControl 
        case returnType 
        case methodName 
        case params 
        case invokes 
    }

}

// MARK: - ObjcTypeNode Codable
extension ObjcTypeNode {
    enum CodingKeys: String, CodingKey {
        case key
        case interface_0
        case implementaion_0
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case .interface(let val0):
                try container.encode("interface", forKey: .key)
                try container.encode(val0, forKey: .interface_0)
            case .implementaion(let val0):
                try container.encode("implementaion", forKey: .key)
                try container.encode(val0, forKey: .implementaion_0)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = try container.decode(String.self, forKey: .key)
        switch key {
        case "interface":
            self = .interface(
                try container.decode(InterfaceNode.self, forKey: .interface_0)
            )
        default:
            self = .implementaion(
                try container.decode(ImplementationNode.self, forKey: .implementaion_0)
            )
        }
    }
}

// MARK: - Param Codable
extension Param {
    enum CodingKeys: String, CodingKey {
        case outterName 
        case type 
        case innerName 
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        outterName = try container.decode(String.self, forKey: .outterName)
        type = try container.decode(String.self, forKey: .type)
        innerName = try container.decode(String.self, forKey: .innerName)
    }
}

// MARK: - ProtocolNode Codable
extension ProtocolNode {
    enum CodingKeys: String, CodingKey {
        case name 
        case supers 
    }

}

// MARK: - SwiftTypeNode Codable
extension SwiftTypeNode {
    enum CodingKeys: String, CodingKey {
        case key
        case class_0
        case protocol_0
        case extension_0
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case .class(let val0):
                try container.encode("`class`", forKey: .key)
                try container.encode(val0, forKey: .class_0)
            case .protocol(let val0):
                try container.encode("`protocol`", forKey: .key)
                try container.encode(val0, forKey: .protocol_0)
            case .extension(let val0):
                try container.encode("`extension`", forKey: .key)
                try container.encode(val0, forKey: .extension_0)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = try container.decode(String.self, forKey: .key)
        switch key {
        case "`class`":
            self = .`class`(
                try container.decode(ClassNode.self, forKey: .class_0)
            )
        case "`protocol`":
            self = .`protocol`(
                try container.decode(ProtocolNode.self, forKey: .protocol_0)
            )
        default:
            self = .`extension`(
                try container.decode(ExtensionNode.self, forKey: .extension_0)
            )
        }
    }
}

