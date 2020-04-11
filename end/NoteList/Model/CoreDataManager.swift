/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import CoreData
import UIKit

class CoreDataManager {
  static let sharedInstance = CoreDataManager()
  
  private init() { }
  
  lazy var persistentContainer: NSPersistentContainer = {
      let container = NSPersistentContainer(name: "NoteList")
      container.loadPersistentStores(completionHandler: { (storeDescription, error) in
          if let error = error as NSError? {
              fatalError("Unresolved error \(error), \(error.userInfo)")
          }
      })
      return container
  }()
  
  func fetchAllNotes() -> [Note] {
    let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
    let context = persistentContainer.viewContext
    guard let results = try? context.fetch(fetchRequest) else {
      return []
    }
    
    return results
  }
  
  func createNote(for title: String, content: String) {
    let managedObjectContext = persistentContainer.viewContext
    let note = Note(context: managedObjectContext)
    note.title = title
    note.content = content
    note.createdDate = Date()
    note.id = UUID()
    
    do {
      try managedObjectContext.save()
    } catch {
      print(error)
    }
  }
  
  func fetchNote(for id: UUID) -> Note? {
    let predicate = NSPredicate(format: "id == %@", id as CVarArg)
    let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
    fetchRequest.predicate = predicate
    let context = persistentContainer.viewContext
    
    guard let results = try? context.fetch(fetchRequest) else {
      return nil
    }
    
    return results.first
  }
  
  func delete(for noteId: UUID) {
    guard let note = fetchNote(for: noteId) else {
      return
    }
    
    let context = persistentContainer.viewContext
    
    do {
      context.delete(note)
      try context.save()
    } catch {
      print("Error saving: \(error)")
    }
  }
}
