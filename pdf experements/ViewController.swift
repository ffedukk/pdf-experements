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
    var test_dict: [String:CGFloat] = ["ДОГ":0.8, "ДОГОВОР":0.8, "ДОГОВОРА":0.8, "ТРУД":0.2, "ТРУДОВОГО ДОГОВОРА":0.5, "ТРУДОВОГО":0.2]
    let stackView = UIStackView()
    let currentPageView = MyUILabel()
    
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
        
        stackView.backgroundColor = .lightGray
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.layer.cornerRadius = 2
//        stackView.layer.masksToBounds = true
        stackView.isUserInteractionEnabled = false
        
    
        currentPageView.translatesAutoresizingMaskIntoConstraints = false
        currentPageView.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .medium)
        currentPageView.backgroundColor = UIColor(red: 0.898, green: 0.898, blue: 0.917, alpha: 0.9)
        currentPageView.textColor = .darkGray
        currentPageView.textAlignment = .center
        currentPageView.layer.cornerRadius = 7
        currentPageView.layer.masksToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(pageChanged), name: NSNotification.Name.PDFViewPageChanged, object: pdfView)
        
        
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false

        if let path = Bundle.main.path(forResource: "myFile", ofType: "pdf"),
           let pdf = PDFDocument(url: URL(fileURLWithPath: path)) {
            
            pdf.delegate = self
            setupPDFView(with: pdf)
            
            setupThumbnailView()
            thumbnailView.addSubview(stackView)
            pdfView.addSubview(currentPageView)
            currentPageView.text = "1 of \(pdf.pageCount)"
            for _ in 0..<pdf.pageCount {
                let v = UIView()
                v.backgroundColor = UIColor(red: 1, green: 1, blue: 0, alpha: CGFloat.random(in: 0...1))
                stackView.addArrangedSubview(v)
            }
            
            
        }
        
        
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: thumbnailView.topAnchor).isActive = true
        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        thumbnailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        thumbnailView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        thumbnailView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        thumbnailView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        stackView.topAnchor.constraint(equalTo: thumbnailView.topAnchor, constant: 15).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -18).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        currentPageView.topAnchor.constraint(equalTo: pdfView.topAnchor, constant: 15).isActive = true
        currentPageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        //currentPageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        currentPageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    @objc func tapped() {
        UIView.animate(withDuration: 0.3) {
            (self.thumbnailView.alpha > 0) ? (self.thumbnailView.alpha = 0) : (self.thumbnailView.alpha = 1)
            ((self.navigationController?.navigationBar.alpha)! > 0) ? (self.navigationController?.navigationBar.alpha = 0) : (self.navigationController?.navigationBar.alpha = 1)
            ((self.currentPageView.alpha) > 0) ? (self.currentPageView.alpha = 0) : (self.currentPageView.alpha = 1)
        }
        searchBar.endEditing(false)
    }
    
    @objc func pageChanged() {
        if let page = pdfView.currentPage {
            currentPageView.text = "\((pdfView.document?.index(for: page) ?? 0) + 1) of \(pdfView.document?.pageCount ?? 0)"
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
        
        var currentWeight: CGFloat = 0
        for annotation in page.annotations {
            if annotation.bounds.intersects(instance.bounds(for: page)) {
                currentWeight += annotation.annotationKeyValues["/weight"] as! CGFloat
            }
        }
        var weight = test_dict[word]! - currentWeight
        if weight <= 0 { return }
        weight = ceil(weight*1000)/1000
        //print(weight, currentWeight)
        
        let highlight = PDFAnnotation(bounds: (instance.bounds(for: page)), forType: .highlight, withProperties: ["weight": weight])
//        highlight.color = UIColor(red: 1, green: 1 - weight, blue: 1, alpha: 1)
        highlight.color = UIColor(red: 1, green: 1, blue: 0, alpha: weight)
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
        thumbnailView.thumbnailSize = CGSize(width: 40, height: 70)
        print(thumbnailView.layoutMargins)
        thumbnailView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
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
        pdfView.document!.beginFindStrings(searchBar.text!.split(separator: " ").map{String($0).uppercased()}.sorted{ $0 > $1 }, withOptions: .caseInsensitive)
        
        for v in stackView.subviews {
            v.backgroundColor = UIColor(red: 1, green: 1, blue: 0, alpha: CGFloat.random(in: 0...1))
        }
        stackView.setNeedsDisplay()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(false)
        for v in stackView.subviews {
            v.backgroundColor = UIColor(red: 1, green: 1, blue: 0, alpha: 0)
        }
    }
}


class MyUILabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        var s = super.intrinsicContentSize
        s.width += 10
        return s
    }
    
    
}
