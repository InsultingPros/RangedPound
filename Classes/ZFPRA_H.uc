//Halloween Variant
class ZFPRA_H extends ZFPRA;

function PatriarchMGPreFire()
{
	PlaySound(Sound'KF_BaseFleshpound_HALLOWEEN.FP_Talk03', SLOT_Misc, 2.0,true,1000.0);
}

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Fleshpound.FP_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Fleshpound.FP_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Fleshpound.FP_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmPound_HALLOWEEN'
     DetachedLegClass=Class'KFChar.SeveredLegPound_HALLOWEEN'
     DetachedHeadClass=Class'KFChar.SeveredHeadPound_HALLOWEEN'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Fleshpound.FP_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Fleshpound.FP_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Fleshpound.FP_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Fleshpound.FP_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Fleshpound.FP_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Fleshpound.FP_Challenge'
     MenuName="HALLOWEEN Flesh Pound Gunner"
     AmbientSound=Sound'KF_BaseFleshpound_HALLOWEEN.FP_Idle1Loop'
     Mesh=SkeletalMesh'RangedPound.FleshpoundGunner_Halloween'
     Skins(0)=Combiner'KF_Specimens_Trip_HALLOWEEN_T.Fleshpound.Fleshpound_RedneckZombie_CMB'
}