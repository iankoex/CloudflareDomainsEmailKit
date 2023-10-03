import Foundation

/// A user that can be used in an email. This can be either the sender or a recipient.
public struct MailUser: Codable {
    /// The user's name that is displayed in an email. Optional.
    public let name: String
    
    /// The user's email address.
    public let email: String
    
    public init(name: String, email: String) {
        self.name = name
        self.email = email
    }
}
