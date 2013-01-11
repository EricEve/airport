#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

planeRegion: Region
//    travelerLeaving(traveler, dest) { "You're about to leave the plane. "; }
//    travelerEntering(traveler, dest) 
//    { 
//        "You're about to enter the plane. ";
//        new Fuse(self, &edesc, 0);
//    }
//    edesc = "You've just boarded the plane. "
;

cockpit: Room 'Cockpit' 'cockpit'
    "The cockpit is quite small but has everything you might expect: a
    windscreen looking forward, a pilot's seat from which you can operate all
    the usual controls, and a door leading out aft. "
    aft = cabinDoor
    south asExit(aft)
    out asExit(aft)
    
    regions = [planeRegion]
;

+ cabinDoor: LockablePlaneDoor 'cabin door'
    otherSide = cockpitDoor
;

+ pilotSeat: Fixture, Platform 'pilot\'s seat;;chair'
        
    dobjFor(Enter) asDobjFor(Board)
    
    allowReachOut(obj)
    {
        return obj.isOrIsIn(controls);
    }
;

+ controls: Fixture 'controls;; instruments;them'
    "The instruments and controls of most immdiate interest to you are
    <<makeListStr(contents, &theName)>>. "
    
    checkReach(actor)
    {
        if(!actor.isIn(pilotSeat))
            "You really need to be sitting in the pilot's seat before you start
            operating the controls. ";
    }
;

++ controlColumn: Fixture 'control column;;stick'
    "It's basically a stick that can be pushed forward or pulled back, with a
    wheel attached at the top. It's currently <<positionDesc>>. "
    listOrder = 10
    
    position = 0
    
    positionDesc = ['pulled back', 'vertical', 'pushed forward'][position + 2]
    
    dobjFor(Push)
    {
        check()
        {
            if(position > 0)
                "It's already pushed forward as far as it will go. ";
        }
        
        action()
        {
            position++;
            "You push the control column so that it's now <<positionDesc>>. ";
        }
    }
    
    dobjFor(Pull)
    {
        check()
        {
            if(position < 0)
                "It's already pulled back as far as it will go. ";
        }
        
        action()
        {
            position--;
            "You pull the control column so that it's now <<positionDesc>>. ";
        }
    }
;

+++ wheel: Fixture 'wheel'
    "The wheel can be turned to port or starboard to steer the aircraft. It's
    currently <<angleDesc>>. "
    
    isTurnable = true
    angle = 0
    
    angleDesc()
    {
        switch(angle)
        {
        case -60:
            "hard to port";
            break;
        case -30:
            "slightly to port";
            break;
        case 0:
            "amidships";
            break;
        case 30:
            "slightly to starboard";
            break;
        case 60:
            "hard to starboard";
            break;
        }
    }
    
    dobjFor(TurnRight)
    {
        check()
        {
            if(angle >= 60)
                "It's already turned as far to starboard as it will go. ";
        }
        
        action()
        {
            angle += 30;
            "You turn the wheel 30 degrees to starboard so that it ends up
            <<angleDesc>>. ";
        }
    }
    
    dobjFor(TurnLeft)
    {
        check()
        {
            if(angle <= -60)
                "It's already turned as far to port as it will go. ";            
        }
        
        action()
        {
            angle -= 30;
            "You turn the wheel 30 degrees to port so that it ends up
            <<angleDesc>>. ";
        }
    }
    
    dobjFor(Push)
    {
        remap = controlColumn
    }
    
    dobjFor(Pull)
    {
        remap = controlColumn
    }
;

++ thrustLever: Settable, Lever 'thrust lever'
    "It's a lever that can be pushed forward or pulled back. It's currently
    <<settingDesc>>. "
    listOrder = 20
    
    settingDesc()
    {
        switch(curSetting)
        {
        case '0':
            return 'pulled all the way back to 0';
        case '5':
            return 'pushed all the way forward to 5';
        default:
            return 'in the <<curSetting>> position';
        }
    }
    
    curSetting = '0'
    minSetting = 0
    maxSetting = 5
    
    isValidSetting(val)
    {
        return delegated NumberedDial(val);
    }
    
    makeSetting(val)
    {
        local oldVal = curSetting;
        inherited(val);
        "You <<if oldVal < val>> push the thrust lever forward<<else>> pull the
        lever back<<end>> to <<curSetting>>. ";
        
        if(ignitionButton.isOn)
        {
            "The whine of the engine <<if oldVal < val>>increases <<else>>
            decreases<<end>> in pitch and volume<<if val=='0'>>, dying away to
            a barely perceptible whisper<<end>>. ";
        }
        
    }
    
    makePulled(stat)
    {        
        makeSetting(stat ? '0' : '5');
    }
    
    isPulled = (curSetting == '0')
    isPushed = (curSetting == '5')
;

++ ignitionButton: Button 'engine ignition button; big green'
    "It's a big green button. "
    listOrder = 30
    isOn = nil
    
    makePushed()
    {
        if(isOn)
            "The engines are already running. ";
        else
        {
            isOn = true;
            "The plane judders as the engines roar into life. ";
        }
    }
;

++ asi: Fixture 'airspeed indicator; air speed; numbers asi'
    "It's currently registering an airspeed of <<airspeed>> knots. Most of the
    numbers round the dial are marked in white, but 115 knots is marked in
    green. "
    listOrder = 40
    
    airspeed = 0
;

++ altimeter: Fixture 'altimeter'
    "It's currently indicating an altitude of <<altitude>> feet. "
    listOrder = 50
    
    altitude = 0
;

++ fuelGauge: Fixture 'fuel gauge'
    "It's currently registering full. "
    listOrder = 60
;

+ windscreen: Fixture 'windscreen;; window windshield'
    desc()
    {
        if(takeoff.isHappening)
            takeoffDesc();
        else
            "The light is starting to fade outside, but you can easily makeout
            the terminal off to the port side and the last-minute bustle of
            preparations around your plane. ";            
    }
    
    takeoffDesc()
    {
        local dt = takeoff.distanceTraveled/5;
        
        "It's now quite dark outside, but you can see the landing lights marking
        the course of the runway <<if asi.airspeed == 0>>stationery on either
        side<<else if asi.airspeed < 30>> moving slowly past <<else>> rushing
        past<<end>>. <<if dt < 10>> Virtually the whole length of the runway
        stretches ahead of you<<else if dt < 33>> Most of the runway still lies
        ahead<< else if dt < 67>> So far as you can judge only about half the
        runway still lies ahead<<else if dt < 85>> You're starting to run out of
        runway<<else>> You're nearly at the end of the runway<<end>>.";
    }
    
    
    dobjFor(LookThrough) asDobjFor(Examine)
;

+ terminalBuilding: Distant 'terminal building; shabby white large; structure'
    "It's a large white structure just off to port. In the fading light you
    can't really make out how shabby it actually looks. "
;

landingLights: Distant 'landing lights; red green;;them'
    "The red lights are to port and the greens ones to starboard. "
;

takeoff: Scene
    startsWhen = (ignitionButton.isOn == true)
    
    whenStarting()
    {
        "A few moments later a truck tows your plane away from the jetway, and
        following the instructions from the control tower, you taxi the plane to 
        the start of Runway 2 just as the sun finally disappears below the
        horizon. About a minute later, you are cleared for take-off. ";
        
        /* reset all controls to their initial positions */
        thrustLever.curSetting = '0';
        wheel.angle = 0;
        controlColumn.position = 0;
        
        /* close off the exit from the plane */
        
        planeFront.port = 'You can\'t leave the plane now it\'s left the jetway.
            ';
        
        landingLights.moveInto(cockpit);
        terminalBuilding.moveInto(nil);
    }
    
    /* The total distance traveled along the runway */
    distanceTraveled = 0
    
    eachTurn()
    {
        local oldSpeed = asi.airspeed;
        
        if(controlColumn.position < 0)
        {
            if(asi.airspeed >= 115)
            {
                "The aircraft leaves the ground and continues up into the sky,
                climbing rapidly above the city. Once you've gained enough
                height you turn the plane --- not south towards Bogota but north
                towards Miami. Hopefully those hoodlums back in passenger cabin
                won't notice, though, at least, not until it's far too late. You
                reach for the radio to call ahead and arrange a suitable
                reception committee, and then settle back in your seat, content
                with a job well done. ";
                
                finishGameMsg(ftVictory, [finishOptionUndo]);
            }
            else if(asi.airspeed > 90)
            {
                "The aircraft leaves the ground for a moment and then stalls,
                rapidly losing speed and bumping back down onto the runway. ";
                
                asi.airspeed -= 30;
            }
            else
                "The aircraft judders slightly but nothing else happens; it
                isn't traveling nearly fast enough to take off. ";
        }
        
        local thrust = toInteger(thrustLever.curSetting) * 400 - asi.airspeed;
        
        asi.airspeed += (thrust/100);
        
        if(asi.airspeed < 0)
            asi.airspeed = 0;
        
        distanceTraveled += ((asi.airspeed + oldSpeed)/2);        
       
        
        /* The following commented-out lines were for testing purposes only */
//         "The aircraft has covered <<distanceTraveled>>m and is now travelling at
//        <<asi.airspeed>> knots. ";   
        
        
        /* If we go too far, we run off the end of the runway */
        if(distanceTraveled > 500)
        {
            "The plane reaches the end of the runway, ploughs through the fences
            and crashes into some buildings. What happens after that you never
            know, but it seems a terribly destructive way to displose of a
            plane-load of hoodlums. ";
            
            finishGameMsg(ftDeath, [finishOptionUndo]);
        }
            
        
        /* 
         *   If we turn the wheel while the plane is moving along the runway,
         *   the results are likely to be catastrophic.
         */        
        
        if(wheel.angle != 0 && asi.airspeed > 0)
        {
            "The plane lurches off the <<if wheel.angle < 0>> port <<else>>
            starboard<<end>> side of the runway <<one of>>into the path of a
            taxying airliner <<or>> and smashes into a hangar <<or>> and
            collides with a stationary airliner <<or>> and runs into a group of
            sheds <<purely at random>> with predictably disastrous consequences.
            Fortunately, you won't be around to answer for your incompetence. ";
            
            finishGameMsg(ftDeath, [finishOptionUndo]);
        }
        
        /* 
         *   If nothing else dramatic has intervened, report what's happening to
         *   the speed.
         */
        
        if(asi.airspeed > oldSpeed && oldSpeed == 0)
            "The plane starts moving forward. ";
        else if (asi.airspeed > oldSpeed)
            "The plane continues to pick up speed. ";
        
        if(asi.airspeed < oldSpeed && asi.airspeed == 0)
            "The plane comes to a halt. ";
        else if(asi.airspeed < oldSpeed)
            "The plane is losing speed. ";
    }   
;


planeFront: Room 'Front of Plane' 'front[n] of the plane;;airplane aeroplane'
    "The main ailse comes to an end at the port exit of the plane, but continues
    aft past the seating. A little further forward is a door that <<unless
      me.hasSeen(cockpit)>>presumably<<end>> leads into the cockpit. "
    
    fore = cockpitDoor
    north asExit(fore)
    port = jetway
    west asExit(port)
    out asExit(port)
    aft = planeRear
    south asExit(aft)
    
    regions = [planeRegion]
;

+ cockpitDoor: PlaneDoor 'cockpit door'
    otherSide = cabinDoor
;


planeRear: Room 'Rear of Plane' 'rear[n] of the plane;;airplane aeroplane'
    "The main aisle continue forward to the front of the plane and aft to the
    bathroom between rows of red coloured seats. "
    fore: TravelConnector
    {
        destination = planeFront
        canTravelerPass(traveler)
        {
            return !takeover.isHappening || cleanerItemCount(traveler) > 3;
        }
        
        explainTravelBarrier(traveler)
        {       
            "You take a step forward towards the front of the plane, but ";
            
            switch(cleanerItemCount(traveler))
            {                
            case 0:
            case 1:
                "as you do so, you catch sight of Pablo Cortez, one of El
                Diablo's most ruthless henchmen, standing near the exit, so you
                take a hasty step back into the throng of passengers before he
                can recognize you, wondering how you might disguise yourself. ";   
                break;
            case 2:
                "you spot Pablo Cortez, El Diablo's evil lieutenant, standing
                by the exit looking increasingly impatient at the passengers'
                disorganized departure. You step back hastily, not at all
                sure that he'll mistake you for a cleaner. ";
                break;
            case 3:
                "at that moment Pablo Cortez, El Diablo's particularly nasty
                right-hand man, glances aft from the front of the plane, as if
                he's trying to place you. Maybe you aren't carrying quite enough
                to be mistaken as a cleaner, so you take a hasty step back. ";
                break;
                
            }
        }
        
        travelDesc = "Clutching the bucket and the garbage bag in such a way to
            hide as much as yourself as possible, you push your way through the
            passengers milling in the aisle, hoping to avoid Pablo Cortez's
            eye. If he catches you, you'll be dead before you can say <q>funeral
            expenses</q>! " 
        
        cleanerItemCount(traveler)
        {
            return traveler.allContents.countWhich(
                { o: o is in (bucket, sponge, garbageBag, brassKey) } );
                
        }
    }
    
    north asExit(fore)
    aft = bathroomDoor
    south asExit(aft)
    
    regions = [planeRegion]    
;

+ bathroomDoor: PlaneDoor 'bathroom door; loo toilet lavatory'
    otherSide = bathroomDoorInside
;

MultiLoc, Decoration 'seats; red; seating seat airline; them'
    "Like all airline seats, these ones look like they were designed for the
    average-sized person of a century and a half ago. "
    
    notImportantMsg = '<<if takeover.isHappening>>You can\'t get at seats for
        the press of passengers in the aisle<<else>>All the seats round here
        seem to be taken, so you\'d best leave them alone<<end>>. '
    
    locationList = [planeFront, planeRear]
;

airlinePassengers: MultiLoc, Decoration 'passengers;;men women; them'
    "<<if takeover.isHappening>>They seem confused and annoyed in equal
    measure<<else>>You sense an air of impatience about them, as if they're all
    wondering when the aircraft is finally going to leave<<end>>. "
    
    notImportantMsg = 'Better leave them alone; you don\'t want to draw
        attention to yourself. ' 
    
    locationList = [planeFront, planeRear]
    
    specialDesc = "The aisle is full of passengers trying to leave their seats,
        retrieve their luggage, and make their way to the front of the plane. "
    
    useSpecialDesc = (takeover.isHappening)  
    
;



bathroom: Room 'Bathroom' 'bathroom;;loo lavatory toilet wc cubicle'
    "The bathroom is just a tiny cubicle with all the standard fittings you'd
    expect. "
    
    fore = bathroomDoorInside
    north asExit(fore)
    out asExit(fore)    
    
    regions = [planeRegion] 
;

+ bathroomDoorInside: LockablePlaneDoor 'cabin door'
    otherSide = bathroomDoor
;

+ Decoration 'fittings; wash; washbasin basin taps faucets bowl; them'
     "At least the washbasin and the bowl look reasonably clean. "
    
    notImportantMsg = 'You have no need to make use of any of these facilities
        right now. '
;

+ bucket: Container 'bucket; plain yellow plastic; pail'
    "It's just a plain yellow plastic bucket. "
    initSpecialDesc = "Some cleaner seems to have left all his things here:
        <<list of location.listableContents.subset({x: x.moved == nil})>>. "
    
    bulk = 6
    bulkCapacity = 6
    
;

+ sponge: Thing 'sponge; turquoise'
    "It's a kind of turquoise colour. "
    
    bulk = 3
;

+ garbageBag: Container 'garbage bag; large green plastic rubbish; bag'
    "It's basically just a large green plastic bag. "
    
    bulk = (2 + getBulkWithin)    
    bulkCapacity = 10
;

+ brassKey: Key 'small brass key; yale'
    "It's just like all the other yale keys you've ever seen. "    
    
    actualLockList = [maintenanceRoomDoor, mrDoorOut]
    plausibleLockList = [maintenanceRoomDoor, mrDoorOut]
    
    bulk = 1
;

Doer 'go dir'
    execAction(c)
    {
        "Shipboard directions don't have much meaning here. ";
        abort;
    }
    
    direction = [portDir, starboardDir, foreDir, aftDir]
    when = (!me.isIn(planeRegion))
;


class PlaneDoor: Door 
    desc = "It's <<if isOpen>>open<<else>>closed<<end>>. "
    lockability = indirectLockable
    indirectLockableMsg = 'It looks like this door can only be locked and
        unlocked from the other side. '
;

class LockablePlaneDoor: Door
    desc = "It's currently <<if isOpen>>open<<else>>closed and <<if isLocked>>
        locked<<else>>unlocked<<end>><<end>>. "
    lockability = lockableWithoutKey
;

takeover: Scene
    startsWhen = (bathroom.visited)
    
    whenStarting()
    {
        "An annoucement comes over the intercom: <q>Due to scheduling problems,
        passengers are kindly requested to disembark from the aircraft and
        return to the airport lounge. Please remember to take all your personal
        belongings with you.</q>\b
        The announcement is immediately greeted by a chorus of groans from the
        cabin. ";   
        
        announcementObj.stop();
        disembarkingPassengers.moveInto(jetway);
        darkSuits.moveInto(nil);
    }
    
    endsWhen = (uniform.wornBy == me)
    
    whenEnding()
    {
        disembarkingPassengers.moveInto(nil);
        airlinePassengers.moveInto(nil);
        criminalPassengers.moveInto(planeFront);
    }
;

criminalPassengers: Decoration 'passengers; smart dark of[prep]; men gangsters
    suits lieutenants bunch people; them'
    "They may all be dressed in smart dark suits but you're well aware they're
    little more than a bunch of gangsters, the senior lieutenants of men like El
    Diablo who'd slit their own grandmothers' throats for a couple of pesos. "
    
    notImportantMsg = 'You really don\'t want to do anything that might make any
        of those people take any notice of you. '
    
    beforeTravel(traveler, connector)
    {
        if(traveler == me && connector == planeRear)
        {
            "You really don't want to call attention to yourself by walking past
            those passengers to the rear of the plane, since even the most
            simple-minded gansgter will think it odd it the pilot goes anywhere
            but the cockpit. ";
            
            exit;
        }
    }
;


disembarkingPassengers: Decoration 
    'disgruntled passengers; disembarking grumbing of[prep]; men women people
    stream throng; them'
    
    "Some of the passengers forced to disembark from the plane are standing
    around grumbling, and some are making their way back into the terminal,
    while others continue to emerge from the plane. "
    
    notImportantMsg = 'You don\'t have time for these people right now. '
;

Doer 'drop Thing'
    execAction(c)
    {
        "You'd better not start dropping things here; it might make Cortez
        notice you. ";
        exit;
    }
    
    where = planeFront
    during = takeover
;

VerbRule(PushForward)
    'push' multiDobj 'forward'
    | 'push' 'forward' 'on' multiDobj
    : VerbProduction
    action = Push
    verbPhrase = 'push/pushing forward (what)'
    missingQ = 'what do you want to push forward'
//    dobjReply = singleNoun
//    priority = 60

;

modify VerbRule(Pull)
    ('pull' multiDobj ( | 'back')) |
    'pull' 'back' 'on' multiDobj    
    : 
;

DefineTAction(TurnLeft)
;

DefineTAction(TurnRight)
;

VerbRule(TurnLeft)
    'turn' singleDobj (| 'to' (| 'the')) ('left' | 'port')
    : VerbProduction
    action = TurnLeft
    verbPhrase = 'turn/turning (what) left'
    missinqQ = 'what do you want to turn left'
    priority = 60
;

VerbRule(TurnRight)
    'turn' singleDobj (| 'to' (| 'the')) ('right' | 'starboard')
    : VerbProduction
    action = TurnRight
    verbPhrase = 'turn/turning (what) right'
    missinqQ = 'what do you want to turn right'
    priority = 60
;

modify Thing
    dobjFor(TurnLeft)
    {
        preCond = [touchObj]
        
        verify()
        {
            if(!isTurnable)
                illogical(cannotTurnMsg);
        }
                
        report()
        {
            "Turning <<gActionListStr>> to the left has no effect. ";
        }
        
    }
    
    dobjFor(TurnRight)
    {
        preCond = [touchObj]
        
        verify()
        {
            if(!isTurnable)
                illogical(cannotTurnMsg);
        }
        
        report()
        {
            "Turning <<gActionListStr>> to the right has no effect. ";
        }
        
    }
;

modify VerbRule(SetTo)
    ('set' | 'move' | 'push' | 'pull') singleDobj 'to' literalIobj
    :
;