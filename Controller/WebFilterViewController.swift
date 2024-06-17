//
//  ViewController.swift
//  WebsiteFilter
//
//  Created by Екатерина Токарева on 03/02/2023.
//

import UIKit
import WebKit
import CoreData

final class WebFilterViewController: UIViewController {
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .white
        return webView
    }()
    private lazy var linkTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter website link"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = UIReturnKeyType.search
        textField.autocapitalizationType = .none
        return textField
    }()
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forward", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var addFilterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var openFiltersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Filters", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter a website link to load a page"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    private var filters: [Filter] = []
    private var persistenceContext: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupLayout()
        updateData()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(forwardButtonTapped), for: .touchUpInside)
        addFilterButton.addTarget(self, action: #selector(addFilterButtonTapped), for: .touchUpInside)
        openFiltersButton.addTarget(self, action: #selector(openFiltersButtonTapped), for: .touchUpInside)
        
        linkTextField.delegate = self
        webView.navigationDelegate = self
        showHint()
        forwardButton.isEnabled = false
        backButton.isEnabled = false
    }
    
    private func updateData() {
        guard let context = persistenceContext else { return }
        let filtersFetchRequest: NSFetchRequest<Filter> = Filter.fetchRequest()
        do {
            filters = try context.fetch(filtersFetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func saveFilter(text: String) {
        guard let context = persistenceContext else { return }
        guard let entity = NSEntityDescription.entity(forEntityName: "Filter", in: context) else { return }
        let dataObject = Filter(entity: entity, insertInto: context)
        dataObject.text = text
        do {
            try context.save()
            filters.append(dataObject)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func setupLayout() {
        view.addSubview(webView)
        view.addSubview(linkTextField)
        view.addSubview(backButton)
        view.addSubview(forwardButton)
        view.addSubview(addFilterButton)
        view.addSubview(openFiltersButton)
        view.addSubview(hintLabel)
        
        NSLayoutConstraint.activate([
            linkTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            linkTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            linkTextField.heightAnchor.constraint(equalToConstant: 40),
            linkTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            
            webView.topAnchor.constraint(equalTo: linkTextField.bottomAnchor, constant: 8),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: backButton.topAnchor, constant: 8),
            
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            backButton.widthAnchor.constraint(equalToConstant: 60),
            backButton.heightAnchor.constraint(equalToConstant: 60),
            
            forwardButton.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            forwardButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            forwardButton.widthAnchor.constraint(equalToConstant: 60),
            forwardButton.heightAnchor.constraint(equalToConstant: 60),
            
            addFilterButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            addFilterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            addFilterButton.widthAnchor.constraint(equalToConstant: 60),
            addFilterButton.heightAnchor.constraint(equalToConstant: 60),
            
            openFiltersButton.trailingAnchor.constraint(equalTo: addFilterButton.leadingAnchor, constant: -8),
            openFiltersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            openFiltersButton.widthAnchor.constraint(equalToConstant: 60),
            openFiltersButton.heightAnchor.constraint(equalToConstant: 60),
            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                hintLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func backButtonTapped() {
        if webView.canGoBack {
            webView.goBack()
            backButton.isEnabled = true
        } else {
            showHint()
        }
        forwardButton.isEnabled = true
    }
    
    @objc private func forwardButtonTapped() {
        if webView.canGoForward {
            webView.goForward()
        } else {
            hideHint()
        }
        forwardButton.isEnabled = webView.canGoForward
        backButton.isEnabled = true
    }
    
    @objc private func addFilterButtonTapped() {
        let alert = UIAlertController(title: "Add Filter", message: "Enter a word to block pages containing it:", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Filter word"
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self, weak alert] _ in
            guard let self else { return }
            guard let alert = alert, let textField = alert.textFields?.first else { return }
            if let text = textField.text {
                if self.filters.contains(where: { $0.text == text }) {
                    self.notUniqueFilter()
                } else if text.isValidFilter {
                    self.saveFilter(text: text)
                } else {
                    self.wrongFilter()
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func notUniqueFilter() {
        let alert = UIAlertController(title: "Filter already exists", message: "The entered filter already exists, please enter a unique filter", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func wrongFilter() {
        let alert = UIAlertController(title: "Filter was not added", message: "Word should contain at least two characters and no whitespaces", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showHint() {
        hintLabel.isHidden = false
        webView.isHidden = true
        forwardButton.isEnabled = true
        backButton.isEnabled = false
    }

    private func hideHint() {
        hintLabel.isHidden = true
        webView.isHidden = false
        backButton.isEnabled = true
    }
    
    @objc private func openFiltersButtonTapped() {
        let filtersVC = FiltersTableViewController()
        let navigationController = UINavigationController(rootViewController: filtersVC)
        present(navigationController, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

extension WebFilterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard var text = linkTextField.text else { return false }
        if !text.isEmpty {
            hideHint()
        } else {
            showHint()
        }
        if !text.isValidUrl {
            text = "https://" + text
        }
        guard let url = URL(string: text) else { return false }
        let request = URLRequest(url: url)
        webView.load(request)
        textField.resignFirstResponder()
        backButton.isEnabled = true
        return true
    }
}

extension WebFilterViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        linkTextField.text = webView.url?.absoluteString
        backButton.isEnabled = true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url?.absoluteString ?? ""
        for filter in filters {
            if let text = filter.text,
               url.contains(text) {
                decisionHandler(.cancel)
                let alert = UIAlertController(title: "This link has been blocked", message: "This link contains a word from your filters and it has been blocked", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                present(alert, animated: true)
                return
            }
        }
        decisionHandler(.allow)
    }
}

import SwiftUI

struct WebFilterViewProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = WebFilterViewController()
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<WebFilterViewProvider.ContainerView>) -> WebFilterViewController {
            viewController
        }
        
        func updateUIViewController(_ uiViewController: WebFilterViewProvider.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<WebFilterViewProvider.ContainerView>) {
        }
    }
}
