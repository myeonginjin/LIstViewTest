import UIKit




struct Filter: Codable{
    let name : String
    let category: String
    let effect : String
    let parameters : [String: Int]
}

struct FiltersData: Codable{
    let filters : [Filter]
}




struct Test: Codable{
    let name : String
    let category: String
    let effect : String
    let parameters : [String: Int]
}

struct TestData2: Codable{
    let tests : [Test]
}



class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var filterList: [Filter] = [] // 필터 데이터를 저장할 배열 (Codable)
    var testList: [Test] = [] // 필터 데이터를 저장할 배열 (JsonSerialization)
    var collectionView: UICollectionView!
    var collectionView2: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let text1 = UILabel()
        let text2 = UILabel()
        
        text1.textColor = .black
        text2.textColor = .black
        text1.backgroundColor = .white
        text2.backgroundColor = .white
        text1.translatesAutoresizingMaskIntoConstraints = false
        text2.translatesAutoresizingMaskIntoConstraints = false
        
        text1.text = "Json - JSONSerialization"
        text2.text = "Json - Codable"
        
        
        
        view.backgroundColor = .black
        
        setupCollectionView2()
        setupCollectionView()
        
        loadFiltersData()
        loadFiltersDataSerialization()
        
        view.addSubview(text1)
        view.addSubview(text2)
        
        text1.textAlignment = .left
        text2.textAlignment = .left
        text1.font = UIFont.systemFont(ofSize: 12)
        text2.font = UIFont.systemFont(ofSize: 12)
        
        NSLayoutConstraint.activate([
            text1.bottomAnchor.constraint(equalTo: collectionView2.topAnchor, constant: -0),
            text1.heightAnchor.constraint(equalToConstant: 30),
            text1.leadingAnchor.constraint(equalTo: collectionView2.leadingAnchor, constant: 0),

            
            text2.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -0),
            text2.heightAnchor.constraint(equalToConstant: 30),
            text2.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: 0),
//            text2.widthAnchor.constraint(equalToConstant: 100)
            
        ])

    }
    
    
    
    
    func loadFiltersData() {
        guard let url = Bundle.main.url(forResource: "filters", withExtension: "json") else {
            print("JSON file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let filtersData = try decoder.decode(FiltersData.self, from: data)
            

            for filter in filtersData.filters {
                print("\(filter.name): \(filter.parameters)")
            }
            
            self.filterList = filtersData.filters
            collectionView.reloadData()
            
            
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
    
    func loadFiltersDataSerialization() {
        guard let url = Bundle.main.url(forResource: "filters", withExtension: "json") else {
            print("JSON file not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let filtersArray = jsonObject["filters"] as? [[String: Any]] {
                self.testList = filtersArray.compactMap { dict -> Test? in
                    guard let name = dict["name"] as? String,
                          let category = dict["category"] as? String,
                          let effect = dict["effect"] as? String,
                          let parameters = dict["parameters"] as? [String: Int] else {
                              return nil
                          }
                    return Test(name: name, category: category, effect: effect, parameters: parameters)
                }
                DispatchQueue.main.async {
                    self.collectionView2.reloadData()
                }
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
    
    
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 140)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(FilterButtonCell.self, forCellWithReuseIdentifier: "FilterButtonCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: collectionView2.bottomAnchor, constant: 100),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        collectionView.backgroundColor = .gray
    }
    
    func setupCollectionView2() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 140)
        
        collectionView2 = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView2.translatesAutoresizingMaskIntoConstraints = false
        collectionView2.register(FilterButtonCell.self, forCellWithReuseIdentifier: "FilterButtonCell")
        collectionView2.dataSource = self
        collectionView2.delegate = self
        view.addSubview(collectionView2)
        
        NSLayoutConstraint.activate([
            collectionView2.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            collectionView2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView2.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        collectionView2.backgroundColor = .gray
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return filterList.count
        } 
        
        
        else if collectionView == self.collectionView2 {
            return testList.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            // collectionView에 대한 셀 구성
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterButtonCell", for: indexPath) as? FilterButtonCell else {
                fatalError("Unable to dequeue FilterButtonCell")
            }
            let filter = filterList[indexPath.row]
            cell.configure(with: UIImage(named: "input.jpg")!, name: "\(filter.name)", category: "\(filter.category)")
            return cell
        } 
        
        
        else if collectionView == self.collectionView2 {
            // collectionView2에 대한 셀 구성
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterButtonCell", for: indexPath) as? FilterButtonCell else {
                fatalError("Unable to dequeue FilterButtonCell")
            }
            let test = testList[indexPath.row]
            cell.configure(with: UIImage(named: "input2.jpg")!, name: "\(test.name)", category: "\(test.category)")
            return cell
        }
        fatalError("Unexpected collectionView")
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionView{
            let selectedFilter : Filter = filterList[indexPath.row]
            
            let message = "Codable Button \(selectedFilter.name) clicked"
            showToast(message: message, seconds: 0.5)
        }
        
        
        else if collectionView == self.collectionView2{
            let selectedFilter : Test = testList[indexPath.row]
            
            let message = "JsonSerialization Button \(selectedFilter.name) clicked"
            showToast(message: message, seconds: 0.5)
        }
        

    }

    
    
    @objc func filterButtonTapped(_ sender: UIButton) {
        let message = "ScrollView Button \(sender.tag) clicked"
        showToast(message: message, seconds: 0.5)
    }

    func showToast(message : String, seconds: Double){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15

        present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds){
            alert.dismiss(animated: true)
        }
    }
    
    
    
}





// MARK: - FilterButtonCell
class FilterButtonCell: UICollectionViewCell {
    private let thumbnailImageView = UIImageView()
    private let nameLabel = UILabel()
    private let CategoryLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        thumbnailImageView.contentMode = .scaleAspectFit
        contentView.addSubview(thumbnailImageView)
        
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        
        
        CategoryLabel.textAlignment = .center
        CategoryLabel.font = UIFont.systemFont(ofSize: 12)
        CategoryLabel.textColor = .white
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(CategoryLabel)
        
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        CategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            thumbnailImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor),
//            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            CategoryLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 4),
            CategoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            CategoryLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 8)
        ])
    }
    
    func configure(with image: UIImage, name: String , category : String) {
        thumbnailImageView.image = image
        nameLabel.text = name
        CategoryLabel.text = category
    }
}

