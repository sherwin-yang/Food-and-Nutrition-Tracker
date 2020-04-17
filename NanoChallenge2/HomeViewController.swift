//
//  HomeViewController.swift
//  NanoChallenge2
//
//  Created by Sherwin Yang on 16/03/20.
//  Copyright © 2020 Sherwin Yang. All rights reserved.
//

import UIKit
import CoreData

struct Foods {
    var date: Date?
    var name: [String]?
    var calorie: [Int]?
    var carbohydrate: [Int]?
    var protein: [Int]?
    var fat: [Int]?
    
    init(date: Date, name: [String], calorie: [Int], carbohydrate: [Int], protein: [Int], fat:[Int]) {
        self.date = date
        self.name = name
        self.calorie = calorie
        self.carbohydrate = carbohydrate
        self.protein = protein
        self.fat = fat
    }
}

class HomeViewController: UIViewController {
    
    var date = Date()
    let dateFormatter = DateFormatter()
    
    var foodsArr = [Food]()
    var foodDateArr = [FoodDate]()
    
    var foods = [Foods]()
    
    var month_year = ""
    
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var carbohydrateLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plusButton: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
        print("Loaded") 
        
        self.dateFormatter.dateFormat = "LLLL yyyy"
        self.monthLabel.text = self.dateFormatter.string(from: date)
        self.caloriesLabel.text = String(self.countTotalCalories())
        self.carbohydrateLabel.text = String(self.countTotalcarbohydrate())
        self.proteinLabel.text = String(self.countTotalProtein())
        self.fatLabel.text = String(self.countTotalFat())
        
        self.view.addSubview(plusButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshHomeView()
    }

    
    // MARK: - IBAction
    
    @IBAction func previousMonth(_ sender: Any) {
        // 1. Change monthLabel
        let substractedDate = Calendar.current.date(byAdding: .month, value: -1, to: date)
        date = substractedDate!
        dateFormatter.dateFormat = "LLLL yyyy"
        monthLabel.text = dateFormatter.string(from: substractedDate!)
        // 2. Reload view
        refreshHomeView()
    }
    
    @IBAction func nextMonth(_ sender: Any) {
        // 1. Change monthLabel
        let addedDate = Calendar.current.date(byAdding: .month, value: 1, to: date)
        date = addedDate!
        dateFormatter.dateFormat = "LLLL yyyy"
        monthLabel.text = dateFormatter.string(from: addedDate!)
        // 2. Reload view
        refreshHomeView()
    }
    
    // MARK: - User Built Functions
    
    func insertDataToStructWithCorrespondingMonth() {
        dateFormatter.dateFormat = "LLLL yyyy"
        
        var isNextDate = false
        for i in 0..<foodDateArr.count {
            isNextDate = false
            let foodDateArrMonth = dateFormatter.string(from: foodDateArr[i].dateEaten!)
            for j in 0..<foodsArr.count {
                if foodDateArr[i].dateEaten == foodsArr[j].parentDate?.dateEaten && foodDateArrMonth == monthLabel.text! {
                    if !isNextDate {
                        foods.append(Foods.init(date: foodDateArr[i].dateEaten!, name: [foodsArr[j].foodName!], calorie: [Int(foodsArr[j].foodCalorie)], carbohydrate: [Int(foodsArr[j].foodCarbohydrate)], protein: [Int(foodsArr[j].foodProtein)], fat: [Int(foodsArr[j].foodFat)]))
                        isNextDate = true
                    }
                    else {
                        foods[i].name?.append(foodsArr[j].foodName!)
                        foods[i].calorie?.append(Int(foodsArr[j].foodCalorie))
                        foods[i].carbohydrate?.append(Int(foodsArr[j].foodCarbohydrate))
                        foods[i].protein?.append(Int(foodsArr[j].foodProtein))
                        foods[i].fat?.append(Int(foodsArr[j].foodFat))
                    }
                }
            }
        }
    }
    
    func countTotalCalories() -> Int {
        var result = 0
        for i in 0..<foods.count {
            for j in 0..<foods[i].calorie!.count {
                result = result + foods[i].calorie![j]
            }
        }
        return result
    }
    
    func countTotalcarbohydrate() -> Int {
        var result = 0
        for i in 0..<foods.count {
            for j in 0..<foods[i].carbohydrate!.count {
                result = result + foods[i].carbohydrate![j]
            }
        }
        return result
    }
    
    func countTotalProtein() -> Int {
        var result = 0
        for i in 0..<foods.count {
            for j in 0..<foods[i].protein!.count {
                result = result + foods[i].protein![j]
            }
        }
        return result
    }
    
    func countTotalFat() -> Int {
        var result = 0
        for i in 0..<foods.count {
            for j in 0..<foods[i].fat!.count {
                result = result + foods[i].fat![j]
            }
        }
        return result
    }
    
    func refreshHomeView() {
        foods.removeAll()
        foodsArr.removeAll()
        foodDateArr.removeAll()
        loadFood()
        // Refresh all labels
        caloriesLabel.text = String(countTotalCalories())
        carbohydrateLabel.text = String(countTotalcarbohydrate())
        proteinLabel.text = String(countTotalProtein())
        fatLabel.text = String(countTotalFat())
        // Refresh Table View
        self.tableView.reloadData()
    }
    
    // MARK: - Data Manipulation Methods
    
    func loadFood() {
        let requestFood: NSFetchRequest<Food> = Food.fetchRequest()
        let requestFoodDate: NSFetchRequest<FoodDate> = FoodDate.fetchRequest()
        do {
            foodsArr = try context.fetch(requestFood)
            foodDateArr = try context.fetch(requestFoodDate)
            insertDataToStructWithCorrespondingMonth()
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
}

// MARK: - Table View

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return foods.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods[section].name?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = foods[indexPath.section].name?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        dateFormatter.dateFormat = "dd/MM/yyyy, EEEE"
        return dateFormatter.string(from: foods[section].date!)
    }
    
}
