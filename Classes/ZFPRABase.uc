/*
 * Author       : theengineertcr
 * Home Repo    : https://github.com/theengineertcr/RangedPound
 * License      : GPL 3.0
 * Copyright    : 2023 theengineertcr
 */
class ZFPRABase extends KFMonster;

var bool bChargingPlayer, bClientCharge;
var bool bFrustrated;
var int TwoSecondDamageTotal;
var float LastDamagedTime, RageEndTime;
var() int RageDamageThreshold;
var bool bFireAtWill, bMinigunning;
var float LastChainGunTime;
var vector TraceHitPos;
var Emitter mTracer, mMuzzleFlash;
var int MGFireCounter;
var bool bClientMiniGunning;
var float MGLostSightTimeout;
var() float MGDamage;
var() float MGAccuracy;
var() float MGFireRate;
var() int MGFireBurst;
var() float MGFireInterval;
var() class <DamageType> MGDamageType;

var(Sounds) sound MiniGunFireSound;
var(Sounds) sound MiniGunSpinSound;
var() vector RotMag;
var() vector RotRate;
var() float RotTime;
var() vector OffsetMag;
var() vector OffsetRate;
var() float OffsetTime;
var FleshPoundAvoidArea AvoidArea;
var name ChargingAnim;

//Variables for tweaking under the mutator
var() float MGDamMult;      // Minigun Damage Multiplier
var() float MGAccMult;      // Minigun Accuracy Multiplier
var() float MGRoFMult;      // Minigun Rate of Fire Multiplier
var() float MGBurstMult;    // Minigun Burst Multiplier
var() float MGDelayMult;    // Minigun Delay Multiplier

replication {
    reliable if (Role == ROLE_Authority)
        bChargingPlayer, bFrustrated, TraceHitPos, bMinigunning;
}

defaultproperties {
    RageDamageThreshold=360
    MiniGunFireSound=Sound'KF_BasePatriarch.Attack.Kev_MG_GunfireLoop'
    MiniGunSpinSound=Sound'KF_BasePatriarch.Attack.Kev_MG_TurbineFireLoop'
    MGDamageType=class'DamTypeMG'
    StunsRemaining=1
    BleedOutDuration=7.000000
    ZapThreshold=1.750000
    ZappedDamageMod=1.250000
    bHarpoonToBodyStuns=false
    DamageToMonsterScale=5.000000
    ZombieFlag=3
    MeleeDamage=35
    MGFireInterval=15.0
    MGDamage=2.0
    MGAccuracy=0.04
    MGFireRate=0.06
    MGFireBurst=15
    damageForce=15000
    bFatAss=true
    KFRagdollName="FleshPound_Trip"
    bMeleeStunImmune=true
    Intelligence=BRAINS_Mammal
    bUseExtendedCollision=true
    ColOffset=(Z=52.000000)
    ColRadius=36.000000
    ColHeight=35.000000
    SeveredArmAttachScale=1.300000
    SeveredLegAttachScale=1.200000
    SeveredHeadAttachScale=1.500000
    PlayerCountHealthScale=0.250000
    OnlineHeadshotOffset=(X=22.000000,Z=68.000000)
    OnlineHeadshotScale=1.300000
    HeadHealth=700.000000
    PlayerNumHeadHealthScale=0.300000
    MotionDetectorThreat=5.000000
    bBoss=true
    ScoringValue=200
    RagDeathUpKick=100.000000
    MeleeRange=55.000000
    GroundSpeed=130.000000
    WaterSpeed=120.000000
    HealthMax=1500.000000
    Health=1500
    HeadHeight=2.500000
    HeadScale=1.300000
    MenuName="Flesh Pound Chaingunner"
    MovementAnims(0)="PoundWalk"
    MovementAnims(1)="WalkB"
    WalkAnims(0)="PoundWalk"
    WalkAnims(1)="WalkB"
    WalkAnims(2)="RunL"
    WalkAnims(3)="RunR"
    IdleCrouchAnim="PoundIdle"
    IdleWeaponAnim="PoundIdle"
    IdleRestAnim="PoundIdle"
    IdleHeavyAnim="PoundIdle"
    IdleRifleAnim="PoundIdle"
    MeleeAnims(0)="PoundAttack1"
    MeleeAnims(1)="PoundAttack3"
    MeleeAnims(2)="PoundAttack1"
    PrePivot=(Z=0.000000)
    Skins(1)=Shader'KFCharacters.FPAmberBloomShader'
    Mass=600.000000
    RotationRate=(Yaw=45000,Roll=0)
    ChargingAnim="PoundRun"
    MGDamMult=1.0
    MGAccMult=1.0
    MGBurstMult=1.0
    MGDelayMult=1.0
    MGRoFMult=1.0
}