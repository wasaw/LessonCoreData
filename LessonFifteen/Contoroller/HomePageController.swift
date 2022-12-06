//
//  HomePageController.swift
//  LessonFifteen
//
//  Created by Александр Меренков on 29.11.2022.
//

import UIKit

class HomePageController: UIViewController {
    
//    MARK: - Properties
    private var tableView: UITableView?
    private let searchBar = UISearchBar(frame: .zero)
    private var selectedCellId: Int?
    private weak var lastCell: TableCell?
    
    private var inputData: [InputData] = []
    private var profiles: [Profile] = []
    
    private let groupProfileImages = DispatchGroup()
    private let groupWorkImages = DispatchGroup()
        
//    MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        isFirstLaunce()
        configureUI()
        view.backgroundColor = .background
    }
 
//    MARK: - Helpers
    
    private func isFirstLaunce() {
        DispatchQueue.main.async {
            if DatabaseService.shared.firstLaunch() {
                self.loadNetworkInformation()
            } else {
                let loadProfiles = DatabaseService.shared.loadInformation()
                guard let loadProfiles = loadProfiles else { return }
                self.profiles = loadProfiles
                self.tableView?.reloadData()
            }
        }
    }
    
    private func loadNetworkInformation() {
        NetworkService.shared.request(requestType: .collections, metod: .get) { response in
            guard let response = response else { return }
            for item in response {
                let OutputData = InputData(userName: item.user.name, imageProfileString: item.user.profile_image.small, previewPhoto: item.preview_photos[0])
                self.inputData.append(OutputData)
            }
                        
            for i in 0..<self.inputData.count {
                self.groupProfileImages.enter()
                let item = self.inputData[i].imageProfileString

                NetworkService.shared.downloadImg(urlString: item) { data in
                    guard let img = UIImage(data: data) else { return }
                    self.inputData[i].profileImg = img
                    self.groupProfileImages.leave()
                }
            }
            
            self.groupProfileImages.notify(queue: DispatchQueue.global()) {
                
                for i in 0..<self.inputData.count {
                    self.groupWorkImages.enter()
                    let item = self.inputData[i].previewPhoto.urls.small
                    
                    NetworkService.shared.downloadImg(urlString: item) { data in
                        guard let img = UIImage(data: data) else { return }
                        self.inputData[i].workImage = img
                        guard let profileImage = self.inputData[i].profileImg else { return }
                        guard let workImage = self.inputData[i].workImage else { return }
                        let profile = Profile(userName: self.inputData[i].userName, profileImage: profileImage, workImage: workImage)
                        self.profiles.append(profile)
                        self.groupWorkImages.leave()
                    }
                }
                
                self.groupWorkImages.notify(queue: DispatchQueue.main) {
                    self.tableView?.reloadData()
                    DatabaseService.shared.saveInformation(profiles: self.profiles)
                }
            }
        }
    }
    
    private func configureUI() {
        configureSearchBar()
        configureTableView()
    }
    
    private func configureSearchBar() {
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 45).isActive = true
        searchBar.barTintColor = .background
        let tf = searchBar.value(forKey: "searchField") as? UITextField
        tf?.textColor = .black
        searchBar.delegate = self
        searchBar.showsCancelButton = true
    }
    
    private func configureTableView() {
        tableView = UITableView(frame: .zero)
        guard let tableView = tableView else { return }
        tableView.register(TableCell.self, forCellReuseIdentifier: TableCell.identifire)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 720).isActive = true
        tableView.backgroundColor = .background
    }
}

//  MARK: - UITableViewDelegate

extension HomePageController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? TableCell
        if cell != lastCell {
            lastCell?.hide()
        }
        let view = UIView()
        view.backgroundColor = .selectedCell
        cell?.selectedBackgroundView = view
        selectedCellId = indexPath.row
        tableView.beginUpdates()
        tableView.endUpdates()
        cell?.addPhoto()
        lastCell = cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedCellId == indexPath.row {
            return 510.0
        }
        return 72.0
    }
}

//  MARK: - UITableViewDataSource

extension HomePageController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableCell.identifire, for: indexPath) as? TableCell else { return UITableViewCell() }
        if !profiles.isEmpty {
            cell.setInformation(cellNumber: indexPath.row + 1, profile: profiles[indexPath.row])
        }
        return cell
    }
}

//  MARK: - UISearchBarDelegate

extension HomePageController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        let loadProfiles = DatabaseService.shared.searchInDB(text)
        guard let loadProfiles = loadProfiles else { return }
        self.profiles = loadProfiles
        self.tableView?.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        let loadProfiles = DatabaseService.shared.loadInformation()
        guard let loadProfiles = loadProfiles else { return }
        self.profiles = loadProfiles
        self.selectedCellId = nil
        self.lastCell?.hide()
        self.tableView?.reloadData()
        view.endEditing(true)
    }
}
