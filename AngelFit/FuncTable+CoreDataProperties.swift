//
//  FuncTable+CoreDataProperties.swift
//  AngelFit
//
//  Created by YiGan on 22/11/2016.
//  Copyright © 2016 aiju_huangjing1. All rights reserved.
//

import Foundation
import CoreData


extension FuncTable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FuncTable> {
        return NSFetchRequest<FuncTable>(entityName: "FuncTable");
    }

    @NSManaged public var main_stepCalculation: Bool
    @NSManaged public var main_sleepMonitor: Bool
    @NSManaged public var main_singleSport: Bool
    @NSManaged public var main_realtimeData: Bool
    @NSManaged public var main_deviceUpdate: Bool
    @NSManaged public var main_heartRate: Bool
    @NSManaged public var main_ancs: Bool
    @NSManaged public var main_timeLine: Bool
    @NSManaged public var alarmCount: Int16
    @NSManaged public var alarmType_wakeUp: Bool
    @NSManaged public var alarmType_sleep: Bool
    @NSManaged public var alarmType_sport: Bool
    @NSManaged public var alarmType_medicine: Bool
    @NSManaged public var alarmType_dating: Bool
    @NSManaged public var alarmType_party: Bool
    @NSManaged public var alarmType_metting: Bool
    @NSManaged public var alarmType_custom: Bool
    @NSManaged public var control_takePhoto: Bool
    @NSManaged public var control_music: Bool
    @NSManaged public var call_calling: Bool
    @NSManaged public var call_callingContact: Bool
    @NSManaged public var call_callingNum: Bool
    @NSManaged public var notify_message: Bool
    @NSManaged public var notify_email: Bool
    @NSManaged public var notify_qq: Bool
    @NSManaged public var notify_weixin: Bool
    @NSManaged public var notify_sinaWeibo: Bool
    @NSManaged public var notify_facebook: Bool
    @NSManaged public var notify_twitter: Bool
    @NSManaged public var notify2_whatsapp: Bool
    @NSManaged public var notify2_message: Bool
    @NSManaged public var notify2_instagram: Bool
    @NSManaged public var notify2_linkedIn: Bool
    @NSManaged public var notify2_calendar: Bool
    @NSManaged public var notify2_skype: Bool
    @NSManaged public var notify2_alarmClock: Bool
    @NSManaged public var other_sedentariness: Bool
    @NSManaged public var other_antilost: Bool
    @NSManaged public var other_oneTouchCalling: Bool
    @NSManaged public var other_findPhone: Bool
    @NSManaged public var other_findDevice: Bool
    @NSManaged public var other_configDefault: Bool
    @NSManaged public var other_upHandGesture: Bool
    @NSManaged public var other_weather: Bool
    @NSManaged public var sms_tipInfoContact: Bool
    @NSManaged public var sms_tipInfoNum: Bool
    @NSManaged public var sms_tipInfoContent: Bool
    @NSManaged public var other2_staticHR: Bool
    @NSManaged public var other2_doNotDisturb: Bool
    @NSManaged public var other2_displayMode: Bool
    @NSManaged public var other2_heartRateMonitor: Bool
    @NSManaged public var other2_bilateralAntiLost: Bool
    @NSManaged public var other2_allAppNotice: Bool
    @NSManaged public var other2_flipScreen: Bool
    @NSManaged public var sport_walk: Bool
    @NSManaged public var sport_run: Bool
    @NSManaged public var sport_bike: Bool
    @NSManaged public var sport_foot: Bool
    @NSManaged public var sport_swim: Bool
    @NSManaged public var sport_climbing: Bool
    @NSManaged public var sport_badminton: Bool
    @NSManaged public var sport_other: Bool
    @NSManaged public var sport2_fitness: Bool
    @NSManaged public var sport2_spinning: Bool
    @NSManaged public var sport2_ellipsoid: Bool
    @NSManaged public var sport2_treadmill: Bool
    @NSManaged public var sport2_sitUp: Bool
    @NSManaged public var sport_pushUp: Bool
    @NSManaged public var sport2_dumbbell: Bool
    @NSManaged public var sport2_weightLifting: Bool
    @NSManaged public var sport3_bodybuildingExercise: Bool
    @NSManaged public var sport3_yoga: Bool
    @NSManaged public var sport3_ropeSkipping: Bool
    @NSManaged public var sport3_pingpang: Bool
    @NSManaged public var sport3_basketball: Bool
    @NSManaged public var sport3_football: Bool
    @NSManaged public var sport3_volleyball: Bool
    @NSManaged public var sport3_tennis: Bool
    @NSManaged public var sport4_golf: Bool
    @NSManaged public var sport4_baseball: Bool
    @NSManaged public var sport4_skiing: Bool
    @NSManaged public var sport4_rollerSkating: Bool
    @NSManaged public var sport4_dance: Bool
    @NSManaged public var main2_logIn: Bool

}
