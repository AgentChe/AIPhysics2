//
//  AssistantAssembly.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import UIKit

final class AssistantAssembly {
    func recognize(from: UIViewController) {
        let nc = NavigationController()
        nc.modalPresentationStyle = .fullScreen
        nc.setNavigationBarHidden(true, animated: false)
        
        let recognizerVC = AssistantRecognizerController.make(close: { [weak nc] in
            nc?.dismiss(animated: true)
        }, result: { [weak nc] result in
            let resultVC = AssistantResultViewController.make(recognized: result)
            
            resultVC.addCloseButtonInNavigationBar { [weak nc] in
                nc?.dismiss(animated: true)
            }
            
            nc?.setNavigationBarHidden(false, animated: false)
            nc?.setViewControllers([resultVC], animated: true)
        })
        
        nc.setViewControllers([recognizerVC], animated: false)
        
        from.present(nc, animated: true)
    }
}
