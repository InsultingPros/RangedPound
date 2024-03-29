/*
 * Author       : theengineertcr
 * Home Repo    : https://github.com/theengineertcr/RangedPound
 * License      : GPL 3.0
 * Copyright    : 2023 theengineertcr
 */
class DamTypeMG extends KFProjectileWeaponDamageType
    abstract;

defaultproperties {
    DeathString="%o was killed by %k."
    FemaleSuicide="%o shot herself in the foot."
    MaleSuicide="%o shot himself in the foot."
    bRagdollBullet=true
    KDamageImpulse=1500.000000
    KDeathVel=110.000000
    KDeathUpKick=2.000000
    PawnDamageEmitter=class'ROEffects.ROBloodPuff'
    LowGoreDamageEmitter=class'ROEffects.ROBloodPuffNoGore'
    LowDetailEmitter=class'ROEffects.ROBloodPuffSmall'
}