//
//  DateTimeUtils.swift
//  CyberFM
//
//  Created by Do Trung Bao on 3/13/19.
//  Copyright © 2019 Cyber FM. All rights reserved.
//

import Foundation

public class DateTimeUtils {
    static func currentTimeMillis() -> Double {
        return Double(Date().timeIntervalSince1970 * 1000)
    }
    
    static func getTimeMillisOfDate(date: Date?) -> Double {
        if date == nil {
            return 0
        }
        return Double(date!.timeIntervalSince1970 * 1000)
    }
    
    static func convertDateToString(_ date: Date, _ dateStyle: DateFormatter.Style, _ timeStyle: DateFormatter.Style = .none) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        let datetime = formatter.string(from: date)
        return datetime
    }
    
    static func getDateFromString(_ strDate: String, _ pattern: String) -> Date? {
        if !pattern.isEmpty {
             let dateFormatter = DateFormatter()
             dateFormatter.dateFormat = pattern
             dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
             return dateFormatter.date(from: strDate)
         }
         return nil
    }
    
    static func getCurrentDate(_ pattern: String) -> String{
        if !pattern.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = pattern
            let date : Date = Date()
            let todaysDate = dateFormatter.string(from: date)
            return todaysDate
        }
        return ""
    }
    
    static func getCurrentDate(_ pattern: String, _ time: Double) -> String{
        if !pattern.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = pattern
            let date : Date = Date(timeIntervalSince1970: TimeInterval(time/1000))
            let todaysDate = dateFormatter.string(from: date)
            return todaysDate
        }
        return ""
    }
    
    static func convertToStringTime(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        if hours == 0 {
            return String.init(format: "%02i:%02i",minutes,seconds)
        }
        else{
            return String.init(format: "%02d:%02i:%02i",hours,minutes,seconds)
        }
    }
    
}
