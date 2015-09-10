//
//  ViewController.swift
//  ContextDemo
//
//  Created by John Donley on 9/10/15.
//  Copyright (c) 2015 JohnDonley. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

  var mainStack : Stack!
  @IBOutlet var tableView: UITableView!
  lazy var frc: NSFetchedResultsController! = { [weak self] in
    if let this = self {
      let request = NSFetchRequest()
      request.entity = NSEntityDescription.entityForName("MSGMessage", inManagedObjectContext: this.mainStack.managedObjectContext)
      request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
      request.predicate = NSPredicate(format: "shouldShow = YES")
      let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: this.mainStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
      frc.delegate = this
      frc.performFetch(nil)
      return frc
    }
    return nil
  }()


  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Play, target: self, action: "leftBarButtonTapped:")
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "rightBarButtonTapped:")
    // Do any additional setup after loading the view, typically from a nib.
  }

  func leftBarButtonTapped(sender: AnyObject) {
    println("left")
    self.flipOneBackGround()
  }

  func flipOneBackGround() {
    let op = NSBlockOperation {
      let request = NSFetchRequest(entityName: "MSGMessage")
      request.predicate = NSPredicate(format: "shouldShow = NO")
      request.fetchLimit = 1
      var error: NSError? = nil

      if let results = self.mainStack.backgroundContext.executeFetchRequest(request, error: &error) as? [MSGMessage] {
        let message = results.first
        println("got message \(message)")
        message?.shouldShow = true
      } else {
        println("poopy doopy")
        println(error?.description)
        abort()
      }
      if self.mainStack.backgroundContext.hasChanges && !self.mainStack.backgroundContext.save(&error) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog("Unresolved error \(error), \(error!.userInfo)")
        abort()
      }
    }
    self.mainStack.saveOperationOnbackground(op)
  }

  func create10In10BackGround() {
    let op = NSBlockOperation {
      let messageEntity = NSEntityDescription.entityForName("MSGMessage", inManagedObjectContext: self.mainStack.backgroundContext)!
      for i in 0...10 {
        println("adding a new background")
        let newMessage = MSGMessage(entity: messageEntity, insertIntoManagedObjectContext: self.mainStack.backgroundContext)
        newMessage.content = "background \(i)"
        newMessage.createdAt = NSDate()
        sleep(1)
      }
      var error: NSError? = nil
      if self.mainStack.backgroundContext.hasChanges && !self.mainStack.backgroundContext.save(&error) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog("Unresolved error \(error), \(error!.userInfo)")
        abort()
      }
    }
    self.mainStack.saveOperationOnbackground(op)
  }

  func rightBarButtonTapped(sender: AnyObject) {
    let messageEntity = NSEntityDescription.entityForName("MSGMessage", inManagedObjectContext: self.mainStack.managedObjectContext)!
    let newMessage = MSGMessage(entity: messageEntity, insertIntoManagedObjectContext: self.mainStack.managedObjectContext)
    newMessage.content = "hamburger"
    newMessage.createdAt = NSDate()
//    newMessage.shouldShow = true
    self.mainStack.saveMainContext()
  }

}

extension ViewController : UITableViewDataSource, UITableViewDelegate {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.frc.fetchedObjects!.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
    let message = self.frc.objectAtIndexPath(indexPath) as! MSGMessage
    cell.textLabel?.text = message.content
    return cell
  }

}

extension ViewController : NSFetchedResultsControllerDelegate {

  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    self.tableView.beginUpdates()
  }

  func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    switch type {
    case .Insert:
      self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
    case .Delete:
      self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
    case .Move:
      break
    case .Update:
      break
    }
  }

  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    switch type {
    case .Insert:
      self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    case .Delete:
      self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
    case .Update:
//      self.configureCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
      break
    case .Move:
      self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
      self.tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
    }
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    self.tableView.endUpdates()
  }

}