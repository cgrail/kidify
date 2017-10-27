/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

enum Theme: Int {
  case `default`, dark
  
  private enum Keys {
    static let selectedTheme = "SelectedTheme"
  }
  
  static var current: Theme {
    let storedTheme = UserDefaults.standard.integer(forKey: Keys.selectedTheme)
    return Theme(rawValue: storedTheme) ?? .default
  }
  
  var mainColor: UIColor {
    switch self {
    case .default:
      return UIColor(red: 87.0/255.0, green: 188.0/255.0, blue: 95.0/255.0, alpha: 1.0)
    case .dark:
      return UIColor(red: 255.0/255.0, green: 115.0/255.0, blue: 50.0/255.0, alpha: 1.0)
    }
  }
  
  var barStyle: UIBarStyle {
    switch self {
    case .default:
      return .default
    case .dark:
      return .black
    }
  }
  
  var backgroundColor: UIColor {
    switch self {
    case .default:
      return UIColor.white
    case .dark:
      return UIColor(white: 0.4, alpha: 1.0)
    }
  }
  
  var textColor: UIColor {
    switch self {
    case .default:
      return UIColor.black
    case .dark:
      return UIColor.white
    }
  }

  func apply() {
    UserDefaults.standard.set(rawValue, forKey: Keys.selectedTheme)
    UserDefaults.standard.synchronize()
    
    UIApplication.shared.delegate?.window??.tintColor = mainColor
    
    UINavigationBar.appearance().barStyle = barStyle
    
    UITabBar.appearance().barStyle = barStyle
    
    UISwitch.appearance().onTintColor = mainColor.withAlphaComponent(0.3)
    UISwitch.appearance().thumbTintColor = mainColor
    
    UITableViewCell.appearance().backgroundColor = backgroundColor
    UITableView.appearance().backgroundColor = backgroundColor
    UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = textColor
  }
}
