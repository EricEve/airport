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

+ angelaAssistingState: ActorState
    specialDesc = "{The subj angela} {is} standing in the middle of the jetway,
        trying to calm the passengers who have just been forced off the plane. "
    
    stateDesc = "Right now, she's looking rather harrassed. "
;

+ angelaTalkingState: ActorState
    specialDesc = "{The subj angela} {is} facing you, waiting for you to speak.
        "    
;

+ angelaSeatedState: ActorState
    specialDesc = "{The subj angela} {is} sitting near the front of the plane. "
    stateDesc = "Right now, though, she's looking worried and afraid. "
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
    }
    
;
    
+ angelaTicketAgenda: ConvAgendaItem
    initiallyActive = true
    
    invokeItem()
    {
        isDone = true;
        "<q>Welcome aboard, sir,</q> {the subj angela} greets you with a smile.
        <q>May I see your ticket please?</q> ";
        
        /* Temporary code until we reach Chapter 11 */
        if(ticket.isDirectlyIn(me))
        {
            "She glances down at the ticket in your hand, and temporarily takes
            it off you to check it. <q>That's fine, sir,</q> she assures you as
            she returns it to you. <q>Please move to the rear of the plane to
            find a seat.</q> ";
            angelaGreetingState.ticketSeen = true;
        }
        
    }
;