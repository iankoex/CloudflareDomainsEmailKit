enum EmailClientError: Error, CustomDebugStringConvertible, CustomStringConvertible {
    case somethingWentWrong
    case workerSendingMailError(String?)
    case requestFailed(String?)
    
    var description: String { debugDescription }
    
    var debugDescription: String {
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
