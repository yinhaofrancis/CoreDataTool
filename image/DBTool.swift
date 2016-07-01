//
//  DBTool.swift
//  image
//
//  Created by YinHao on 16/6/24.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//

import Foundation
import CoreData
// MARK: core data stack
public class CoreDataStack{
    private var _filename:String
    public var filename:String{
        get{
            return _filename
        }
    }
    
    private var _autoMigration:Bool
    public var autoMigration:Bool{
        get{
            return _autoMigration
        }
    }
    
    
    public func getChildContext(isPrivate:Bool)->NSManagedObjectContext{
        let context = NSManagedObjectContext(concurrencyType:isPrivate ? .PrivateQueueConcurrencyType : .MainQueueConcurrencyType)
        context.parentContext = self.managedObjectContext
        return context
    }
    
    lazy public var managedObjectModel:NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(self._filename, withExtension: "momd")!
        let Module = NSManagedObjectModel(contentsOfURL: modelURL)
        return Module!
    }()
    public init(db:String = "db",AutoMigration:Bool = true){
        _filename = db
        _autoMigration = AutoMigration
    }
    public lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    lazy public var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(self.filename).sqlite")
        let failureReason = "There was an error creating or loading the application's saved data."
        do {
            let option:Dictionary<String,Bool>? = [NSMigratePersistentStoresAutomaticallyOption:true,NSInferMappingModelAutomaticallyOption:self._autoMigration]
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: option)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy public var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
        
    }()
    // MARK: - Core Data Saving support
    
    public func saveContext(context:NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}
public class CoreDataProvide:NSObject{
    private static var queue = dispatch_queue_create("CoreDataProvideQueue", nil)
    private static var inst:CoreDataProvide?
    public static let DBName = "db"
    public var batch:Int = 20
    static func shareInstace()->CoreDataProvide{
        if inst == nil{
            inst = CoreDataProvide()
        }
        return inst!
    }
    override init() {
        super.init()
    }
    public func query(name:String,condition:NSPredicate?,result:(data:[NSManagedObject]?)->Void){
        let fetch = NSFetchRequest(entityName: name)
        fetch.fetchBatchSize = self.batch
        fetch.predicate = condition
        asyncRun(CoreDataProvide.queue, clusure: {[weak self] in
            if self == nil{
                return
            }
            do{
                let array = try self!.stack.managedObjectContext.executeFetchRequest(fetch)
                result(data: array as? [NSManagedObject])
            }catch{
                result(data: nil)
            }
            })
        
    }
    public func insert(m:[String:AnyObject],type:String,callBack:((object:NSManagedObject)->Void)?) {
        asyncRun(CoreDataProvide.queue) { [weak self] in
            if self != nil{
                let desc = NSEntityDescription.entityForName(type, inManagedObjectContext: self!.stack.managedObjectContext)
                let k = NSManagedObject(entity: desc!, insertIntoManagedObjectContext: self!.stack.managedObjectContext)
                k.setJSON(m)
                self!.stack.saveContext(self!.stack.managedObjectContext)
                callBack?(object: k)
            }
        }
    }
    public func count(type: String, condition: NSPredicate?,Count:(NSNumber?)->Void) {
        let request = NSFetchRequest(entityName: type)
        request.predicate = condition
        asyncRun(CoreDataProvide.queue) {[weak self] in
            if self != nil{
                var error: NSError?
                let count = self?.stack.managedObjectContext.countForFetchRequest(request, error: &error)
                Count(count)
                if error != nil{
                    print(error)
                }
            }
        }
    }
    public func del(m: NSManagedObject, type: String) {
        asyncRun(CoreDataProvide.queue) { [weak self] in
            if self != nil{
                self!.stack.managedObjectContext.deleteObject(m)
                self!.save()
            }
        }
        
    }
    public func save() {
        self.stack.saveContext(self.stack.managedObjectContext)
    }
    lazy var stack:CoreDataStack = {
        return CoreDataStack(db: CoreDataProvide.DBName,AutoMigration: true)
    }()
}
let group = dispatch_group_create()
func asyncRun(queue:dispatch_queue_t,clusure:dispatch_block_t){
    dispatch_group_async(group, queue, clusure)
    threadWatcher.watcher.add()
}
func asyncMainRun(clusure:dispatch_block_t){
    dispatch_group_async(group, dispatch_get_main_queue(), clusure)
    threadWatcher.watcher.add()
}
// MARK: threadWatcher
class threadWatcher{
    static let queue = dispatch_queue_create("com.YH.Watcher", DISPATCH_QUEUE_SERIAL)
    static let watcher = threadWatcher()
    private var call:dispatch_block_t? = nil
    func add(){
        if call == nil{
            return
        }
        dispatch_group_notify(group, threadWatcher.queue, call!)
    }
    func setCallBack(k:dispatch_block_t){
        call = k;
    }
}
extension NSManagedObject{
    func setJSON(JSON:[String:AnyObject]){
        for i in JSON {
            self.setValue(i.1, forKey: i.0)
        }
    }
}