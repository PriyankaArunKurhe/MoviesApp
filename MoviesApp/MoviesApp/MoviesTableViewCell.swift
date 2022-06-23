import UIKit
class MoviesTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var myButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        posterImage.layer.borderWidth=2.0
        posterImage.layer.masksToBounds = false
        posterImage.layer.cornerRadius = 5
        posterImage.clipsToBounds = true
    }
    
}
