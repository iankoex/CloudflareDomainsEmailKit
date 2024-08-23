import Foundation

public enum EmailClientError: Error {
    case somethingWentWrong
    case workerSendingMailError(String?)
    case requestFailed(String?)
}

extension EmailClientError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
            case .somethingWentWrong:
                return "Something went wrong"
            case .workerSendingMailError(let str):
                return "Your request was recieved by the worker. However the email was not sent. \(str ?? "")"
            case .requestFailed(let error):
                return "Request Failed: \(error ?? "nil")"
        }
    }
}

extension EmailClientError: CustomStringConvertible {
    public var description: String { debugDescription }
}

extension EmailClientError: LocalizedError {
    public var errorDescription: String? { debugDescription }
}
