//Alternate take on the zed, which is basically OldSchool RangedPound
class ZFPRA extends ZFPRABase
    Abstract;

function bool CanGetOutOfWay()
{
    return false;
}

function bool FlipOver()
{
    return false;
}

simulated function PostBeginPlay()
{
    super.PostBeginPlay();

    if( Role < ROLE_Authority )
    {
        return;
    }

    if (Level.Game != none)
    {
        if( Level.Game.GameDifficulty < 2.0 )
        {
            MGFireInterval = default.MGFireInterval * 1.25 * MGDelayMult;
            MGDamage = default.MGDamage * 0.5 * MGDamMult;
            MGAccuracy = default.MGAccuracy * 1.25 * MGAccMult;
            MGFireBurst = default.MGFireBurst * 0.7 * MGBurstMult;
            MGFireRate = default.MGFireRate * 1.5 * MGRoFMult;
        }
        else if( Level.Game.GameDifficulty < 4.0 )
        {
            MGFireInterval = default.MGFireInterval * 1 * MGDelayMult;
            MGDamage = default.MGDamage * 1.0 * MGDamMult;
            MGAccuracy = default.MGAccuracy * 1.0 * MGAccMult;
            MGFireBurst = default.MGFireBurst * 1.0 * MGBurstMult;
            MGFireRate = default.MGFireRate * 1.0 * MGRoFMult;
        }
        else if( Level.Game.GameDifficulty < 5.0 )
        {
            MGFireInterval = default.MGFireInterval * 0.75 * MGDelayMult;
            MGDamage = default.MGDamage * 1.0 * MGDamMult;
            MGAccuracy = default.MGAccuracy * 0.9 * MGAccMult;
            MGFireBurst = default.MGFireBurst * 1.33 * MGBurstMult;
            MGFireRate = default.MGFireRate * 0.833333 * MGRoFMult;
        }
        else
        {
            MGFireInterval = default.MGFireInterval * 0.6 * MGDelayMult;
            MGDamage = default.MGDamage * 1.0 * MGDamMult;
            MGAccuracy = default.MGAccuracy * 0.80 * MGAccMult;
            MGFireBurst = default.MGFireBurst * 1.67 * MGBurstMult;
            MGFireRate = default.MGFireRate * 0.68 * MGRoFMult;
        }
    }
}

simulated function bool HitCanInterruptAction()
{
    if( bShotAnim )
    {
        return false;
    }

    return true;
}

simulated function Destroyed()
{
    if( mTracer!=none )
        mTracer.Destroy();
    if( mMuzzleFlash!=none )
        mMuzzleFlash.Destroy();
    if( AvoidArea!=None )
        AvoidArea.Destroy();

    super.Destroyed();
}

simulated Function PostNetBeginPlay()
{
    if (AvoidArea == None)
        AvoidArea = Spawn(class'FleshPoundAvoidArea',self);
    if (AvoidArea != None)
        AvoidArea.InitFor(Self);

    EnableChannelNotify ( 1,1);
    AnimBlendParams(1, 1.0, 0.0,, 'Bip01 Spine1');
    super.PostNetBeginPlay();
    TraceHitPos = vect(0,0,0);
    bNetNotify = true;
}

// This zed has been taken control of. Boost its health and speed
function SetMindControlled(bool bNewMindControlled)
{
    if( bNewMindControlled )
    {
        NumZCDHits++;

        // if we hit him a couple of times, make him rage!
        if( NumZCDHits > 1 )
        {
            if( !IsInState('ChargeToMarker') )
            {
                GotoState('ChargeToMarker');
            }
            else
            {
                NumZCDHits = 1;
                if( IsInState('ChargeToMarker') )
                {
                    GotoState('');
                }
            }
        }
        else
        {
            if( IsInState('ChargeToMarker') )
            {
                GotoState('');
            }
        }

        if( bNewMindControlled != bZedUnderControl )
        {
            SetGroundSpeed(OriginalGroundSpeed * 1.25);
            Health *= 1.25;
            HealthMax *= 1.25;
        }
    }
    else
    {
        NumZCDHits=0;
    }

    bZedUnderControl = bNewMindControlled;
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    if( Level.TimeSeconds - LastPainAnim < MinTimeBetweenPainAnims )
        return;

    // Don't interrupt the controller if its waiting for an animation to end
    if( !Controller.IsInState('WaitForAnim') && Damage >= 10 )
        PlayDirectionalHit(HitLocation);

    LastPainAnim = Level.TimeSeconds;

    if( Level.TimeSeconds - LastPainSound < MinTimeBetweenPainSounds )
        return;

    LastPainSound = Level.TimeSeconds;
    PlaySound(HitSound[0], SLOT_Pain,1.25,,400);
}

// changes colors on Device (notified in anim)
simulated function DeviceGoRed()
{
    Skins[1]=Shader'KFCharacters.FPRedBloomShader';
}

simulated function DeviceGoNormal()
{
    Skins[1] = Shader'KFCharacters.FPAmberBloomShader';
}

// Handle the zed being commanded to move to a new location
function GivenNewMarker()
{
    if( bChargingPlayer && NumZCDHits > 1  )
    {
        GotoState('ChargeToMarker');
    }
    else
    {
        GotoState('');
    }
}

function RangedAttack(Actor A)
{
    local float Dist;

    if ( bShotAnim || Physics == PHYS_Swimming )
        return;
    else if ( CanAttack(A) )
    {
        bShotAnim = true;
        SetAnimAction('Claw');
        return;
    }

    Dist = VSize(A.Location-Location);

    if ( !bWaitForAnim && !bShotAnim && !bDecapitated && !bChargingPlayer && !bFrustrated && LastChainGunTime<Level.TimeSeconds )
    {
        if (!Controller.LineOfSightTo(A))
        {
            LastChainGunTime = Level.TimeSeconds + MGFireInterval + (FRand() *1.0);
            return;
        }

        LastChainGunTime = Level.TimeSeconds + MGFireInterval + (FRand() *2.0);

        bShotAnim = true;
        Acceleration = vect(0,0,0);
        SetAnimAction('PreFireMG');
        HandleWaitForAnim('PreFireMG');

        MGFireCounter =  MGFireBurst;

        GoToState('FireChaingun');
    }
}

// Sets the FP in a berserk charge state until he either strikes his target, or hits timeout
function StartCharging()
{
    local float RageAnimDur;

    if( Health <= 0 )
    {
        return;
    }

    SetAnimAction('PoundRage');
    Acceleration = vect(0,0,0);
    bShotAnim = true;
    Velocity.X = 0;
    Velocity.Y = 0;
    Controller.GoToState('WaitForAnim');
    KFMonsterController(Controller).bUseFreezeHack = True;
    RageAnimDur = GetAnimDuration('PoundRage');
    ControllerZFPRA(Controller).SetPoundRageTimout(RageAnimDur);
    GoToState('BeginRaging');
}

state BeginRaging
{
    Ignores StartCharging;

    // Set the zed to the zapped behavior
    simulated function SetZappedBehavior()
    {
        Global.SetZappedBehavior();
        GoToState('');
    }

    function bool CanGetOutOfWay()
    {
        return false;
    }

    simulated function bool HitCanInterruptAction()
    {
        return false;
    }

    function Tick( float Delta )
    {
        Acceleration = vect(0,0,0);

        global.Tick(Delta);
    }

Begin:
    Sleep(GetAnimDuration('PoundRage'));
    GotoState('RageCharging');
}


simulated function SetBurningBehavior()
{
    if( bFrustrated || bChargingPlayer )
    {
        return;
    }

    super.SetBurningBehavior();
}

state RageCharging
{
Ignores StartCharging;

    // Set the zed to the zapped behavior
    simulated function SetZappedBehavior()
    {
        Global.SetZappedBehavior();
           GoToState('');
    }

    function PlayDirectionalHit(Vector HitLoc)
    {
        if( !bShotAnim )
        {
            super.PlayDirectionalHit(HitLoc);
        }
    }

    function bool CanGetOutOfWay()
    {
        return false;
    }

    // Don't override speed in this state
    function bool CanSpeedAdjust()
    {
        return false;
    }

    function BeginState()
    {
        local float DifficultyModifier;

        if( bZapped )
        {
            GoToState('');
        }
        else
        {
            bChargingPlayer = true;
            if( Level.NetMode!=NM_DedicatedServer )
                ClientChargingAnims();

            // Scale rage length by difficulty
            if( Level.Game.GameDifficulty < 2.0 )
            {
                DifficultyModifier = 0.85;
            }
            else if( Level.Game.GameDifficulty < 4.0 )
            {
                DifficultyModifier = 1.0;
            }
            else if( Level.Game.GameDifficulty < 5.0 )
            {
                DifficultyModifier = 1.25;
            }
            else // Hardest difficulty
            {
                DifficultyModifier = 3.0; // Doubled Fleshpound Rage time for Suicidal and HoE in Balance Round 1
            }

            RageEndTime = (Level.TimeSeconds + 5 * DifficultyModifier) + (FRand() * 6 * DifficultyModifier);
            NetUpdateTime = Level.TimeSeconds - 1;
        }
    }

    function EndState()
    {
        bChargingPlayer = False;
        bFrustrated = false;

        ControllerZFPRA(Controller).RageFrustrationTimer = 0;

        if( Health>0 && !bZapped )
        {
            SetGroundSpeed(GetOriginalGroundSpeed());
        }

        if( Level.NetMode!=NM_DedicatedServer )
            ClientChargingAnims();

        NetUpdateTime = Level.TimeSeconds - 1;
    }

    function Tick( float Delta )
    {
        if( !bShotAnim )
        {
            SetGroundSpeed(OriginalGroundSpeed * 2.3);//2.0;
            if( !bFrustrated && !bZedUnderControl && Level.TimeSeconds>RageEndTime )
            {
                GoToState('');
            }
        }

        // Keep the flesh pound moving toward its target when attacking
        if( Role == ROLE_Authority && bShotAnim)
        {
            if( LookTarget!=None )
            {
                Acceleration = AccelRate * Normal(LookTarget.Location - Location);
            }
        }

        global.Tick(Delta);
    }

    function Bump( Actor Other )
    {
        local float RageBumpDamage;
        local KFMonster KFMonst;

        KFMonst = KFMonster(Other);

        // Hurt/Kill enemies that we run into while raging
        if( !bShotAnim && KFMonst!=None && ZombieFleshPound(Other)==None && Pawn(Other).Health>0 )
        {
            // Random chance of doing obliteration damage
            if( FRand() < 0.4 )
            {
                 RageBumpDamage = 501;
            }
            else
            {
                 RageBumpDamage = 450;
            }

            RageBumpDamage *= KFMonst.PoundRageBumpDamScale;

            Other.TakeDamage(RageBumpDamage, self, Other.Location, Velocity * Other.Mass, class'DamTypePoundCrushed');
        }
        else Global.Bump(Other);
    }
    // If fleshie hits his target on a charge, then he should settle down for abit.
    function bool MeleeDamageTarget(int hitdamage, vector pushdir)
    {
        local bool RetVal,bWasEnemy;

        bWasEnemy = (Controller.Target==Controller.Enemy);
        RetVal = Super.MeleeDamageTarget(hitdamage*1.75, pushdir*3);
        if( RetVal && bWasEnemy )
            GoToState('');
        return RetVal;
    }
}

// State where the zed is charging to a marked location.
// Not sure if we need this since its just like RageCharging,
// but keeping it here for now in case we need to implement some
// custom behavior for this state
state ChargeToMarker extends RageCharging
{
Ignores StartCharging;

    function Tick( float Delta )
    {
        if( !bShotAnim )
        {
            SetGroundSpeed(OriginalGroundSpeed * 2.3);
            if( !bFrustrated && !bZedUnderControl && Level.TimeSeconds>RageEndTime )
            {
                GoToState('');
            }
        }

        // Keep the flesh pound moving toward its target when attacking
        if( Role == ROLE_Authority && bShotAnim)
        {
            if( LookTarget!=None )
            {
                Acceleration = AccelRate * Normal(LookTarget.Location - Location);
            }
        }

        global.Tick(Delta);
    }
}

simulated function PlayDyingAnimation(class<DamageType> DamageType, vector HitLoc)
{
    Super.PlayDyingAnimation(DamageType,HitLoc);
    if( Level.NetMode!=NM_DedicatedServer )
        DeviceGoNormal();
}

simulated function ClientChargingAnims()
{
    PostNetReceive();
}

simulated function AddTraceHitFX( vector HitPos )
{
    local vector Start,SpawnVel,SpawnDir;
    local float hitDist;

    Start = GetBoneCoords('tip').Origin;
    if( mTracer==None )
        mTracer = Spawn(Class'KFMod.KFNewTracer',,,Start);
    else mTracer.SetLocation(Start);
    if( mMuzzleFlash==None )
    {
        // KFTODO: Replace this
        mMuzzleFlash = Spawn(Class'MuzzleFlash3rdMG');
        AttachToBone(mMuzzleFlash, 'tip');
    }
    else mMuzzleFlash.SpawnParticle(1);
    hitDist = VSize(HitPos - Start) - 50.f;

    if( hitDist>10 )
    {
        SpawnDir = Normal(HitPos - Start);
        SpawnVel = SpawnDir * 10000.f;
        mTracer.Emitters[0].StartVelocityRange.X.Min = SpawnVel.X;
        mTracer.Emitters[0].StartVelocityRange.X.Max = SpawnVel.X;
        mTracer.Emitters[0].StartVelocityRange.Y.Min = SpawnVel.Y;
        mTracer.Emitters[0].StartVelocityRange.Y.Max = SpawnVel.Y;
        mTracer.Emitters[0].StartVelocityRange.Z.Min = SpawnVel.Z;
        mTracer.Emitters[0].StartVelocityRange.Z.Max = SpawnVel.Z;
        mTracer.Emitters[0].LifetimeRange.Min = hitDist / 10000.f;
        mTracer.Emitters[0].LifetimeRange.Max = mTracer.Emitters[0].LifetimeRange.Min;
        mTracer.SpawnParticle(1);
    }
    Instigator = Self;

    if( HitPos != vect(0,0,0) )
    {
        Spawn(class'ROBulletHitEffect',,, HitPos, Rotator(Normal(HitPos - Start)));
    }
}

simulated function AnimEnd( int Channel )
{
    local name  Sequence;
    local float Frame, Rate;

    if( Level.NetMode==NM_Client && bMinigunning )
    {
        GetAnimParams( Channel, Sequence, Frame, Rate );

        if( Sequence != 'PreFireMG' && Sequence != 'FireMG' )
        {
            Super.AnimEnd(Channel);
            return;
        }

        PlayAnim('FireMG');
        bWaitForAnim = true;
        bShotAnim = true;
        IdleTime = Level.TimeSeconds;
    }
    else Super.AnimEnd(Channel);
}

state FireChaingun
{
    function RangedAttack(Actor A)
    {
        Controller.Target = A;
        Controller.Focus = A;
    }

    function EndState()
    {
        TraceHitPos = vect(0,0,0);
        bMinigunning = false;

        AmbientSound = default.AmbientSound;
        SoundVolume=default.SoundVolume;
        SoundRadius=default.SoundRadius;
        MGFireCounter=0;

        LastChainGunTime = Level.TimeSeconds + MGFireInterval + (FRand() *2.0);
    }

    function BeginState()
    {
        bFireAtWill = false;
        Acceleration = vect(0,0,0);
        MGLostSightTimeout = 0.0;
        bMinigunning = true;
    }

    function AnimEnd( int Channel )
    {
        if( MGFireCounter <= 0 )
        {
            bShotAnim = true;
            Acceleration = vect(0,0,0);
            SetAnimAction('FireEndMG');
            HandleWaitForAnim('FireEndMG');
            GoToState('');
        }
        else
        {
            if ( Controller.Enemy != none )
            {
                if ( Controller.LineOfSightTo(Controller.Enemy) && FastTrace(GetBoneCoords('tip').Origin,Controller.Enemy.Location))
                {
                    MGLostSightTimeout = 0.0;
                    Controller.Focus = Controller.Enemy;
                    Controller.FocalPoint = Controller.Enemy.Location;
                }
                else
                {
                    MGLostSightTimeout = Level.TimeSeconds + (0.25 + FRand() * 0.35);
                    Controller.Focus = none;
                }

                Controller.Target = Controller.Enemy;
            }
            else
            {
                MGLostSightTimeout = Level.TimeSeconds + (0.25 + FRand() * 0.35);
                Controller.Focus = none;
            }

            if ( FRand() < 0.03 && Controller.Enemy != none && PlayerController(Controller.Enemy.Controller) != none )
            {
                PlayerController(Controller.Enemy.Controller).Speech('AUTO', 9, "");
            }

            bFireAtWill = true;
            bShotAnim = true;
            Acceleration = vect(0,0,0);

            SetAnimAction('FireMG');
            bWaitForAnim = true;
        }
    }

    function FireMGShot()
    {
        local vector Start,End,HL,HN,Dir;
        local rotator R;
        local Actor A;
        local KFPawn KFP;
        local float Dist;

        KFP = KFPawn(Controller.Target);
        Dist = VSize(Controller.Target.Location-Location);

        MGFireCounter--;

        if( AmbientSound != MiniGunFireSound )
        {
            SoundVolume=255;
            SoundRadius=400;
            AmbientSound = MiniGunFireSound;
        }

        Start = GetBoneCoords('tip').Origin;
        if( Controller.Focus!=none )
            R = rotator(Controller.Focus.Location-Start);
        else R = rotator(Controller.FocalPoint-Start);
        if( NeedToTurnFor(R) )
            R = Rotation;
        Dir = Normal(vector(R)+VRand()*MGAccuracy);
        End = Start+Dir*10000;

        bBlockHitPointTraces = false;
        A = Trace(HL,HN,End,Start,true);
        bBlockHitPointTraces = true;

        if( A==none )
            return;
        TraceHitPos = HL;
        if( Level.NetMode!=NM_DedicatedServer )
            AddTraceHitFX(HL);

        if( A!=Level )
        {
            // This spams server logs with "Accessed None PlayerReplicationInfo"
            if(KFPlayerReplicationInfo(KFP.PlayerReplicationInfo).ClientVeteranSkill != class'KFVetBerserker' &&
               KFPlayerReplicationInfo(KFP.PlayerReplicationInfo) != none)
                A.TakeDamage(MGDamage,self,HL,Dir*500,MGDamageType);
            else
                A.TakeDamage((MGDamage + 1),self,HL,Dir*500,MGDamageType);
        }
        else    return;
    }

    function bool NeedToTurnFor( rotator targ )
    {
        local int YawErr;

        targ.Yaw = DesiredRotation.Yaw & 65535;
        YawErr = (targ.Yaw - (Rotation.Yaw & 65535)) & 65535;
        return !((YawErr < 2000) || (YawErr > 64535));
    }

Begin:
    While( true )
    {
        Acceleration = vect(0,0,0);

        if( MGLostSightTimeout > 0 && Level.TimeSeconds > MGLostSightTimeout )
        {
            bShotAnim = true;
            Acceleration = vect(0,0,0);
            SetAnimAction('FireEndMG');
            HandleWaitForAnim('FireEndMG');
            GoToState('');
        }

        if( MGFireCounter <= 0 )
        {
            bShotAnim = true;
            Acceleration = vect(0,0,0);
            SetAnimAction('FireEndMG');
            HandleWaitForAnim('FireEndMG');
            GoToState('');
        }

        if(bDecapitated)
        {
            SetAnimAction('HitF');
            GoToState('');
        }

        if( bFireAtWill )
            FireMGShot();
        Sleep(MGFireRate);
    }
}

simulated function PostNetReceive()
{
    if( bClientMiniGunning != bMinigunning )
    {
        bClientMiniGunning = bMinigunning;
        // Hack so Patriarch won't go out of MG Firing to play his idle anim online
        if( bMinigunning )
        {
            IdleHeavyAnim='FireMG';
            IdleRifleAnim='FireMG';
            IdleCrouchAnim='FireMG';
            IdleWeaponAnim='FireMG';
            IdleRestAnim='FireMG';
        }
        else
        {
            IdleHeavyAnim='PoundIdle';
            IdleRifleAnim='PoundIdle';
            IdleCrouchAnim='PoundIdle';
            IdleWeaponAnim='PoundIdle';
            IdleRestAnim='PoundIdle';
        }
    }

    if( bClientCharge!=bChargingPlayer && !bZapped )
    {
        bClientCharge = bChargingPlayer;
        if (bChargingPlayer)
        {
            MovementAnims[0]=ChargingAnim;
            MeleeAnims[0]='FPRageAttack';
            MeleeAnims[1]='FPRageAttack';
            MeleeAnims[2]='FPRageAttack';
            DeviceGoRed();
        }
        else
        {
            MovementAnims[0]=default.MovementAnims[0];
            MeleeAnims[0]=default.MeleeAnims[0];
            MeleeAnims[1]=default.MeleeAnims[1];
            MeleeAnims[2]=default.MeleeAnims[2];
            DeviceGoNormal();
        }
    }

    if( TraceHitPos!=vect(0,0,0) )
    {
        AddTraceHitFX(TraceHitPos);
        TraceHitPos = vect(0,0,0);
    }
}

function ClawDamageTarget()
{
    local vector PushDir;
    local KFHumanPawn HumanTarget;
    local KFPlayerController HumanTargetController;
    local float UsedMeleeDamage;
    local name  Sequence;
    local float Frame, Rate;

    GetAnimParams( ExpectingChannel, Sequence, Frame, Rate );

    if( MeleeDamage > 1 )
    {
       UsedMeleeDamage = (MeleeDamage - (MeleeDamage * 0.05)) + (MeleeDamage * (FRand() * 0.1));
    }
    else
    {
       UsedMeleeDamage = MeleeDamage;
    }

    // Reduce the melee damage for anims with repeated attacks, since it does repeated damage over time
    if( Sequence == 'PoundAttack1' )
    {
        UsedMeleeDamage *= 0.5;
    }

    if(Controller!=none && Controller.Target!=none)
    {
        //calculate based on relative positions
        PushDir = (damageForce * Normal(Controller.Target.Location - Location));
    }
    else
    {
        //calculate based on way Monster is facing
        PushDir = damageForce * vector(Rotation);
    }
    if ( MeleeDamageTarget( UsedMeleeDamage, PushDir))
    {
        HumanTarget = KFHumanPawn(Controller.Target);
        if( HumanTarget!=None )
            HumanTargetController = KFPlayerController(HumanTarget.Controller);
        if( HumanTargetController!=None )
            HumanTargetController.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);
        PlaySound(MeleeAttackHitSound, SLOT_Interact, 1.25);
    }
}

simulated function int DoAnimAction( name AnimName )
{
    if( AnimName=='PoundAttack1' || AnimName=='FPRageAttack' || AnimName=='PoundAttack3' || AnimName=='FireEndMG')
    {
        AnimBlendParams(1, 1.0, 0.0,, FireRootBone);
        PlayAnim(AnimName,, 0.1, 1);
        Return 1;
    }
    Return Super.DoAnimAction(AnimName);
}

simulated event SetAnimAction(name NewAction)
{
    local int meleeAnimIndex;

    if( NewAction=='' )
        return;
    if(NewAction == 'Claw')
    {
        meleeAnimIndex = Rand(3);
        NewAction = meleeAnims[meleeAnimIndex];
        CurrentDamtype = ZombieDamType[meleeAnimIndex];
    }
    else if( NewAction == 'DoorBash' )
    {
       CurrentDamtype = ZombieDamType[Rand(3)];
    }
    ExpectingChannel = DoAnimAction(NewAction);

    if( Controller != none )
    {
       ControllerZFPRA(Controller).AnimWaitChannel = ExpectingChannel;
    }

    if( AnimNeedsWait(NewAction) )
    {
        bWaitForAnim = true;
    }
    else
    {
        bWaitForAnim = false;
    }

    if( Level.NetMode!=NM_Client )
    {
        AnimAction = NewAction;
        bResetAnimAct = true;
        ResetAnimActTime = Level.TimeSeconds+0.3;
    }
}

simulated function HandleWaitForAnim( name NewAnim )
{
    local float RageAnimDur;

    Controller.GoToState('WaitForAnim');
    RageAnimDur = GetAnimDuration(NewAnim);

    ControllerZFPRA(Controller).SetWaitForAnimTimout(RageAnimDur,NewAnim);
}

simulated function bool AnimNeedsWait(name TestAnim)
{
    if( TestAnim == 'FireMG' || TestAnim == 'PreFireMG' || TestAnim == 'FireEndMG' ||
        TestAnim == 'PoundRage' || TestAnim == 'DoorBash' )
    {
        return true;
    }

    return false;
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
    local int OldHealth;
    local bool bIsHeadShot;
    local float HeadShotCheckScale;


    if( LastDamagedTime<Level.TimeSeconds )
        TwoSecondDamageTotal = 0;
    LastDamagedTime = Level.TimeSeconds+2;
    OldHealth = Health; // Corrected issue where only the Base Health is counted toward the FP's Rage in Balance Round 6(second attempt)

    HeadShotCheckScale = 1.0;

    // Do larger headshot checks if it is a melee attach
    if( class<DamTypeMelee>(damageType) != none )
    {
        HeadShotCheckScale *= 1.25;
    }

    bIsHeadShot = IsHeadShot(Hitlocation, normal(Momentum), 1.0);

    // He takes less damage to small arms fire (non explosives)
    // Frags and LAW rockets will bring him down way faster than bullets and shells.
    if ( DamageType != class 'DamTypeFrag' && DamageType != class 'DamTypeLaw' && DamageType != class 'DamTypePipeBomb'
        && DamageType != class 'DamTypeM79Grenade' && DamageType != class 'DamTypeM32Grenade'
        && DamageType != class 'DamTypeM203Grenade' && DamageType != class 'DamTypeMedicNade'
        && DamageType != class 'DamTypeSPGrenade' && DamageType != class 'DamTypeSealSquealExplosion'
        && DamageType != class 'DamTypeSeekerSixRocket' )
    {
        // Don't reduce the damage so much if its a high headshot damage weapon
        if( bIsHeadShot && class<KFWeaponDamageType>(damageType)!=none &&
            class<KFWeaponDamageType>(damageType).default.HeadShotDamageMult >= 1.5 )
        {
            Damage *= 0.75;
        }
        else if ( Level.Game.GameDifficulty >= 5.0 && bIsHeadshot && (class<DamTypeCrossbow>(damageType) != none || class<DamTypeCrossbowHeadShot>(damageType) != none) )
        {
            Damage *= 0.35; // was 0.3 in Balance Round 1, then 0.4 in Round 2, then 0.3 in Round 3/4, and 0.35 in Round 5
        }
        else
        {
            Damage *= 0.5;
        }
    }
    // double damage from handheld explosives or poison
    else if (DamageType == class 'DamTypeFrag' || DamageType == class 'DamTypePipeBomb' || DamageType == class 'DamTypeMedicNade' )
    {
        Damage *= 2.0;
    }
    // A little extra damage from the grenade launchers, they are HE not shrapnel,
    // and its shrapnel that REALLY hurts the FP ;)
    else if( DamageType == class 'DamTypeM79Grenade' || DamageType == class 'DamTypeM32Grenade'
         || DamageType == class 'DamTypeM203Grenade' || DamageType == class 'DamTypeSPGrenade'
         || DamageType == class 'DamTypeSealSquealExplosion' || DamageType == class 'DamTypeSeekerSixRocket')
    {
        Damage *= 1.25;
    }

    // Shut off his "Device" when dead
    if (Damage >= Health)
        PostNetReceive();

    if (damageType == class 'DamTypeVomit' || damageType == MGDamageType)
    {
        Damage = 0; // nulled
    }
    else if( damageType == class 'DamTypeBlowerThrower' )
    {
       // Reduced damage from the blower thrower bile, but lets not zero it out entirely
       Damage *= 0.25;
    }

    Super.takeDamage(Damage, instigatedBy, hitLocation, momentum, damageType,HitIndex) ;

    TwoSecondDamageTotal += OldHealth - Health; // Corrected issue where only the Base Health is counted toward the FP's Rage in Balance Round 6(second attempt)
//
    if (!bDecapitated && TwoSecondDamageTotal > RageDamageThreshold && !bChargingPlayer &&
        !bZapped && (!(bCrispified && bBurnified) || bFrustrated) )
        StartCharging();

}

function OldPlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, optional int HitIndex)
{
    if(LastChainGunTime<Level.TimeSeconds + 1)
        return;

        super.OldPlayHit(Damage,InstigatedBy,HitLocation,damageType,Momentum,HitIndex);
}

simulated function Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    // Keep the flesh pound moving toward its target when attacking
    if( Role == ROLE_Authority && bShotAnim)
    {
        if( LookTarget!=None && !IsInState('FireChaingun') )
        {
            Acceleration = AccelRate * Normal(LookTarget.Location - Location);
        }
    }
}

function bool SameSpeciesAs(Pawn P)
{
    return (ZombieFleshPound(P)!=None || ZFPRA(P)!=None);
}

defaultproperties
{
    ControllerClass=class'RangedPound.ControllerZFPRA'
}