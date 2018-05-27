class NoteDB {
    var id: Int
    var title: String
    var note: String
    var files: String
    var timestamp: String
    var location: String
    init(id:Int,title:String,note:String,files:String,timestamp:String,location:String){
         self.id = id
         self.title = title
         self.note = note
         self.files = files
         self.timestamp = timestamp
         self.location = location
    }
}
class TagDB{
    var id: Int
    var tag: String
    init(id:Int,tag:String){
        self.id = id
        self.tag = tag
    }
}

