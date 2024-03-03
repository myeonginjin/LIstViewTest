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




struct Test{
    let name : String
    let category: String
    let effect : String
    let parameters : [String: Int]
}

struct XMLFilter {
    var name: String = ""
    var category: String = ""
    var effect: String = ""
    var parameters: [String: String] = [:]
}





class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var filterList: [Filter] = [] // 필터 데이터를 저장할 배열 (Codable)
    var testList: [Test] = [] // 필터 데이터를 저장할 배열 (JsonSerialization)
    var xmlFiltersList: [XMLFilter] = []
    var collectionView: UICollectionView!
    var collectionView2: UICollectionView!
    var collectionView3: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let text1 = UILabel()
        let text2 = UILabel()
        let text3 = UILabel()
        
        text1.textColor = .black
        text2.textColor = .black
        text1.backgroundColor = .white
        text2.backgroundColor = .white
        text3.textColor = .black
        text3.backgroundColor = .white
        text1.translatesAutoresizingMaskIntoConstraints = false
        text2.translatesAutoresizingMaskIntoConstraints = false
        text3.translatesAutoresizingMaskIntoConstraints = false
        
        text1.text = "Json - JSONSerialization"
        text2.text = "Json - Codable"
        text3.text = "XML - XMLParser"
        
        
        
        view.backgroundColor = .black
        
        setupCollectionView2()
        setupCollectionView()
        setupCollectionView3()
        
        loadFiltersData()
        loadFiltersDataSerialization()
        loadXMLFiltersData()
        
        view.addSubview(text1)
        view.addSubview(text2)
        view.addSubview(text3)
        
        text1.textAlignment = .left
        text2.textAlignment = .left
        text3.textAlignment = .left
        text1.font = UIFont.systemFont(ofSize: 12)
        text2.font = UIFont.systemFont(ofSize: 12)
        text3.font = UIFont.systemFont(ofSize: 12)
        
        NSLayoutConstraint.activate([
            text1.bottomAnchor.constraint(equalTo: collectionView2.topAnchor, constant: -0),
            text1.heightAnchor.constraint(equalToConstant: 30),
            text1.leadingAnchor.constraint(equalTo: collectionView2.leadingAnchor, constant: 0),

            
            text2.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -0),
            text2.heightAnchor.constraint(equalToConstant: 30),
            text2.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: 0),
//            text2.widthAnchor.constraint(equalToConstant: 100)
            
            text3.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 70),
            text3.heightAnchor.constraint(equalToConstant: 30),
            text3.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: 0),
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
    
    func loadXMLFiltersData() {
        if let url = Bundle.main.url(forResource: "filters", withExtension: "xml"),
           let data = try? Data(contentsOf: url) {
            print("XML 데이터 로드 성공") // 성공적으로 로드되었는지 확인
            let parser = XMLFiltersParser()
            let xmlFilters = parser.parse(data: data)
            self.xmlFiltersList = xmlFilters
            collectionView3.reloadData()
        } else {
            print("XML 데이터 로드 실패") // 파일 로드 실패 시
        }
    }

    
    class XMLFiltersParser: NSObject, XMLParserDelegate {
        var filters: [XMLFilter] = []
        var currentElement = ""
        var currentFilter: XMLFilter?
        var currentValue = ""

        // 추가된 parse(data:) 메서드
        func parse(data: Data) -> [XMLFilter] {
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
            return filters
        }

        // 태그의 시작
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            
            print("시작 태그: \(elementName)")
            
            currentElement = elementName
            if elementName == "filter" {
                currentFilter = XMLFilter()
            }
        }

        // 태그 사이의 문자열
        func parser(_ parser: XMLParser, foundCharacters string: String) {
            
            print("찾은 문자열: \(string)")
            
            currentValue += string
        }

        // 태그의 끝
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            
            print("종료 태그: \(elementName)")
            
            switch elementName {
            case "filter":
                if let filter = currentFilter {
                    filters.append(filter)
                }
                currentFilter = nil
            case "name":
                currentFilter?.name = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
            case "category":
                currentFilter?.category = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
            case "effect":
                currentFilter?.effect = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
            default:
                if currentElement == "parameters" && elementName != "parameters" {
                    currentFilter?.parameters[elementName] = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            currentValue = ""
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
            collectionView2.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            collectionView2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView2.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        collectionView2.backgroundColor = .gray
    }
    
    func setupCollectionView3() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 140)
        
        collectionView3 = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView3.translatesAutoresizingMaskIntoConstraints = false
        collectionView3.register(FilterButtonCell.self, forCellWithReuseIdentifier: "FilterButtonCell")
        collectionView3.dataSource = self
        collectionView3.delegate = self
        view.addSubview(collectionView3)
        
        NSLayoutConstraint.activate([
            collectionView3.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 100),
            collectionView3.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView3.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView3.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        collectionView3.backgroundColor = .gray
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return filterList.count
        } 
        
        
        else if collectionView == self.collectionView2 {
            return testList.count
        }
        
        else if collectionView == self.collectionView3 {
            print(xmlFiltersList.count)
            return xmlFiltersList.count
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
        
        
        else if collectionView == self.collectionView3 {
            // collectionView2에 대한 셀 구성
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterButtonCell", for: indexPath) as? FilterButtonCell else {
                fatalError("Unable to dequeue FilterButtonCell")
            }
            let xmlFilter = xmlFiltersList[indexPath.row]
            cell.configure(with: UIImage(named: "input2.jpg")!, name: "\(xmlFilter.name)", category: "\(xmlFilter.category)")
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
        
        else if collectionView == self.collectionView3{
            let selectedFilter : Test = testList[indexPath.row]
            
            let message = "XMLParser Button \(selectedFilter.name) clicked"
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

