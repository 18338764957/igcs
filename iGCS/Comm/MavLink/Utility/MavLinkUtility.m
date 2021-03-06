//
//  MavLinkUtility.m
//  iGCS
//
//  Created by Claudio Natoli on 21/07/13.
//
//

#import "MavLinkUtility.h"
#import "GCSCraftModes.h"

@implementation MavLinkUtility


NSMutableDictionary *_missionItemMetadata;
NSDictionary *_ardupilotModes;

+ (void) initialize {
    if (self == [MavLinkUtility class]) {
        // Define the list of mission item meta-data
        _missionItemMetadata = [NSMutableDictionary dictionary];
        
        // NAV mission items
        _missionItemMetadata[@(MAV_CMD_NAV_WAYPOINT)] = @[[[MissionItemField alloc] initWithLabel:@"Altitude"
                                                                                         andUnits:GCSItemUnitMetres
                                                                                     andFieldType:GCSItemParamZ]];

        _missionItemMetadata[@(MAV_CMD_NAV_LOITER_UNLIM)] = @[[[MissionItemField alloc] initWithLabel:@"Altitude"
                                                                                             andUnits:GCSItemUnitMetres
                                                                                         andFieldType:GCSItemParamZ]];

        _missionItemMetadata[@(MAV_CMD_NAV_LOITER_TURNS)] = @[[[MissionItemField alloc] initWithLabel:@"Altitude"
                                                                                             andUnits:GCSItemUnitMetres
                                                                                         andFieldType:GCSItemParamZ],
                                                              [[MissionItemField alloc] initWithLabel:@"# Turns"
                                                                                         andFieldType:GCSItemParam1]];

        _missionItemMetadata[@(MAV_CMD_NAV_LOITER_TIME)] = @[[[MissionItemField alloc] initWithLabel:@"Altitude"
                                                                                            andUnits:GCSItemUnitMetres
                                                                                        andFieldType:GCSItemParamZ],
                                                             // FIXME: test this - older docs say (seconds*10), code suggests it is in seconds
                                                             [[MissionItemField alloc] initWithLabel:@"Time"
                                                                                            andUnits:GCSItemUnitSeconds
                                                                                        andFieldType:GCSItemParam1]];

        _missionItemMetadata[@(MAV_CMD_NAV_RETURN_TO_LAUNCH)] = @[[[MissionItemField alloc] initWithLabel:@"Altitude"
                                                                                                 andUnits:GCSItemUnitMetres
                                                                                             andFieldType:GCSItemParamZ]];

        _missionItemMetadata[@(MAV_CMD_NAV_LAND)] = @[[[MissionItemField alloc] initWithLabel:@"Altitude"
                                                                                     andUnits:GCSItemUnitMetres
                                                                                 andFieldType:GCSItemParamZ]];

        _missionItemMetadata[@(MAV_CMD_NAV_TAKEOFF)] = @[[[MissionItemField alloc] initWithLabel:@"Altitude"
                                                                                        andUnits:GCSItemUnitMetres
                                                                                    andFieldType:GCSItemParamZ],
                                                         [[MissionItemField alloc] initWithLabel:@"Takeoff Pitch"
                                                                                        andUnits:GCSItemUnitDegrees
                                                                                    andFieldType:GCSItemParam1]];
        
        // Conditional CMD mission items
        _missionItemMetadata[@(MAV_CMD_CONDITION_DELAY)] = @[[[MissionItemField alloc] initWithLabel:@"Time"
                                                                                            andUnits:GCSItemUnitSeconds
                                                                                        andFieldType:GCSItemParam3]];

        _missionItemMetadata[@(MAV_CMD_CONDITION_CHANGE_ALT)] = @[[[MissionItemField alloc] initWithLabel:@"Rate"
                                                                                                 andUnits:GCSItemUnitCentimetresPerSecond
                                                                                             andFieldType:GCSItemParam1],
                                                                  [[MissionItemField alloc] initWithLabel:@"Final Altitude"
                                                                                                 andUnits:GCSItemUnitMetres
                                                                                             andFieldType:GCSItemParam2]];

        _missionItemMetadata[@(MAV_CMD_CONDITION_DISTANCE)] = @[[[MissionItemField alloc] initWithLabel:@"Distance"
                                                                                               andUnits:GCSItemUnitMetres
                                                                                           andFieldType:GCSItemParam3]];
        
        // DO CMD mission items
        _missionItemMetadata[@(MAV_CMD_DO_JUMP)] = @[[[MissionItemField alloc] initWithLabel:@"Index" andFieldType:GCSItemParam1],
                                                     [[MissionItemField alloc] initWithLabel:@"Repeat Count" andFieldType:GCSItemParam3]];

        _missionItemMetadata[@(MAV_CMD_DO_CHANGE_SPEED)] = @[[[MissionItemField alloc] initWithLabel:@"Speed type"
                                                                                        andFieldType:GCSItemParam1],
                                                             [[MissionItemField alloc] initWithLabel:@"Speed"
                                                                                            andUnits:GCSItemUnitMetresPerSecond
                                                                                        andFieldType:GCSItemParam2],
                                                             [[MissionItemField alloc] initWithLabel:@"Throttle (%)"
                                                                                        andFieldType:GCSItemParam3]];
        
        /*
        // FIXME: review implementation of do_set_home - appears that lat/lon/alt are from x/y/z a(nd not param2/3/4 as per earlier doc)
        _missionItemMetadata[@(MAV_CMD_DO_SET_PARAMETER)] = @[[[MissionItemField alloc] initWithLabel:@"Use current" andFieldType:GCSItemParam1],
                                                              [[MissionItemField alloc] initWithLabel:@"Altitude"    andFieldType:GCSItemParam2],
                                                              [[MissionItemField alloc] initWithLabel:@"Latitude"    andFieldType:GCSItemParam3],
                                                              [[MissionItemField alloc] initWithLabel:@"Longitude"   andFieldType:GCSItemParam4]];
         
        
        _missionItemMetadata[@(MAV_CMD_DO_SET_PARAMETER)] = @[[[MissionItemField alloc] initWithLabel:@"Param #" andFieldType:GCSItemParam1],
                                                              [[MissionItemField alloc] initWithLabel:@"Param Value" andFieldType:GCSItemParam2]];
        */
         
        _missionItemMetadata[@(MAV_CMD_DO_SET_RELAY)] = @[[[MissionItemField alloc] initWithLabel:@"Relay #" andFieldType:GCSItemParam1],
                                                          [[MissionItemField alloc] initWithLabel:@"On/Off" andFieldType:GCSItemParam2]];

        _missionItemMetadata[@(MAV_CMD_DO_REPEAT_RELAY)] = @[[[MissionItemField alloc] initWithLabel:@"Relay #"
                                                                                        andFieldType:GCSItemParam1],
                                                             [[MissionItemField alloc] initWithLabel:@"Cycle count"
                                                                                        andFieldType:GCSItemParam2],
                                                             [[MissionItemField alloc] initWithLabel:@"Cycle time"
                                                                                            andUnits:GCSItemUnitSeconds
                                                                                        andFieldType:GCSItemParam3]];
        
        _missionItemMetadata[@(MAV_CMD_DO_SET_SERVO)] = @[[[MissionItemField alloc] initWithLabel:@"Servo # (5-8)" andFieldType:GCSItemParam1],
                                                          [[MissionItemField alloc] initWithLabel:@"On/Off" andFieldType:GCSItemParam2]];
        
        _missionItemMetadata[@(MAV_CMD_DO_REPEAT_SERVO)] = @[[[MissionItemField alloc] initWithLabel:@"Servo # (5-8)"
                                                                                        andFieldType:GCSItemParam1],
                                                             [[MissionItemField alloc] initWithLabel:@"Cycle count"
                                                                                        andFieldType:GCSItemParam2],
                                                             [[MissionItemField alloc] initWithLabel:@"Cycle time"
                                                                                            andUnits:GCSItemUnitSeconds
                                                                                        andFieldType:GCSItemParam3]];

        NSDictionary *apmPlaneCustomModes = @{@(APMPlaneManual): @"Manual",
                                              @(APMPlaneCircle): @"Circle",
                                              @(APMPlaneStabilize): @"Stabilize",
                                              @(APMPlaneFlyByWireA): @"FBW_A",
                                              @(APMPlaneFlyByWireB): @"FBW_B",
                                              @(APMPlaneFlyByWireC): @"FBW_C",
                                              @(APMPlaneAuto): @"Auto",
                                              @(APMPlaneRtl): @"RTL",
                                              @(APMPlaneLoiter): @"Loiter",
                                              @(APMPlaneTakeoff): @"Takeoff",
                                              @(APMPlaneLand): @"Land",
                                              @(APMPlaneGuided): @"Guided",
                                              @(APMPlaneInitialising): @"Initialising"};

        NSDictionary *apmCopterCustomModes = @{@(APMCopterStabilize): @"Stabilize",
                                               @(APMCopterAcro): @"Acro",
                                               @(APMCopterAltHold): @"AltHold",
                                               @(APMCopterAuto): @"Auto",
                                               @(APMCopterGuided): @"Guided",
                                               @(APMCopterLoiter): @"Loiter",
                                               @(APMCopterRtl): @"RTL",
                                               @(APMCopterCircle): @"Circle",
                                               @(APMCopterPosition): @"Position",
                                               @(APMCopterLand): @"Land",
                                               @(APMCopterOfLoiter): @"OfLoiter",
                                               @(APMCopterDrift): @"Drift",
                                               @(APMCopterSport): @"Sport"};

        _ardupilotModes = @{@(MAV_TYPE_FIXED_WING): apmPlaneCustomModes,
                            @(MAV_TYPE_TRICOPTER):  apmCopterCustomModes,
                            @(MAV_TYPE_QUADROTOR):  apmCopterCustomModes,
                            @(MAV_TYPE_HEXAROTOR):  apmCopterCustomModes,
                            @(MAV_TYPE_OCTOROTOR):  apmCopterCustomModes,
                            @(MAV_TYPE_HELICOPTER): apmCopterCustomModes};
    }
}

+ (NSString *) mavModeEnumToString:(enum MAV_MODE)mode {
    NSString *str = [NSString stringWithFormat:@""];
    if (mode & MAV_MODE_FLAG_TEST_ENABLED)          str = [str stringByAppendingString:@"Test "];
    if (mode & MAV_MODE_FLAG_AUTO_ENABLED)          str = [str stringByAppendingString:@"Auto "];
    if (mode & MAV_MODE_FLAG_GUIDED_ENABLED)        str = [str stringByAppendingString:@"Guided "];
    if (mode & MAV_MODE_FLAG_STABILIZE_ENABLED)     str = [str stringByAppendingString:@"Stabilize "];
    if (mode & MAV_MODE_FLAG_HIL_ENABLED)           str = [str stringByAppendingString:@"HIL "];
    if (mode & MAV_MODE_FLAG_MANUAL_INPUT_ENABLED)  str = [str stringByAppendingString:@"Manual "];
    if (mode & MAV_MODE_FLAG_CUSTOM_MODE_ENABLED)   str = [str stringByAppendingString:@"Custom "];
    if (!(mode & MAV_MODE_FLAG_SAFETY_ARMED))       str = [str stringByAppendingString:@"(Disarmed)"];
    return str;
}

+ (NSString *) mavStateEnumToString:(enum MAV_STATE)state {
    switch (state) {
        case MAV_STATE_UNINIT:      return @"Uninitialized";
        case MAV_STATE_BOOT:        return @"Boot";
        case MAV_STATE_CALIBRATING: return @"Calibrating";
        case MAV_STATE_STANDBY:     return @"Standby";
        case MAV_STATE_ACTIVE:      return @"Active";
        case MAV_STATE_CRITICAL:    return @"Critical";
        case MAV_STATE_EMERGENCY:   return @"Emergency";
        case MAV_STATE_POWEROFF:    return @"Power Off";
        case MAV_STATE_ENUM_END:    break;
    }
    return [NSString stringWithFormat:@"MAV_STATE (%d)", state];
}

+ (NSString *) mavCustomModeToString:(mavlink_heartbeat_t) heartbeat {
    
    NSString *modeName;
    
    // APMPlane Auto Pilot Modes
    if (heartbeat.autopilot == MAV_AUTOPILOT_ARDUPILOTMEGA) {
        modeName = _ardupilotModes[@(heartbeat.type)][@(heartbeat.custom_mode)];
    }
    //The ARDrone shows up as a MAV_AUTOPILOT_GENERIC
    //It also uses the system_status field for the moding instead of the custom_mode field
    if (heartbeat.autopilot == MAV_AUTOPILOT_GENERIC && heartbeat.type == MAV_TYPE_QUADROTOR) {
        modeName = [MavLinkUtility mavStateEnumToString:heartbeat.system_status];
    }
    
    return modeName ?: [NSString stringWithFormat:@"CUSTOM_MODE (%d)", heartbeat.custom_mode];
}

+ (NSArray *) supportedMissionItemTypes {
    return [[_missionItemMetadata allKeys] sortedArrayUsingSelector: @selector(compare:)];
}

+ (NSArray *) missionItemMetadataWith:(uint16_t)command {
    return _missionItemMetadata[@(command)];
}

+ (BOOL) isSupportedMissionItemType:(uint16_t)command {
    return ([MavLinkUtility missionItemMetadataWith:command] != nil);
}

@end
