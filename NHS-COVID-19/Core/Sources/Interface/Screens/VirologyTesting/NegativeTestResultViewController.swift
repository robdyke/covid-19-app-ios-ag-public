//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol NegativeTestResultViewControllerInteracting {
    func didTapOnlineServicesLink()
    func didTapReturnHome()
}

public class NegativeTestResultViewController: UIViewController {
    
    public typealias Interacting = NegativeTestResultViewControllerInteracting
    
    private let interactor: Interacting
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: .bigSpacing).isActive = true
        
        let checkmark = UIImageView(.checkmark)
        checkmark.adjustsImageSizeForAccessibilityContentSizeCategory = true
        checkmark.tintColor = UIColor(.nhsButtonGreen)
        checkmark.styleAsDecoration()
        
        let titleLabel = UILabel()
        titleLabel.text = localize(.end_of_isolation_isolate_title)
        titleLabel.styleAsPageHeader()
        titleLabel.textAlignment = .center
        titleLabel.isAccessibilityElement = false
        
        let endOfIsolationLabel = UILabel()
        endOfIsolationLabel.text = localize(.end_of_isolation_finished_description)
        endOfIsolationLabel.styleAsHeading()
        endOfIsolationLabel.textAlignment = .center
        endOfIsolationLabel.isAccessibilityElement = false
        
        let pleaseIsolateStack = UIStackView(arrangedSubviews: [titleLabel, endOfIsolationLabel])
        pleaseIsolateStack.axis = .vertical
        
        let indicationLabel = UILabel()
        indicationLabel.text = localize(.end_of_isolation_negative_test_result)
        indicationLabel.styleAsSecondaryTitle()
        
        let infobox = InformationBox(views: [indicationLabel], style: .goodNews)
        
        let explanationLabel = UILabel()
        explanationLabel.text = localize(.end_of_isolation_explanation_negative_test_result)
        explanationLabel.styleAsSecondaryBody()
        
        let linkLabel = UILabel()
        linkLabel.text = localize(.end_of_isolation_link_label)
        linkLabel.styleAsSecondaryBody()
        
        let onlineServicesLink = LinkButton(title: localize(.end_of_isolation_online_services_link))
        onlineServicesLink.addTarget(self, action: #selector(didTapOnlineServicesLink), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [spacer, checkmark, pleaseIsolateStack, infobox, explanationLabel, linkLabel, onlineServicesLink])
        stack.axis = .vertical
        stack.spacing = .standardSpacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .standard
        
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(stack)
        
        let backToHomeButton = UIButton()
        backToHomeButton.setTitle(localize(.end_of_isolation_corona_back_to_home_button), for: .normal)
        backToHomeButton.styleAsPrimary()
        backToHomeButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        backToHomeButton.addTarget(self, action: #selector(didTapReturnHome), for: .touchUpInside)
        
        let bottomButtonStack = UIStackView(arrangedSubviews: [backToHomeButton])
        bottomButtonStack.axis = .vertical
        bottomButtonStack.spacing = .standardSpacing
        bottomButtonStack.isLayoutMarginsRelativeArrangement = true
        bottomButtonStack.layoutMargins = .standard
        
        view.addAutolayoutSubview(scrollView)
        view.addAutolayoutSubview(bottomButtonStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomButtonStack.topAnchor, constant: -.standardSpacing),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomButtonStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomButtonStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomButtonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
        ])
    }
    
    @objc func didTapOnlineServicesLink() {
        interactor.didTapOnlineServicesLink()
    }
    
    @objc func didTapReturnHome() {
        interactor.didTapReturnHome()
    }
}
