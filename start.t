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
//    paraBrksBtwnSubcontents = nil
    
    showIntro()
    {
//        local obj = ticket;
//        gMessageParams(obj);
//        "{I} need {an obj}. ";
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
        card and takes it off you with a disapproving shake of his head. ";
        
        IDcard.moveInto(counter);
    }
    
    travelDesc()
    {
        "You pass through the metal detector without incident. ";
        
        if(takeover.startedAt == nil)
            announcementObj.start();
    }
;

+ Decoration 'power cable; trailing; cord wire wires'
    "The cable trails rather slackly from one side of the metal detector across
    the floor and then out of sight behind a desk. You're not sure it's an
    arrangement that would find favour with health and safety inspectors back
    home, but it appears to do the job. "
    
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
tFlightDepartures: Topic 'flight departures; plane; times';

VerbRule(GoogleFor)
    'google' ('for'|) topicIobj 'on' singleDobj
    : VerbProduction
    action = ConsultAbout
    
    verbPhrase = 'look/looking up (what) (in what)'
    missingQ = 'what do you want to google that on;what do you want to google'
    dobjReply = singleNoun
;