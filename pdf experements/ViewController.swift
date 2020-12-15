//
//  ViewController.swift
//  pdf experements
//
//  Created by 18592232 on 30.10.2020.
//

import UIKit
import PDFKit

class ViewController: UIViewController, PDFDocumentDelegate {
    
    let pdfView = PDFView()
    let thumbnailView = PDFThumbnailView()
    let gesture = UITapGestureRecognizer()
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        gesture.addTarget(self, action: #selector(tapped))
        pdfView.addGestureRecognizer(gesture)
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        navigationItem.titleView = searchBar
        
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false

        if let path = Bundle.main.path(forResource: "myFile", ofType: "pdf"),
           let pdf = PDFDocument(url: URL(fileURLWithPath: path)) {
            
            pdf.delegate = self
            setupPDFView(with: pdf)
            setupThumbnailView()
        }
        
        
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: thumbnailView.topAnchor).isActive = true
        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        thumbnailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        thumbnailView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        thumbnailView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        thumbnailView.heightAnchor.constraint(equalToConstant: 120).isActive = true
    }
    
    @objc func tapped() {
        UIView.animate(withDuration: 0.5) {
            (self.thumbnailView.alpha > 0) ? (self.thumbnailView.alpha = 0) : (self.thumbnailView.alpha = 1)
            ((self.navigationController?.navigationBar.alpha)! > 0) ? (self.navigationController?.navigationBar.alpha = 0) : (self.navigationController?.navigationBar.alpha = 1)
        }
    }
    
    func didMatchString(_ instance: PDFSelection) {
        let highlight = PDFAnnotation(bounds: (instance.bounds(for: instance.pages[0])), forType: .highlight, withProperties: nil)
        let color = UIColor.green.withAlphaComponent(0.5)
        color.setStroke()
        highlight.color = UIColor.green.withAlphaComponent(0.5)
        instance.pages[0].addAnnotation(highlight)
    }
    
    private func setupPDFView(with document: PDFDocument) {
        pdfView.backgroundColor = .black
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true)
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        pdfView.autoScales = true
        pdfView.document = document
        view.addSubview(pdfView)
    }
    
    private func setupThumbnailView() {
        thumbnailView.pdfView = pdfView
        thumbnailView.backgroundColor = .black
        thumbnailView.layoutMode = .horizontal
        thumbnailView.thumbnailSize = CGSize(width: 40, height: 100)
        thumbnailView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.addSubview(thumbnailView)
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        for i in 0..<pdfView.document!.pageCount {
            for annotation in pdfView.document!.page(at: i)!.annotations {
                pdfView.document!.page(at: i)!.removeAnnotation(annotation)
            }
        }
        for word in searchBar.text!.split(separator: " ") {
            pdfView.document!.beginFindString(String(word), withOptions: [.caseInsensitive])
        }
        pdfView.setNeedsDisplay()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(false)
    }
}
