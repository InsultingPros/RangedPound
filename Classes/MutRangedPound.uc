/*
 * Mutator that replaces Fleshpounds(including seasonal variants) with their gunner counter-part
 * All code taken from Marco's Mixed Zeds Mut
 *
 * Author       : theengineertcr
 * Home Repo    : https://github.com/theengineertcr/RangedPound
 * License      : GPL 3.0
 * Copyright    : 2023 theengineertcr
 */
class MutRangedPound extends Mutator;

function PostBeginPlay()
{
    SetTimer(0.1,False);
}

function Timer()
{
    local KFGameType KF;
    local int i,j;

    KF = KFGameType(Level.Game);

    if (KF == none)
    {
        log("KFGameType not found, terminating!", self.name);
        Destroy();
        return;
    }

    if ( KF!=None )
    {
        for( i=0; i<KF.InitSquads.Length; i++ )
        {
            for( j=0; j<KF.InitSquads[i].MSquad.Length; j++ )
                KF.InitSquads[i].MSquad[j] = GetReplaceClass(KF.InitSquads[i].MSquad[j]);
        }
        for( i=0; i<KF.MonsterCollection.default.SpecialSquads.Length; i++ )
        {
            for( j=0; j<KF.MonsterCollection.default.SpecialSquads[i].ZedClass.Length; j++ )
                ReplaceMonsterStr(KF.MonsterCollection.default.SpecialSquads[i].ZedClass[j]);
        }
        for( i=0; i<KF.MonsterCollection.default.FinalSquads.Length; i++ )
        {
            for( j=0; j<KF.MonsterCollection.default.FinalSquads[i].ZedClass.Length; j++ )
                ReplaceMonsterStr(KF.MonsterCollection.default.FinalSquads[i].ZedClass[j]);
        }
    }

    Destroy();
}

//In the order of seasons, chronologically :)
final function Class<KFMonster> GetReplaceClass( Class<KFMonster> MC )
{
    switch( MC )
    {
    case Class'ZombieFleshpound_STANDARD':
        return Class'ZFPRA_S';
    case Class'ZombieFleshpound_CIRCUS':
        return Class'ZFPRA_C';
    case Class'ZombieFleshpound_HALLOWEEN':
        return Class'ZFPRA_H';
    case Class'ZombieFleshpound_XMAS':
        return Class'ZFPRA_X';
    default:
        return MC;
    }
}

final function ReplaceMonsterStr( out string MC )
{
    if( MC~="KFChar.ZombieFleshpound_STANDARD" )
        MC = "RangedPound.ZFPRA_S";
    if( MC~="KFChar.ZombieFleshpound_CIRCUS" )
        MC = "RangedPound.ZFPRA_C";
    if( MC~="KFChar.ZombieFleshpound_HALLOWEEN" )
        MC = "RangedPound.ZFPRA_H";
    if( MC~="KFChar.ZombieFleshpound_XMAS" )
        MC = "RangedPound.ZFPRA_X";
}

defaultproperties
{
    // Don't be active with TWI muts
    GroupName="KF-MonsterMut"
    FriendlyName="Ranged Fleshpounds"
    Description="Regular Fleshpounds are replaced with their Chaingun variant. Have fun!"

    bAlwaysRelevant=true
    RemoteRole=ROLE_SimulatedProxy
    bAddToServerPackages=true
}