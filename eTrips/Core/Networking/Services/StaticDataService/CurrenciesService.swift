import Foundation

/// Loading list of currencies.
class CurrenciesService {
    var managedObjectContext = CoreDataStack.shared.managedObjectContext

    func downloadCurrencies(completion: @escaping (_ success: Bool) -> Void) {
        eTripsAPIProvider.request(.currencies) { result in
            switch result {
            case let .success(response):
                let statusCode = response.statusCode
                switch statusCode {
                case 200...299:
                    do {
                        let parsedCurrencies: [Currency]? = try response.mapArray(Currency.self)
                        
                        if let currencies = parsedCurrencies {
                            
                            CurrencyEntity.deleteAll(in: self.managedObjectContext)
                            
                            for currency in currencies {
                                _ = CurrencyEntity.insert(into: self.managedObjectContext, object: currency)
                            }
                            
                            CoreDataStack.shared.saveContext()
                            completion(true)
                        } else {
                            completion(false)
                        }
                    } catch {
                        completion(false)
                    }
                default:
                    completion(false)
                }
            case .failure:
                completion(false)
            }
        }
    }
}
