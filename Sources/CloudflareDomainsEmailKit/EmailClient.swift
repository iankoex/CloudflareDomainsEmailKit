import Foundation
import AsyncHTTPClient
import NIOCore

public struct EmailClient {
    
    public static func sendMail(content: MailChannelsContent, using workerURL: String) async throws {
        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        var emailClientError: EmailClientError? = nil
        do {
            let data = try JSONEncoder().encode(content)
            var request = HTTPClientRequest(url: workerURL)
            request.method = .POST
            request.headers.add(name: "content-type", value: "application/json")
            request.body = .bytes(ByteBuffer(data: data))
            let response = try await httpClient.execute(request, timeout: .seconds(60))
            guard response.status == .ok else {
                throw EmailClientError.somethingWentWrong
            }
            guard let responseCode = response.headers.first(name: "x-mc-status"),
                  responseCode == "202"
            else {
                let code = response.headers.first(name: "x-mc-status") ?? "nil"
                let text = response.headers.first(name: "x-mc-status-text") ?? "nil"
                let time = response.headers.first(name: "x-response-time") ?? "nil"
                
                throw EmailClientError.workerSendingMailError("\(code) \(text) \(time)")
            }
        } catch {
            emailClientError = EmailClientError.requestFailed(error.localizedDescription)
        }
        try await httpClient.shutdown()
        if let emailClientError = emailClientError {
            throw emailClientError
        }
    }
    
}
