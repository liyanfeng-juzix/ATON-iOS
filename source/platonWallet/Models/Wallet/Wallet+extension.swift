//
//  Wallet+extension.swift
//  platonWallet
//
//  Created by Ned on 14/3/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit
import BigInt

import Localize_Swift

enum BalanceStatus {
    case NotSufficient,Sufficient,unknowStatus
}

extension Wallet {

    func lockedBalanceAttrForDisplayAsset() -> NSAttributedString? {
        let balanceVisiable = UserDefaults.standard.object(forKey: AssetHidingStatus) as? Bool
        guard let lockedBalanceString = lockedBalanceDescription() else { return nil }

        let attachment = NSTextAttachment()
        attachment.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
        attachment.image = UIImage(named: "1.icon_An error")

        let iconAttr = NSMutableAttributedString()
        iconAttr.append(NSAttributedString(attachment: attachment))

        let lockedBalanceAttr = NSMutableAttributedString(string: "(")
        lockedBalanceAttr.append(iconAttr)

        lockedBalanceAttr.append(NSAttributedString(string: " " + Localized("wallet_balance_restricted") + (balanceVisiable == true ? "--" : lockedBalanceString)))
        lockedBalanceAttr.append(NSAttributedString(string: ")"))
        return lockedBalanceAttr
    }

    func lockedBalanceDescription() -> String? {
        guard
            let balance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == self.address.lowercased() }),
            let lockValue = BigUInt(balance.lock ?? "0"), lockValue > BigUInt.zero,
            let balanceStr = balance.lock?.vonToLATString else { return nil }

        WalletService.sharedInstance.updateWalletLockedBalance(self, value: balance.lock ?? "0")
        return balanceStr.ATPSuffix()
    }

    var restrictBalanceString: String? {
        guard
        let balance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == self.address.lowercased() }),
        let lockValue = BigUInt(balance.lock ?? "0"), lockValue > BigUInt.zero,
        let balanceStr = balance.lock?.vonToLATString else { return nil }
        return balanceStr
    }

    var freeBalance: BigUInt {
        guard
            let balance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == self.address.lowercased() }),
            let free = BigUInt(balance.free ?? "0") else { return BigUInt.zero }
        return free
    }

    var lockBalance: BigUInt {
        guard
            let balance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == self.address.lowercased() }),
            let lock = BigUInt(balance.lock ?? "0") else { return BigUInt.zero }
        return lock
    }

    var balanceString: String {
        guard
        let balance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == self.address.lowercased() }),
        let balanceStr = balance.free?.vonToLATString else { return "0.00" }
        return balanceStr
    }

    func balanceDescriptionForDisplayAsset() -> String {
        let balanceVisiable = UserDefaults.standard.object(forKey: AssetHidingStatus) as? Bool
        return balanceVisiable == true ? "***" : balanceDescription()
    }

    func balanceDescription() -> String {
        guard
            let balance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == self.address.lowercased() }),
            let balanceStr = balance.free?.vonToLATString else { return "0.00".ATPSuffix() }

        WalletService.sharedInstance.updateWalletBalance(self, balance: balance.free ?? "0")
        return balanceStr.ATPSuffix()
    }

    func image() -> UIImage {
        return UIImage(named: address.walletAddressLastCharacterAvatar())!
    }

    func WalletBalanceStatus() -> BalanceStatus {
        let balance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == address.lowercased() })
        guard let b = balance else { return .unknowStatus }
        guard let free = b.free, free != "0" else { return .NotSufficient }
        return .Sufficient
    }
}

extension Wallet {
    var normalIcon: UIImage? {
        switch type {
        case .classic:
            return UIImage(named: "icon_cold_unselected")
        case .cold:
            return UIImage(named: "icon_cold_unselected")
        case .observed:
            return UIImage(named: "icon_observer_unselected")
        }
    }

    var selectedIcon: UIImage? {
        switch type {
        case .classic:
            return UIImage(named: "home_classicWallet_icon_selected")
        case .cold:
            return UIImage(named: "icon_cold_selected")
        case .observed:
            return UIImage(named: "icon_observer_selected")
        }
    }

    var normalImg: UIImage? {
        switch type {
        case .classic:
            return UIImage(named: "img_normal_default")
        case .cold:
            return UIImage(named: "img_cold_default")
        case .observed:
            return UIImage(named: "img_observed_default")
        }
    }

    var selectedImg: UIImage? {
        switch type {
        case .classic:
            return UIImage(named: "img_normal_selected")
        case .cold:
            return UIImage(named: "img_cold_selected")
        case .observed:
            return UIImage(named: "img_observed_selected")
        }
    }

    var walletNameTextColor: UIColor {
        switch type {
        case .classic:
            return UIColor(rgb: 0x5E616B)
        case .cold:
            return wallet_gray_color
        case .observed:
            return wallet_orange_color
        }
    }
}
