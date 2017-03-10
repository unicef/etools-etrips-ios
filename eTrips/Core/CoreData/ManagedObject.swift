import CoreData

public class ManagedObject: NSManagedObject {
}

public protocol ManagedObjectType: class {
	static var entityName: String { get }
	static var defaultSortDescriptors: [NSSortDescriptor] { get }
	static var defaultPredicate: NSPredicate { get }
	var managedObjectContext: NSManagedObjectContext? { get }
}

extension ManagedObjectType {
	public static var defaultSortDescriptors: [NSSortDescriptor] {
		return []
	}
	
	public static var defaultPredicate: NSPredicate { return NSPredicate(value: true) }
	
	public static var sortedFetchRequest: NSFetchRequest<NSFetchRequestResult> {
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
		request.sortDescriptors = defaultSortDescriptors
		return request
	}
	
	public static func predicate(format: String, args: CVarArg...) -> NSPredicate {
		let predicate = withVaList(args) { NSPredicate(format: format, arguments: $0) }
		return predicateWithPredicate(predicate: predicate)
	}
	
	public static func predicateWithPredicate(predicate: NSPredicate) -> NSPredicate {
		return NSCompoundPredicate(andPredicateWithSubpredicates: [defaultPredicate, predicate])
	}
}

extension ManagedObjectType where Self: ManagedObject {
	public static func findOrCreate(in context: NSManagedObjectContext,
	                                with predicate: NSPredicate,
	                                configure: @escaping (Self) -> Void) -> Self {
		guard let object = findOrFetch(in: context, with: predicate) else {
			let newObject: Self = context.insertObject()
			configure(newObject)
			return newObject
		}
		return object
	}
	
	public static func findAndUpdateOrCreate(in context: NSManagedObjectContext,
	                                         with predicate: NSPredicate,
	                                         configure: @escaping (Self) -> Void) -> Self {
		guard let object = findOrFetch(in: context, with: predicate) else {
			let newObject: Self = context.insertObject()
			configure(newObject)
			return newObject
		}
		configure(object)
		return object
		
	}
	
	public static func findOrFetch(in context: NSManagedObjectContext, with predicate: NSPredicate) -> Self? {
        guard let object = materializedObject(in: context, matching: predicate) else {
            return fetch(in: context) { request in
                request.predicate = predicate
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
            }.first
        }
        return object
	}
	
	public static func fetch(in context: NSManagedObjectContext,
	                         configurationBlock: (NSFetchRequest<NSFetchRequestResult>) -> Void = { _ in }) -> [Self] {
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: Self.entityName)
		configurationBlock(request)
		guard let result = try! context.fetch(request) as? [Self] else {
			fatalError("Fetched objects have wrong type")
		}
		return result
	}
	
    public static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        for object in context.registeredObjects where !object.isFault {
            guard let result = object as? Self, predicate.evaluate(with: result) else { continue }
            return result
        }
        return nil
    }
}

extension ManagedObjectType where Self: ManagedObject {
	public static func fetchSingleObject(in context: NSManagedObjectContext,
	                                     cacheKey: String,
	                                     configure: (NSFetchRequest<NSFetchRequestResult>) -> Void) -> Self? {
		guard let cached = context.object(for: cacheKey) as? Self else {
			let result = fetchSingleObject(in: context, configure: configure)
			context.set(object: result, forSingleObjectCacheKey: cacheKey)
			return result
		}
		return cached
	}
	
	public static func fetchSingleObject(in context: NSManagedObjectContext,
	                                     configure: (NSFetchRequest<NSFetchRequestResult>) -> Void) -> Self? {
		let result = fetch(in: context) { request in
			configure(request)
			request.fetchLimit = 2
		}
		switch result.count {
		case 0: return nil
		case 1: return result[0]
		default: fatalError("Returned multiple objects, expected max 1")
		}
	}
}
