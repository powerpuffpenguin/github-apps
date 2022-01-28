#!/usr/bin/env bash
# merge bash
######    src/github-apps.sh/0.sh   ######
######    configure   ######
set -e

function FlagsClear
{
    # if platform not supported, set error in this
    FlagPlatformError=""

    # if not 0 only test commands don't actually change apps
    FlagTest=0
    # app install dir
    FlagInstallDir=""
    # target version
    FlagVersion=""
    # if not 0 automatic 'yes' to prompts
    FlagYes=0
    # if not 0 automatic 'no' to prompts
    FlagNo=0
    # if 0 not check sum
    FlagSum=1
    
    # if not 0 delete configuration file
    FlagDeleteConf=0
    # if not 0 delete data file
    FlagDeleteData=0

    # download file url
    FlagDownloadFile=""
    # download hash file url
    FlagDownloadHash=""
    # http url return latest version info
    FlagUrlLatest=""
    # http url return list version info
    FlagUrlList=""
    # http url return tag version info
    FlagUrlTag=""
}
# Command
# Root dir
if [[ "$BASH_SOURCE" == "" ]];then
    Root=$(pwd)
    Command="install.sh"
else
    Root=$(cd $(dirname $BASH_SOURCE) && pwd)
    Command=$(basename $BASH_SOURCE)
fi
# Configure dir
Configure="$Root/github-apps.configure"
# Cache dir
Cache="$Root/github-apps.cache"


if [[ ! -d "$Cache" ]];then
    mkdir "$Cache"
fi

FlagsClear
function FlagsPush
{
    __FlagPlatformError=$FlagPlatformError

    __FlagTest=$FlagTest
    __FlagInstallDir=$FlagInstallDir
    __FlagVersion=$FlagVersion
    __FlagYes=$FlagYes
    __FlagNo=$FlagNo
    __FlagSum=$FlagSum

    __FlagDeleteConf=$FlagDeleteConf
    __FlagDeleteData=$FlagDeleteData

    __FlagDownloadFile=$FlagDownloadFile
    __FlagDownloadHash=$FlagDownloadHash
    __FlagUrlLatest=$FlagUrlLatest
    __FlagUrlList=$FlagUrlList
    __FlagUrlTag=$FlagUrlTag
}
function FlagsPop
{
    FlagPlatformError=$__FlagPlatformError
    
    FlagTest=$__FlagTest
    FlagInstallDir=$__FlagInstallDir
    FlagVersion=$__FlagVersion
    FlagYes=$__FlagYes
    FlagNo=$__FlagNo
    FlagSum=$__FlagSum

    FlagDeleteConf=$__FlagDeleteConf
    FlagDeleteData=$__FlagDeleteData

    FlagDownloadFile=$__FlagDownloadFile
    FlagDownloadHash=$__FlagDownloadHash
    FlagUrlLatest=$__FlagUrlLatest
    FlagUrlList=$__FlagUrlList
    FlagUrlTag=$__FlagUrlTag
}
######    src/github-apps.sh/1.sh   ######
######    callback   ######

function AppsHash
{
    sha256sum "$1"
}

# set download url
# FlagVersion
# FlagDownloadFile
# FlagDownloadHash
function AppsRequestVersion
{
    RequestVersion
}
# set download url
# FlagVersion
# FlagDownloadFile
# FlagDownloadHash
function AppsRequestVersionList
{
    RequestVersionList
}

######    src/github-apps.sh/2.sh   ######
Apps_Version="v1.0.1"

######    src/github-apps.sh/3.sh   ######
######    callback   ######
function AppsPlatform
{
   if [[ "$InstallDir" == "" ]];then
        FlagInstallDir="/usr/bin"
    else
        FlagInstallDir="$InstallDir"
    fi
}
function AppsSetUrl
{
    local owner_repo="powerpuffpenguin/github-apps"
    FlagUrlLatest="https://api.github.com/repos/$owner_repo/releases/latest"
    FlagUrlList="https://api.github.com/repos/$owner_repo/releases"
    if [[ "$FlagVersion" != "" ]];then
        FlagUrlTag="https://api.github.com/repos/$owner_repo/releases/tags/$FlagVersion"
    fi
    return 0
}
function AppsSetFile
{
    local name="$1"
    local url="$2"
    if [[ "$name" == "bin.tar.gz" ]];then
        FlagDownloadFile=$url
    elif [[ "$name" == "bin.tar.gz.sha256" ]];then
        FlagDownloadHash=$url
    fi
}
function AppsVersion
{
    # local app="$1"
    local version="$2"
    if [[ "$version" == "" ]];then
        local exe="$FlagInstallDir/github-apps.sh"
        if [[ -f "$exe" ]];then
            local str=$("$exe" -v )
            AppsVersionValue=$str
        fi
    else
        echo write version "$version"
    fi
}
function AppsUnpack
{
    local file="$1"
    if [[ ! -d "$FlagInstallDir" ]];then
        echo mkdir "$FlagInstallDir"
        if [[ "$FlagTest" == 0 ]];then
            mkdir "$FlagInstallDir"
        fi
    fi
    local conf="$FlagInstallDir/github-apps.configure"
    if [[ ! -d "$conf" ]];then
        echo mkdir "$conf"
        if [[ "$FlagTest" == 0 ]];then
            mkdir "$conf"
        fi
    fi

    local tmp="$Cache/self.tmp"
    if [[ ! -d "$tmp" ]];then
        echo mkdir "$tmp"
        mkdir "$tmp"
    fi
    echo tar -zxf "$1" -C "$tmp"
    tar -zxf "$1" -C "$tmp"

    echo cp github-apps.sh "$FlagInstallDir/github-apps.sh"
    if [[ "$FlagTest" == 0 ]];then
        cp "$tmp/github-apps.sh" "$FlagInstallDir/github-apps.sh"
    fi
    local confs="$tmp/github-apps.configure"
    local apps=$(find "$confs" -maxdepth 1 -name "*.sh" -type f | {
        while read file
        do
            name=$(basename "$file")
            for str in $name
            do
                if [[ "$str" == "$name" ]];then
                    name=${name%.sh}
                    echo "$name "
                fi
                break
            done
        done
    })
    local app
    for app in $apps
    do
        local dst="$FlagInstallDir/github-apps.configure/$app.sh"
        local src="$confs/$app.sh"
        if [[ -f "$src" ]];then
            echo cp "github-apps.configure/$app.sh" "$dst"
            if [[ "$FlagTest" == 0 ]];then
                cp "$src" "$dst"
            fi
        fi
    done

    echo rm "$tmp" -rf
    rm "$tmp" -rf
}
######    src/github-apps.sh/9.sh   ######
######    input   ######
function InputPrompts
{
    InputPromptsOk=0
    while read -p "$1 (y/n): " cmd
    do
        if [[ "$cmd" == "n" ]];then
            InputPromptsOk=0
            break
        elif [[ "$cmd" == "y" ]];then
            InputPromptsOk=1
            break
        fi
    done
}
######    src/github-apps.sh/10.sh   ######
######    version   ######
function appVersionSet
{
    local app="$1"
    local version="$2"
    local versionFile="$FlagInstallDir/apps.version"
    echo "write version '$version' to '$versionFile'"
    if [[ "$FlagTest" == 0 ]];then
        echo "$FlagVersion" > "$versionFile"
    fi
}
function appVersionGet
{
    if [[ "$FlagInstallDir" != "" ]];then
        local versionFile="$FlagInstallDir/apps.version"
        if [[ -f "$versionFile" ]];then
            local val=$(cat "$versionFile")
            appVersionParse "$val"
            if [[ $appVersionOk == 1 ]];then
                AppsVersionValue=$val
            fi
        fi
    fi
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
######    src/github-apps.sh/50.sh   ######
######    net request   ######
function RequestDownload
{
    local file="$1"
    local hash="$2"
    if [[ -f "$file" && "$hash" != "" ]];then
        local str=$(AppsHash "$file")
        for str in $str
        do
            str=$str
            break
        done
        if [[ "$str" == "$hash" ]];then
            return
        fi
    fi

    local url
    if [[ "$DevFile" == "" ]];then
        url=$FlagDownloadFile
    else
        url=$DevFile
    fi
    echo curl -#Lo "$file" "$url"
    curl -#Lo "$file" "$url"
}
RequestHashValue=""
function RequestHash
{
    RequestHashValue=""
    if [[ "$FlagDownloadHash" == "" ]];then
        return
    fi
    echo curl -sL "$FlagDownloadHash"
    local hash
    if [[ "$DevHash" == "" ]];then
        hash="$(curl -sL "$FlagDownloadHash")"
    else
        hash=$DevHash
    fi
    local str
    for str in $hash
    do
        RequestHashValue=$str
        break
    done
}
# request version
function RequestVersion
{
    local version=$FlagVersion
    local url
    if [[ "$version" == "" ]];then
        if [[ "$DevUrlLatest" == "" ]];then
            url=$FlagUrlLatest
        else
            url=$DevUrlLatest
        fi
    else
        if [[ "$DevUrlTag" == "" ]];then
            url=$FlagUrlTag
        else
            url=$DevUrlTag
        fi
    fi
    echo curl -H "Accept: application/vnd.github.v3+json" "$url"
    eval $(curl -s -H "Accept: application/vnd.github.v3+json" "$url" | {
        local value
        declare -i depth=0
        local assets=0
        declare -i assetsIndex=0
        local line
        while read line
        do
            # trim
            line=$(echo $line)
            if [[ "$line" == "{" || "$line" == "[" ]];then
                depth=depth+1
                continue
            elif [[ "$line" == "}" || "$line" == "}," || "$line" == "]" || "$line" == "]," ]];then
                depth=depth-1
                if [[ $depth == 1 ]];then
                    assets=0
                elif [[ $depth == 2 ]];then
                    if [[ $assets == 1 ]];then
                        assetsIndex=assetsIndex+1
                    fi
                fi
                continue
            fi

            value=${line#\"*\":}
            key=${line::${#line}-${#value}}
            value=${value%,}
            value=$(echo $value)

            if [[ "$key" != \"*\": ]];then
                continue
            fi
            key=${key:1:${#key}-3}
            if [[ $depth == 1 ]];then
                if [[ "$key" == "message" ]];then
                    echo "local error=$value"
                    return 0
                elif [[ "$key" == "tag_name" ]];then
                    echo "local tag_name=$value"
                elif [[ "$key" == "assets" ]];then
                    assets=1 
                fi
            elif [[ $depth == 3 ]];then
                if [[ $assets == 1 ]];then
                    if [[ "$key" == "name" ]];then
                        echo "local name_$assetsIndex=$value"
                    elif [[ "$key" == "size" ]];then
                        echo "local size_$assetsIndex=$value"
                    elif [[ "$key" == "browser_download_url" ]];then
                        echo local "url_$assetsIndex=$value"
                    fi
                fi
            fi
            if [[ "$value" == "{" || "$value" == "[" ]];then
                depth=depth+1
            fi
        done
        echo "local assetsSize=$assetsIndex"
    })
    if [[ "$error" != "" ]];then
        echo "Error: $error"
        return 1
    elif [[ "$tag_name" == "" ]];then
        echo "Parse response tag_name error"
        return 1
    fi
    VersionNext "$tag_name"
    if [[ "$VersionNextOk" == 0 ]];then
        echo "not supported installed version: $tag_name"
        return 1
    fi
    FlagVersion="$tag_name"

    declare -i assets=$assetsSize
    local i=0
    local browser_download_url=""
    local sha256_browser_download_url=""
    for((;i<assets;i++))
    do
        eval "local name=\$name_$i"
        eval "local url=\$url_$i"

        AppsSetFile "$name" "$url"
    done

    if [[ "$FlagDownloadFile" == "" ]];then
        echo "Parse assets not found download file" 
        return 1
    fi
    if [[ "$FlagSum" == 0 ]];then
        FlagDownloadHash=""
    fi
}
# request from version
function RequestVersionList
{
    local url
    if [[ "$DevUrlList" == "" ]];then
        url=$FlagUrlList
    else
        url=$DevUrlList
    fi

    echo curl -H "Accept: application/vnd.github.v3+json" "$url"
    eval $(curl -s -H "Accept: application/vnd.github.v3+json" "$url" | {
        declare -i depth=0
        local line
        declare -i index=0
        local assets=0
        local tag_name=""
        local release=1
        local names=()
        local urls=()
        while read line
        do
            # trim
            line=$(echo $line)
            if [[ "$line" == "{" || "$line" == "[" ]];then
                depth=depth+1
                if [[ "$depth" == 2 && "$line" == "{" ]];then
                    offset=offset+1
                fi
                continue
            elif [[ "$line" == "}" || "$line" == "}," || "$line" == "]" || "$line" == "]," ]];then
                depth=depth-1
                case $depth in
                    1)
                        if [[ $release == 1 && "$tag_name" != "" && $index != "0" ]];then
                            VersionNext "$tag_name"
                            if [[ $VersionNextOk == 1 ]];then
                                VersionCompare
                                FlagDownloadFile=""
                                if [[ $VersionCompareValue == 1 ]];then
                                    local i
                                    for((i=0;i<index;i++))
                                    do
                                        local name=${names[i]}
                                        local url=${urls[i]}
                                        AppsSetFile "$name" "$url"
                                    done
                                    if [[ "$FlagDownloadFile" != "" ]];then
                                        echo "local tag_name=\"$tag_name\""
                                        echo "local assetsSize=$index"
                                        for((i=0;i<index;i++))
                                        do
                                            local name=${names[i]}
                                            local url=${urls[i]}
                                            echo "local name_$i=\"$name\""
                                            echo "local url_$i=\"$url\""
                                        done
                                        return 0
                                    fi
                                fi
                            fi
                        fi
                        # clear
                        assets=0
                        index=0
                        tag_name=""
                        release=1
                        names=()
                        urls=()
                    ;;
                    2)
                        if [[ $assets == 1 ]];then
                            assets=0
                        fi
                    ;;
                    3)
                        if [[ $assets == 1 ]];then
                            index=index+1
                        fi
                    ;;
                esac
                continue
            fi

            value=${line#\"*\":}
            key=${line::${#line}-${#value}}
            value=${value%,}
            value=$(echo $value)

            if [[ "$key" != \"*\": ]];then
                continue
            fi
            key=${key:1:${#key}-3}
            if [[ $depth == 1 ]];then
                if [[ "$key" == "message" ]];then
                    echo "local error=$value"
                    return 0
                fi
            elif [[ $depth == 2 ]];then
                case "$key" in
                    tag_name)
                        tag_name=${value#\"}
                        tag_name=${tag_name%\"}
                    ;;
                    assets)
                        assets=1
                        index=0
                    ;;
                    draft|prerelease)
                        if [[ "$value" == "true" ]];then
                            release=0
                        fi
                    ;;
                esac
            elif [[ $depth == 4 && $assets == 1 ]];then
                case "$key" in
                    name)
                        value=${value#\"}
                        value=${value%\"}
                        names[index]=$value
                    ;;
                    browser_download_url)
                        value=${value#\"}
                        value=${value%\"}
                        urls[index]=$value
                    ;;
                esac
            fi

            case "$value" in
                "{"|"[")
                    depth=depth+1
                ;;
            esac
        done
    })
     if [[ "$error" != "" ]];then
        echo "Error: $error"
        return 1
    elif [[ "$tag_name" == "" ]];then
        echo "Parse response tag_name error"
        return 1
    fi
    VersionNext "$tag_name"
    if [[ "$VersionNextOk" == 0 ]];then
        echo "not supported installed version: $tag_name"
        return 1
    fi
    FlagVersion="$tag_name"

    declare -i assets=$assetsSize
    local i=0
    local browser_download_url=""
    local sha256_browser_download_url=""
    for((;i<assets;i++))
    do
        eval "local name=\$name_$i"
        eval "local url=\$url_$i"

        AppsSetFile "$name" "$url"
    done

    if [[ "$FlagDownloadFile" == "" ]];then
        echo "Parse assets not found download file" 
        return 1
    fi
    if [[ "$FlagSum" == 0 ]];then
        FlagDownloadHash=""
    fi
}
######    src/github-apps.sh/109.sh   ######
function installExecute
{
    local app="$1"
    AppsRequestVersion

    local success="Successfully installed '$app' to '$FlagInstallDir'. $FlagVersion"

    AppsVersion "$app"
    if [[ "$AppsVersionValue" != "" ]];then
        local current=$AppsVersionValue
        VersionCurreant "${current}"
        if [[ "$VersionCurreantOk" == 0 ]];then
            echo parse current version error
            if [[ "$FlagNo" != 0 ]];then
                 echo automatic canceled
                 return 1
            elif [[ "$FlagYes" == 0 ]];then
                InputPrompts "do you want to reinstall?"
                if [[ $InputPromptsOk == 0 ]];then
                    echo user canceled
                    return
                fi
            fi
            local success="Successfully reinstalled '$app' to '$FlagInstallDir'. $FlagVersion"
        else
            echo "An identical version already exists: $current"
            VersionCompare
            case $VersionCompareValue in
                0)
                    success="Successfully reinstalled '$app' to '$FlagInstallDir'. $FlagVersion"
                    if [[ "$FlagNo" != 0 ]];then
                        echo automatic canceled
                        return 1
                    elif [[ "$FlagYes" == 0 ]];then
                        InputPrompts "do you want to reinstall?"
                        if [[ $InputPromptsOk == 0 ]];then
                            echo user canceled
                            return
                        fi
                    fi
                ;;
                1)
                    success="Successfully upgraded '$app' to '$FlagInstallDir'. $current -> $FlagVersion"
                    echo "upgrade: $current -> $FlagVersion"
                    if [[ "$FlagNo" != 0 ]];then
                        echo automatic canceled
                        return 1
                    elif [[ "$FlagYes" == 0 ]];then
                        InputPrompts "do you want to upgrade?"
                        if [[ $InputPromptsOk == 0 ]];then
                            echo user canceled
                            return
                        fi
                    fi
                ;;
                2)
                    success="Successfully force upgraded '$app' to '$FlagInstallDir'. $current -> $FlagVersion"
                    echo "no matched upgrade: $current -> $FlagVersion"
                    if [[ "$FlagNo" != 0 ]];then
                        echo automatic canceled
                        return 1
                    elif [[ "$FlagYes" == 0 ]];then
                        InputPrompts "do you want to force upgrade?"
                        if [[ $InputPromptsOk == 0 ]];then
                            echo user canceled
                            return
                        fi
                    fi
                ;;
                3)
                    success="Successfully downgrade '$app' to '$FlagInstallDir'. $current -> $FlagVersion"
                    echo "downgrade: $current -> $FlagVersion"
                    if [[ "$FlagNo" != 0 ]];then
                        echo automatic canceled
                        return 1
                    elif [[ "$FlagYes" == 0 ]];then
                        InputPrompts "do you want to force downgrade?"
                        if [[ $InputPromptsOk == 0 ]];then
                            echo user canceled
                            return
                        fi
                    fi
                ;;
                *)
                    echo "VersionCompare return unknow value: $VersionCompareValue"
                    return 1
                ;;
            esac
        fi
    fi

    # get hash
    RequestHash
    local hash=$RequestHashValue

    # download
    local file="$Cache/$app"
    RequestDownload "$file" "$hash"
    if [[ $hash != "" ]];then
        local str
        str=$(AppsHash "$file")
        for tmp in $str
        do
            str=$tmp
            break
        done
        if [[ "$hash" != "$str" ]];then
            echo "hash not matched"
            echo "remote: $hash" 
            echo "download: $str" 
            return 1
        fi
    fi

    # AppsUnpack
    AppsUnpack "$file"

    # Wriete version
    AppsVersion "$app" "$FlagVersion"

    echo rm "$file"
    rm "$file"
    echo "$success"
}
######    src/github-apps.sh/110.sh   ######
######    install   ######
function appsInstallOne
{
    FlagsPush

    local app="$1"
    local flags=""
    if [[ "$FlagVersion" != "" ]];then
        flags="$FlagVersion "
    fi
    if [[ $FlagSum == 0 ]];then
        flags="${flags}skip-checksum "
    fi
    if [[ $FlagTest != 0 ]];then
        flags="${flags}test "
    fi

    AppsPlatform
    if [[ "$FlagPlatformError" != "" ]];then
        echo "$FlagPlatformError"
        return 1
    elif [[ "$FlagInstallDir" == "" ]];then
        echo "FlagInstallDir not set"
        return 1
    fi
    echo "Install '$app' to '$FlagInstallDir'"
    if [[ "$flags" != "" ]];then
        echo "$flags"
    fi

    AppsSetUrl
    installExecute "$app"

    FlagsPop
}
######    src/github-apps.sh/150.sh   ######
######    self   ######
function appsSelfHelp
{
    echo "install script for github-apps.sh"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    echo "  -t, --test            test delete cache but won't actually delete from hard disk"
    echo "  -v, --version         specify the install or upgrade version number"
    echo "  -i, --install         install dir (default '/usr/bin')"
    echo "  -y, --yes             automatic yes to prompts"
    echo "  -n, --no              automatic no to prompts"
    echo "      --skip-checksum   don't validate archive hash"
    echo "  -h, --help            help for $Command"
}
function appsSelf
{
    FlagsClear

    InstallDir="/usr/bin"
    local ARGS
    ARGS=`getopt -o htv:i:yn --long help,test,version:i:,yes,no,skip-checksum,install -n "$Command" -- "$@"`
    eval set -- "${ARGS}"
    while true
    do
    case "$1" in
        -h|--help)
            appsSelfHelp
            return 0
        ;;
        -t|--test)
            FlagTest=1
            shift
        ;;
        -v|--version)
            FlagVersion="$2"
            shift 2
        ;;
        -i|--install)
            InstallDir="$2"
            shift 2
        ;;
        -y|--yes)
            FlagYes=1
            shift
        ;;
        -n|--no)
            FlagNo=1
            shift
        ;;
        --skip-checksum)
            FlagSum=0
            shift
        ;;
        --)
            shift
            break
        ;;
        *)
            echo Error: unknown flag "'$1'" for "$Command"
            echo "Run '$Command --help' for usage."
            return 1
        ;;
    esac
    done

    appsInstallOne "github-apps.sh"
    if [[ -d "$Cache" ]];then
        rm "$Cache" -rf
    fi
}
appsSelf "$@"