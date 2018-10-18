import Vapor
import Web3

final class ERC20Controller: RouteCollection {

    // 5 req/s limit
    private let etherscanApiKeys = [
        "C4F9EQA9DGMHIQHBH9NJB8GPBSSECEPE13",
        "ZR7RBEJ3R4XNIF81DBY7NRC39BVHS326UC",
        "6AEHG8CR2QK4CKUVG88IQFVW7N7CUM345T",
    ]

    private var index = 0

    func boot(router: Router) throws {
        let route = router.grouped("api", "erc20")
        route.get("tokens", use: tokens)
        route.get("tokens", String.parameter, use: tokensOfAddress)
    }

    static let tokens: [EthToken] = {
        let data = ethTokens.data(using: .utf8)!
        return try! JSONDecoder().decode([EthToken].self, from: data)
    }()

    func tokens(_ req: Request) throws -> Future<[EthToken]> {
        return Future.map(on: req) { 
            return ERC20Controller.tokens
        }
    }

    func tokensOfAddress(_ req: Request) throws -> Future<[EthToken]> {
        let key = etherscanApiKeys[index % 3]

        index += 1
        index %= 500

        let address = try req.parameters.next(String.self)
        let response = try req.client().get("https://api.etherscan.io/api") { request in
            let parameters = [
                "module" : "account",
                "action" : "txlist",
                "address" : address,
                "sort" : "desc",
                "apikey" : key,
            ]
            try request.query.encode(parameters)
        }

        let transactions = response.flatMap(to: [Transaction].self) { response in
            response.content.get([Transaction].self, at: "result")
        }

        let tokens = transactions.map(to: [EthToken].self) { transactions in
            let to = Set(transactions.map { $0.to })
            return ERC20Controller.tokens.filter { to.contains($0.address) }
        }

        return tokens
    }
    
}

struct Transaction: Content {
    let to: String
}
