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
    var test_dict: [String:CGFloat] = ["ДОГ":0.6, "ДОГОВОР":0.6, "ДОГОВОРА":0.6, "ТРУД":0.3, "ТРУДОВОГО ДОГОВОРА":0.45, "ТРУДОВОГО":0.3]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        gesture.addTarget(self, action: #selector(tapped))
        pdfView.addGestureRecognizer(gesture)
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        navigationItem.titleView = searchBar
        navigationController?.navigationBar.barTintColor = .clear
//        navigationController?.navigationBar.isTranslucent = true
        searchBar.searchTextField.backgroundColor = .lightGray
        
        
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
        thumbnailView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    @objc func tapped() {
        UIView.animate(withDuration: 0.5) {
            (self.thumbnailView.alpha > 0) ? (self.thumbnailView.alpha = 0) : (self.thumbnailView.alpha = 1)
            ((self.navigationController?.navigationBar.alpha)! > 0) ? (self.navigationController?.navigationBar.alpha = 0) : (self.navigationController?.navigationBar.alpha = 1)
        }
    }
    
    func didMatchString(_ instance: PDFSelection) {
        let word = instance.string!.uppercased()
        let page = instance.pages[0]
//        let rng = instance.range(at: 0, on: page)
        
//        if let ranges = test_dict[word]?.ranges {
//            for range in ranges {
//                let newInstance = pdfView.document!.selection(from: page, atCharacterIndex: rng.lowerBound + range.lowerBound, to: page, atCharacterIndex: rng.lowerBound + range.lowerBound + range.length - 1)!
//                let highlight = PDFAnnotation(bounds: (newInstance.bounds(for: page)), forType: .highlight, withProperties: ["weight": 0.5])
//                highlight.color = UIColor(red: 1, green: 1 - CGFloat(test_dict[word]!.weight), blue: 1, alpha: 1)
//                page.addAnnotation(highlight)
//            }
//        }
//        print(instance.range(at: 0, on: page))
        var currentWeight: CGFloat = 0
        for annotation in page.annotations {
            if annotation.bounds.intersects(instance.bounds(for: page)) {
                currentWeight += annotation.annotationKeyValues["/weight"] as! CGFloat
                print(annotation.color)
            }
        }
        
//        print(currentWeight)
        let weight = test_dict[word]! - currentWeight
        if weight <= 0 { return }
        let highlight = PDFAnnotation(bounds: (instance.bounds(for: page)), forType: .highlight, withProperties: ["weight": weight])
        highlight.color = UIColor(red: 1, green: 1 - weight, blue: 1, alpha: 1)
        page.addAnnotation(highlight)
 
    }
    
//    func getRanges(word: NSString) -> [NSRange] {
//        var result: [NSRange] = []
//        var ranges: [NSRange] = []
//        for anotherWord in test_dict.keys{
//            if NSString(string: anotherWord) != word && word.contains(anotherWord) {
//                var newRange = word.range(of: anotherWord, options: .caseInsensitive)
//                for range in ranges {
//                    if let _ = newRange.intersection(range) {
//                        newRange.formUnion(range)
//                        ranges.remove(at: ranges.firstIndex(of: range)!)
//                    }
//                }
//                ranges.append(newRange)
//            }
//        }
//        if ranges.isEmpty {
//            return [NSRange(location: 0, length: word.length)]
//        }
//
//        var lowerBound = 0
//        ranges.sort { (left, right) -> Bool in
//            left.location < right.location
//        }
//        for range in ranges {
//            if range.lowerBound != 0 {
//                result.append(NSRange(location: lowerBound, length: range.lowerBound - lowerBound))
//            }
//            lowerBound = range.upperBound
//        }
//        if lowerBound < word.length {
//            result.append(NSRange(location: lowerBound, length: word.length - lowerBound))
//        }
//        return result
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        test_dict.forEach { (key, value) in
//            value.ranges = getRanges(word: NSString(string: key))
//        }
        pdfView.document?.beginFindStrings(test_dict.keys.sorted { $0 > $1 }, withOptions: .caseInsensitive)
    }
    
    private func setupPDFView(with document: PDFDocument) {
        pdfView.backgroundColor = .black
//        pdfView.displayDirection = .horizontal
//        pdfView.usePageViewController(true)
        pdfView.pageBreakMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
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
        
        pdfView.document!.beginFindStrings(searchBar.text!.split(separator: " ").map{String($0)}, withOptions: .caseInsensitive)
        
//        for word in searchBar.text!.split(separator: " ") {
////            pdfView.document!.beginFindString(String(word), withOptions: [.caseInsensitive])
//            pdfView.document!.findString(String(word), withOptions: [.caseInsensitive])
//        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(false)
    }
}
