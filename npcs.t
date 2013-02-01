#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

guard: Actor 'security guard; burly flab; man; him' @securityGate
    "He's a burly-looking fellow, though it's probably as much flab as muscle. "
    
    actorSpecialDesc = "A security guard stands by the metal detector, eyeing
        you suspiciously. "
    
    shouldNotAttackMsg = 'With your training you could probably overpower him
        easily enough, although he\'s armed and you\'re not, but that would
        probably result all the other airport security staff coming after you,
        which is a complication you could do without right now. '
;

+ AskTopic, StopEventList @tFlightDepartures
    [
        '<q>When\'s the next plane out of here?</q> you ask.\b
        <q>Listen for the announcements, Se&ntilde;or,</q> he suggests, <q>or
        look at the departure boards through there.</q> He jerks his thumb
        vaguely in the direction of north. ',
        
        '<q>Is there a flight leaving soon?</q> you enquire.\b
        <q>I already told you, Se&ntilde;or: listen for the announcements or
        watch the board,</q> he replies with a faint air of impatience.'
    ]
;

+ TellTopic, StopEventList @cortez
    [
        '<q>A criminal called Pablo Cortez has just tried to take over the
        flight to Buenos Aires,</q> you say.\b
        <q>I am sure it will all be taken care of, Se&ntilde;or,</q> the guard
        assures you nonchalantly. ',
        
        '<q>Pablo Cortez...</q> you begin.\b
        The guard cuts you off with a gesture of his hand. <q>All taken care
        of, Se&ntilde;or,</q> he insists. '
    ]
;

+ AskForTopic @IDcard
    "<q>Can I have my ID card back, please?</q> you ask.\b
    <q>That was not your ID card, Se&ntilde;or,</q> the guard replies equably.
    <q>I know Antonio Velaquez, and you are not he.</q> "
    
    isActive = gRevealed('card-confiscated') && IDcard.location == counter
;

+ ShowTopic @IDcard
    topicResponse()
    {
        "You flash the ID card at the security guard, in the hope that it'll
        persuade him to let you straight through without any further questions,
        but instead he snatches it off you, stares at it with a deep frown.\b
        <q>This is not yours, Se&ntilde;or,</q> he remarks.\b
        So saying, he hands the card to a colleague who at once carries it off
        somewhere.<.reveal card-confiscated> ";
        
        IDcard.moveInto(counter);
    }
    
;

+ DefaultAnyTopic
    "The guard merely shrugs and mutters something that could be either, <q>Not
    my concern, Se&ntilde;or,</q> or <q>Not your concern, Se&ntilde;or.</q> "
;

//==============================================================================

cortez: Actor 'Pablo Cortez; evil latinate;man;him'
    "He's really quite a handsome man, in a latinate sort of way; if you met him
    in a different context you might not realize quite what an evil devil he
    actually is. "
    
    actorSpecialDesc = "Pablo Cortez<<first time>>, El Diabo's right-hand man,
        <<only>> is standing by the main exit, hurrying the passengers off the
        plane with muzzle of his machine-pistol. "
    
    shouldNotAttackMsg = 'You know better than to attempt it; he\'s known to be
        quite deadly with that gun. '
    
    cannotTakeFromActorMsg(obj)
    {
        return 'Cortez would shoot you dead before your hands got anywhere near
            it. ';
    }
    
    actorBeforeTravel(traveler, connector)
    {
        if(traveler == me && connector == cockpitDoor)
        {
            "Cortez looks round at you suspiciously as you head for the cockpit
            door. <q>Hey, you, Pond!</q> he shouts. As you make a dash for the
            door he opens fire with his machine pistol, riddling your body with
            bullets. ";
            finishGameMsg(ftDeath, [finishOptionUndo]);
        }
    }
;

+ DefaultAnyTopic
    "You really don't want to attract his attention. If he recognizes you he'll
    kill you. "
    
    isConversational = nil
;

+ gun: Thing 'gun; machine 93r beretta; pistol machine-pistol'
    "It's a Beretta 93R, capable of firing at a rate of more than a thousand
    rounds per minute. "
;

+ cortezArrivalAgenda: AgendaItem
    initiallyActive = true
    isReady = (takeover.isHappening)
    
    invokeItem()
    {
        isDone = true;
        getActor.moveInto(planeFront);
        getActor.addToAgenda(cortezTalkingAgenda);
    }
;

+ cortezTalkingAgenda: AgendaItem
    isReady = (me.isIn(planeFront))
    
    invokeItem()
    {
        isDone = true;
        "<q>Hurry up! Get off this plane! El Diablo is not a patient man and he
        needs it for important business!</q> you hear Cortez tell the
        passengers. <q>If the plane is not cleared by the time our pilot arrives
        I shall shoot any of you who are still aboard! Now, move, move!</q> ";
        
        getActor.addToAgenda(cortezShootingAgenda.setDelay(2));
    }
;

+ cortezShootingAgenda: DelayedAgendaItem
    invokeItem()
    {
        isDone = true;
        if(me.isIn(planeFront))
        {
            "Cortez suddenly looks your way. For a split-second he seems frozen
            with astonishment, but only for a split-second.\b
            <q>Hey! You!</q> he cries. A moment later he raises his machine
            pistol and fires into your belly at point-blank range. ";
            finishGameMsg(ftDeath, [finishOptionUndo]);
        }
        else
            getActor.moveInto(nil);                
    }
;
    

//==============================================================================

angela: Actor 'flight attendant; statuesque young; woman angela; her'
    @planeFront
    "She's a statuesque and by no means unattractive young woman. "
    
    shouldNotAttackMsg = 'That would be cruel and unnecessary. '
    
    globalParamName = 'angela'
    
    makeProper
    {
        proper = true;
        name = 'Angela';
        return name;
    }
    
    suggestionKey = 'top'
;

+ TopicGroup 'top';

++ AskTopic @angela
    keyTopics = 'angela'
    
    name = 'herself'
;

++ QueryTopic 'when' 'this plane is going to leave; depart take off'
    "<q>When is this plane going to leave?</q> you ask.\b
    <q>Just as soon as the pilot comes aboard,</q> she tells you. <.reveal
    pilot-awaited> "
    
    askMatchObj = tFlightDepartures
;


++ AskTopic @tPilot
    "<q>What's happened to the pilot?</q> you ask.\b
    <q>I don't know; we're still waiting for him,</q> she replies. <q>But don't
    worry; I'm sure he'll turn up any moment now.</q> "

    autoName = true
    isActive = gRevealed('pilot-awaited')
;



+ QueryTopic 'what' 'her name is; your'
    "<q>What's your name?</q> you ask.\b
    <q><<getActor.makeProper>>,</q> she replies. "
    
    isActive = !getActor.proper
    
    convKeys = 'angela'
;

+ QueryTopic, StopEventList 'what' @tDoingTonight
    [
        '<q>What are you doing tonight?</q> you ask.\b
        She cocks one eyebrow at you. <q>I have my plans,</q> she replies
        vaguely. ',
        
        '<q>What <i>are</i> you doing tonight?</q> you insist.\b
        <q>I don\'t think that\'s any of your business,</q> she replies, with
        rather a bleak smile. <q>Do you?</q> <.convnode not-your-business>',
        
        '<q>About tonight...</q> you begin.\b
        She cuts you off by pressing her lips together and raising her eyebrows
        in a mildly disapproving manner, as if to say, <q>That topic is
        closed.</q> '       
    ]
    
    convKeys = 'angela'
;

+ ConvNode 'not-your-business';

++ YesTopic
    "<q>As a matter of fact I do,</q> you reply boldly.\b
    <q>In that case we shall have to agree to differ,</q> she replies, just a
    little stiffly."     
;

++ NoTopic
    "<q>No, I suppose not,</q> you concede.\b
    <q>No; well, there you are then,</q> she remarks. "  
;

+ QueryTopic 'when' 'this plane is going to leave; depart take off'
    "<q>When is this plane going to leave?</q> you ask.\b
    <q>Just as soon as the pilot comes aboard,</q> she tells you. <.reveal
    pilot-awaited> "
    
    askMatchObj = tFlightDepartures
;

+ DefaultAskForTopic
    "{The subj angela} listens to your request and shakes her head. <q>Sorry, I
    can't help you with that,</q> she says. "
;
    
+ DefaultCommandTopic
    "<q><<if angela.proper>>Angela<<else>>Miss<<end>>, would you
    <<actionPhrase>>, please?</q> you request.\b
    In reply she merely cocks an eyebrow at you and looks at you as if to say,
    <q>Who do you think you're talking to?</q> "
;


+ DefaultAnyTopic
    "{The subj angela} smiles and shrugs. "  
;

+ DefaultGiveShowTopic
    "You offer {the angela} {the dobj}, but she shakes her head and pushes {him
    dobj} away, saying, <q>I'm afraid I can't accept {that dobj} from you,
    sir.</q> "
;

+ DefaultShowTopic
    "You point towards {the dobj}.\b
    <q>Very interesting, I'm sure, sir,</q> {the subj angela} remarks without
    much enthusiasm. "
    
    isActive = gDobj.isFixed
;

+ TopicGroup
    isActive = getActor.curState == angelaSeatedState
;

++ DefaultAskQueryTopic
    "<q>That question's too difficult for me!</q> she declares. "
;

+ angelaGreetingState: ActorState
    isInitState = true
    specialDesc = "{The subj angela} {is} standing just inside the entrance
        greeting passengers as they board. "
    stateDesc = "Right now, she's wearing a fixed professional smile. "
    
    beforeTravel(traveler, connector)
    {
        if(traveler == me)
        {
            switch(connector)
            {
            case cockpitDoor:
                "<q>I'm afraid you can't go in there, sir,</q> {the subj angela}
                stops you. <q>Only flight crew are allowed in the cockpit.</q>.
                ";
                
                exit;
               
            case planeRear:
                if(!ticketSeen)
                {
                    "<q>I'm afraid I can\'t let you board the plane till I\'ve
                    seen your ticket, sir,</q> {the subj angela} insists. ";
                    exit;
                }
                break;
            case jetway:
                if(!ticketSeen)
                    getActor.addToAgenda(angelaTicketAgenda);
                break;
            default:
                break;
            }
        }
    }
    
    ticketSeen = nil
;

++ GiveShowTopic @ticket
    topicResponse()
    {
        "<q>Here you are,</q> you say, holding out the ticket for {the angela}
        to see.\b
        She glances down at the ticket in your hand, and temporarily takes it
        off you to check. <q>That's fine, sir,</q> she assures you as she
        returns it to you. <q>Please move to the rear of the plane to find a
        seat.</q> ";
        angelaGreetingState.ticketSeen = true;
        boardingAchievement.awardPointsOnce();
    }
;
    
++ QueryTopic 'if|whether' @tEnjoyWork
    "<q>Do you enjoy your work?</q> you ask.\b
    <q>Of course, sir,</q> she replies with a bland smile. "    
    
    convKeys = 'angela'
;

+ TopicGroup +5
    isActive = angela.curState == angelaGreetingState &&
    !angelaGreetingState.ticketSeen
;

++ DefaultAskQueryTopic
    "<q>I really need to see your ticket, sir,</q> she insists <<one
      of>>politely<<or>>once more<<stopping>>. "
;

++ DefaultSayTellTalkTopic
    "{The subj angela} listens <<one of>>politely<<or>>a little impatiently
    <<stopping>> to what you have to say, then replies, <q>May I see your
    ticket, sir?</q> "
;

+ TopicGroup +5
    isActive = angela.curState == angelaGreetingState &&
    angelaGreetingState.ticketSeen
;

++ DefaultAskQueryTopic
    "<q>If you have any further questions perhaps you could ask them once we're
    in flight,</q> she <<one of>>suggests<<or>>repeats<<stopping>>. <q><<one
      of>>It would be best if you moved <<or>> Please move<<stopping>> to the
    rear of the plane and <<one of>>took<<or>>take<<stopping>> your seat now,
    sir.</q> "
;

++ DefaultSayTellTalkTopic
    "{The subj angela} holds up her hand to stop you in mid-flow. <q>Can I ask
    you to move to the rear of your plane and take your seat now, sir?</q> she
    <<one of>>requests<<or>>repeats<<or>>insists<<stopping>>. "
;



+ angelaAssistingState: ActorState
    specialDesc = "{The subj angela} {is} standing in the middle of the jetway,
        trying to calm the passengers who have just been forced off the plane. "
    
    stateDesc = "Right now, she's looking rather harrassed. "
;

++ HelloTopic, StopEventList
    [
        '<q>Excuse me, might I have a word?</q> you say.\b
        {The subj angela} turns to you with a fixed smile, no doubt mentally
        preparing herself for another barrage of complaints. <q>Yes; how can I
        help?</q> she replies. ',
        
        '<q>Might I have another word?</q> you ask.\b
        <q>Yes?</q> she replies, turning to you just a little warily. '
    ]
    
    changeToState = angelaTalkingState
;




+ angelaTalkingState: ActorState
    specialDesc = "{The subj angela} {is} facing you, waiting for you to speak.
        "    
;

++ QueryTopic 'if|whether' @tEnjoyWork
   "<q>Do you enjoy your work -- at times like these?</q> you ask.\b
   <q>At times like these...</q> she leaves the sentence unfinished with an
   expressive grimace. "    
    
    convKeys = 'angela'
;

++ ByeTopic
    "<q>Well, cheerio for now then,</q> you say.\b
    <q>Goodbye,</q> she replies with a brisk nod, before turning to yet another
    importuning displaced passenger anxious for her attention. "
    
    changeToState = angelaAssistingState
;

++ LeaveByeTopic
    "{The subj angela} looks momentarily taken aback at your somewhat abrupt
    departure, but quickly turns back to the other passengers clamouring for
    her attention. "
    
    changeToState = angelaAssistingState
;

++ AskTellTopic, StopEventList @cortez
    [
        '<q>Do you know who that man waving a gun around at the front of the
        plane is?</q> you ask, lowering your voice. <q>It\'s Pablo Cortez, El
        Diablo\'s right-hand man!</q>\b
        Her smile becomes rather frosty as she replies, <q>What\'s that to
        you?</q> <.inform cortez> <.convnodet what-to-you>',
        
        '<q>You need to be <i>very</i> careful around Cortez,</q> you warn
        her.\b
        <q>I shall be,</q> she assures you. '
    
    ]
    autoName = true
    convKeys = 'top'
    suggestAs = TellTopic
;

+ ConvNode 'what-to-you';
    
++ TellTopic @me    
    "<q>The name's Pond, Sherlock Pond,</q> you tell her. <q>I'm a British
    secret agent on the track of these villains!</q>\b
    <q>Indeed!</q> she replies with ill-disguised scepticism. <.inform agent>" 
    
    name = 'yourself'    
;

++ SayTopic 'Cortez is dangerous'
    "<q>Pablo Cortez is a <i>very</i> dangerous man,</q> you warn her. <q>He's
    killed more men than I've had hot dinners!</q><.inform cortez-dangerous>\b
    <q>Anyone waving a gun around aboard a passenger aircraft might be
    considered dangerous,</q> she points out pragmatically. "        
;

++ SayTopic 'she should call security; you'
    "<q>You should call airport security to deal with him!</q> you urge her.\b
    <q>Airport security -- in Narcosia?</q> she asks incredulously. <q>Somehow I
    don\'t think that will exactly help the situation!</q> "    
;

++ DefaultAnyTopic, StopEventList
    [
        '<q>No, but what is it to you who this man is?</q> she interrupts you.
        <.convstay> ',
    
        'She shakes her head. <q>Very well, don\'t answer my question then,</q>
        she mutters. '
    ]    
;

++ NodeEndCheck
    canEndConversation(reason)
    {
        if(reason == endConvBye)
        {
            "<q><q>Goodbye,</q> isn't an answer,</q> {the subj angela}
            complains. <q>Why are you so bothered about this man Cortez?</q> ";
                              
            return blockEndConv;
        }
        
        if(reason == endConvLeave)
        {
            "This doesn't seem a good point to break off the conversation. ";
            return nil;
        }
        
        return true;
    }
;

+ TopicGroup +5
    isActive = angela.curState == angelaTalkingState
;

++  DefaultAskQueryTopic, ShuffledEventList
    [
        '{The subj angela} mutters something inaudible and looks round, as if
        dropping a heavy hint that she has other people besides you to attend
        to. ',
        
        '<q>Maybe we can discuss that some other time,</q> she suggests, with
        a significant glance at the other passengers anxious to attract her
        attention. ',
        
        '<q>Hm, well,</q> she says, in a tone of voice that rather suggests
        she has more urgent things on her mind. ',
        
        '<q>I think perhaps...</q> she begins, and then trails off as one of the
        other passengers taps her on the arm in an attempt to grab her
        attention. '
    ]
;

++ DefaultSayTellTalkTopic
    "{The subj angela} listens to what you have to say without comment, but with
    the air of one who has other things on her mind. "
;



+ angelaSeatedState: ActorState
    specialDesc = "{The subj angela} {is} sitting near the front of the plane. "
    stateDesc = "Right now, though, she's looking worried and afraid. "
;

++ QueryTopic 'if|whether' @tEnjoyWork
   "<q>Are you enjoying your work now?</q> you ask.\b
   <q>I'll be glad when this particular flight is over,</q> she replies
   quietly. "    
    
    convKeys = 'angela'
;

++ QueryTopic, StopEventList 'what' @tDoingTonight
    [
        '<q>What are your plans for tonight now?</q> you ask.\b
        <q>I\'m not sure,</q> she replies, just a little nervously. <q>I think
        I\'d rather wait until this plane has safely landed at its destination
        and -- well, you know.</q> She indicates the new set of passengers witha
        flick of her eyes. <q>I think I\'d rather wait until this is all over
        before making any further plans.</q> ',
        
        '<q>About later tonight...</q> you begin.\b
        <q>Let\'s discuss it when we\'ve arrived at the other end,</q> she
        insists. '
    ]
    
    convKeys = 'angela'
;

+ TopicGroup +5
    isActive = angela.curState == angelaSeatedState
;

++ DefaultAskQueryTopic, ShuffledEventList
    [
        '{The subj angela} lowers her voice and swivels her eyes just enough to
        remind you of the other people in earshot. <q>Perhaps we should discuss
        that some other time,</q> she suggests. ',
        
        '<q>I don\'t think I care to answer that right now,</q> she replies,
        with just enough movement of the head to indicate how easily you might
        be overheard by the hoodlums in the other passenger seats. ',
        
        '<q>I think...</q> she begins, and then breaks off. <q>I think this may
        not be the best time to talk about that,</q> she concludes. ',
        
        '<q>Hm,</q> she says, <q>right.</q> It\'s obviously intended as a
        non-answer, perhaps because she\'s worried about who else might here
        what she says. '       
    ]
;

++ DefaultSayTellTalkTopic
    "{The subj angela} merely listens, looking faintly disapproving at your
    garrulouslness. "
;
    
    

+ angelaAssistingAgenda: AgendaItem
    initiallyActive = true
    isReady = (takeover.isHappening)
    
    invokeItem()
    {
        isDone = true;
        getActor.moveInto(jetway);
        getActor.setState(angelaAssistingState);
        getActor.addToAgenda(angelaReboardingAgenda);
    }
;

+ angelaReboardingAgenda: AgendaItem
    isReady = (takeover.hasHappened)
    
    invokeItem()
    {
        isDone = true;
        getActor.moveInto(planeFront);
        getActor.setState(angelaSeatedState);
        getActor.addToAgenda(angelaPilotAgenda);
    }
    
;

+ angelaPilotAgenda: ConvAgendaItem    
    invokeItem()
    {
        isDone = true;
        "{The subj angela} looks up at you sharply and frowns. <q>Hey! You're
        one the the passengers, aren't you?</q> she remarks. <q>I remember
        looking at your ticket! You certainly aren't our pilot. What are you
        doing in that uniform?</q><.convnodet uniform> ";
        
    }
;
    
+ ConvNode 'uniform';

++ SayTopic 'all British agents learn to fly'
    "<q>I told you, I'm a British agent, and all British agents learn to fly --
    it's part of our training,</q> you tell her.\b
    <q>You mean you actually intend to fly this aircraft?</q> she demands,
    startled. <.convnodet intend-fly> "
    
    isActive = gInformed('agent')
;

++ SayTopic 'you have a pilot\'s license; i'
    "<q>It's quite all right, I have a pilot\'s license,</q> you assure you.\b
    <q>Yes, but...</q> she begins. <q>Do you actually mean to say you intend to
    fly this plane?</q> <.convnodet intend-fly> "
    
    isActive = !gInformed('agent')
;

++ SayTopic 'you\'re the replacement pilot; you are i am i\'m'
    "<q>You said you were waiting for the pilot, but there's no sign of him, so
    I'm standing in for him,</q> you reply.\b
    <q>You!</q> she exclaims. <q>You mean, <i>you're</i> going to fly this
    plane?</q> <.convnodet intend-fly> "
    
    isActive = gRevealed('pilot-awaited')
;

++ SayTopic 'you just found the uniform; i'
    "<q>I found the uniform, you need a pilot,</q> you reply with a smile and a
    shrug. <q>Besides, I do know how to fly -- I have a license.</q>\b
    <q>You mean you're intending to fly this plane?</q> she demands
    incredulously. <.convnodet intend-fly> "
;

++ DefaultAnyTopic, ShuffledEventList
    [
        '<q>No, but answer my question,</q> she interrupts you. <q>What are you
        doing in that uniform?</q> <.convstay> ',
        
        '<q>That\'s not what I asked,</q> she complains. <q>Tell me why you\'re
        wearing that uniform!</q> <.convstay>',
        
        '<q>Why are you wearing that uniform?</q> she insists, brushing aside
        your irrelevant remarks. <.convstay> ',
        
        '<q>That still doesn\'t tell me what you\'re doing with that
        uniform,</q> she complains. <q>Why are you wearing it?</q> <.convstay> '
    ]
;


++ NodeEndCheck
    canEndConversation(reason)
    {
        switch(reason)
        {
        case endConvBye:
            "<q>Oh no, you're not avoiding my question like that!</q> she tells
            you. <q>Tell me, why are you wearing that pilot's uniform?</q>";
            return blockEndConv;
        case endConvLeave:
            "<q>You're not going anywhere until you tell me what you're doing in
            that uniform!</q> {the subj angela} insists. ";
            return blockEndConv;
        default:
            return nil;
        }
    }
;

++ NodeContinuationTopic
    "<q><<one of>>I asked you a question<<or>>I'm still waiting for an
    answer<<cycling>>,</q> {the subj angela} <<one of>> reminds
    you<<or>> insists<<or>> repeats<<cycling>>. <q>Why are you wearing that
    uniform?</q> "
;
    

+ ConvNode 'intend-fly'
   commonResponse = "\b<q>Very well, then,</q> she sighs. <q>I suppose we don't
       have too much choice now, do we? Just as long as you know what you're
       doing...</q> "
;

++ YesTopic
    "<q>Yes, why not?</q> you reply breezily. <q>You can't wait here all day --
    Pablo Cortez and his merry crew won't stand for it, for one thing!</q>
    <<location.commonResponse>>"
;

++ QueryTopic 'why not'
    "<q>Why not?</q> you ask. <q>You need a pilot and I need to get out of here.
    Besides, I wouldn't want to be in your shoes when this lot run out of
    patience!</q> You nod towards the gansgters and drug barons occupying the
    passenger seats further down the aisle. <<location.commonResponse>>"
;

++ QueryTopic 'whether|if she has a better idea; you have'
    "<q>Do you have a better idea?</q> you counter. <q>There's no sign of your
    regular pilot, and I wouldn't want to be in your shoes when your current
    passengers run out of patience!</q> <<location.commonResponse>>"
;

++ DefaultAnyTopic
    "<q>Please answer my question,</q> she insists. <q>Do you really intend to
    fly this plane?</q> <.convstay>"
;

++ NodeEndCheck
    canEndConversation(reason)
    {
        switch(reason)
        {
        case endConvBye:
            "<q>That's not an answer!</q> she complains. <q>Tell me, are
            you proposing to fly this plane yourself?</q>";
            return blockEndConv;
        case endConvLeave:
            "<q>Don't walk off until you've told me whether you're proposing to
            fly this plane, </q> {the subj angela} insists. <q>Well, are
            you?</q> ";
            return blockEndConv;
        default:
            return nil;
        }
    }
;

++ NodeContinuationTopic
    "<q>I'd appreciate it if you answered my question,</q> {the subj angela}
    insists. <q>Are you really proposing to fly this aircraft?</q> "
;


+ angelaTicketAgenda: ConvAgendaItem
    initiallyActive = true
    
    invokeItem()
    {
        isDone = true;
        "<q>Welcome aboard, sir,</q> {the subj angela} greets you with a smile.
        <q>May I see your ticket please?</q> ";
        
//        /* The code shown commented out below can be deleted */
//        if(ticket.isDirectlyIn(me))
//        {
//            "She glances down at the ticket in your hand, and temporarily takes
//            it off you to check it. <q>That's fine, sir,</q> she assures you as
//            she returns it to you. <q>Please move to the rear of the plane to
//            find a seat.</q> ";
//            angelaGreetingState.ticketSeen = true;
//        }
        
    }
;

