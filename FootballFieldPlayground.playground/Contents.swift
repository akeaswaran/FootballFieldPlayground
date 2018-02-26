// FootballFieldPlayground: a playground for testing out building a drive-tracker UIView in Swift
// Author: Akshay Easwaran <akeaswaran@me.com>
// Inspiration from https://github.com/criscokid/Canvas-Field/blob/master/field.js
  
import UIKit
import CoreGraphics

enum FFTeam: String {
    case Home
    case Away
    
    func team() -> String {
        return self.rawValue
    }
}

class FootballField : UIView {
    private var startPoint: CGFloat = 0.0
    private var currentPoint: CGFloat = 0.0
    private var startPlayY: CGFloat = 0.0
    private var currentPlayY: CGFloat = 0.0
    
    private var awayStartPoint: CGFloat = 660.0
    private var awayCurrentPoint: CGFloat = 660.0
    
    public var homeTeamColor: UIColor = UIColor.blue
    public var awayTeamColor: UIColor = UIColor.red
    
    public var teamWithBall: FFTeam = FFTeam.Home
    
    private var driveList: [Dictionary<FFTeam, [Dictionary<String, CGFloat>]>] = []
    
    override init(frame: CGRect) {
        homeTeamColor = UIColor.init(red:0.72, green:0.07, blue:0.20, alpha:1.00)
        awayTeamColor = UIColor.init(red:0.16, green:0.22, blue:0.38, alpha:1.00)
        super.init(frame: CGRect(x: 0, y: 0, width: 720, height: 300))
        backgroundColor = UIColor.init(red: 0, green: 153.0/255.0, blue: 41.0/255.0, alpha: 1.0)
    }
    
    required init?(coder: NSCoder) {
        homeTeamColor = UIColor.init(red:0.72, green:0.07, blue:0.20, alpha:1.00)
        awayTeamColor = UIColor.init(red:0.16, green:0.22, blue:0.38, alpha:1.00)
        super.init(coder: coder)
        backgroundColor = UIColor.init(red: 0, green: 153.0/255.0, blue: 41.0/255.0, alpha: 1.0)
    }
    
    private func drawYardLine(loc: CGFloat, context: CGContext) {
        context.beginPath()
        context.move(to: CGPoint(x: loc, y: 0))
        context.addLine(to: CGPoint(x: loc, y: 300))
        context.setStrokeColor(UIColor.white.cgColor)
        context.strokePath()
    }
    
    private func fillEndZones(context: CGContext) {
        context.setFillColor(homeTeamColor.cgColor)
        context.fill(CGRect(x:0, y:0, width: 60, height:300))
        context.setFillColor(awayTeamColor.cgColor)
        context.fill(CGRect(x:660, y:0, width: 60, height:300))
    }
    
    private func markPlay(context: CGContext, yards: CGFloat, team: FFTeam) {
        if (team == FFTeam.Home) {
            let endPoint: CGFloat = min(currentPoint + yards * 3.0 * 2.0, 660)
            context.setStrokeColor(homeTeamColor.cgColor)
            context.setLineWidth(10.0)
            
            context.beginPath()
            context.move(to: CGPoint(x: currentPoint, y: currentPlayY))
            context.addLine(to: CGPoint(x: endPoint - 4, y: currentPlayY))
            context.strokePath()
            
            context.beginPath()
            context.setStrokeColor(UIColor.black.cgColor)
            context.move(to: CGPoint(x: endPoint - 4, y: currentPlayY))
            context.addLine(to: CGPoint(x: endPoint, y: currentPlayY))
            context.strokePath()
            
            currentPoint = endPoint
        } else {
            let endPoint: CGFloat = max(60, awayCurrentPoint - (yards * 3.0 * 2.0))
            context.setStrokeColor(awayTeamColor.cgColor)
            context.setLineWidth(10.0)
            
            context.beginPath()
            context.move(to: CGPoint(x: awayCurrentPoint, y: currentPlayY))
            context.addLine(to: CGPoint(x: endPoint + 4, y: currentPlayY))
            context.strokePath()
            
            context.beginPath()
            context.setStrokeColor(UIColor.black.cgColor)
            context.move(to: CGPoint(x: endPoint + 4, y: currentPlayY))
            context.addLine(to: CGPoint(x: endPoint, y: currentPlayY))
            context.strokePath()
            
            awayCurrentPoint = endPoint
        }
        currentPlayY += 12.0
    }
    
    public func addNewPlay(yards: CGFloat, team: FFTeam) {
        let newPlay: Dictionary<String, CGFloat> = [
            "yards" : yards
        ]
        var recentDriveDict: [FFTeam : [Dictionary<String, CGFloat>]] = driveList.last!
        var recentDrivePlays: [Dictionary<String, CGFloat>] = recentDriveDict[team]!
        recentDrivePlays.append(newPlay)
        recentDriveDict[team] = recentDrivePlays
        driveList[driveList.count - 1] = recentDriveDict
    }
    
    public func updateField() {
        currentPoint = startPoint
        currentPlayY = startPlayY
        awayCurrentPoint = awayStartPoint
        setNeedsDisplay()
    }
    
    public func yardsToGo(team: FFTeam) -> CGFloat {
        if (team == FFTeam.Home) {
            return (660.0 - currentPoint) / 2.0 / 3.0;
        } else {
            return (660.0 - awayCurrentPoint) / 2.0 / 3.0;
        }
    }
    
    private func drawFirstDownLine(context: CGContext, yardLine: CGFloat) {
        context.beginPath()
        context.move(to: CGPoint(x: yardLine * 2.0 * 3.0 + 60.0, y: 0))
        context.addLine(to: CGPoint(x: yardLine * 2.0 * 3.0 + 60.0, y: 300))
        context.setStrokeColor(UIColor.yellow.cgColor)
        context.setLineWidth(2.0)
        context.strokePath()
    }
    
    public func drawFirstDownLine(yardLine: CGFloat) {
        let context = UIGraphicsGetCurrentContext()
        drawFirstDownLine(context: context!, yardLine: yardLine)
    }
    
    private func setStartingPoint(start: CGFloat, team: FFTeam) {
        print(start)
        if (team == FFTeam.Home) {
            startPoint = start * 2.0 * 3.0 + 60.0
            currentPoint = start * 2.0 * 3.0 + 60.0
        } else {
            awayStartPoint = 660 - (start * 2.0 * 3.0)
            awayCurrentPoint = 660 - (start * 2.0 * 3.0)
        }
    }
    
    public func startNewDrive(start: CGFloat, team: FFTeam) {
        teamWithBall = team
        driveList.append([team: [["start" : start]]])
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        
        for i in 0...11 {
            drawYardLine(loc: 60.0 + 60.0 * CGFloat(i), context: context!)
        }
        
        fillEndZones(context: context!)
        for drive in driveList {
            print(drive)
            for item in drive {
                let team: FFTeam = item.key
                let plays: [Dictionary<String, CGFloat>] = item.value
                for play in plays {
                    if (play.keys.contains("yards")) {
                        markPlay(context: context!, yards: play["yards"]!, team: team)
                    } else {
                        setStartingPoint(start: play["start"]!, team: team)
                    }
                }
            }
        }
    }
}

var field: FootballField = FootballField()
// drive 1 by home
field.startNewDrive(start: 25, team: FFTeam.Home)
field.addNewPlay(yards: 20.0, team: FFTeam.Home)
field.addNewPlay(yards: -5, team: FFTeam.Home)
field.addNewPlay(yards: 40, team: FFTeam.Home)

// drive 2 by away
field.startNewDrive(start: 25.0, team: FFTeam.Away)
field.addNewPlay(yards: 20.0, team: FFTeam.Away)
field.addNewPlay(yards: -5, team: FFTeam.Away)
field.addNewPlay(yards: 40, team: FFTeam.Away)

// drive 3 by home
field.startNewDrive(start: 20.0, team: FFTeam.Home)
field.addNewPlay(yards: 10.0, team: FFTeam.Home)
field.addNewPlay(yards: -2, team: FFTeam.Home)
field.addNewPlay(yards: 20, team: FFTeam.Home)

// drive 4 by away
field.startNewDrive(start: 20.0, team: FFTeam.Away)
field.addNewPlay(yards: 10.0, team: FFTeam.Away)
field.addNewPlay(yards: -2, team: FFTeam.Away)
field.addNewPlay(yards: 20, team: FFTeam.Away)

// drive 5 by home
field.startNewDrive(start: 50.0, team: FFTeam.Home)
field.addNewPlay(yards: 15.0, team: FFTeam.Home)
field.addNewPlay(yards: -3, team: FFTeam.Home)
field.addNewPlay(yards: 7, team: FFTeam.Home)

// drive 6 by away
field.startNewDrive(start: 50.0, team: FFTeam.Away)
field.addNewPlay(yards: 15.0, team: FFTeam.Away)
field.addNewPlay(yards: -3, team: FFTeam.Away)
field.addNewPlay(yards: 7, team: FFTeam.Away)

// drive 7 by home
field.startNewDrive(start: 10.0, team: FFTeam.Home)
field.addNewPlay(yards: 5.0, team: FFTeam.Home)
field.addNewPlay(yards: -10, team: FFTeam.Home)
field.addNewPlay(yards: 70, team: FFTeam.Home)

// drive 8 by away
field.startNewDrive(start: 10.0, team: FFTeam.Away)
field.addNewPlay(yards: 5.0, team: FFTeam.Away)
field.addNewPlay(yards: -10, team: FFTeam.Away)
field.addNewPlay(yards: 70, team: FFTeam.Away)

field.updateField()
