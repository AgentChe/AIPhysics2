//
//  HistoryViewModel.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import RxSwift
import RxCocoa

final class HistoryViewModel {
    enum Route {
        case select(HistoryAssistantResult)
    }
    
    private lazy var firstPageActivity = RxActivityIndicator()
    private lazy var paginationActivity = RxActivityIndicator()
    
    private lazy var assistantManager = AssistantManager()
}

// MARK: Public
extension HistoryViewModel {
    struct Input {
        let didSelect: Signal<HistoryAssistantResult>
        let didScrollToBottom: Signal<Void>
    }
    
    struct Output {
        let elements: Driver<[HistoryTableElement]>
        let route: Driver<Route>
        let firstPageActivity: Driver<Bool>
        let paginationActivity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        Output(
            elements: makeElements(didScrollToBottom: input.didScrollToBottom),
            route: makeRoute(didSelect: input.didSelect),
            firstPageActivity: firstPageActivity.asDriver(),
            paginationActivity: paginationActivity.asDriver()
        )
    }
}

// MARK: Private
private extension HistoryViewModel {
    func makeElements(didScrollToBottom: Signal<Void>) -> Driver<[HistoryTableElement]> {
        var lastPage: AssistantRecentPage?
        
        func fetch(page: Int) -> Driver<AssistantRecentPage> {
            assistantManager
                .recent(page: page)
                .trackActivity(page == 1 ? firstPageActivity : paginationActivity)
                .compactMap { $0 }
                .asDriver(onErrorDriveWith: .never())
                .do(onNext: { page in
                    lastPage = page
                })
        }
        
        let firstPage = fetch(page: 1)
        let downloadedPage = firstPage
            .flatMapLatest { firstPage -> Driver<AssistantRecentPage> in
                didScrollToBottom
                    .compactMap { lastPage }
                    .filter { ($0.page.nextPage <= $0.page.total) && ($0.page.current != $0.page.total) }
                    .flatMapFirst { lastPage -> Driver<AssistantRecentPage> in
                        fetch(page: lastPage.page.nextPage)
                    }
                    .startWith(firstPage)
            }
        
        return downloadedPage
            .map { page -> [HistoryTableElement] in
                page.history.map { item -> HistoryTableElement in
                    HistoryTableElement(item: item)
                }
            }
    }
    
    func makeRoute(didSelect: Signal<HistoryAssistantResult>) -> Driver<Route> {
        didSelect
            .map { Route.select($0) }
            .asDriver(onErrorDriveWith: .never())
    }
}
