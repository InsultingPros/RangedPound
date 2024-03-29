/*
 * Standard Variant
 *
 * Author       : theengineertcr
 * Home Repo    : https://github.com/theengineertcr/RangedPound
 * License      : GPL 3.0
 * Copyright    : 2023 theengineertcr
 */
class ZFPRA_S extends ZFPRA;

function PatriarchMGPreFire() {
    PlaySound(Sound'KF_BaseFleshpound.FP_Challenge1', SLOT_Misc, 2.0, true, 1000.0);
}

defaultproperties {
    MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Talk'
    MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_HitPlayer'
    JumpSound=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Jump'
    DetachedArmClass=class'KFChar.SeveredArmPound'
    DetachedLegClass=class'KFChar.SeveredLegPound'
    DetachedHeadClass=class'KFChar.SeveredHeadPound'
    HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Pain'
    DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Death'
    ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
    ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
    ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
    ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
    AmbientSound=Sound'KF_BaseFleshpound.FP_IdleLoop'
    Mesh=SkeletalMesh'RangedPound.FleshpoundGunner'
    Skins(0)=Combiner'KF_Specimens_Trip_T.fleshpound_cmb'
}