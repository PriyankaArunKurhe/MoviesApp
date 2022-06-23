import Foundation
import SQLite3
class DBManager {
    static let shared = DBManager()
    private var dbDetails: OpaquePointer?
    private var tableMovies = "Movies"
    private init() {
        guard let dbDetails = self.createAndOpenDB() else {
            return
        }
        self.dbDetails = dbDetails
        self.createMovieTableInDB(tableName: tableMovies)
    }
    private func fetchDocumentDirectoryPath() -> URL? {
        do{
            let documentDirectoryURL = try FileManager.default.url(for: .documentDirectory,
                                                                      in: .userDomainMask,
                                                                      appropriateFor: nil,
                                                                      create: false)
            return documentDirectoryURL
        }catch{
            print("Error is:\(error.localizedDescription)")
            return nil
        }
    }
    private func fetchDBPath() -> String? {
        guard let dbPath = fetchDocumentDirectoryPath()
        else{
            return nil
        }
        let DBPath = dbPath.appendingPathComponent("bitcode.sqlite")
        print("DB should be created at: \(DBPath.absoluteString)")
        return DBPath.absoluteString
    }
    private func createAndOpenDB() -> OpaquePointer? {
        let dbPath = fetchDBPath()
        var dbDetails: OpaquePointer?
        
        if(sqlite3_open(dbPath, &dbDetails)) == SQLITE_OK {
            return dbDetails
        }else{
            print("Data Base Can not open")
            return nil
        }
    }
    private func createMovieTableInDB(tableName: String){
        var createTableStatement: OpaquePointer?
        let createTableQuery = "CREATE TABLE \(tableName)(Title TEXT PRIMARY KEY, Image TEXT)"
        if (sqlite3_prepare(self.dbDetails,
                            createTableQuery,
                            -1,
                            &createTableStatement,
                            nil) == SQLITE_OK){
            if(sqlite3_step(createTableStatement) == SQLITE_DONE){
                print("Create Table Query excuted Successfully...")
            }else{
                print("Create Table Query not excuted...")
            }
        }else{
            print("Crate Query not Prepared...")
        }
    }
    //MARK: Insert Data
    func insertDataInMovieTable(movie: MoviesModel) {
        var insertStatement: OpaquePointer?
        let insertQuery = "INSERT INTO \(tableMovies)(Title, Image) VALUES (?,?)"
        if sqlite3_prepare(self.dbDetails, insertQuery, -1, &insertStatement, nil) == SQLITE_OK{
            let title = (movie.title! as NSString).utf8String
            let image = (movie.posterImage! as NSString).utf8String
            
            sqlite3_bind_text(insertStatement, 1, title, -1, nil)
            sqlite3_bind_text(insertStatement, 2, image, -1, nil)
            if(sqlite3_step(insertStatement) == SQLITE_DONE){
                print("Data insereted successfully to table....")
            } else {
                print("Data not insereted  to table....")
            }
        } else {
            print("Insert Query could not be prapared")
            
        }
    }
    //MARK: Read data
    func readMovieDataFromDB(completionHandler: (_ status: Bool, [MoviesModel]) -> ()) {
        var array = [MoviesModel]()
        var readStatement: OpaquePointer?
        let readQuery = "SELECT * FROM \(tableMovies)"
        if sqlite3_prepare_v2(self.dbDetails, readQuery, -1, &readStatement, nil) == SQLITE_OK {
            while sqlite3_step(readStatement) == SQLITE_ROW {
                let titleUTF8 = sqlite3_column_text(readStatement, 0)!
                let imageUTF8 = sqlite3_column_text(readStatement, 1)!
                let title = String(cString: titleUTF8)
                let image = String(cString: imageUTF8)
                let movies = MoviesModel(title: title, posterImage: image)
                array.append(movies)
            }
            completionHandler(true, array)
        } else {
            print("Unable to prepare read Query for Student Table...")
            completionHandler(false, array)
        }
    }
}

