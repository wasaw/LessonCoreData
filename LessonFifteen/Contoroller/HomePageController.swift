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
    private var lastCell: TableCell?
    
    private var profiles: [OutputData] = []
    private var imageStringArray: [String] = []
        
//    MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        isFirstLaunce()
        configureUI()
        view.backgroundColor = .background
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DatabaseService.shared.saveInformation(profiles: profiles)
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
                self.imageStringArray.append(item.user.profile_image.small)
                let user = OutputData(userName: item.user.name, profileImg: UIImage(), workImage: UIImage(), previewPhoto: item.preview_photos[0])
                self.profiles.append(user)
            }
            var index = 0
            for item in self.imageStringArray {
                NetworkService.shared.downloadImg(urlString: item) { data in
                    guard let img = UIImage(data: data) else { return }
                    self.profiles[index].profileImg = img
                    index += 1
                }
            
            }
                var secondIndex = 0
                for item in self.profiles {
                    NetworkService.shared.downloadImg(urlString: item.previewPhoto.urls.small) { data in
                        guard let img = UIImage(data: data) else { return }
                        self.profiles[secondIndex].workImage = img
                        secondIndex += 1
                    }
                }
                self.tableView?.reloadData()
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
        self.tableView?.reloadData()
        view.endEditing(true)
    }
}
