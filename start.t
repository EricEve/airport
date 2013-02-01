#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

versionInfo: GameID
    IFID = 'bcb7d5c4-81ee-30b0-5aec-7672b10e2cd6' 
    name = 'Airport'
    byline = 'by Michael Roberts (and Eric Eve)'
    htmlByline = 'by <a href="mailto:an.author@somemail.com">
                  A.N. Author</a>'
    version = '1'
    authorEmail = 'A.N. Author <an.author@somemail.com>'
    desc = 'Your blurb here.'
    htmlDesc = 'Your blurb here.'    
    
;

gameMain: GameMainDef
    /* Define the initial player character; this is compulsory */
    initialPlayerChar = me
    paraBrksBtwnSubcontents = nil
    
    showIntro()
    {
       "<font size=+2><b>Airport</b></font>\b
       They're out to get you. No, they really are --- <q>they</q> being the
       local drug barons. You've just got the evidence that will put them behind
       bars for the rest of the century, and now you're desperate to leave with
       it while you still can, since El Diablo and his henchmen will be equally
       desperate to stop you --- for good. They've pursued you as far as the
       airport and now your only hope is to get the first plane out of here.\b";
    }       
;


/* The starting location; this can be called anything you like */

terminal: Room 'Terminal' 'terminal'   
   "You are in the airport's main terminal. To the east, you see some ticket
   counters; to the north is the main concourse. The main exit to the city and
   car parks lies directly to the south. "
    east = ticketArea
    north = securityGate
    south 
    { 
        "If you go back out that way you're likely to run straight into a hail
        of bullets. ";
    }
        
    out asExit(south)
;

/* 
 *   The player character object. This doesn't have to be called me, but me is a
 *   convenient name. If you change it to something else, rememember to change
 *   gameMain.initialPlayerChar accordingly.
 */

+ me: Thing 'you'   
    "Secret agents are normally meant to be well equipped, but your quick
    getaway just now meant you had to leave just about everything behind
    except what you're wearing, and that's not much. You couldn't even go back
    to pick up your wallet or your credit card. "
    isFixed = true    
    proper = true
    ownsContents = true
    person = 2   
    contType = Carrier    
;


ticketArea: Room 'Ticket Area' 'ticket area'
    "You are in the ticket counter area. Ticket counters
    line the north wall; so many people are waiting in line that 
    you're sure you'll never manage to get to an agent. The main
    terminal is back to the west. "
    west = terminal
;

+ counter: Surface, Fixture 'ticket counter; untended' 
     "The ticket counter runs round two sides of the area, staffed by too few
     hard-pressed clerks, while at least half of it is totally untended. "  
;

++ IDcard: Key 'an ID Card; identification poor; photo'     
    "According to what's on the front it apparently belongs to one Antonio
    Velaquez. Fortunately the accompanying photo is so poor it could be of
    almost anyone, even you. A magnetic stripe runs down the back. "
    
    actualLockList = [securityDoor]
    plausibleLockList = [securityDoor]
    
    bulk = 1
    
    dobjFor(ShowTo)   {  preCond = [objHeld]   }
;

+++ Fixture 'magnetic stripe; mag metallic brown; strip'
    "It's a brown metallic strip running down the reverse of the card. "
    
    cannotTakeMsg = 'It would be pretty hard to peel the magnetic stripe away
        from the card, and it would almost certainly render the card useless if
        you did so. '
;

+ Decoration 'people; of[prep]; line queue tourists businesspeople; them'
    "A motley collection of tourists and businesspeople, so far as you can
    tell, many of them looking increasingly frustrated at the length of the
    queue. "
  
    notImportantMsg = 'You don\'t have time to bother with them, and you don\'t
        want to risk drawing attention to yourself. '
;

+ Decoration 'booking clerks; ticket male female hard-pressed hard pressed
    ; men women agents agent clerk; them'
    "The booking clerks, male and female in roughly equal numbers, all seem
    equally lacking in any sense of urgency to service the ever-lengthening
    queues. "
    
    notImportantMsg = 'Unfortunately you can\'t get anywhere near any of them. '
;


securityGate: Room 'Security Gate' 'security gate'
    "You are at the security gate leading into the main
    concourse and boarding gate areas. The concourse lies to the
    north, through a metal detector. The terminal is back to the
    south. "
    north = metalDetector
    south = terminal
;

+ metalDetector: Passage 'metal detector; crude; frame'
    "The metal detector is little more than a crude metal frame, just large
    enough to step through, with a power cable trailing across the floor. "
    destination = concourse
    
    isOn = (powerSwitch.isOn == true)
    
    canTravelerPass(traveler)
    {
        return !isOn || !IDcard.isIn(traveler);
    }
    
    explainTravelBarrier(traveler)
    {
        "The metal detector buzzes furiously as you pass through it. The
        security guard beckons you back immediately, with a pointed
        tap of his holstered pistol. After a brisk search, he discovers the ID
        card and takes it off you with a disapproving shake of his head,
        before handing it to a colleague who walks off with it. <.reveal
        card-confiscated> ";
        
        IDcard.moveInto(counter);
    }
    
    travelDesc()
    {
        "You pass through the metal detector without incident. ";
        
        if(takeover.startedAt == nil)
            announcementObj.start();
    }
;

+ powerCable: Decoration 'power cable; trailing; cord wire wires'
    "The cable trails rather slackly from one side of the metal detector across
    the floor and then out of sight behind a desk over to the right on the far
    side. You're not sure it's an arrangement that would find favour with health
    and safety inspectors back home, but it appears to do the job. "
    
    notImportantMsg = 'You\'re morally certain the security guard won\'t let you
        get anywhere near it. '
;


concourse: Room 'Concourse' 'concourse; long; hallway'
    "You are in a long hallway connecting the terminal
    building (which lies to the south) to the boarding gates (which are
    to the north). To the east is a snack bar, and a door leads west.
    Next to the door on the west in a small slot that looks like it
    accepts magnetic ID cards to operate the door lock. "
    
    north = gateArea
    south = securityGate
    east = snackBar
    west = securityDoor
;

+ securityDoor: Door 'door'
    "It's clearly marked PRIVADO and is <<if isOpen>> currently open<<else>>
    firmly closed<<end>>. "
    
    otherSide = concourseDoor
    
    lockability = lockableWithKey    
    isLocked = true    
    
    makeLocked(stat)
    {
        inherited(stat);
        if(stat == nil)
        {
            makeOpen(true);
            "The door pops open a fraction. ";
        }
    }
    
    makeOpen(stat)
    {
        inherited(stat);
        if(stat == nil)
        {
            makeLocked(true);
            "You hear a slight click as the door locks itself again. ";
        }
        
    }
;

+ cardslot: Fixture 'card slot'  
    "The slot appears to accept special ID cards with magnetic encoding. If you
    had an appropriate ID card, you could put it in the slot to open the door. "
    
    cannotPutInMsg = '{The subj dobj} {does}n\'t look as if {he dobj}{\'s} meant
        to fit in there. '
;

Doer 'put IDcard in cardslot'
    execAction(c)
    {
        redirect(c, UnlockWith, dobj: securityDoor, iobj: IDcard);
    }
;

snackBar: Room 'Snack Bar' 'snack bar'
    "The snack bar seems to be full of passengers jostling one another to get at
    the serving counter, or consuming their homogenized snacks at the crowded
    tables, though for some reason, one table remains free. To the west lies
    the relative calm of the concourse. "
    
    west = concourse
    out asExit(west)
;
    
+ Decoration 'passengers; ; locals americans people; them'
    "From the sound of their voices they seem to be a mixture of Americans and
    locals, all alike casually dressed<< if darkSuits.isIn(location)>> -- except
    for a handful of men in dark suits<<end>>. "
;

+ darkSuits: Decoration 'men[n] in[prep] dark suits; sinister senior; 
    lieutenants; them'    
    "Even to the untrained eye they'd probably look pretty sinister. To you they
    look worse than that; you're pretty sure they're some of El Dialo's senior
    lieutenants. Fortunately they seem too absorbed in their own discussion at
    the other end of the room right now to notice you. "
    
    notImportantMsg = 'Right now, you don\'t want to go near any of them. '
;

+ Decoration 'crowded tables;;;them'
    
;

+ Surface, Fixture 'free table; small round'
    "Perhaps the reason this small round table remains free is that there are no
    chairs round it; presumably they've all been borrowed by passengers at the
    other tables. "
;

++ newspaper: Thing 'newspaper; narcosia; paper herald'
    "It's a copy of the latest edition of the <i>Narcosia Herald</i>. "
    
    readDesc = '''A quick skim of the paper reveals nothing unusual for this part
        of the world. Yet another government minister is denying charges of
        corruption, money-laundering and enjoying a surfeit of mistresses whose
        combined age would only just add up to his. Only eighteen gang-related
        killings were committed on the streets of Narcosia yesterday, making it
        an unusually quiet day in the capital. The President had defended
        spending another twenty billion trillion terapesos (about half a billion
        dollars) on yet another grand extension to his palace on the grounds
        that it vital to national prestige and will surely attract the kind of
        foreign investment that will lift the poorest eighty per cent of the
        nation slightly closer to the breadline. The defence minister is
        congratulated for his acumen in buying up stock in Polemicorp
        International before placing a large arms order with them; the finance
        minister is quoted as saying that this is just the kind of
        entrepreneurial spirit the country needs. The police have once again
        failed to make any arrests of the enterprising drug barons who are
        largely funding their pension pots. All in all, it's business as usual
        -- except for some editorial speculation that El Diablo may be planning
        something <i>big</i>, but you knew that anyway; that's what brought you
        to this godforsaken hell-hole. '''
    
    hiddenIn = [ticket]
    
    revealOnMove()
    {
        
        if(hiddenIn.length > 0)
        {
            "As you pick up the newspaper <<list of hiddenIn>> {prev} {falls}
            out of it and {lands} on the floor. ";
            
            moveHidden(&hiddenIn, getOutermostRoom);
        }
    }
    
    lookInMsg = (readDesc)
    
    bulk = 4
;

ticket: Thing 'ticket'
    "It's a ticket for flight TI 179 to Buenos Aires. "
    
    readDesc = (desc)
    specialDesc = "A ticket lies on the ground. "
    useSpecialDesc = (location == getOutermostRoom)
    
    bulk = 1
    
    dobjFor(Take)
    {
        action()
        {
            inherited;
            ticketAchievement.awardPointsOnce();
        }   
    }
;

securityArea: Room 'Security Area' 'security area'
    "This somewhat bare room seems to be lobby for other areas. There are exits
    south and west, while the way out back to the concourse lies through the
    door to the east. "
        
    east = concourseDoor
    south = lounge
    west = securityCentre
    out asExit(east)
    
;

+ concourseDoor: Door 'door'
    "It's currently <<if isOpen>>open <<else>>closed<<end>>. "
    
    otherSide = securityDoor
;

lounge: Room 'Pilot\'s Lounge' 'pilot\'s lounge'
    "Even if the somewhat faded decor of this room didn't suggest that it was
    meant to be some sort of relaxation area, this is plain enough from the long
    settee that runs along one wall and the scattering of easy chairs. The only
    way out is to the north. "
    
    north = securityArea
    out asExit(north)
;

+ suitcase: Thing 'suitcase;;case' 
    "It's a black suitcase with a combination lock and a prominent sticker
    bearing a French tricolor and the slogan <q>Vive la revolution
    francaise!</q>. "
    initSpecialDesc = "A suitcase stands neatly placed next to the settee. "  
    
    bulk = 8
    
    remapIn: SubComponent
    {
        isOpenable = true
        lockability = indirectLockable
        isLocked = true
        bulkCapacity = 8
        indirectLockableMsg = 'You\'ll have to use the combination lock for
            that. '
    }
;
    

++ Fixture 'sticker; prominent french; tricolor'
    "The sticker is prominently marked with a tricolor and bears the slogan
    <q>Vive la revolution francaise!</q> &mdash; Long Live the French
    Revolution! "  
    
    readDesc = (desc)
;

++ comboLock: Fixture 'combination lock'
    "The combination lock consists of four small brass wheels, each of which
    can be turned to any number between 0 and 9. They're currently showing
    the combination <<currentCombo>>."
    
    currentCombo = (wheel1.curSetting + wheel2.curSetting + wheel3.curSetting +
                    wheel4.curSetting)
    
    correctCombo = '1789'
    
    checkCombo()
    {
        if(currentCombo == correctCombo)
        {
            reportAfter('You fancy you hear a slight click from the lock. ');
            location.remapIn.makeLocked(nil);            
        }
        else
            location.remapIn.makeLocked(true);
    }
    
;



+++ wheel1: ComboWheel 'first wheel; small brass 1'
    curSetting = '3'
    listOrder = 1
;

+++ wheel2: ComboWheel 'second wheel; small brass 2'
    curSetting = '5'
    listOrder = 2
;

+++ wheel3: ComboWheel 'third wheel; small brass 3'
    curSetting = '9'
    listOrder = 3
;

+++ wheel4: ComboWheel 'fourth wheel; small brass 4'
    curSetting = '2'
    listOrder = 4
;


++ uniform: Wearable 'pilot\'s uniform; timo large'  
    "It's a uniform for a Timo Airlines pilot. It's a little large for you, but
    <<if wornBy == me>> it's not too bad a f<<else>>you could probably wear
    <<end>>it. "
    
    bulk = 6
    subLocation = &remapIn
    
    dobjFor(Doff)
    {
        check()
        {
            "After going to all that trouble to get this uniform you're in no
            hurry to take it off. ";
        }
    }
;

+ Decoration 'long settee;;sofa'
;

+ Decoration 'easy chairs;;;them'
;

class ComboWheel: NumberedDial
    desc = "It's a small brass wheel that can be turned to any number between 0
        and 9, and is currently at <<curSetting>>. "
    
    maxSetting = 9
    
    cannotTakeMsg = 'You can\'t; it\'s part of the combination lock. '
    
    makeSetting(val)
    {
        inherited(val);
        location.checkCombo();
    }
;


securityCentre: Room 'Security Centre' 'security centre'
    "Judging by the monitors on the walls, this must be some sort of security
    centre. Otherwise the room is mostly bare apart from the utilitarian desk
    located somewhere in the middle. The only way out is to the east. "
    
    east = securityArea
    out asExit(east)
;

+ Decoration 'security monitors; blank; screens ;them'
    "They're all blank; either they're switched off or they're not working. "
    
    notImportantMsg = 'You really don\'t have time to play around with the
        monitors. '
;

+ desk: Heavy 'desk; utilitarian metal'
    "It's a utilitarian metal desk with a single drawer. "
    
    remapIn = drawer
    remapOn: SubComponent { }    
;

++ drawer: Fixture, OpenableContainer 'drawer'
    
    bulkCapacity = 5
    
    cannotTakeMsg = 'The drawer is part of the desk. '
;

+++ notebook: Thing 'notebook; little green book; writing'
    "It's just a little green book with writing in it. "
    
    readDesc = "It turns to be full of lots of sets of random-looking
        characters, all crossed out apart from the last, which reads
        <<password>>. "

    password = 'B49qJt0'
    
    dobjFor(Open) asDobjFor(Read)
;

++ computer: Heavy, Consultable 'computer;; pc keyboard screen'
    "The computer is currently <<if isOn>>on and <<if passwordEntered>> ready
    for use<<else>> waiting for you to enter a password<<end>> <<else>>
    off<<end>>."
    
    specialDesc = "A computer sits squarely on top of the desk. "
    subLocation = &remapOn
    
    isSwitchable = true
    
    makeOn(stat)
    {
        inherited(stat);
        if(stat)
        {
            "The computer rapidly boots up and displays a screen asking you
            to enter a password. ";
            passwordEntered = nil;
        }
        else
            "The computer rapidly powers down. ";
    }
    
    passwordEntered = nil
    
    dobjFor(ConsultAbout)
    {
        check()
        {
            if(!isOn)
                "You can't do that until the computer is switched on. ";
            else if(!passwordEntered)
                "You'll need to enter a password first. ";
        }
    }
    
    isEnterOnable = true
    
    dobjFor(EnterOn)
    {
        check()
        {
            if(passwordEntered)
                "You've already entered the password; this is no time to start
                playing around with random commands. ";
        }
        
        action()
        {
            if(gLiteral == notebook.password)
            {
                "The computer displays WELCOME for a few seconds, and then
                clears to allow you to enter commands. ";
                
                passwordEntered  = true;
            }
            else
                "The computer flashes PASSWORD NOT RECOGNIZED at you. ";
                
        }
    }
 
    dobjFor(TypeOn) asDobjFor(EnterOn)
    
;

+++ ConsultTopic @tFrenchRevolution
    "According to Wikipedia, the French Revolution began in 1789. The article
    goes on to tell you quite a bit more about it, but you don't have time to
    read it all now. "
;

+++ ConsultTopic @tFlightDepartures
    "So far as you can tell from the information displayed, Timo Flight 179 to
    Buenos Aires is likely to be the only one out of here for the next several
    hours, all the others being delayed for a variety of annoying reasons such
    as strikes, illness and inclement weather. "
;

+++ DefaultConsultTopic
    "That's of no immediate interest to you right now; you have more urgent
    things to attend to. "
;

tFrenchRevolution: Topic 'french revolution';
tFlightDepartures: Topic '() flight departures; plane; times';
tPilot: Topic 'pilot';
tDoingTonight: Topic 'she\'s doing tonight; she is you are';
tEnjoyWork: Topic 'she enjoys her work; you enjoy your like likes; job';

VerbRule(GoogleFor)
    'google' ('for'|) topicIobj 'on' singleDobj
    : VerbProduction
    action = ConsultAbout
    
    verbPhrase = 'look/looking up (what) (in what)'
    missingQ = 'what do you want to google that on;what do you want to google'
    dobjReply = singleNoun
;

ticketAchievement: Achievement +10 "finding the plane ticket";
boardingAchievement: Achievement +10 "boarding the plane";
escapeAchievement: Achievement +10 "escaping Pablo Cortez";
powerAchievement: Achievement +10 "cutting the power to the metal detector";
securityAchievement: Achievement +10 "opening the security door";
suitcaseAchievement: Achievement +15 "opening the suitcase";
uniformAchievement: Achievement +10 "putting on the pilot's uniform";
cockpitAchievement: Achievement +10 "entering the cockpit";
flyingAchievement: Achievement +15 "flying the plane";


TopHintMenu;

+ Goal 'Where can I find a plane ticket?'
    [
        'You don\'t have the wherewithal to buy one. ',
        'But perhaps someone else may have mislaid theirs. ',
        'If you hunt around a bit you may find it. ',
        'Where might people go in an airport when awaiting a flight? ',
        'Especially if they\'re a bit peckish. ',
        'Have you visited the snack bar? ',
        'Has anything been left lying around there? ',
        'Try taking a closer look at that newspaper. '
    ]
    
    openWhenSeen = angela
    closeWhenAchieved = ticketAchievement
;

+ Goal 'How do I get the ID Card through the metal detector?'
    [
        'Did you take a good look at the ID Card? ',
        'Have you found it again after it was confiscated? ',
        'If not, where do you think the other security guard may have taken it?
        ',
        'Might it have been left for its owner to collect? ',
        'Might that be why it was left there in the first place? ',
        'What might the magnetic stripe on the card do the metal detector? ',
        'How closely have you examined the metal detector? ',
        'What does the power cable leading to the metal detector suggest? ',
        powerHint
        
    ]

    openWhenRevealed = 'card-confiscated'
    closeWhenAchieved = powerAchievement
;

++ powerHint: Hint 
    'Might there be a way of cutting the power to the metal detector? '
    [powerGoal]
;

+ powerGoal: Goal 'How do I cut the power to the metal detector? '
    [
        'Which direction does the power cable lead in? ',
        'What else lies in roughly that direction? ',
        'What lies beyond the metal detector? ',
        'Where might the power be controlled from? ',
        maintenanceHint
    ]
    
    closeWhenAchieved = powerAchievement
;

++ maintenanceHint: Hint
    'What might the Maintenance Room be for? '
    [maintenanceGoal]
;

+ maintenanceGoal: Goal 'How do I open the door to the Maintenance Room?'
    [
        'What\'s preventing the door from being opened? ',
        'Who might have the the key to it? ',
        'What sort of places might such a person visit in his work? ',
        'Where might he clean? ',
        'Where might you find a bathroom or toilet? ',
        'Could there be one aboard the plane? '    
    ]
    openWhenRevealed = 'maintenance-door-locked'
    closeWhenSeen = maintenanceRoom
;

+ Goal 'Where can I find the power switch for the metal detector?'
    [
        'Which room might you expect to find it in? ',
        'What can you see in that room? ',
        'You are looking in the Maintenance Room, aren\'t you? ',
        'What might be in those cabinets? ',
        'Where might someone hide the cabinet key? ',
        'What\'s on top of the shorter cabinet? ',
        'What might be under the pot plant? ',
        'What\'s inside the shorter cabinet? '
    ]
    
    openWhenTrue = maintenanceRoom.seen && gRevealed('card-confiscated') 
    && (powerCable.examined || powerGoal.goalState == OpenGoal)
    
    closeWhenAchieved = powerAchievement
;