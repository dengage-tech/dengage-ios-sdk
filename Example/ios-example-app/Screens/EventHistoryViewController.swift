import UIKit
import Dengage

final class EventHistoryViewController: UIViewController {
    
    private lazy var eventTypePickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    private lazy var eventTypeTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Select Event Type"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.autocapitalizationType = .none
        view.delegate = self
        view.inputView = eventTypePickerView
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var tableNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Table: -"
        label.font = .italicSystemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    private lazy var sendEventButton: UIButton = {
        let view = UIButton()
        view.setTitle("Send Event", for: .normal)
        view.addTarget(self, action: #selector(didTapSendEventButton), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
    
    private lazy var addParameterButton: UIButton = {
        let view = UIButton()
        view.setTitle("+ Add New Parameter", for: .normal)
        view.addTarget(self, action: #selector(didTapAddParameterButton), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            eventTypeTextField,
            tableNameLabel,
            addParameterButton,
            sendEventButton
        ])
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 10
        return view
    }()
    
    // Data structures
    struct EventTypeConfig {
        let tableName: String
        let parameters: [EventParameter]
    }
    
    struct EventParameter {
        var key: String
        var value: String
        var isReadOnly: Bool
        var inputType: InputType
        var options: [String]
        
        enum InputType {
            case text
            case dropdown
        }
        
        init(key: String, value: String = "", isReadOnly: Bool = false, inputType: InputType = .text, options: [String] = []) {
            self.key = key
            self.value = value
            self.isReadOnly = isReadOnly
            self.inputType = inputType
            self.options = options
        }
    }
    
    private var eventTypesMap: [String: EventTypeConfig] = [:]
    private var availableEventTypes: [String] = []
    private let allowedEventTypes: Set<String> = ["category_view", "product_view", "remove_from_basket", "add_to_basket"]
    private var currentParameters: [EventParameter] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.loadEventTypesFromSDK()
    }
    
    private func setupUI(){
        title = "Event History"
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaTopAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
    }
    
    private func loadEventTypesFromSDK() {
        
        guard let sdkParameters = Dengage.getSdkParameters() else {
            print("ERROR: SDK parameters not available")
            showToast("SDK parameters not available")
            return
        }
        
        eventTypesMap.removeAll()
        let systemAttributes: Set<String> = ["event_time", "device_id", "session_id"]
        
        for (index, eventMapping) in sdkParameters.eventMappings.enumerated() {
            print("Processing event mapping \(index): \(eventMapping.eventTableName ?? "nil")")
            
            guard let tableName = eventMapping.eventTableName, !tableName.isEmpty else { 
                print("Skipping mapping \(index): empty table name")
                continue 
            }
            
            if let eventTypeDefinitions = eventMapping.eventTypeDefinitions {
                for (_, eventTypeDefinition) in eventTypeDefinitions.enumerated() {
                    guard let eventType = eventTypeDefinition.eventType,
                          !eventType.isEmpty,
                          allowedEventTypes.contains(eventType) else {
                        continue
                    }
                                        
                    var parameters: [EventParameter] = []
                    
                    if let filterConditions = eventTypeDefinition.filterConditions {
                        print("Filter conditions count: \(filterConditions.count)")
                        for filterCondition in filterConditions {
                            guard let fieldName = filterCondition.fieldName,
                                  !fieldName.isEmpty,
                                  !systemAttributes.contains(fieldName) else { continue }
                            
                            switch filterCondition.operator {
                            case "Equals":
                                let value = filterCondition.values?.first ?? ""
                                parameters.append(EventParameter(
                                    key: fieldName,
                                    value: value,
                                    isReadOnly: true,
                                    inputType: .text
                                ))
                            case "In":
                                let values = filterCondition.values ?? []
                                let defaultValue = values.first ?? ""
                                parameters.append(EventParameter(
                                    key: fieldName,
                                    value: defaultValue,
                                    isReadOnly: false,
                                    inputType: .dropdown,
                                    options: values
                                ))
                            default:
                                break
                            }
                        }
                    }
                    
                    if let attributes = eventTypeDefinition.attributes {
                        print("Attributes count: \(attributes.count)")
                        for attribute in attributes {
                            guard let tableColumnName = attribute.tableColumnName,
                                  !systemAttributes.contains(tableColumnName) else { continue }
                            let alreadyExists = parameters.contains { $0.key == tableColumnName }
                            if !alreadyExists {
                                parameters.append(EventParameter(key: tableColumnName, value: ""))
                            }
                        }
                    }
                    
                    eventTypesMap[eventType] = EventTypeConfig(
                        tableName: tableName,
                        parameters: parameters
                    )
                }
            }
        }
        
        availableEventTypes = Array(eventTypesMap.keys).sorted()
        
        if availableEventTypes.isEmpty {
            print("No event types found, adding fallback")
        }
        
        // Picker view'ı güncelle ve ilk değeri seç
        DispatchQueue.main.async {
            print("Updating picker view with \(self.availableEventTypes.count) items")
            self.eventTypePickerView.reloadAllComponents()
            
            if !self.availableEventTypes.isEmpty {
                // İlk event type'ı seç
                let firstEventType = self.availableEventTypes[0]
                print("Selecting first event type: \(firstEventType)")
                self.eventTypeTextField.text = firstEventType
                self.eventTypePickerView.selectRow(0, inComponent: 0, animated: false)
                self.loadParametersForEventType(firstEventType)
                self.updateTableNameLabel(for: firstEventType)
            }
        }
        
        print("=== loadEventTypesFromSDK completed ===")
    }
    
    private func loadParametersForEventType(_ eventType: String) {
        currentParameters.removeAll()
        
        if let config = eventTypesMap[eventType] {
            currentParameters = config.parameters.map { param in
                EventParameter(
                    key: param.key,
                    value: param.value,
                    isReadOnly: param.isReadOnly,
                    inputType: param.inputType,
                    options: param.options
                )
            }
        }
        
        for view in stackView.arrangedSubviews {
            if view is EventParameterItemView {
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }
        
        for (index, parameter) in currentParameters.enumerated() {
            let parameterView = EventParameterItemView(parameter: parameter) { [weak self] in
                self?.removeParameter(at: index)
            }
            stackView.insertArrangedSubview(parameterView, at: 2 + index)
        }
        
        updateTableNameLabel(for: eventType)
    }
    
    private func updateTableNameLabel(for eventType: String) {
        let tableName = eventTypesMap[eventType]?.tableName ?? ""
        tableNameLabel.text = "Table: \(tableName)"
    }
    
    private func removeParameter(at index: Int) {
        guard index < currentParameters.count, currentParameters.count > 1 else { return }
        
        currentParameters.remove(at: index)
        
        let parameterViews = stackView.arrangedSubviews.compactMap { $0 as? EventParameterItemView }
        if index < parameterViews.count {
            let viewToRemove = parameterViews[index]
            stackView.removeArrangedSubview(viewToRemove)
            viewToRemove.removeFromSuperview()
        }
    }
    
    @objc private func didTapSendEventButton() {
        guard let selectedEventType = eventTypeTextField.text,
              !selectedEventType.isEmpty,
              let eventConfig = eventTypesMap[selectedEventType] else {
            showToast("Please select an event type")
            return
        }
        
        var eventData: [String: Any] = [:]
        
        let parameterViews = stackView.arrangedSubviews.compactMap { $0 as? EventParameterItemView }
        for (index, parameterView) in parameterViews.enumerated() {
            if let values = parameterView.values, !values.0.isEmpty {
                eventData[values.0] = values.1
            } else if index < currentParameters.count {
                let param = currentParameters[index]
                if !param.key.isEmpty {
                    eventData[param.key] = param.value
                }
            }
        }
        
        Dengage.sendCustomEvent(eventTable: eventConfig.tableName, parameters: eventData)
        showToast("Event sent to table: \(eventConfig.tableName)")
    }
    
    @objc private func didTapAddParameterButton() {
        let newParameter = EventParameter(key: "", value: "")
        currentParameters.append(newParameter)
        
        let parameterView = EventParameterItemView(parameter: newParameter) { [weak self] in
            guard let self = self else { return }
            self.removeParameter(at: self.currentParameters.count - 1)
        }
        
        stackView.insertArrangedSubview(parameterView, at: stackView.arrangedSubviews.count - 1)
    }
    
    private func showToast(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }
}

// MARK: - UIPickerView DataSource & Delegate
extension EventHistoryViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let count = availableEventTypes.count
        print("Picker numberOfRows: \(count)")
        return count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard row < availableEventTypes.count else { 
            print("Picker titleForRow: row \(row) out of bounds (\(availableEventTypes.count))")
            return "Error"
        }
        let title = availableEventTypes[row]
        print("Picker titleForRow \(row): \(title)")
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row < availableEventTypes.count else { 
            print("Picker didSelectRow: row \(row) out of bounds")
            return 
        }
        let selectedEventType = availableEventTypes[row]
        print("Picker selected: \(selectedEventType)")
        eventTypeTextField.text = selectedEventType
        loadParametersForEventType(selectedEventType)
        view.endEditing(true)
    }
}

// MARK: - UITextField Delegate
extension EventHistoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // EventTypeTextField için klavye ile editlemeyi engelle, sadece picker'dan seçim yapılabilsin
        if textField == eventTypeTextField {
            return true // Picker view açılabilir ama klavye ile yazılamaz
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // EventTypeTextField için karakterlerin değiştirilmesini engelle
        if textField == eventTypeTextField {
            return false
        }
        return true
    }
}

// MARK: - EventParameterItemView
extension EventHistoryViewController {
    final class EventParameterItemView: UIView {
        
        private lazy var keyTextField: UITextField = {
            let view = UITextField()
            view.placeholder = "key"
            view.borderStyle = .roundedRect
            view.textColor = .black
            return view
        }()
        
        private lazy var valueTextField: UITextField = {
            let view = UITextField()
            view.placeholder = "value"
            view.borderStyle = .roundedRect
            view.textColor = .black
            return view
        }()
        
        private lazy var valuePickerView: UIPickerView = {
            let picker = UIPickerView()
            picker.delegate = self
            picker.dataSource = self
            return picker
        }()
        
        private lazy var removeButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("X", for: .normal)
            button.setTitleColor(.red, for: .normal)
            button.addTarget(self, action: #selector(didTapRemoveButton), for: .touchUpInside)
            button.widthAnchor.constraint(equalToConstant: 30).isActive = true
            return button
        }()
        
        private lazy var stackView: UIStackView = {
            let view = UIStackView(arrangedSubviews: [keyTextField, valueTextField, removeButton])
            view.axis = .horizontal
            view.spacing = 10
            view.distribution = .fill
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private var parameter: EventParameter
        private let onRemove: () -> Void
        
        init(parameter: EventParameter, onRemove: @escaping () -> Void) {
            self.parameter = parameter
            self.onRemove = onRemove
            super.init(frame: .zero)
            setupUI()
            configureForParameter()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            addSubview(stackView)
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
        
        private func configureForParameter() {
            keyTextField.text = parameter.key
            keyTextField.isEnabled = !parameter.isReadOnly
            
            switch parameter.inputType {
            case .text:
                valueTextField.isHidden = false
                valueTextField.text = parameter.value
                valueTextField.isEnabled = !parameter.isReadOnly
                valueTextField.inputView = nil
                
            case .dropdown:
                valueTextField.isHidden = false
                valueTextField.text = parameter.value
                valueTextField.isEnabled = !parameter.isReadOnly
                valueTextField.inputView = valuePickerView
                
                if let index = parameter.options.firstIndex(of: parameter.value) {
                    valuePickerView.selectRow(index, inComponent: 0, animated: false)
                }
            }
            
            removeButton.isEnabled = !parameter.isReadOnly
        }
        
        @objc private func didTapRemoveButton() {
            onRemove()
        }
        
        var values: (String, String)? {
            guard let key = keyTextField.text,
                  let value = valueTextField.text,
                  !key.isEmpty, !value.isEmpty else { return nil }
            return (key, value)
        }
    }
}

// MARK: - UIPickerView for EventParameterItemView
extension EventHistoryViewController.EventParameterItemView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return parameter.options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return parameter.options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedValue = parameter.options[row]
        valueTextField.text = selectedValue
        parameter.value = selectedValue
    }
}
