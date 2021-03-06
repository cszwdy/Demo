//
//  ViewController.swift
//  EditResponder
//
//  Created by Emiaostein on 15/4/10.
//  Copyright (c) 2015年 BoTai Technology. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var componentViewModels: [ComponentViewModel] = []
    var maskViewsModels: [MaskViewModel] = []
    var componentViews: [ComponentView] = []
    var maskViews: [MaskProxyView] = []
    var mutliSelectable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let acomponentViewModels = createComponentViewModels()
        addComponents(acomponentViewModels)
    }
}

// MARK: - Private Func
extension ViewController {
    
    private func createComponentViewModels() -> [ComponentViewModel] {
        let models = DataCreator.componentModels()
        var viewModels: [ComponentViewModel] = []
        
        for model in models {
            let viewModel = ComponentViewModel(model: model)
            viewModels.append(viewModel)
        }
        
        return viewModels
    }
    
    private func addComponents(viewModels: [ComponentViewModel]) {
        for viewModel in viewModels {
            addComponentBy(viewModel)
        }
    }
    
    private func addComponentBy(componentViewModel: ComponentViewModel) {
        
        let componentView = ComponentView(viewModel: componentViewModel)
        componentViewModels.append(componentViewModel)
        componentViews.append(componentView)
        view.addSubview(componentView)
    }
    
    private func addMaskViewBy(componentViewModel: ComponentViewModel) {
        
        let maskViewModel = MaskViewModel(viewModel: componentViewModel)
        let maskView = MaskProxyView(viewModel: maskViewModel)
        maskViewsModels.append(maskViewModel)
        maskViews.append(maskView)
        view.addSubview(maskView)
    }
    
    private func removeComponentBy(componentModel: ComponentModel) {
        
        for componentView in componentViews {
            
            if let viewmodel = componentView.viewModel {
                if viewmodel == componentModel {
                    maskViews.removeItem(componentView)
                    componentView.removeFromSuperview()
                    
                    if componentViewModels.contain(componentModel) {
                        componentViewModels.removeItem(componentModel)
                    }
                    break
                }
            }
        }
    }
    
    private func removeMaskBy(maskViewModel: MaskViewModel) {
        
        for maskView in maskViews {
            
            if let viewmodel = maskView.viewModel {
                if viewmodel == maskViewModel {
                    maskViews.removeItem(maskView)
                    maskView.removeFromSuperview()
                    
                    if maskViewsModels.contain(maskViewModel) {
                        maskViewsModels.removeItem(maskViewModel)
                        
                    }
                    break
                }
            }
        }
    }
    
    private func removeComponentsAll() {
        
        for com in componentViews {
            com.removeFromSuperview()
        }
        componentViews.removeAll(keepCapacity: false)
        componentViewModels.removeAll(keepCapacity: false)
    }
    
    private func removeMasksAll() {
        
        for mask in maskViews {
            mask.removeFromSuperview()
        }
        maskViews.removeAll(keepCapacity: false)
        maskViewsModels.removeAll(keepCapacity: false)
    }
    
    private func refresh() {
        
        removeComponentsAll()
        removeMasksAll()
        componentViewModels = createComponentViewModels()
        addComponents(componentViewModels)
    }
    
    private func inSpecialRegions(regionViewModels: [ComponentViewModel], regionViews: [ComponentView]) -> (Bool, Int) {
        
        for regionView in regionViews {
            if let regionViewModel = regionView.viewModel {
                
                for (index, viewModel) in enumerate(regionViewModels) {
                    
                    if regionViewModel == viewModel  {
                        return (true, index)
                    }
                }
            }
        }
        
        return (false, intmax_t())
    }
    
    private func inMaskSpecialRegions(regionViewModels: [MaskViewModel], regionViews: [MaskProxyView]) -> (Bool, Int) {
        
        for regionView in regionViews {
            if let regionViewModel = regionView.viewModel {
                
                for (index, viewModel) in enumerate(regionViewModels) {
                    
                    if regionViewModel == viewModel  {
                        return (true, index)
                    }
                }
            }
        }
        
        return (false, intmax_t())
    }
}

// MARK - IBAction
extension ViewController {
    
    
    @IBAction func Refresh(sender: UIButton) {
        refresh()
    }
    
    @IBAction func longPressAction(sender: UILongPressGestureRecognizer) {
        
                let location = sender.locationInView(view)
        
                switch sender.state {
                case .Began:
                    println("longPress began")
                    let InmaskViews = maskViews.filter({ (spectialView) -> Bool in
                        let convertPoint = self.view.convertPoint(location, toView: spectialView)
                        return CGRectContainsPoint(spectialView.bounds, convertPoint)
                    })
                    
                    if let reveMaskViews = InmaskViews.last {
                        mutliSelectable = true
                        return
                    }
                    
                    let InComViews = componentViews.filter({ (spectialView) -> Bool in
                        let convertPoint = self.view.convertPoint(location, toView: spectialView)
                        return CGRectContainsPoint(spectialView.bounds, convertPoint)
                    })
                    
                    if let reveComViews = InComViews.last {
                        addMaskViewBy(reveComViews.viewModel)
                        mutliSelectable = true
                        return
                    }
                    
                    mutliSelectable = false
                    return
                    
        
                case .Ended, .Cancelled:
                    println("longpressEnd")
                    mutliSelectable = false
        
                default:
                    return
                }
    }
    
    @IBAction func TapAction(sender: UITapGestureRecognizer) {
        
        println("TapAction")
        let location = sender.locationInView(view)
        
        if mutliSelectable {
            
            let InmaskViews = maskViews.filter({ (spectialView) -> Bool in
                let convertPoint = self.view.convertPoint(location, toView: spectialView)
                return CGRectContainsPoint(spectialView.bounds, convertPoint)
            })
            
            if let reveMaskViews = InmaskViews.last {
                removeMaskBy(reveMaskViews.viewModel)
                return
            }
            
            let inRegionView = componentViews.filter({ (spectialView) -> Bool in
                let convertPoint = self.view.convertPoint(location, toView: spectialView)
                return CGRectContainsPoint(spectialView.bounds, convertPoint)
            })
            
            if let selectedView = inRegionView.last {
                addMaskViewBy(selectedView.viewModel)
                return
            }
            
            return
            
            
        } else {
            
            Incomponents(location)
            
        }
    }
    
    private func Incomponents(location: CGPoint) {
        
        let InComViews = componentViews.filter({ (componentView) -> Bool in
            let convertPoint = self.view.convertPoint(location, toView: componentView)
            return CGRectContainsPoint(componentView.bounds, convertPoint)
        })
        
        if InComViews.count <= 0 {
            removeMasksAll()
            return
        }
        
        if let selectedComView = InComViews.last {
                removeMasksAll()
                addMaskViewBy(selectedComView.viewModel)
                return
            }
        
        removeMasksAll()
        return
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
}

extension Array {
    mutating func removeItem<T: Equatable>(item: T) -> Bool {
        var index: Int?
        for (idx, objectToCompare) in enumerate(self) {
            if let to = objectToCompare as? T {
                if item == to {
                    index = idx
                }
            }
        }
        
        if(index != nil) {
            self.removeAtIndex(index!)
            return true
        }
        
        return false
    }
    
    func contain<T: Equatable>(item: T) -> Bool {
        var index: Int?
        for (idx, objectToCompare) in enumerate(self) {
            if let to = objectToCompare as? T {
                if item == to {
                    index = idx
                }
            }
        }
        
        if(index != nil) {
            
            return true
        }
        
        return false
    }
}




