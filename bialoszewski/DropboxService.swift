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
    
    let controller: RecordViewController!
    let handler: ErrorService!
    
    init(ctrl: RecordViewController) {
        controller = ctrl
        handler = ErrorService(ctrl: controller)
        
        if !DBAccountManager.sharedManager().linkedAccount {
            DBAccountManager.sharedManager().linkFromController(controller)
        } else {
            setupDropboxFilesystem()
        }
    }
    
    func setupDropboxFilesystem() {
        filesystem = DBFilesystem(account: DBAccountManager.sharedManager().linkedAccount)
        DBFilesystem.setSharedFilesystem(filesystem)
    }
    
    func setupFile(name: String, path: String) {
        localPath = path
        dropboxPath = DBPath.root().childPath(name)
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
        if error {
            handler.error(message)
        }
    }

}