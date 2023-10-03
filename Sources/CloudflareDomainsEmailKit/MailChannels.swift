import Foundation

/// The JSON body required by mailchannels
public struct MailChannelsContent: Codable {
    public var personalizations: [Personalizations]
    
    // The sender of the email
    public var from: MailUser
    
    // optional user for reply_to field shown in the email
    public var replyTo: MailUser?
    
    // Subject
    public var subject: String
    
    // The actual email body Content
    public var content: [EmailBody]
    
    public init(
        personalizations: [Personalizations],
        from: MailUser,
        replyTo: MailUser? = nil,
        subject: String,
        content: [EmailBody]
    ) {
        self.personalizations = personalizations
        self.from = from
        self.subject = subject
        self.replyTo = replyTo
        self.content = content
    }
    
    enum CodingKeys: String, CodingKey {
        case personalizations
        case from
        case replyTo = "reply_to"
        case subject
        case content
    }
}

extension MailChannelsContent {
    public struct Personalizations: Codable {
        public var recipients: [MailUser]
        public var dkimDomain: String?
        public var dkimSelector: String?
        public var dkimPrivateKey: String?
        
        public init(
            recipients: [MailUser],
            dkimDomain: String? = nil,
            dkimSelector: String? = nil,
            dkimPrivateKey: String? = nil
        ) {
            self.recipients = recipients
            self.dkimDomain = dkimDomain
            self.dkimSelector = dkimSelector
            self.dkimPrivateKey = dkimPrivateKey
        }
        
        enum CodingKeys: String, CodingKey {
            case recipients = "to"
            case dkimDomain = "dkim_domain"
            case dkimSelector = "dkim_selector"
            case dkimPrivateKey = "dkim_private_key"
        }
    }
}

extension MailChannelsContent {
    public struct EmailBody: Codable {
        public var type: String
        public var value: String
        
        public init(type: ContentType = .plainText, value: String) {
            self.type = type.rawValue
            self.value = value
        }
        
        public enum ContentType: String {
            case plainText
            case html
            
            public var rawValue: String {
                switch self {
                    case .plainText:
                        return "text/plain"
                    case .html:
                        return "text/html"
                }
            }
        }
    }
}
