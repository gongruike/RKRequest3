import UIKit

class ViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onUserBtnClicked(_ sender: Any) {
        getUserInfo(userID: "354287")
    }
    
    @IBAction func onUserListBtnClicked(_ sender: Any) {
        getUserList()
    }
    
    // 根据userID获取用户信息
    func getUserInfo(userID: String) {
        let request = UserInfoRequest(userID: userID) { (result) in
            switch result {
            case .success(let user):
                print(user)
            case .failure(let error):
                print(error.getErrorInfo())
            }
        }
        HTTPClient.shared.startRequest(request)
    }
    
    // 获取用户列表
    func getUserList() {
        let request = UserListRequest { (result) in
            switch result {
            case .success(let users):
                print(users)
            case .failure(let error):
                print(error.getErrorInfo())
            }
        }
        HTTPClient.shared.startRequest(request)
    }
    
}

