//Circus Variant
class ZFPRA_C extends ZFPRA;

#exec OBJ LOAD FILE=KF_BaseFleshpound_CIRCUS.uax

function PatriarchMGPreFire()
{
	PlaySound(Sound'KF_BaseFleshpound_CIRCUS.FP_Talk22', SLOT_Misc, 2.0,true,1000.0);
}

simulated function DeviceGoRed()
{
	Skins[0]= Shader'KF_Specimens_Trip_CIRCUS_T.pound_CIRCUS.pound_CIRCUS_Red_Shdr';
	Skins[1]= Shader'KFCharacters.FPRedBloomShader';
}

simulated function DeviceGoNormal()
{
	Skins[0] = Shader'KF_Specimens_Trip_CIRCUS_T.pound_CIRCUS.pound_CIRCUS_Amber_Shdr';
	Skins[1] = Shader'KFCharacters.FPAmberBloomShader';
}

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Fleshpound.FP_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Fleshpound.FP_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Fleshpound.FP_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmPound_CIRCUS'
     DetachedLegClass=Class'KFChar.SeveredLegPound_CIRCUS'
     DetachedHeadClass=Class'KFChar.SeveredHeadPound_CIRCUS'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Fleshpound.FP_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Fleshpound.FP_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Fleshpound.FP_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Fleshpound.FP_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Fleshpound.FP_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Fleshpound.FP_Challenge'
     MenuName="Circus Flesh Pound Gunner"
     AmbientSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Fleshpound.FP_Idle'
     Mesh=SkeletalMesh'RangedPound.FleshpoundGunner_Summer'
     Skins(0)=Shader'KF_Specimens_Trip_CIRCUS_T.pound_CIRCUS.pound_CIRCUS_Amber_Shdr'
}