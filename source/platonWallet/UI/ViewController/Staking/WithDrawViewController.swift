//
//  WithDrawViewController.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class WithDrawViewController: BaseViewController {
    
    var currentNode: Node?
    var listData: [DelegateTableViewCellStyle] = []
    
    lazy var tableView = { () -> UITableView in
        let tbView = UITableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(NodeInfoTableViewCell.self, forCellReuseIdentifier: "NodeInfoTableViewCell")
        tbView.register(WalletTableViewCell.self, forCellReuseIdentifier: "WalletTableViewCell")
        tbView.register(WalletBalanceTableViewCell.self, forCellReuseIdentifier: "WalletBalanceTableViewCell")
        tbView.register(SendInputTableViewCell.self, forCellReuseIdentifier: "SendInputTableViewCell")
        tbView.register(SingleButtonTableViewCell.self, forCellReuseIdentifier: "SingleButtonTableViewCell")
        tbView.register(DoubtTableViewCell.self, forCellReuseIdentifier: "DoubtTableViewCell")
        tbView.separatorStyle = .none
        tbView.backgroundColor = normal_background_color
        tbView.tableFooterView = UIView()
        return tbView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        super.leftNavigationTitle = "delegate_withdraw_title"
        // Do any additional setup after loading the view.
        currentNode = Node(nodeId: "hellotest", ranking: 1, name: "nodename", deposit: "100000", url: "", ratePA: "", nodeStatus: .Active, isInit: true)
        
        initListData()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func initListData() {
        guard let node = currentNode else { return }
        
        let item1 = DelegateTableViewCellStyle.nodeInfo(node: node)
        
        let index = (AssetVCSharedData.sharedData.walletList as! [Wallet]).firstIndex(of: AssetVCSharedData.sharedData.selectedWallet as! Wallet)
        let walletStyle = WalletsCellStyle(wallets: AssetVCSharedData.sharedData.walletList as! [Wallet], selectedIndex: index ?? 0, isExpand: false)
        let balanceStyle = BalancesCellStyle(balances: [
            (Localized("staking_balance_Delegated"), "100000"),
            (Localized("staking_balance_unlocked_Delegated"), "600000"),
            (Localized("staking_balance__release_Delegated"), "400000")], selectedIndex: 0, isExpand: false)
        
        let item2 = DelegateTableViewCellStyle.wallets(walletStyle: walletStyle)
        let item3 = DelegateTableViewCellStyle.walletBalances(balanceStyle: balanceStyle)
        let item4 = DelegateTableViewCellStyle.inputAmount
        let item5 = DelegateTableViewCellStyle.singleButton(title: Localized("statking_validator_Withdraw"))
        
        let contents = [
            (Localized("staking_doubt_delegate"), Localized("staking_doubt_delegate_detail")),
            (Localized("staking_doubt_reward"), Localized("staking_doubt_reward_detail")),
            (Localized("staking_doubt_risk"), Localized("staking_doubt_risk_detail"))
        ]
        let item6 = DelegateTableViewCellStyle.doubt(contents: contents)
        listData.append(contentsOf: [item1, item2, item3, item4, item5, item6])
    }

}

extension WithDrawViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let style = listData[section]
        switch style {
        case .wallets(let walletStyle):
            return walletStyle.cellCount
        case .walletBalances(let balanceStyle):
            return balanceStyle.cellCount
        case .doubt(let contents):
            return contents.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let style = listData[indexPath.section]
        switch style {
        case .nodeInfo(let node):
            let cell = tableView.dequeueReusableCell(withIdentifier: "NodeInfoTableViewCell") as! NodeInfoTableViewCell
            cell.node = node
            return cell
        case .wallets(let walletStyle):
            let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTableViewCell") as! WalletTableViewCell
            cell.setupCellData(for: walletStyle.getWallet(for: indexPath.row))
            cell.walletBackgroundView.isHidden = indexPath.row != 0
            cell.bottomlineV.isHidden = (indexPath.row == 0 || indexPath.row == walletStyle.cellCount - 1)
            cell.rightImageView.image = indexPath.row == 0 ? UIImage(named: "3.icon_ drop-down") : indexPath.row == walletStyle.selectedIndex + 1 ? UIImage(named: "iconApprove") : nil
            
            cell.cellDidHandle = { [weak self] (_ cell: WalletTableViewCell) in
                guard let self = self else { return }
                self.walletCellDidHandle(cell, walletStyle: walletStyle)
            }
            return cell
        case .walletBalances(let balanceStyle):
            let cell = tableView.dequeueReusableCell(withIdentifier: "WalletBalanceTableViewCell") as! WalletBalanceTableViewCell
            cell.setupBalanceData(balanceStyle.balance(for: indexPath.row))
            cell.bottomlineV.isHidden = (indexPath.row == 0 || indexPath.row == balanceStyle.cellCount - 1)
            cell.rightImageView.image = indexPath.row == 0 ? UIImage(named: "3.icon_ drop-down") : indexPath.row == balanceStyle.selectedIndex + 1 ? UIImage(named: "iconApprove") : nil
            
            cell.cellDidHandle = { [weak self] (_ cell: WalletBalanceTableViewCell) in
                guard let self = self else { return }
                self.balanceCellDidHandle(cell, balanceStyle: balanceStyle)
            }
            return cell
        case .inputAmount:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SendInputTableViewCell") as! SendInputTableViewCell
            cell.cellDidContentChangeHandle = { [weak self] in
                self?.updateHeightOfRow(cell)
            }
            return cell
        case .singleButton(let title):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SingleButtonTableViewCell") as! SingleButtonTableViewCell
            cell.button.setTitle(title, for: .normal)
            cell.cellDidTapHandle = { [weak self] in
                self?.nextButtonCellDidHandle()
            }
            return cell
        case .doubt(let contents):
            let content = contents[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "DoubtTableViewCell") as! DoubtTableViewCell
            cell.titleLabel.text = content.0
            cell.contentLabel.text = content.1
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    
}

extension WithDrawViewController {
    func nextButtonCellDidHandle() {
        let cellStyle = listData.filter { (style) -> Bool in
            if case .wallets = style {
                return true
            } else {
                return false
            }
        }.first!
        
        guard case let .wallets(walletStyle) = cellStyle else { return }
        
        showPasswordInputPswAlert(for: walletStyle.currentWallet) { [weak self] privateKey in
            
        }
    }
    
    func walletCellDidHandle(_ cell: WalletTableViewCell, walletStyle: WalletsCellStyle) {
        let indexPath = tableView.indexPath(for: cell)
        var newWalletStyle = walletStyle
        newWalletStyle.isExpand = !newWalletStyle.isExpand
        guard let indexRow = indexPath?.row, let indexSection = indexPath?.section else { return }
        if indexRow != 0 {
            newWalletStyle.selectedIndex = indexRow - 1
        }
        listData[indexSection] = DelegateTableViewCellStyle.wallets(walletStyle: newWalletStyle)
        tableView.reloadSections(IndexSet([indexSection]), with: .fade)
    }
    
    func balanceCellDidHandle(_ cell: WalletBalanceTableViewCell, balanceStyle: BalancesCellStyle) {
        let indexPath = tableView.indexPath(for: cell)
        var newBalanceStyle = balanceStyle
        newBalanceStyle.isExpand = !newBalanceStyle.isExpand
        guard let indexRow = indexPath?.row, let indexSection = indexPath?.section else { return }
        if indexRow != 0 {
            newBalanceStyle.selectedIndex = indexRow - 1
        }
        
        listData[indexSection] = DelegateTableViewCellStyle.walletBalances(balanceStyle: newBalanceStyle)
        tableView.reloadSections(IndexSet([indexSection]), with: .fade)
    }
    
    func updateHeightOfRow(_ cell: SendInputTableViewCell) {
        let size = cell.amountView.bounds.size
        let newSize = tableView.sizeThatFits(CGSize(width: size.width,
                                                    height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
}
