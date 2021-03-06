//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import SwiftUI
import UIKit

public protocol SymptomsReviewInteracting {
    func changeSymptomAnswer(index: Int)
    func confirmSymptoms(selectedDay: GregorianDay?, hasCheckedNoDate: Bool) -> Result<Void, UIValidationError>
}

public class SymptomsReviewViewController: UIViewController {
    public typealias Interacting = SymptomsReviewInteracting
    private let symptoms: [SymptomInfo]
    private let dateSelectionWindow: Int
    private let interactor: Interacting
    
    public init(_ symptoms: [SymptomInfo], dateSelectionWindow: Int, interactor: Interacting) {
        self.symptoms = symptoms
        self.dateSelectionWindow = dateSelectionWindow
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        title = localize(.symptom_review_title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func divider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = UIColor.systemGray5
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }
    
    func symptomStack(imageView: UIImageView, text: String) -> UIStackView {
        imageView.setContentHuggingPriority(.almostRequest, for: .horizontal)
        
        let label = UILabel()
        label.text = text
        label.textColor = UIColor(.secondaryText)
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        
        let hStack = UIStackView(arrangedSubviews: [imageView, label])
        hStack.alignment = .center
        hStack.spacing = .stripeSpacing
        
        let stack = UIStackView(arrangedSubviews: [hStack, divider()])
        stack.axis = .vertical
        stack.spacing = .standardSpacing
        return stack
    }
    
    func dynamicLabel(font: UIFont.TextStyle, color: UIColor, text: String?) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.setDynamicTextStyle(font)
        return label
    }
    
    private lazy var noDateLabel = dynamicLabel(font: .body, color: UIColor(.primaryText), text: localize(.symptom_review_no_date))
    
    private lazy var noDateStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [noDateUnchecked, noDateChecked, noDateLabel])
        stack.alignment = .center
        stack.spacing = .standardSpacing
        stack.isUserInteractionEnabled = false
        return stack
    }()
    
    private lazy var noDateContainer: UIButton = {
        let button = UIButton()
        button.addFillingSubview(noDateStack)
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(pickNoDate), for: .touchUpInside)
        button.isAccessibilityElement = true
        
        button.accessibilityLabel = localize(.symptom_review_no_date_accessability_label_not_checked)
        return button
    }()
    
    private lazy var errorBox: ErrorBox = {
        ErrorBox(localize(.symptom_list_error_heading), description: localize(.symptom_review_error_description))
    }()
    
    private lazy var errorBoxVC: UIHostingController<ErrorBox> = {
        UIHostingController(rootView: errorBox)
    }()
    
    private let calendarImage: UIImageView = {
        let image = UIImageView(image: UIImage(.calendar))
        image.widthAnchor.constraint(equalTo: image.heightAnchor).isActive = true
        image.tintColor = UIColor(.primaryText)
        return image
    }()
    
    private lazy var dateStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [textField, calendarImage])
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .standard
        stack.isUserInteractionEnabled = false
        return stack
    }()
    
    private lazy var dateContainer: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(pickDate), for: .touchUpInside)
        button.addFillingSubview(dateStack)
        button.layer.borderColor = UIColor(.primaryText).cgColor
        button.layer.borderWidth = 2
        button.isUserInteractionEnabled = true
        button.accessibilityTraits = .none
        button.accessibilityLabel = localize(.symptom_review_date_placeholder)
        button.accessibilityHint = localize(.symptom_review_date_hint)
        return button
    }()
    
    private lazy var dateLabel = dynamicLabel(font: .title3, color: UIColor(.primaryText), text: localize(.symptom_review_date_heading))
    
    private lazy var dateInfoBox = InformationBox(views: [dateLabel, dateContainer, noDateContainer], style: .noNews)
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.accessibilityElementsHidden = true
        return textField
    }()
    
    var selectedDay: GregorianDay? {
        didSet {
            if selectedDay != nil {
                noDateUnchecked.isHidden = false
                noDateChecked.isHidden = true
            }
        }
    }
    
    let scrollView = UIScrollView()
    let datePicker = UIPickerView()
    let noDateUnchecked = UIImageView(image: UIImage(systemName: "square"))
    let noDateChecked = UIImageView(image: UIImage(systemName: "checkmark.square.fill"))
    let toolbar = UIToolbar()
    
    lazy var earliestOnsetDate = GregorianDay.today - DayDuration(dateSelectionWindow - 1)
    
    func getDay(for row: Int) -> (GregorianDay, String) {
        let rowDate = earliestOnsetDate + DayDuration(row)
        let rowString = localize(.symptom_onset_select_day(rowDate.startDate(in: .current)))
        return (rowDate, rowString)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let stepLabel = dynamicLabel(font: .caption1, color: UIColor(.secondaryText), text: localize(.step_label(index: 2, count: 2)))
        stepLabel.accessibilityLabel = localize(.step_accessibility_label(index: 2, count: 2))
        
        let heading = dynamicLabel(font: .largeTitle, color: UIColor(.primaryText), text: localize(.symptom_review_heading))
        
        let confirmHeaderImage = UIImageView(image: UIImage(systemName: "checkmark"))
        confirmHeaderImage.tintColor = UIColor(.nhsButtonGreen)
        let confirmStack = symptomStack(imageView: confirmHeaderImage, text: localize(.symptom_review_confirm_heading))
        
        let denyHeaderImage = UIImageView(image: UIImage(systemName: "xmark"))
        denyHeaderImage.tintColor = UIColor(.errorRed)
        let denyStack = symptomStack(imageView: denyHeaderImage, text: localize(.symptom_review_deny_heading))
        
        for (index, symptom) in symptoms.enumerated() {
            let symptomLabel = dynamicLabel(font: .headline, color: UIColor(.primaryText), text: symptom.heading)
            
            let symptomButton = UIButton()
            symptomButton.setTitle(localize(.symptom_review_button), for: .normal)
            symptomButton.setTitleColor(UIColor(.nhsBlue), for: .normal)
            symptomButton.titleLabel?.setDynamicTextStyle(.headline)
            symptomButton.tag = index
            symptomButton.addTarget(self, action: #selector(changeSymptom(sender:)), for: .touchUpInside)
            symptomButton.setContentHuggingPriority(.almostRequest, for: .horizontal)
            symptomButton.accessibilityLabel = localize(.symptom_review_button_accessibility_label(symptom: symptom.heading))
            
            let symptomRow = UIStackView(arrangedSubviews: [symptomLabel, symptomButton])
            symptomRow.spacing = .standardSpacing
            
            if symptom.isConfirmed {
                confirmStack.addArrangedSubview(symptomRow)
                confirmStack.addArrangedSubview(divider())
            } else {
                denyStack.addArrangedSubview(symptomRow)
                denyStack.addArrangedSubview(divider())
            }
        }
        
        datePicker.delegate = self
        
        toolbar.sizeToFit()
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(finishDatePicking))
        doneButton.tintColor = UIColor(.nhsBlue)
        toolbar.setItems([spacer, doneButton], animated: false)
        
        textField.inputAccessoryView = toolbar
        textField.inputView = datePicker
        textField.font = UIFont.preferredFont(forTextStyle: .headline)
        textField.placeholder = localize(.symptom_review_date_placeholder)
        
        let calendarImage = UIImageView(image: UIImage(.calendar))
        calendarImage.widthAnchor.constraint(equalTo: calendarImage.heightAnchor).isActive = true
        calendarImage.tintColor = UIColor(.primaryText)
        
        noDateUnchecked.tintColor = UIColor(.secondaryText)
        noDateUnchecked.setContentHuggingPriority(.almostRequest, for: .horizontal)
        
        noDateChecked.tintColor = UIColor(.nhsButtonGreen)
        noDateChecked.setContentHuggingPriority(.almostRequest, for: .horizontal)
        noDateChecked.isHidden = true
        
        let noDateStack = UIStackView(arrangedSubviews: [noDateUnchecked, noDateChecked, noDateLabel])
        noDateStack.alignment = .center
        noDateStack.spacing = .standardSpacing
        noDateStack.isUserInteractionEnabled = false
        
        let confirmButton = UIButton()
        confirmButton.styleAsPrimary()
        confirmButton.setTitle(localize(.symptom_review_button_submit), for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmSymptoms), for: .touchUpInside)
        
        errorBoxVC.view.backgroundColor = .clear
        let stack = UIStackView(arrangedSubviews: [errorBoxVC.view, stepLabel, heading, confirmStack, denyStack, dateInfoBox, confirmButton])
        stack.axis = .vertical
        stack.spacing = .doubleSpacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .largeInset
        
        scrollView.addFillingSubview(stack)
        
        view.addAutolayoutSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stack.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1),
        ])
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        errorBoxVC.view.isHidden = true
    }
    
    @objc func pickDate() {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: datePicker.frame.height + toolbar.frame.height, right: 0)
        textField.becomeFirstResponder()
        
        let row = dateSelectionWindow - 1
        let (rowDate, rowString) = getDay(for: row)
        selectedDay = rowDate
        textField.text = rowString
        dateContainer.accessibilityLabel = rowString
        datePicker.selectRow(row, inComponent: 0, animated: false)
    }
    
    @objc func pickNoDate() {
        noDateUnchecked.isHidden.toggle()
        noDateChecked.isHidden.toggle()
        if selectedDay != nil {
            selectedDay = nil
            textField.text = nil
        }
        
        if noDateChecked.isHidden {
            noDateContainer.accessibilityLabel = localize(.symptom_review_no_date_accessability_label_not_checked)
        } else {
            noDateContainer.accessibilityLabel = localize(.symptom_review_no_date_accessability_label_checked)
        }
        
    }
    
    @objc func finishDatePicking() {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.endEditing(true)
    }
    
    @objc func confirmSymptoms() {
        switch interactor.confirmSymptoms(selectedDay: selectedDay, hasCheckedNoDate: noDateUnchecked.isHidden) {
        case .success(()):
            break
        case .failure:
            errorBoxVC.view.isHidden = false
            scrollView.setContentOffset(.zero, animated: true)
            dateInfoBox.style = .badNews
        }
    }
    
    @objc func changeSymptom(sender: LinkButton) {
        interactor.changeSymptomAnswer(index: sender.tag)
    }
    
}

extension SymptomsReviewViewController: UIPickerViewDelegate {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        dateSelectionWindow
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let (_, rowString) = getDay(for: row)
        return rowString
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let (rowDate, rowString) = getDay(for: row)
        selectedDay = rowDate
        textField.text = rowString
    }
}

extension SymptomsReviewViewController: UIPickerViewDataSource {}
