//
//  Constants.swift
//  ARJoystick
//
//  Created by Alex Nagy on 27/07/2018.
//  Copyright © 2018 Alex Nagy. All rights reserved.
//

import UIKit

//var joystickNotificationName = NSNotification.Name("joystickNotificationName")
//let joystickVelocityMultiplier: CGFloat = 0.00005

struct Constants {
  static let focusScenePath = "art.scnassets/Models/FocusScene.scn"
  static let floorScenePath = "art.scnassets/Models/Floor.scn"
  static let surfaceTexturePath = "art.scnassets/Textures/Surface.png"
  
  static let heroScenePath = "art.scnassets/Models/Hero.scn"
  
  static let focusNodeName = "focus"
  static let cursorNodeName = "cursor"
  static let floorNodeName = "floor"
  
  static let heroNodeName = "hero"
  
  static let detectSurfaceStatusMessage = "Scan entire surface...Hit 'Start' when ready!"
  static let pointToSurfaceStatusMessage = "Point at designated surface first!"
  static let readyToPlayStatusMessage = "Scan entire surface...Hit 'Start' when ready!"
  static let noSuchGameStateStatusMessage = "Error: No such game state!"
  
  static let notAvailableTrackingStatusMessage = "Tacking: Not available!"
  static let normalTrackingStatusMessage = "Tracking: All Good!"
  static let excessiveMotionTrackingStatusMessage = "Tracking: Limited due to excessive motion!"
  static let insufficientFeaturesTrackingStatusMessage = "Tracking: Limited due to insufficient features!"
  static let relocalizingTrackingStatusMessage = "Tracking: Relocalizing..."
  static let initializingTrackingStatusMessage = "Tracking: Initializing..."
  
  static let sessionDidFailWithErrorStatusMessage = "AR Session Failure: "
  static let sessionWasInterruptedStatusMessage = "AR Session Was Interrupted!"
  static let sessionInterruptionEndedStatusMessage = "AR Session Failure: "
  
  static let arWorldTrackingNotSupportedTrackingStatusMessage = "AR World Tracking Not Supported!"
  
}
