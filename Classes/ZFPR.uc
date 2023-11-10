/*
 * Original, untouched code
 * Zombie Monster for KF Invasion gametype
 *
 * Author       : theengineertcr
 * Home Repo    : https://github.com/theengineertcr/RangedPound
 * License      : GPL 3.0
 * Copyright    : 2023 theengineertcr
 */
class ZFPR extends ZombieFleshPound_STANDARD;

var float NextMinigunTime;
var byte MGFireCounter;
var vector TraceHitPos;
var Emitter mTracer,mMuzzleFlash;
var bool bHadAdjRot;

replication {
    reliable if (Role == ROLE_Authority)
        TraceHitPos;
}

function SpawnTwoShots();
simulated function DeviceGoRed();
simulated function DeviceGoNormal();

function RangedAttack(Actor A) {
    if (bShotAnim) {
        return;
    } else if (CanAttack(A)) {
        bShotAnim = true;
        DoAnimAction('TurnLeft');
        Controller.bPreparingMove = true;
        Acceleration = vect(0, 0, 0);
        MGFireCounter = Rand(20);
        FireMGShot();
        GoToState('Minigunning');
    } else if (
        VSize(A.Location - Location) <= 1200 &&
        NextMinigunTime < Level.TimeSeconds &&
        !bDecapitated
    ) {
        if (FRand() < 0.25) {
            NextMinigunTime = Level.TimeSeconds + FRand() * 10;
            return;
        }
        NextMinigunTime = Level.TimeSeconds + 10 + FRand() * 60;
        bShotAnim = true;
        DoAnimAction('TurnLeft');
        Acceleration = vect(0, 0, 0);
        MGFireCounter = Rand(20);
        FireMGShot();
        GoToState('Minigunning');
    }
}

simulated function AnimEnd(int Channel) {
    if (Channel == 1 && Level.NetMode != NM_DedicatedServer && bHadAdjRot) {
        bHadAdjRot = false;
        SetBoneDirection(LeftFArmBone, Rotation,, 0, 0);
    }
    if (Channel == 1 && Level.NetMode != NM_Client) {
        bShotAnim = false;
    }
    super.AnimEnd(Channel);
}

simulated function int DoAnimAction(name AnimName) {
    if (AnimName == 'TurnLeft') {
        AnimBlendParams(1, 1.0, 0.0,, SpineBone1);
        PlayAnim(AnimName,10.f, 0.1, 1);
        return 1;
    }
    return super.DoAnimAction(AnimName);
}

State Minigunning {
Ignores StartCharging,PlayTakeHit;

    function RangedAttack(Actor A) {
        Controller.Target = A;
        Controller.Focus = A;
    }

    function EndState() {
        TraceHitPos = vect(0, 0, 0);
        GroundSpeed = default.GroundSpeed;
    }

    function BeginState() {
        GroundSpeed = 90;
    }

    function AnimEnd( int Channel ) {
        if (Channel != 1) {
            return;
        }
        MGFireCounter++;
        if (Controller.Enemy != none && Controller.Target == Controller.Enemy) {
            if (Controller.LineOfSightTo(Controller.Enemy)) {
                Controller.Focus = Controller.Enemy;
                Controller.FocalPoint = Controller.Enemy.Location;
            } else {
                Controller.Focus = none;
                Acceleration = vect(0, 0, 0);
                if (!Controller.IsInState('WaitForAnim')) {
                    Controller.GoToState('WaitForAnim');
                }
            }
            Controller.Target = Controller.Enemy;
        } else {
            Controller.Focus = Controller.Target;
            Acceleration = vect(0, 0, 0);
            if (!Controller.IsInState('WaitForAnim')) {
                Controller.GoToState('WaitForAnim');
            }
        }

        FireMGShot();
        bShotAnim = true;
        DoAnimAction('TurnLeft');
        bWaitForAnim = true;
        if (MGFireCounter >= 70 || Controller.Target == none) {
            GoToState('');
        }
    }

Begin:
    while (true) {
        Acceleration = vect(0, 0, 0);
        Sleep(0.15);
    }
}

function FireMGShot() {
    local vector Start, End, HL, HN, Dir;
    local rotator R;
    local Actor A;

    Start = GetBoneCoords('CHR_L_Blade3').Origin;
    if (Controller.Focus != none) {
        R = rotator(Controller.Focus.Location - Start);
    } else {
        R = rotator(Controller.FocalPoint - Start);
    }
    Dir = Normal(vector(R) + VRand() * 0.04);
    End = Start + Dir * 10000;
    // Have to turn of hit point collision so trace doesn't hit the Human Pawn's bullet whiz cylinder
    bBlockHitPointTraces = false;
    A = Trace(HL, HN, End, Start, true);
    bBlockHitPointTraces = true;
    if (A == none) {
        return;
    }
    TraceHitPos = HL;
    if (Level.NetMode != NM_DedicatedServer) {
        AddTraceHitFX(HL);
    }
    if (A != Level) {
        A.TakeDamage(1 + Rand(3), self, HL, Dir * 100, class'DamageType');
    }
}

simulated function AddTraceHitFX(vector HitPos) {
    local vector Start, SpawnVel, SpawnDir;
    local float hitDist;
    local KFHitEffect H;
    local rotator FireDir;

    if (Level.NetMode == NM_Client) {
        DoAnimAction('TurnLeft');
    }
    Start = GetBoneCoords('CHR_L_Blade3').Origin;
    if (mTracer == none) {
        mTracer = Spawn(class'NewTracer',,, Start);
    } else {
        mTracer.SetLocation(Start);
    }
    FireDir = rotator(HitPos - Start);
    if (mMuzzleFlash == none) {
        mMuzzleFlash = Spawn(class'MuzzleFlash3rdMP',,, Start, FireDir);
    } else {
        mMuzzleFlash.SetRotation(FireDir);
        mMuzzleFlash.SetLocation(Start);
    }
    mMuzzleFlash.Trigger(self, self);
    hitDist = VSize(HitPos - Start) - 50.f;
    SetBoneDirection(LeftFArmBone, FireDir,, 1.0, 1);
    bHadAdjRot = true;
    PlaySound(Sound'Bullpup_Fire');
    if (hitDist > 10) {
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
    Instigator = self;
    H = Spawn(class'KFHitEffect',,, HitPos);
    if (H != none) {
        H.RemoteRole = ROLE_None;
    }
}

simulated function PostNetReceive() {
    if (TraceHitPos != vect(0 ,0, 0)) {
        AddTraceHitFX(TraceHitPos);
        TraceHitPos = vect(0, 0, 0);
    } else {
        super.PostNetReceive();
    }
}

simulated function Destroyed() {
    if (mTracer != none) {
        mTracer.Destroy();
    }
    if (mMuzzleFlash != none) {
        mMuzzleFlash.Destroy();
    }
    super.Destroyed();
}

defaultproperties {
    MenuName="Flesh Pound Chaingunner"
    ZombieFlag=1
    MeleeDamage=16
    damageForce=150000
    ScoringValue=12
    HealthMax=1600.000000
    Health=1600
}