//
//  DropboxService.swift
//  bialoszewski
//
//  Created by Kamil Nicieja on 03/08/14.
//  Copyright (c) 2014 Kamil Nicieja. All rights reserved.
//

class DropboxService {
    
    var filesystem: DBFilesystem!
    var error: DBError?
    var dropboxPath: DBPath!
    var localPath: String!
    var file: DBFile!
    
    var folder: String!
    let dateFormat: String =  "yyyy-MM-dd"
    
    let controller: RecordViewController!
    let handler: ErrorService!
    
    init(ctrl: RecordViewController) {
        controller = ctrl
        handler = ErrorService(ctrl: controller)
        
        if !(DBAccountManager.sharedManager().linkedAccount != nil) {
            linkToDropbox()
        } else {
            setupDropboxFilesystem()
        }
    }
    
    func setupDropboxFilesystem() {
        filesystem = DBFilesystem(account: DBAccountManager.sharedManager().linkedAccount)
        DBFilesystem.setSharedFilesystem(filesystem)
    }
    
    func linkToDropbox() {
        var delta: Int64 = 1 * Int64(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, delta)
        
        dispatch_after(time, dispatch_get_main_queue(), {
            if DBAccountManager.sharedManager().linkedAccount == nil && !(self.controller.presentedViewController is UINavigationController) {
                DBAccountManager.sharedManager().linkFromController(self.controller)
            }
            self.linkToDropbox()
        })
    }
    
    func setupFile(name: String, path: String) {
        localPath = path
        setFolderName()
        dropboxPath = DBPath.root().childPath("\(folder)/\(name)")
    }
    
    func setFolderName() {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        var timestamp: NSDate = NSDate.date()
        folder = dateFormatter.stringFromDate(timestamp)
    }
    
    func fetchOrCreate() {
        if var info: DBFileInfo = filesystem.fileInfoForPath(dropboxPath, error: nil) {
            openDropboxFile()
        } else {
            createDropboxFile()
        }
    }
    
    func openDropboxFile() {
        file = filesystem.openFile(dropboxPath, error: &error)
        errorHandler(error, message: "The file could not be opened.")
    }
    
    func createDropboxFile() {
        file = filesystem.createFile(dropboxPath, error: &error)
        errorHandler(error, message: "The file could not be created.")
    }
    
    func saveToFile() {
        file.writeContentsOfFile(localPath, shouldSteal: true, error: &error)
        errorHandler(error, message: "The file could not be saved.")
    }
    
    func save() {
        fetchOrCreate()
        saveToFile()
    }
    
    func errorHandler(error: DBError?, message: String) {
        if (error != nil) {
            handler.error(message)
        }
    }

}