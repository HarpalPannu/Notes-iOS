//  ViewController.swift
//  Notes
//  Created by Mac on 3/28/18.
//  Copyright © 2018 Harpal. All rights reserved.

import UIKit
import SQLite3
class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {

    @IBOutlet var tableView: UITableView!
    var db: OpaquePointer?
    var Notes = [NoteDB]()
      var tableIndex: NSIndexPath? = nil
    let filterString:[Int:String] = [0:"Date(First to Last)", 1:"Date(Last to First)", 2:"By Name(Z to A)",3:"By Name(A to Z)"]
    let Filter:Int =  UserDefaults.standard.integer(forKey: "Filter")
    let documentsDirPath =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(documentsDirPath)
         self.hideKeyboardWhenTappedAround()
        // UserDefaults.standard.set(0,forKey: "Tag")
     //   let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
      //  view.addGestureRecognizer(tap)
        let isDataBaseFileExists = FileManager.default.fileExists(atPath: documentsDirPath.appendingPathComponent("NotesDB.db").path)
        let src = Bundle.main.resourceURL!.appendingPathComponent("NotesDB.db")
        let dst = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("NotesDB.db")
        if !isDataBaseFileExists{
            do{
                try FileManager.default.copyItem(at:src , to: dst)
            }catch{
                print(error)
            }
        }
        if sqlite3_open(documentsDirPath.appendingPathComponent("NotesDB.db").path, &db) != SQLITE_OK {
            print("error opening database")
        }
        updateTable(filter: Filter,tag:UserDefaults.standard.integer(forKey: "Tag"))
    }
  
    override func viewDidAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow{          //Gets index of Selected Cell
            self.tableView.deselectRow(at: index, animated: true)       //deselects cell of Table view
        }
        if UserDefaults.standard.bool(forKey: "tableUpdate"){
            updateTable(filter: UserDefaults.standard.integer(forKey: "Filter"),tag:UserDefaults.standard.integer(forKey: "Tag"))
            UserDefaults.standard.set(false, forKey: "tableUpdate")
            print("Yes")
        }else{
            print("Na")
        }
    }
    @IBAction func filter(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "filterView", sender: nil)
        
       //  self.updateTable(filter: 2)
//        let alert = UIAlertController(title: "",
//                                      message: "",
//                                      preferredStyle: .alert)
//
//        // Change font of the title and message
//        let titleFont:[NSAttributedStringKey : AnyObject] = [ NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue) : UIFont(name: "AmericanTypewriter", size: 18)! ]
//        let messageFont:[NSAttributedStringKey : AnyObject] = [ NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue) : UIFont(name: "AmericanTypewriter", size: 14)! ]
//        let attributedTitle = NSMutableAttributedString(string: "Select Filter", attributes: titleFont)
//        let attributedMessage = NSMutableAttributedString(string: "Current Filter : \(filterString[UserDefaults.standard.integer(forKey: "Filter")] ?? "None")" , attributes: messageFont)
//        alert.setValue(attributedTitle, forKey: "attributedTitle")
//        alert.setValue(attributedMessage, forKey: "attributedMessage")
//
//        let action1 = UIAlertAction(title: filterString[0], style: .default, handler: { (action) -> Void in
//            print("ACTION 1 selected!")
//            self.updateTable(filter: 0)
//            self.defaults.set(0, forKey: "Filter")
//        })
//
//        let action2 = UIAlertAction(title: filterString[1], style: .default, handler: { (action) -> Void in
//            print("ACTION 2 selected!")
//            self.updateTable(filter: 1)
//            self.defaults.set(1, forKey: "Filter")
//        })
//
//        let action3 = UIAlertAction(title: filterString[2], style: .default, handler: { (action) -> Void in
//            print("ACTION 3 selected!")
//            self.updateTable(filter: 2)
//            self.defaults.set(2, forKey: "Filter")
//        })
//
//        let action4 = UIAlertAction(title: filterString[3], style: .default, handler: { (action) -> Void in
//            print("ACTION 3 selected!")
//            self.updateTable(filter: 3)
//            self.defaults.set(3, forKey: "Filter")
//        })
//
//
//        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
//
//
//        alert.view.tintColor = UIColor.brown  // change text color of the buttons
//        alert.view.backgroundColor = UIColor.white  // change background color
//        alert.view.layer.cornerRadius = 25   // change corner radius
//
//
//        // Add action buttons and present the Alert
//        alert.addAction(action1)
//        alert.addAction(action2)
//        alert.addAction(action3)
//        alert.addAction(action4)
//        alert.addAction(cancel)
//        present(alert, animated: true, completion: nil)
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return Notes.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! TableViewCell
        cell.title.text = Notes[indexPath.row].title
        cell.date.text = convertDate(timestamp: Double(Notes[indexPath.row].timestamp)!)
        if(indexPath.row % 2 == 0){
             cell.layer.backgroundColor  = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0).cgColor
        }else{
            cell.layer.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0).cgColor
        }
        return cell
    }
    
    func convertDate(timestamp:Double)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "EEEE, MMM d"
        let strDate = dateFormatter.string(from: Date(timeIntervalSince1970:timestamp))
        return "Created : " + strDate
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let segueData = self.Notes[indexPath.row]
        performSegue(withIdentifier: "dataView", sender: segueData)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "dataView" {
            let destVC = segue.destination as! ViewNote
            destVC.NotesData = sender as? NoteDB
        }
        if segue.identifier == "filterView" {
            let destVC = segue.destination as! FilterView
            destVC.onSave = {
                (data) in
                let filter = data[0]
                let tag = data[1]
                print(filter)
                self.updateTable(filter:filter,tag:tag)
            }
            
        }
    }
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 60
   }
    func updateTable(filter:Int,tag:Int){
        
        var tagId = ""
        UserDefaults.standard.set(tag,forKey: "Tag")
        if(tag > 0){
            tagId = " WHERE TAGID = " + String(tag)
        }
        var queryString:String = String()
        if(filter == 0){
            queryString = "SELECT * FROM Notes" + tagId + " Order BY id DESC"
        }else if(filter == 1){
            queryString = "SELECT * FROM Notes" + tagId + " Order BY id ASC"
        }else if(filter == 2){
            queryString = "SELECT * FROM Notes" + tagId + " Order BY TITLE DESC"
        }else if(filter == 3){
            queryString = "SELECT * FROM Notes" + tagId + " Order BY TITLE ASC"

        }
        print(queryString)
        var stmt:OpaquePointer?
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        Notes.removeAll()
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let title = String(cString: sqlite3_column_text(stmt, 1))
            let note = String(cString: sqlite3_column_text(stmt, 2))
            let files = String(cString: sqlite3_column_text(stmt, 3))
            let timestamp = String(cString: sqlite3_column_text(stmt, 4))
            let location = String(cString: sqlite3_column_text(stmt, 5))
            Notes.append(NoteDB(id: Int(id),title:title,note:note,files:files,timestamp:timestamp,location:location))
        }
        
        tableView.refreshTable()
    }
    
    func Search(search:String){
        let queryString = "SELECT * FROM Notes WHERE TITLE LIKE '" + search + "%' OR NOTE LIKE '" + search + "%'"
      //  print(queryString)
        var stmt:OpaquePointer?
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        Notes.removeAll()
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let title = String(cString: sqlite3_column_text(stmt, 1))
            let note = String(cString: sqlite3_column_text(stmt, 2))
            let files = String(cString: sqlite3_column_text(stmt, 3))
            let timestamp = String(cString: sqlite3_column_text(stmt, 4))
            let location = String(cString: sqlite3_column_text(stmt, 5))
            Notes.append(NoteDB(id: Int(id),title:title,note:note,files:files,timestamp:timestamp,location:location))
        }
        tableView.refreshTable()
    }
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.tableIndex = indexPath as NSIndexPath
            let planetToDelete = self.Notes[indexPath.row]
            self.confirmDelete(note: planetToDelete.title)
        }
        
        let share = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            // share item at indexPath
            
            print("I want to share: ")
        }
        
        share.backgroundColor = UIColor.blue
        
        return [delete, share]
        
    }
    
    func delete(ID:Int) {
        var deleteStatement: OpaquePointer? = nil
        let deleteStatementStirng = "DELETE FROM Notes WHERE ID=" + String(ID)
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    
    // Delete Confirmation and Handling
    func confirmDelete(note: String) {
        let alert = UIAlertController(title: "Delete Note", message: "Are you sure you want to permanently delete \"\(note)\" ?", preferredStyle: .actionSheet)
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDelete)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDelete)
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleDelete(alertAction: UIAlertAction!) -> Void {
        if let indexPath = tableIndex {
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath as IndexPath], with: .left)
            delete(ID: Notes[indexPath.row].id)
            
            if(!Notes[indexPath.row].files.isEmpty){
                let Images = Notes[indexPath.row].files.components(separatedBy: ",")
                if(Images.count > 0){
                    for Image in Images{
                        do{
                            let imagePath = documentsDirPath.appendingPathComponent(Image)
                            try FileManager.default.removeItem(at: imagePath)
                        }catch{
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            Notes.remove(at: indexPath.row)
            tableIndex = nil
            tableView.endUpdates()
        }
    }
    
    func cancelDelete(alertAction: UIAlertAction!) {
        tableIndex = nil
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       // print(searchText)
        if searchText.isEmpty {
            updateTable(filter: UserDefaults.standard.integer(forKey: "Filter"),tag:UserDefaults.standard.integer(forKey: "Tag"))
            return
        }
        Search(search: searchText)
        tableView.refreshTable()
    }
}
extension UITableView {
    func refreshTable(){
        let indexPathForSection = NSIndexSet(index: 0)
        self.reloadSections(indexPathForSection as IndexSet, with: UITableViewRowAnimation.left)
    }
}
extension Date {
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        return end - start
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

