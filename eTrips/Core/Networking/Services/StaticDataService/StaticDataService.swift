import Foundation

/// Loading of WBS, Grants, Funds.
class StaticDataService {
    var managedObjectContext = CoreDataStack.shared.managedObjectContext
    
    func downloadStaticData(businessArea: Int,
                            completion: @escaping (_ success: Bool, _ staticDataEntity: StaticDataEntity?) -> Void) {
        eTripsAPIProvider.request(.wbsGrantsFunds(businessArea: businessArea)) { result in
            switch result {
            case let .success(response):
                let statusCode = response.statusCode
                switch statusCode {
                case 200...299:
                    do {
                        let parsedStaticData: StaticData? = try response.mapObject(StaticData.self)
                        
                        if let staticData = parsedStaticData {
                            let staticDataEntity =
                                StaticDataEntity.insert(in: self.managedObjectContext, object: staticData)
                            
                            CoreDataStack.shared.saveContext()
                            completion(true, staticDataEntity)
                        } else {
                            completion(false, nil)
                        }
                    } catch {
                        completion(false, nil)
                    }
                default:
                    completion(false, nil)
                }
                
            case .failure:
                completion(false, nil)
            }
        }
    }
}
