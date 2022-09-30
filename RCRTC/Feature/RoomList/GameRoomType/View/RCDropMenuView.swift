

private let SCREEN_WIDTH = UIScreen.main.bounds.size.width
private let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

protocol RCDropMenuViewDelegate: NSObjectProtocol {
    func menu(_ menu: RCDropMenuView, didSelectRowAtIndexPath index: RCDropMenuView.Index)
    func menu(_ menu: RCDropMenuView, didClickTitleBtn column: Int, isShow: Bool)
    func menu(_ menu: RCDropMenuView, cancelClickTitleBtn column: Int)
}

protocol RCDropMenuViewDataSource: NSObjectProtocol {

    func numberOfColumns(in menu: RCDropMenuView) -> Int

    func menu(_ menu: RCDropMenuView, numberOfRowsInColumn column: Int) -> Int

    func menu(_ menu: RCDropMenuView, titleForRowsInIndePath index: RCDropMenuView.Index) -> String

    func menu(_ menu: RCDropMenuView, numberOfItemsInRow row: Int, inColumn: Int) -> Int

    func menu(_ menu: RCDropMenuView, titleForItemInIndexPath indexPath: RCDropMenuView.Index) -> String
}


extension RCDropMenuViewDataSource {
    func numberOfColumns(in menu: RCDropMenuView) -> Int {
        return 1
}

func menu(_ menu: RCDropMenuView, numberOfItemsInRow row: Int, inColumn: Int) -> Int {
    return 0
}

func menu(_ menu: RCDropMenuView, titleForItemInIndexPath indexPath: RCDropMenuView.Index) -> String {
    return ""
}
}


import UIKit

class RCDropMenuView: UIView {

    public struct Index {
        // 列
        var column: Int
        //行
        var row: Int
        
        init(column: Int, row: Int) {
            self.column = column
            self.row = row
        }
    }

    //MARK:- 数据源
    weak var dataSource: RCDropMenuViewDataSource? {
        didSet {
            if oldValue === dataSource {
                return
            }
            dataSourceDidSet(dataSource: dataSource!)
        }
    }

    weak var delegate: RCDropMenuViewDelegate?

    private lazy var backgroundView: UIView = {
        let bgView = UIView(frame: CGRect(x: menuOrigin.x, y: menuOrigin.y, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        bgView.alpha = 0
        return bgView
    }()

    // 菜单的原点坐标
    private var menuOrigin: CGPoint = CGPoint.zero
    // 菜单高度
    private var menuHeight: CGFloat = 0
    // tableView最大高度
    private var maxTableViewHeight: CGFloat = SCREEN_HEIGHT - 200
    // 当前选中的是哪一列
    private var selectedColumn: Int = -1
    // 每一列选中的row
    private var selectedRows = Array<Int>()
    // 列表是否正在展示
    private var isShow: Bool = false
    // 动画时长
    private var animationDuration: TimeInterval = 0.25
    // cell的高度
    private let cellHeight: CGFloat = 50
    // cell的标识
    private let DropViewTableCellID = "DropViewTableCellID"
    // titleLabels
    private var titleLabels = [UILabel]()
    // 背景颜色
    private var bgColor: UIColor = UIColor.white
    // title字体颜色
    private var titleColor: UIColor =  UIColor.white
    // title 字体大小
    private var titleFont: UIFont = UIFont.systemFont(ofSize: 15)
    // 分割线颜色
    private var seperatorLineColor: UIColor = UIColor.lightGray
    
    
    
    private lazy var filterContentView: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor(hexString: "#E8F0F3")
        instance.addSubview(gamesCollectionView)
        instance.addSubview(cancelBtn)
        instance.addSubview(doneBtn)
        instance.layer.cornerRadius = 15
        instance.layer.masksToBounds = true
        return instance
    }()
    
    private lazy var gamesCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: 100.resize, height: 33.resize)
        flowLayout.minimumInteritemSpacing=1

        let instance = UICollectionView(frame: CGRect(x: 0, y: 55, width: SCREEN_WIDTH, height: 120), collectionViewLayout: flowLayout)
        instance.backgroundColor = UIColor(hexString: "#E8F0F3")
        instance.showsHorizontalScrollIndicator = false
        instance.showsVerticalScrollIndicator = false
        instance.delegate = self
        instance.dataSource = self
        
        instance.contentInset = UIEdgeInsets(top: 1.resize, left: 24.resize, bottom: 15.resize, right: 24.resize)
        instance.register(RCGameFiterViewCell.self, forCellWithReuseIdentifier: "FILTER_CELL")
        return instance
    }()
    
    private lazy var cancelBtn: UIButton = {
        let instance = UIButton(frame: CGRect(x: 22, y: gamesCollectionView.bottomY + 18, width: SCREEN_WIDTH/2 - 31, height: 36))
        instance.setTitle("取消", for: .normal)
        instance.setTitleColor(UIColor(hexString: "#686689"), for: .normal)
        instance.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 15)
        instance.backgroundColor = UIColor(hexString: "#DBE2E8")
        instance.layer.cornerRadius = 15
        instance.layer.masksToBounds = true
        instance.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        return instance
    }()
    
    private lazy var doneBtn: UIButton = {
        let instance = UIButton(frame: CGRect(x: cancelBtn.x+cancelBtn.width+20, y: gamesCollectionView.bottomY + 18, width: SCREEN_WIDTH/2 - 31, height: 36))
        instance.setTitle("完成", for: .normal)
        instance.setTitleColor(UIColor(hexString: "#FFFFFF"), for: .normal)
        instance.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 15)
        instance.backgroundColor = UIColor(hexString: "#FC5262")
        instance.layer.cornerRadius = 15
        instance.layer.masksToBounds = true
        instance.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        return instance
    }()
    
    @objc func cancelBtnClick() {
        self.tapToDismiss()
    }
    
    @objc func doneBtnClick() {
        //收回列表
        animationTableView(show: false)
        isShow = false
        guard self.selectedRows[selectedColumn] != -1 else {
            delegate?.menu(self, cancelClickTitleBtn: -1)
            return
        }
        //更新title
        if let dataSource = dataSource {
            titleLabels[selectedColumn].text = dataSource.menu(self, titleForItemInIndexPath: Index(column: selectedColumn, row: selectedRows[selectedColumn]))
        }
        
        delegate?.menu(self, didSelectRowAtIndexPath: Index(column: selectedColumn, row: selectedRows[selectedColumn]))
    }
    
    init(menuOrigin: CGPoint, menuHeight: CGFloat) {
        self.menuOrigin = menuOrigin
        self.menuHeight = menuHeight
        
        super.init(frame: CGRect(x: menuOrigin.x, y: menuOrigin.y, width: SCREEN_WIDTH, height: menuHeight))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss))
        backgroundView.addGestureRecognizer(tapGesture)
        
        backgroundColor = bgColor
        
    }

    @objc func tapToDismiss() {
        animationTableView(show: false)
        isShow = false
        delegate?.menu(self, cancelClickTitleBtn: -1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func dataSourceDidSet(dataSource: RCDropMenuViewDataSource) {
        let columns = dataSource.numberOfColumns(in: self)
        createtitleLabels(columns: columns)
        
        selectedRows = Array<Int>(repeating: -1, count: columns)
    }

    private func createtitleLabels(columns: Int) {

        let btnW: CGFloat = 90
        let btnH: CGFloat = 25
        let btnY: CGFloat = 15
        var btnX: CGFloat = 25
        
        let defaultTitles = ["不限性别", "不限游戏"]
        
        for i in 0..<columns {
            let btn = UIButton(type: .custom)
            btnX = CGFloat(i) * btnW + 30
            btn.frame = CGRect(x: btnX, y: btnY, width: btnW, height: btnH)
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 58, height: 20))
            label.textColor = UIColor(hexString: "#03003A",alpha: 0.6)
            label.font = UIFont(name: "PingFangSC-Medium", size: 14)
            if i < 2 {
                label.text = defaultTitles[i]
            }
            
            let imageView = UIImageView(frame: CGRect(x: label.width+5, y: 8.5, width: 10, height: 8))
            imageView.image = R.image.groom_arrowdown_icon()
            
            btn.addSubview(label)
            btn.addSubview(imageView)
            
            btn.addTarget(self, action: #selector(titleBtnDidClick(btn:)), for: .touchUpInside)
            btn.tag = i + 1000
            addSubview(btn)
            titleLabels.append(label)
        }
    }

    @objc func titleBtnDidClick(btn: UIButton) {
        let column = btn.tag - 1000
        
        if selectedColumn == column && isShow {
            // 收回列表
            animationTableView(show: false)
            isShow = false
            
        } else {
            selectedColumn = column
            gamesCollectionView.reloadData()
            
            // 展开列表
            animationTableView(show: true)
            isShow = true
        }
        delegate?.menu(self, didClickTitleBtn: column, isShow: isShow)
    }

    //MARK:- 展示或者隐藏TableView
    func animationTableView(show: Bool) {
        var rows = (gamesCollectionView.numberOfItems(inSection: 0) / 3) + 1
        if rows < 2 {
            rows = 2
        }
        let tableViewHeight : CGFloat = 125.0 + CGFloat(rows)*48.0
        
        if show {
            superview?.addSubview(backgroundView)
            superview?.addSubview(self)
            
            filterContentView.frame = CGRect(x: menuOrigin.x, y: -tableViewHeight, width: SCREEN_WIDTH, height: tableViewHeight)
            superview?.insertSubview(filterContentView, belowSubview: self)
            gamesCollectionView.frame.size.height = tableViewHeight - 125.0
            cancelBtn.y = gamesCollectionView.bottomY + 18
            doneBtn.y = gamesCollectionView.bottomY + 18

            UIView.animate(withDuration: animationDuration) {
                self.backgroundView.alpha = 1.0
                self.filterContentView.y = self.menuOrigin.y
            }
        } else {
            UIView.animate(withDuration: animationDuration, animations: {
                self.backgroundView.alpha = 0
                self.filterContentView.y = -tableViewHeight
            }) { (_) in
                self.backgroundView.removeFromSuperview()
                self.filterContentView.removeFromSuperview()
            }
        }
    }

    }

extension RCDropMenuView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FILTER_CELL", for: indexPath) as! RCGameFiterViewCell
        
        if let dataSource = dataSource {
            cell.contentlabel.text = dataSource.menu(self, titleForRowsInIndePath: Index(column: selectedColumn, row: indexPath.row))
        }

        // 选中上次选中的那行
        if selectedRows[selectedColumn] == indexPath.row {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let dataSource = dataSource {
            return dataSource.menu(self, numberOfRowsInColumn: selectedColumn)
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedRows[selectedColumn] = indexPath.row
    }
}
