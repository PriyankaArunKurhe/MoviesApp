import UIKit
class ViewController: UIViewController {
//MARK: Outlets and Variables
    @IBOutlet weak var moviesTableView: UITableView!
    var moviesDetail = [MoviesModel]()
    let dbManager = DBManager.shared
    //MARK: LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Movies"
        self.moviesTableView.dataSource = self
        self.moviesTableView.delegate = self
        fetchData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        dbManager.readMovieDataFromDB {[weak self] status, movies in
            if status {
                self?.moviesDetail = movies
                moviesTableView.reloadData()
            } else {
                print("Unable to read data")
            }
        }
    }
    //MARK: URL Session Method
    private func fetchData() {
        let urlString = "https://api.themoviedb.org/3/discover/movie?now_playing&api_key=34c902e6393dc8d970be5340928602a7"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) {[weak self] data, response, error in
            if error == nil {
                guard let data = data else {
                    print("Data is nil")
                    return
                }
                do {
                    guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                        return
                    }
                    guard let jsonObject = jsonObject["results"] as? [[String: Any]] else {
                        print("Json not found")
                        return
                    }
                    for dictionary in jsonObject {
                        let eachDictionary = dictionary as? [String: Any]
                        let postTitle = eachDictionary!["title"] as? String ?? ""
                        let postImage = eachDictionary!["poster_path"] as? String ?? ""
                        let movies = MoviesModel(title: postTitle, posterImage: postImage)
                        self?.moviesDetail.append(movies)
                    }
                    DispatchQueue.main.async {
                        self?.moviesTableView.reloadData()
                    }
                } catch {
                    print(error.localizedDescription)
                }
                
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
        dataTask.resume()
    }
}
//MARK: DataSource Protocol
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        moviesDetail.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.moviesTableView.dequeueReusableCell(withIdentifier: "MoviesTableViewCell", for: indexPath) as? MoviesTableViewCell else {
            return UITableViewCell()
        }
        cell.layer.borderWidth = 2.0
        let moviesRecord = moviesDetail[indexPath.row]
        cell.titleLabel.text = moviesRecord.title!
        let path = URL(string: "https://image.tmdb.org/t/p/original\(moviesRecord.posterImage ?? "")")
        URLSession.shared.dataTask(with: path!) {
            (data, response, error) in
            guard
                let data = data
            else {
                return
            }
            DispatchQueue.main.async {
                cell.posterImage.image = UIImage(data: data)
            }
        }.resume()
        return cell
    }
    
}
//MARK: Delegate Protocol
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        140
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dbManager.insertDataInMovieTable(movie: self.moviesDetail[indexPath.row])
    }
}
