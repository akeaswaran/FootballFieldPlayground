// FootballFieldPlayground: A Swift playground to test out building a football drive-tracker using UIView and CoreGraphics.
// Author: Akshay Easwaran <akeaswaran@me.com>
// Inspired by https://github.com/criscokid/Canvas-Field/blob/master/field.js
  
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
    // setup some private vars
    private var startPoint: CGFloat = 0.0
    private var currentPoint: CGFloat = 0.0
    private var startPlayY: CGFloat = 0.0
    private var currentPlayY: CGFloat = 0.0
    
    private var awayStartPoint: CGFloat = 660.0
    private var awayCurrentPoint: CGFloat = 660.0
    
    // these can be modified by the user
    public var homeTeamColor: UIColor = UIColor.blue
    public var awayTeamColor: UIColor = UIColor.red
    
    public var teamWithBall: FFTeam = FFTeam.Home
    
    // this is the main container of the drive data
    private var driveList: [Dictionary<FFTeam, [Dictionary<String, CGFloat>]>] = []
    
    // override the two init methods
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
    
    // Draws the white yard lines on the field
    private func drawYardLine(loc: CGFloat, context: CGContext) {
        context.beginPath()
        context.move(to: CGPoint(x: loc, y: 0))
        context.addLine(to: CGPoint(x: loc, y: 300))
        context.setStrokeColor(UIColor.white.cgColor)
        context.strokePath()
    }
    
    // Fills the end zones with the home and away colors
    private func fillEndZones(context: CGContext) {
        context.setFillColor(homeTeamColor.cgColor)
        context.fill(CGRect(x:0, y:0, width: 60, height:300))
        context.setFillColor(awayTeamColor.cgColor)
        context.fill(CGRect(x:660, y:0, width: 60, height:300))
    }
    
    // Draws a play bar starting from the current line of scrimmage to the new one after a given value of yards gained/lost
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
    
    // Public-facing interface for adding a play to an active drive
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
    
    // Redraws the field using the drive data
    public func updateField() {
        currentPoint = startPoint
        currentPlayY = startPlayY
        awayCurrentPoint = awayStartPoint
        setNeedsDisplay()
    }

    // Sets the drive's starting yard marker
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
    
    // Public facing interface to set the drive's starting yard marker
    public func startNewDrive(start: CGFloat, team: FFTeam) {
        teamWithBall = team
        driveList.append([team: [["start" : start]]])
    }
    
    // Actually does the drawing of the field.
    // We need to redraw the field after adding all of our plays/drives, so we kick off a draw in updateField() by calling setNeedsDisplay().
    // This method draws the yard lines and endzones first, then starts drawing the play bars drive-by-drive.
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

// Example usage

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

// redraw the field
field.updateField()
