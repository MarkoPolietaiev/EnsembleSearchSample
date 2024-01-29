//
//  FilterViewController.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-25.
//

import UIKit

/// Protocol for the delegate to handle filter changes in the FilterViewController.
protocol FilterViewControllerDelegate: AnyObject {
    /// Notifies the delegate when a new filter is saved.
    func didSaveNewFilter(year: Int?, type: MovieType?)
}

/// View controller for displaying and managing filters.
class FilterViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var gestureView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var yearPicker: UIPickerView!
    @IBOutlet weak var yearSelectionImageView: UIImageView!
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var typeSelectionImageView: UIImageView!
    
    // MARK: - Properties
    
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var originalPosition: CGPoint?
    private var currentPositionTouched: CGPoint?
    
    weak var delegate: FilterViewControllerDelegate?
    
    private var years: [Int] = {
        var years = [Int]()
        for year in 1900...2025 {
            years.append(year)
        }
        return years
    }()
    
    var year: Int?
    var type: MovieType?
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.25, delay: 0.20) { [weak self] in
            self?.backgroundView.alpha = 0.5
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.backgroundView.alpha = 0
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.roundCorners([.topLeft, .topRight], radius: 16)
    }
    
    // MARK: - Actions
    
    @IBAction func yearButtonPressed(_ sender: Any) {
        if year != nil {
            year = nil
        } else {
            year = years[yearPicker.selectedRow(inComponent: 0)]
        }
        updateYearView()
    }
    
    @IBAction func typeButtonPressed(_ sender: Any) {
        if type != nil {
            type = nil
        } else {
            type = MovieType.allCases[typePicker.selectedRow(inComponent: 0)]
        }
        updateTypeView()
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        delegate?.didSaveNewFilter(year: year, type: type)
        dismiss(animated: true)
    }
}

// MARK: - Private Extensions

private extension FilterViewController {
    func setupView() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGestureRecognizer!)
        panGestureRecognizer?.cancelsTouchesInView = false
        if let panGestureRecognizer {
            for gesture in yearPicker.gestureRecognizers ?? [] {
                panGestureRecognizer.require(toFail: gesture)
            }
            for gesture in typePicker.gestureRecognizers ?? [] {
                panGestureRecognizer.require(toFail: gesture)
            }
        }
        closeButton.layer.cornerRadius = closeButton.frame.size.height / 2
        gestureView.layer.cornerRadius = gestureView.frame.size.height / 2
        yearPicker.delegate = self
        yearPicker.dataSource = self
        typePicker.delegate = self
        typePicker.dataSource = self
        if let year {
            yearPicker.selectRow(years.firstIndex(of: year) ?? years.count-1, inComponent: 0, animated: false)
        } else {
            yearPicker.selectRow(years.count-1, inComponent: 0, animated: false)
        }
        updateTogglingViews()
    }
    
    func updateTogglingViews() {
        updateYearView()
        updateTypeView()
    }
    
    func updateYearView() {
        let isSelected = year != nil
        yearPicker.isUserInteractionEnabled = isSelected
        yearPicker.alpha = isSelected ? 1 : 0.3
        yearSelectionImageView.image = UIImage(systemName: "circlebadge\(isSelected ? ".fill" : "")")
    }
    
    func updateTypeView() {
        let isSelected = type != nil
        typePicker.isUserInteractionEnabled = isSelected
        typePicker.alpha = isSelected ? 1 : 0.3
        typeSelectionImageView.image = UIImage(systemName: "circlebadge\(isSelected ? ".fill" : "")")
    }
    
    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: view)

        if panGesture.state == .began {
          originalPosition = view.center
          currentPositionTouched = panGesture.location(in: view)
        } else if panGesture.state == .changed, translation.y >= 0 {
            view.frame.origin = CGPoint(
                x: view.frame.origin.x,
                y: translation.y
            )
        } else if panGesture.state == .ended {
          let velocity = panGesture.velocity(in: view)

          if velocity.y >= 1500 {
            UIView.animate(withDuration: 0.2
              , animations: {
                self.view.frame.origin = CGPoint(
                  x: self.view.frame.origin.x,
                  y: self.view.frame.size.height
                )
                self.backgroundView.alpha = 0
              }, completion: { (isCompleted) in
                if isCompleted {
                  self.dismiss(animated: true)
                }
            })
          } else {
            UIView.animate(withDuration: 0.2, animations: {
              self.view.center = self.originalPosition!
            })
          }
        }
    }
}

// MARK: - UIPickerViewDataSource Extension

extension FilterViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case yearPicker:
            return years.count
        case typePicker:
            return MovieType.allCases.count
        default:
            return 0
        }
    }
}

// MARK: - UIPickerViewDelegate Extension

extension FilterViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case yearPicker:
            return "\(years[row])"
        case typePicker:
            return MovieType.allCases[row].localizedValue
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case yearPicker:
            year = years[row]
        case typePicker:
            type = MovieType.allCases[row]
        default:
            return
        }
    }
}
