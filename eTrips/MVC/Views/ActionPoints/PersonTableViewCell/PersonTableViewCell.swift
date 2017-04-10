import UIKit

class PersonTableViewCell: UITableViewCell {

}

// MARK: - ConfigurableCell
extension PersonTableViewCell: ConfigurableCell {
    func configureForObject(object: UserEntity) {
        self.textLabel?.text = object.name
    }
}
