/*
 * XMas Variant
 *
 * Author       : theengineertcr
 * Home Repo    : https://github.com/theengineertcr/RangedPound
 * License      : GPL 3.0
 * Copyright    : 2023 theengineertcr
 */
class ZFPRA_X extends ZFPRA;

function PatriarchMGPreFire() {
    PlaySound(Sound'KF_BaseFleshpound_XMas.FP_Talk28', SLOT_Misc, 2.0, true, 1000.0);
}

simulated function DeviceGoRed() {
    Skins[2] = Shader'KFCharacters.FPRedBloomShader';
}

simulated function DeviceGoNormal() {
    Skins[2] = Shader'KFCharacters.FPAmberBloomShader';
}

defaultproperties {
    MoanVoice=SoundGroup'KF_EnemiesFinalSnd_Xmas.Fleshpound.FP_Talk'
    MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Fleshpound.FP_HitPlayer'
    JumpSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Fleshpound.FP_Jump'
    DetachedArmClass=class'KFChar.SeveredArmPound_XMas'
    DetachedLegClass=class'KFChar.SeveredLegPound_XMas'
    DetachedHeadClass=class'KFChar.SeveredHeadPound_XMas'
    HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Fleshpound.FP_Pain'
    DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Fleshpound.FP_Death'
    ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Fleshpound.FP_Challenge'
    ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Fleshpound.FP_Challenge'
    ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Fleshpound.FP_Challenge'
    ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Fleshpound.FP_Challenge'
    MenuName="Nutpound Gunner"
    AmbientSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Fleshpound.FP_Idle'
    Mesh=SkeletalMesh'RangedPound.FleshpoundGunner_XMas'
    Skins(0)=Combiner'KF_Specimens_Trip_XMAS_T.NutPound.NutPound_cmb'
    Skins(1)=FinalBlend'KF_Specimens_Trip_XMAS_T.NutPound.nutpound_hair_fb'
    Skins(2)=Shader'KFCharacters.FPAmberBloomShader'
}