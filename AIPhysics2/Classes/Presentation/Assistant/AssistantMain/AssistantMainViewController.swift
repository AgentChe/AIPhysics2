//
//  AssistantMainViewController.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 24.09.2024.
//

import UIKit
import RxSwift

final class AssistantMainViewController: UIViewController {
    private lazy var mainView = AssistantMainView()
    
    private lazy var viewModel = AssistantMainViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: AssistantMainViewModel.Input(
            didTapRecent: mainView.tableView.didTapRecent,
            didSelectRecentItem: mainView.tableView.didSelectRecentItem,
            didTapCamera: mainView.tableView.didTapCamera,
            didTapDone: mainView.tableView.didTapDone
        ))
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         
         navigationController?.setNavigationBarHidden(true, animated: false)
     }
     
     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         
         navigationController?.setNavigationBarHidden(false, animated: false)
     }
}

// MARK: Public
extension AssistantMainViewController {
    static func make() -> AssistantMainViewController {
        let vc = AssistantMainViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension AssistantMainViewController {
    func route(_ route: AssistantMainViewModel.Route) {
        switch route {
        case .recent:
            let vc = HistoryViewController.make()
            navigationController?.pushViewController(vc, animated: true)
        case .recentItem(let item):
            let vc = AssistantResultViewController.make(recentItem: item)
            navigationController?.pushViewController(vc, animated: true)
        case .recognizeImage:
            AssistantAssembly().recognize(from: self)
        case .manual(let text):
            let vc = AssistantResultViewController.make(manual: text)
            navigationController?.pushViewController(vc, animated: true)
        case .paygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
    }
}
