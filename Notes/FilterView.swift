//
//  FilterView.swift
//  Notes
//
//  Created by Mac on 4/4/18.
//  Copyright © 2018 Harpal. All rights reserved.
//

import UIKit
import  SQLite3
class FilterView: UIViewController , UITableViewDelegate, UITableViewDataSource,UICollectionViewDataSource , UICollectionViewDelegate ,UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var collectionView: UICollectionView!
    var db: OpaquePointer?
    var TagData:[TagDB] = []
    var onSave:((_ data:[Int])->())?
    var selectedTag:Int? = nil
    var selected:Int? = nil
    let documentsDirPath =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let filterString:[String] = ["Date(First to Last)","Date(Last to First)","By Name(Z to A)","By Name(A to Z)"]
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return TagData.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTag = indexPath.row
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterString.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath) as! FilterTableCell
        cell.label.text = filterString[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.red
        selected = indexPath.row
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 25
    }
 
    override func viewDidAppear(_ animated: Bool) {
        collectionView.flashScrollIndicators()
    }
    @IBAction func cancelBtn(_ sender: Any) {
              self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveBtn(_ sender: Any) {
        if(selectedTag == nil){
            selectedTag  = 0
        }else{
            selectedTag = TagData[selectedTag!].id
        }
        if(selected == nil){
            selected = UserDefaults.standard.integer(forKey: "Filter")
        }
        let data:[Int] = [selected!,selectedTag!]
        onSave?(data)
       self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        for button in buttons{
            button.layer.borderColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0).cgColor;
            button.layer.borderWidth = 0.5
        }
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        if sqlite3_open(documentsDirPath.appendingPathComponent("NotesDB.db").path, &db) != SQLITE_OK {
            print("error opening database")
        }
        loadTags()
    }
    func loadTags(){
        TagData.removeAll()
        let tagQuery = "Select * FROM TAG ORDER BY ID ASC"
        var stmt:OpaquePointer?
        if sqlite3_prepare(db, tagQuery, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let tag = String(cString: sqlite3_column_text(stmt, 1))
            TagData.append(TagDB(id: Int(id),tag:tag))
        }
    }
    func Search(search:String){
        let queryString = "SELECT * FROM TAG WHERE TAG LIKE '" + search + "%'"
        print(queryString)
        var stmt:OpaquePointer?
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        TagData.removeAll()
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let tag = String(cString: sqlite3_column_text(stmt, 1))
            TagData.append(TagDB(id: Int(id),tag:tag))
        }
         collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterTag", for: indexPath) as! FilterCell
        cell.label.text = TagData[indexPath.row].tag
        cell.layer.borderColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0).cgColor;
        cell.layer.borderWidth = 0.8;
        cell.layer.cornerRadius = 5.0
        return cell
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // print(searchText)
        if searchText.isEmpty {
            loadTags()
            collectionView.reloadData()
            return
        }
        Search(search: searchText)
    }
}















