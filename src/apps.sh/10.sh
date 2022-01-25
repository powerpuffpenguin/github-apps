######    version   ######
appVersionGetValue=""
function appVersionGet
{
    appVersionGetValue=""
    local app="$1"
    CallbackClear
    FlagsPush

    set +e
    local v
    source "$Configure/$app.sh"
    v=$(AppsPlatform)
    if [[ $? == 0 ]];then
        AppsPlatform
    fi
    if [[ "$FlagInstallDir" != "" ]];then
        local versionFile="$FlagInstallDir/apps.version"
        if [[ -f "$versionFile" ]];then
            appVersionGetValue=$(cat "$versionFile")
            appVersionParse "$appVersionGetValue"
            if [[ $appVersionOk == 0 ]];then
                appVersionGetValue=""
            fi
            set -e
            FlagsPop
            return 
        fi
    fi
    set -e
    FlagsPop
}
function appVersionParse
{
    appVersionOk=0
    appVersionX=0
    appVersionY=0
    appVersionZ=0

    local str="$1"
    str=${str#v}
    str="$str."
    local tmp=${str#*.}
    if [[ "$tmp" == "$str" ]];then
        return
    fi
    local x=${str::${#str}-${#tmp}-1}
    if [[  ! "$x" =~ ^[0-9]+$ ]];then
        return
    fi

    str=$tmp
    tmp=${str#*.}
    if [[ "$tmp" == "$str" ]];then
        return
    fi
    local y=${str::${#str}-${#tmp}-1}
    if [[  ! "$y" =~ ^[0-9]+$ ]];then
        return
    fi
    
    str=$tmp
    tmp=${str#*.}
    if [[ "$tmp" == "$str" || "$tmp" != "" ]];then
        return
    fi
    local z=${str::${#str}-${#tmp}-1}
    if [[  ! "$z" =~ ^[0-9]+$ ]];then
        return
    fi

    appVersionOk=1
    appVersionX=$x
    appVersionY=$y
    appVersionZ=$z
}
function VersionCurreant
{
    appVersionParse "$1"

    VersionCurreantOk=$appVersionOk
    VersionCurreantX=$appVersionX
    VersionCurreantY=$appVersionY
    VersionCurreantZ=$appVersionZ
}
function VersionNext
{
    appVersionParse "$1"

    VersionNextOk=$appVersionOk
    VersionNextX=$appVersionX
    VersionNextY=$appVersionY
    VersionNextZ=$appVersionZ
}

# return VersionCompareValue
# * 0 equal
# * 1 matched
# * 2 not matched
# * 3 matched but less
function VersionCompare
{
    if [[ "$VersionCurreantX" == 0 &&  "$VersionNextX" == 1 ]];then
        VersionCompareValue=1
    elif [[ "$VersionCurreantX" != "$VersionNextX" ]];then
        VersionCompareValue=2
    else
        if (($VersionCurreantY<$VersionNextY));then
            VersionCompareValue=1
        elif (($VersionCurreantY==$VersionNextY));then
            if (($VersionCurreantZ<$VersionNextZ));then
                VersionCompareValue=1
            elif (($VersionCurreantZ==$VersionNextZ));then
                VersionCompareValue=0
            else
                VersionCompareValue=3
            fi
        else
            VersionCompareValue=3
        fi
    fi
}