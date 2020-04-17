//
//  InputFoodViewController.swift
//  NanoChallenge2
//
//  Created by Sherwin Yang on 16/03/20.
//  Copyright © 2020 Sherwin Yang. All rights reserved.
//

import UIKit
import CoreData

class InputFoodViewController: UIViewController {
    
    var selectedDate: Date!
    var foodName = ""
    var calories = 0
    var carbohydrate = 0
    var protein = 0
    var fat = 0
    
    var foodsArr = [Food]()
    var foodDateArr = [FoodDate]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var selectDateTextField: UITextField!
    @IBOutlet weak var foodNameTextField: UITextField!
    @IBOutlet weak var carbohydrateTextField: UITextField!
    @IBOutlet weak var proteinTextField: UITextField!
    @IBOutlet weak var fatTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.load()
        
        // Date Picker declaration for selectDateTextField
        self.selectDateTextField.setInputViewDatePicker(target: self, selector: #selector(tapDone))
        
        // Show keyboard on selectDateTextField when first time appear
        self.selectDateTextField.becomeFirstResponder()
        
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
    }
    
    // MARK: - IBAction
    
    @IBAction func cancelButtonDidTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func carbohydrateStepper(_ sender: UIStepper) {
        if(sender.value == 1) {
            carbohydrate = carbohydrate + 1
            carbohydrateTextField.text! = String(carbohydrate)
        }
        else if(sender.value == 0 && Int(carbohydrateTextField.text!) != 0) {
            carbohydrate = carbohydrate - 1
            carbohydrateTextField.text! = String(carbohydrate)
        }
        else if(sender.value == 2) {
            carbohydrate = carbohydrate + 1
            carbohydrateTextField.text! = String(carbohydrate)
        }
        sender.value = 1
    }
    
    @IBAction func carbohydrateTextFieldDidChange(_ sender: Any) {
        if(!carbohydrateTextField.text!.isEmpty) {
            carbohydrate = Int(carbohydrateTextField.text!)!
            carbohydrateTextField.text = String(carbohydrate)
        }
    }
    
    @IBAction func proteinStepper(_ sender: UIStepper) {
        if(sender.value == 1) {
            protein = protein + 1
            proteinTextField.text! = String(protein)
        }
        else if(sender.value == 0 && Int(proteinTextField.text!) != 0) {
            protein = protein - 1
            proteinTextField.text! = String(protein)
        }
        else if(sender.value == 2) {
            sender.value = 1
            protein = protein + 1
            proteinTextField.text! = String(protein)
        }
        sender.value = 1
    }
    
    @IBAction func proteinTextFieldDidChange(_ sender: Any) {
        if(!proteinTextField.text!.isEmpty) {
            protein = Int(proteinTextField.text!)!
            proteinTextField.text = String(protein)
        }
    }
    
    @IBAction func fatStepper(_ sender: UIStepper) {
        if(sender.value == 1) {
            fat = fat + 1
            fatTextField.text! = String(fat)
        }
        else if(sender.value == 0 && Int(fatTextField.text!) != 0) {
            fat = fat - 1
            fatTextField.text! = String(fat)
        }
        else if(sender.value == 2) {
            fat = fat + 1
            fatTextField.text! = String(fat)
        }
        sender.value = 1
    }
    
    @IBAction func fatTextFieldDidChange(_ sender: Any) {
        if(!fatTextField.text!.isEmpty) {
            fat = Int(fatTextField.text!)!
            fatTextField.text = String(fat)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if checkForEmptyTextField() {
            // Do Nothing
        }
        else {
            let newFood = Food(context: self.context)
            
            dateFormatter.dateFormat = "LLLL, dd-MM-yyyy"
            
            selectedDate = dateFormatter.date(from: selectDateTextField.text!)
            foodName = foodNameTextField.text!
            carbohydrate = Int(carbohydrateTextField.text!)!
            protein = Int(proteinTextField.text!)!
            fat = Int(fatTextField.text!)!
            calories = (carbohydrate*4) + (protein*4) + (fat*9)
            
            newFood.foodName = foodName
            newFood.foodCalorie = Int32(calories)
            newFood.foodCarbohydrate = Int32(carbohydrate)
            newFood.foodProtein = Int32(protein)
            newFood.foodFat = Int32(fat)
            
            let sameDateIndex = isThereSameDate(date: selectedDate)
            if sameDateIndex == -999 {
                let newFoodDate = FoodDate(context: self.context)
                newFoodDate.dateEaten = selectedDate
                
                newFood.parentDate = newFoodDate
                self.foodDateArr.append(newFoodDate)
                self.foodsArr.append(newFood)
            }
            else {
                newFood.parentDate = foodDateArr[sameDateIndex]
                self.foodsArr.append(newFood)
            }
            
            self.saveFood()
            dismiss(animated: true)
        }
    }
    
    // MARK: - User Built Functions
    
    @objc func tapDone() {
        if let datePicker = self.selectDateTextField.inputView as? UIDatePicker {
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "LLLL, dd-MM-yyyy"
            self.selectDateTextField.text = dateformatter.string(from: datePicker.date)
        }
    }
    
    func checkForEmptyTextField() -> Bool{
        if(selectDateTextField.text!.isEmpty) {
            selectDateTextField.attributedPlaceholder = NSAttributedString(string:"Please Select Date", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return true
        }
        else if(foodNameTextField.text!.isEmpty) {
            foodNameTextField.attributedPlaceholder = NSAttributedString(string:"Please Enter Food Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return true
        }
        else if(carbohydrateTextField.text!.isEmpty) {
            carbohydrateTextField.attributedPlaceholder = NSAttributedString(string:"!", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return true
        }
        else if(proteinTextField.text!.isEmpty) {
            proteinTextField.attributedPlaceholder = NSAttributedString(string:"!", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return true
        }
        else if(fatTextField.text!.isEmpty) {
            fatTextField.attributedPlaceholder = NSAttributedString(string:"!", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return true
        }
        return false
    }
    
    func isThereSameDate(date: Date) -> Int{
        for index in 0..<foodDateArr.count {
            if date == foodDateArr[index].dateEaten {
                return index
            }
        }
        return -999
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveFood() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error) ")
        }
    }
    
    func load() {
        let requestFood: NSFetchRequest<Food> = Food.fetchRequest()
        let requestFoodDate: NSFetchRequest<FoodDate> = FoodDate.fetchRequest()
        do {
            foodsArr = try context.fetch(requestFood)
            foodDateArr = try context.fetch(requestFoodDate)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }

    
}
