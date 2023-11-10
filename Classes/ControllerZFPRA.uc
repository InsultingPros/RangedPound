class ControllerZFPRA extends KFMonsterController;

var NavigationPoint HidingSpots;

var     float       WaitAnimTimeout;
var     int         AnimWaitChannel;
var     name        AnimWaitingFor;
var     float       RageAnimTimeout;
var		bool		bDoneSpottedCheck;
var     float       RageFrustrationTimer;       // Tracks how long we have been walking toward a visible enemy
var     float       RageFrustrationThreshhold;  // Base value for how long the FP should walk torward an enemy without reaching them before getting frustrated and raging

state ZombieHunt
{
    event SeePlayer(Pawn SeenPlayer)
    {
        if ( !bDoneSpottedCheck && PlayerController(SeenPlayer.Controller) != none )
        {
            // 25% chance of first player to see this Fleshpound saying something
            if ( !KFGameType(Level.Game).bDidSpottedFleshpoundMessage && FRand() < 0.25 )
            {
                PlayerController(SeenPlayer.Controller).Speech('AUTO', 12, "");
                KFGameType(Level.Game).bDidSpottedFleshpoundMessage = true;
            }

            bDoneSpottedCheck = true;
        }

        super.SeePlayer(SeenPlayer);
    }
}

// Don't ever do this
function AvoidThisMonster(KFMonster Feared){}

function bool FireWeaponAt(Actor A)
{
    if ( A == none )
        A = Enemy;
    if ( (A == none) || (Focus != A) )
        return false;
    Target = A;

    if( (VSize(A.Location - Pawn.Location) >= ZFPRA(Pawn).MeleeRange + Pawn.CollisionRadius + Target.CollisionRadius) &&
        ZFPRA(Pawn).LastChainGunTime - Level.TimeSeconds > 0 )
    {
        return false;
    }

    Monster(Pawn).RangedAttack(Target);
    return false;
}

function TimedFireWeaponAtEnemy()
{
    if ( (Enemy == none) || FireWeaponAt(Enemy) )
        SetCombatTimer();
    else
        SetTimer(0.01, true);
}


state ZombieCharge
{
    function Tick( float Delta )
    {
        local ZFPRA ZFP;
        Global.Tick(Delta);

        // Make the FP rage if we haven't reached our enemy after a certain amount of time
        if( RageFrustrationTimer < RageFrustrationThreshhold )
        {
            RageFrustrationTimer += Delta;

            if( RageFrustrationTimer >= RageFrustrationThreshhold )
            {
                ZFP = ZFPRA(Pawn);

                if( ZFP != none && !ZFP.bChargingPlayer )
                {
                    ZFP.StartCharging();
                    ZFP.bFrustrated = true;
                }
            }
        }
    }

    function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest)
    {
        return false;
    }

    function bool TryStrafe(vector sideDir)
    {
        return false;
    }

    function Timer()
    {
        Disable('NotifyBump');
        Target = Enemy;
        TimedFireWeaponAtEnemy();
    }

    function BeginState()
    {
        super.BeginState();

        RageFrustrationThreshhold = default.RageFrustrationThreshhold + (Frand() * 5);
        RageFrustrationTimer = 0;
    }

WaitForAnim:

    if ( Monster(Pawn).bShotAnim )
    {
        Goto('Moving');
    }
    if ( !FindBestPathToward(Enemy, false,true) )
        GotoState('ZombieRestFormation');
Moving:
    MoveToward(Enemy);
    WhatToDoNext(17);
    if ( bSoaking )
        SoakStop("STUCK IN CHARGING!");
}

function SetPoundRageTimout(float NewRageTimeOut)
{
    RageAnimTimeout = NewRageTimeOut;
}

function SetWaitForAnimTimout(float NewWaitAnimTimeout, name AnimToWaitFor)
{
    WaitAnimTimeout = NewWaitAnimTimeout;
    AnimWaitingFor = AnimToWaitFor;
}

state WaitForAnim
{
Ignores SeePlayer,HearNoise,Timer,EnemyNotVisible,NotifyBump,Startle;

    function GetOutOfTheWayOfShot(vector ShotDirection, vector ShotOrigin){}

    function BeginState()
    {
        bUseFreezeHack = False;
    }

    // The rage anim has ended, clear the flags and let the AI do its thing
    function RageTimeout()
    {
        if( bUseFreezeHack )
        {
            if( Pawn!=None )
            {
                Pawn.AccelRate = Pawn.Default.AccelRate;
                Pawn.GroundSpeed = Pawn.Default.GroundSpeed;
            }
            bUseFreezeHack = False;
            AnimEnd(0);
        }
    }

    function WaitTimeout()
    {
        if( bUseFreezeHack )
        {
            if( Pawn!=none )
            {
                Pawn.AccelRate = Pawn.default.AccelRate;
                Pawn.GroundSpeed = Pawn.default.GroundSpeed;
            }
            bUseFreezeHack = false;
        }

        AnimEnd(AnimWaitChannel);
    }

    event AnimEnd(int Channel)
    {

        Pawn.AnimEnd(Channel);
        if ( !Monster(Pawn).bShotAnim )
            WhatToDoNext(99);
    }

    function Tick( float Delta )
    {
        Global.Tick(Delta);

        if( WaitAnimTimeout > 0 )
        {
            WaitAnimTimeout -= Delta;

            if( WaitAnimTimeout <= 0 )
            {
                WaitAnimTimeout = 0;
                WaitTimeout();
            }
        }

        if( RageAnimTimeout > 0 )
        {
            RageAnimTimeout -= Delta;

            if( RageAnimTimeout <= 0 )
            {
                RageAnimTimeout = 0;
                RageTimeout();
            }
        }

        if( bUseFreezeHack )
        {
            MoveTarget = none;
            MoveTimer = -1;
            Pawn.Acceleration = vect(0,0,0);
            Pawn.GroundSpeed = 1;
            Pawn.AccelRate = 0;
        }
    }
    function EndState()
    {
        super.EndState();

        if( Pawn!=None )
        {
            Pawn.AccelRate = Pawn.Default.AccelRate;
            Pawn.GroundSpeed = Pawn.Default.GroundSpeed;
        }
        bUseFreezeHack = False;

        AnimWaitingFor = '';
    }

Begin:
    While( KFM.bShotAnim )
    {
        Sleep(0.15);
    }
    WhatToDoNext(99);

}
defaultproperties
{
     RageFrustrationThreshhold=10.000000
}
