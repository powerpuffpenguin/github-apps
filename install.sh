#!/usr/bin/env bash
# merge bash
######    src/github-apps.sh/0.sh   ######
######    configure   ######
set -e

# DevUrlLatest="http://192.168.251.50/tools/dev/github_coredns_latest.json"
# DevUrlList="http://192.168.251.50/tools/dev/github_coredns_list.json"
# DevUrlTag="http://192.168.251.50/tools/dev/github_coredns_v1.7.1.json"
# DevHash="40a0382681a8133f6612171fc8df0fc3403a28bd11f889c8f82a92039969d0b6"
# DevFile="http://192.168.251.50/tools/dev/coredns_1.8.7_linux_amd64.tgz"

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
Command=$(basename $BASH_SOURCE)
# Root dir
Root=$(cd $(dirname $BASH_SOURCE) && pwd)
# Configure dir
Configure="$Root/github-apps.configure"
# Cache dir
Cache="$Root/github-apps.cache"

# apps
if [[ ! -d "$Configure" ]];then
    mkdir "$Configure"
fi
Apps=$(find "$Configure" -maxdepth 1 -name "*.sh" -type f | {
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
if [[ ! -d "$Cache" ]];then
    mkdir "$Cache"
    chmod 777 "$Cache" 
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
function CallbackClear
{
    eval 'function AppsPlatform
{
    FlagPlatformError="function AppsPlatform not implemented"
}
function AppsSetUrl
{
    echo function SetUrl not implemented
    return 1
}
function AppsSetFile
{
    echo function AppsSetFile not implemented
    return 1
}
function AppsUnpack
{
    echo function AppsUnpack not implemented
    return 1
}
function AppsRemove
{
    echo function AppsRemove not implemented
    return 1
}
function AppsHash
{
    sha256sum "$1"
}
function AppsVersion
{
    if [[ "$2" == "" ]];then
        AppsVersionValue=""
        appVersionGet "$1"
    else
        appVersionSet "$1" "$2"
    fi
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
'
}

######    src/github-apps.sh/2.sh   ######
Apps_Version="v1.0.1"

######    src/github-apps.sh/3.sh   ######
######    callback   ######
function CallbackSelf
{
    eval 'function AppsPlatform
{
    if [[ "$GithubAppsSelf" == 1 ]];then
        FlagInstallDir="$Root"
    elif [[ "$InstallDir" == "" ]];then
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
        if [[ "$GithubAppsSelf" == 1 ]];then
            AppsVersionValue="$Apps_Version"
            return
        fi
        local exe="$FlagInstallDir/github-apps.sh"
        if [[ -f "$exe" ]];then
            local str=$("$exe" -v )
            AppsVersionValue=$str
        fi
    else
        echo write version "'$version'"
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
        if [[ -f "$dst" ]];then
            echo "file exists: $dst"
            continue
        fi
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
function AppsRemove
{
    local dir=$FlagInstallDir
    local file="$dir/github-apps.sh"
    if [[ -f "$file" ]];then
        echo rm "$file"
        if [[ "$FlagTest" == 0 ]];then
            rm "$file"
        fi
    fi
    local cache="$Cache"
    if [[ -d "$cache" ]];then
        echo rm "$cache" -rf
        if [[ "$FlagTest" == 0 ]];then
            rm "$cache" -rf
        fi
    fi

    if [[ "$FlagDeleteConf" != 0 ]];then
        local conf="$Configure"
        if [[ -d "$conf" ]];then
            echo rm "$conf" -rf
            if [[ "$FlagTest" == 0 ]];then
                rm "$conf" -rf
            fi
        fi
    fi
}
'
}
######    src/github-apps.sh/9.sh   ######
######    input   ######
function InputPrompts
{
    local cmd
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
function installHelp
{
    echo "Install apps"
    echo
    echo "Example:"
    echo "  # install coredns"
    echo "  $ $Command coredns"
    echo "  $ $Command coredns -v v1.8.7"
    echo
    echo "  # install multiple apps"
    echo "  $ $Command coredns ariang"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    echo "  -t, --test          test install but won't actually install to hard disk"
    echo "  -v, --version       install version tag, only supported on install one app"
    echo "  -y, --yes           automatic yes to prompts"
    echo "  -n, --no            automatic no to prompts"
    echo "      --skip-checksum        don't validate archive hash"
    echo "  -h, --help          help for $Command"
}
function appsInstallOne
{
    CallbackClear
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
   
   if [[ "$GithubAppsSourceSelf" == 1 ]];then
        CallbackSelf
   else
       source "$Configure/$app.sh"
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
function appsInstall
{
    FlagsClear

    local ARGS
    ARGS=`getopt -o htv:yn --long help,test,version:,yes,no,skip-checksum -n "$Command" -- "$@"`
    eval set -- "${ARGS}"
    while true
    do
    case "$1" in
        -h|--help)
            installHelp
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
            exit 1
        ;;
    esac
    done
    if [[ "${#@}" == 0 ]];then
        echo Please enter the name of the apps you want to install
        echo "Run '$Command --help' for usage."
        return 1
    fi
    if [[ "$FlagVersion" != "" && "${#@}" != 1 ]];then
        echo "flag '-v, --version' only supported on install one app"
        return 1
    fi

    local app
    for app in "$@"
    do
        appsInstallOne "$app"
    done
}
######    src/github-apps.sh/119.sh   ######
function upgradeExecute
{
    local app="$1"
    # load current version
    AppsVersion "$app"
    if [[ "$AppsVersionValue" == "" ]];then
        echo "get version error"
        return 1
    fi
    local current="$AppsVersionValue"
    VersionCurreant "${current}"
    if [[ "$VersionCurreantOk" == 0 ]];then
        echo parse current version error
        return 1
    fi
    # request remote version
    local target=$FlagVersion
    AppsRequestVersion
    VersionCompare
    case $VersionCompareValue in
        0)
            echo "'$app' no new version"
            echo "upgraded '$app' completed"
            return
        ;;
        1)
            echo "'$app' found a new version: $FlagVersion"
        ;;
        2)
            if [[ "$target" == "" ]];then
                # not matched so reset
                FlagVersion=""
                FlagDownloadFile=""
                FlagDownloadHash=""
                AppsRequestVersionList
            else
                echo "target version not matched: $current -> $target"
                return 1
            fi
        ;;
        3)
            echo "a newer version is already installed locally"
            echo "upgraded '$app' completed"
            return
        ;;
        *)
            echo "VersionCompare return unknow value: $VersionCompareValue"
            return 1
        ;;
    esac

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
    echo "Successfully upgraded '$app' to '$FlagInstallDir'. $current -> $FlagVersion"
}
######    src/github-apps.sh/120.sh   ######
######    upgrade   ######
function upgradeHelp
{
    echo "Upgrade apps"
    echo
    echo "Example:"
    echo "  # upgrade coredns"
    echo "  $ $Command coredns"
    echo "  $ $Command coredns -v v1.8.7"
    echo
    echo "  # upgrade multiple apps"
    echo "  $ $Command coredns ariang"
    echo
    echo "  # upgrade all installed apps"
    echo "  $ $Command"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    echo "  -t, --test          test upgrade but won't actually upgrade to hard disk"
    echo "  -v, --version       upgrade version tag, only supported on upgrade one app"
    echo "  -y, --yes           automatic yes to prompts"
    echo "  -n, --no            automatic no to prompts"
    echo "      --skip-checksum        don't validate archive hash"
    echo "  -h, --help          help for $Command"
}

function appsUpgradePush
{
    CallbackClear
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
    if [[ "$GithubAppsSourceSelf" == 1 ]];then
        CallbackSelf
    else
        source "$Configure/$app.sh"
    fi

    appsUpgradePushFlags="$flags"
}

function appsUpgradeOne
{
    local app="$1"
    if [[ "$2" != 1 ]];then
        appsUpgradePush "$app"
    
        AppsPlatform
        if [[ "$FlagPlatformError" != "" ]];then
            echo "$FlagPlatformError"
            return 1
        elif [[ "$FlagInstallDir" == "" ]];then
            echo "FlagInstallDir not set"
            return 1
        fi
    fi

    echo "Upgrade '$app' on '$FlagInstallDir'"
    if [[ "$appsUpgradePushFlags" != "" ]];then
        echo "$appsUpgradePushFlags"
    fi

    AppsSetUrl
    upgradeExecute "$app"

    FlagsPop
}

function appsUpgradeAll
{
    local app
    for app in $Apps
    do
        appsUpgradePush "$app"

        AppsPlatform
        if [[ "$FlagPlatformError" != "" || "$FlagInstallDir" == "" ]];then
            FlagsPop
            continue
        fi

        AppsVersion "$app"
        if [[ "$AppsVersionValue" == "" ]];then
            FlagsPop
        else
            appsUpgradeOne "$app" 1
        fi
    done
}
function appsUpgrade
{
    FlagsClear

    local ARGS
    ARGS=`getopt -o htv:yn --long help,test,version:,yes,no,skip-checksum -n "$Command" -- "$@"`
    eval set -- "${ARGS}"
    while true
    do
    case "$1" in
        -h|--help)
            upgradeHelp
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
            exit 1
        ;;
    esac
    done
    if [[ "$FlagVersion" != "" && "${#@}" != 1 ]];then
        echo "flag '-v, --version' only supported on upgrade one app"
        return 1
    fi

    if [[ "${#@}" == 0 ]];then
        appsUpgradeAll
        return
    fi

    local app
    for app in "$@"
    do
        appsUpgradeOne "$app"
    done
}
######    src/github-apps.sh/130.sh   ######
######    remove   ######
function removeHelp
{
    echo "Remove apps"
    echo
    echo "Example:"
    echo "  # remove coredns"
    echo "  $ $Command coredns"
    echo
    echo "  # remove multiple apps"
    echo "  $ $Command coredns ariang"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    echo "  -t, --test          test remove but won't actually remove from hard disk"
    echo "  -a, --all           delete the application, also delete the configuration file and data file"
    echo "  -c, --conf          delete the application, also delete the configuration file"
    echo "  -d, --data          delete the application, also delete the data file"
    echo "  -h, --help          help for $Command"
}
function appRemoveOne
{
    CallbackClear
    FlagsPush

    local app="$1"
    local flags=""
    if [[ $FlagTest != 0 ]];then
        flags="${flags}test "
    fi
    if [[ $FlagDeleteConf != 0 ]];then
        flags="${flags}delete-conf "
    fi
    if [[ $FlagDeleteData != 0 ]];then
        flags="${flags}delete-data "
    fi
    if [[ "$GithubAppsSourceSelf" == 1 ]];then
        CallbackSelf
    else
        source "$Configure/$app.sh"
    fi
   
    AppsPlatform
    if [[ "$FlagPlatformError" != "" ]];then
        echo "$FlagPlatformError"
        return 1
    elif [[ "$FlagInstallDir" == "" ]];then
        echo "FlagInstallDir not set"
        return 1
    fi
    echo "Remove '$app' from '$FlagInstallDir'"
    if [[ "$flags" != "" ]];then
        echo "$flags"
    fi

    AppsRemove "$app"
    
    FlagsPop
}
function appRemove
{
    FlagsClear

    local ARGS
    ARGS=`getopt -o htacd --long help,test,all,conf,data -n "$Command" -- "$@"`
    eval set -- "${ARGS}"
    while true
    do
    case "$1" in
        -h|--help)
            removeHelp
            return 0
        ;;
        -t|--test)
            FlagTest=1
            shift
        ;;
        -a|--all)
            FlagDeleteConf=1
            FlagDeleteData=1
            shift
        ;;
        -c|--conf)
            FlagDeleteConf=1
            shift
        ;;
        -d|--data)
            FlagDeleteData=1
            shift
        ;;
        --)
            shift
            break
        ;;
        *)
            echo Error: unknown flag "'$1'" for "$Command"
            echo "Run '$Command --help' for usage."
            exit 1
        ;;
    esac
    done
    if [[ "${#@}" == 0 ]];then
        echo Please enter the name of the apps you want to remove
        echo "Run '$Command --help' for usage."
        return 1
    fi

    local app
    for app in "$@"
    do
        appRemoveOne "$app"
    done
}
######    src/github-apps.sh/140.sh   ######
######    cache   ######
function cacheHelp
{
    echo "Cache manage"
    echo
    echo "Example:"
    echo "  # print buffer size"
    echo "  $ $Command"
    echo
    echo "  # clear cache"
    echo "  $ $Command -d"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    echo "  -t, --test          test delete cache but won't actually delete from hard disk"
    echo "  -d, --delete        delete cache"
    echo "  -h, --help          help for $Command"
}
function appsCache
{
    local delete=0
    local ARGS
    ARGS=`getopt -o htd --long help,test,delete -n "$Command" -- "$@"`
    eval set -- "${ARGS}"
    while true
    do
    case "$1" in
        -h|--help)
            cacheHelp
            return 0
        ;;
        -t|--test)
            FlagTest=1
            shift
        ;;
        -d|--delete)
            delete=1
            shift
        ;;
        --)
            shift
            break
        ;;
        *)
            echo Error: unknown flag "'$1'" for "$Command"
            echo "Run '$Command --help' for usage."
            exit 1
        ;;
    esac
    done
    
    if [[ $delete == 0 ]];then
        echo du -sh "$Cache"
        du -sh "$Cache"
    else
        find "$Cache" -maxdepth 1| {
            clean=0
            while read file
            do
                if [[ "$file" == "$Cache" ]];then
                    continue
                fi
                clean=1
                echo rm "$file" -rf
                if [[ "$FlagTest" == 0 ]];then
                    rm "$file" -rf
                fi
            done
            if [[ $clean == 0 ]];then
                echo clean
            fi
        }
    fi
}
######    src/github-apps.sh/150.sh   ######
######    self   ######
function appsSelfHelp
{
    echo "github-apps.sh self manage"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    echo "  -t, --test          test delete cache but won't actually delete from hard disk"
    echo "  -i, --install        reinstall self"
    echo "  -u, --upgrade        upgrade self"
    echo "  -v, --version        specify the install or upgrade version number"
    echo "  -y, --yes           automatic yes to prompts"
    echo "  -n, --no            automatic no to prompts"
    echo "      --skip-checksum        don't validate archive hash"
    echo "  -r, --remove        remove self"
    echo "  -a, --all        also delete the configuration file and data file"
    echo "  -c, --conf        also delete the configuration file"
    echo "  -d, --data        also delete the data file"
    echo "  -h, --help          help for $Command"
}
function appsSelf
{
    FlagsClear
    GithubAppsSourceSelf=1

    local ARGS
    ARGS=`getopt -o htiuv:racdyn --long help,test,install,upgrade,version:,remove,all,conf,data,yes,no,skip-checksum -n "$Command" -- "$@"`
    eval set -- "${ARGS}"
    local install=0
    local upgrade=0
    local remove=0
    local installFlag=""
    local upgradeFlag=""
    local removeFlag=""
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
        -i|--install)
            installFlag="$1"
            if [[ "$upgradeFlag" != "" ]];then
                echo "Parameters '$installFlag' and '$upgradeFlag' cannot be specified at the same time"
                return 1
            elif [[ "$removeFlag" != "" ]];then
                echo "Parameters '$installFlag' and '$removeFlag' cannot be specified at the same time"
                return 1
            fi
            install=1
            shift
        ;;
        -u|--upgrade)
            upgradeFlag="$1"
            if [[ "$installFlag" != "" ]];then
                echo "Parameters '$upgradeFlag' and '$installFlag' cannot be specified at the same time"
                return 1
            elif [[ "$removeFlag" != "" ]];then
                echo "Parameters '$upgradeFlag' and '$removeFlag' cannot be specified at the same time"
                return 1
            fi
            upgrade=1
            shift
        ;;
        -v|--version)
            FlagVersion="$2"
            shift 2
        ;;
        -r|--remove)
            removeFlag="$1"
            if [[ "$installFlag" != "" ]];then
                echo "Parameters '$removeFlag' and '$installFlag' cannot be specified at the same time"
                return 1
            elif [[ "$upgradeFlag" != "" ]];then
                echo "Parameters '$removeFlag' and '$upgradeFlag' cannot be specified at the same time"
                return 1
            fi
            remove=1
            shift
        ;;
        -a|--all)
            FlagDeleteConf=1
            FlagDeleteData=1
            shift
        ;;
        -c|--conf)
            FlagDeleteConf=1
            shift
        ;;
        -d|--data)
            FlagDeleteData=1
            shift
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

    if [[ $install == 1 ]];then
        appsInstallOne "github-apps.sh"
        return $?
    elif [[ $upgrade == 1 ]];then
        GithubAppsSelf=1
        appsUpgradeOne "github-apps.sh"
        return $?
    elif [[ $remove == 1 ]];then
        GithubAppsSelf=1
        appRemoveOne "github-apps.sh"
        return $?
    fi

    appsSelfHelp
    return 1
}
######    src/github-apps.sh/198.sh   ######
######    completion   ######
function completionHelp
{
    echo "Generate the autocompletion script for the bash shell."
    echo
    echo "Example:"
    echo "  # to load completions in your current shell session:"
    echo "  $ source <($Command)"
    echo
    echo "  # to load completions for every new session, execute once:"
    echo "  #"
    echo "  # Linux execute:"
    echo "  $ $Command > /etc/bash_completion.d/github-app.sh"
    echo "  # MacOS execute:"
    echo "  $ $Command > /usr/local/etc/bash_completion.d/github-app.sh"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    echo "  -h, --help          help for $Command"
}
function appsCompletion
{
    local version=0
    local install=0
    local ARGS
    ARGS=`getopt -o h --long help -n "$Command" -- "$@"`
    eval set -- "${ARGS}"
    while true
    do
    case "$1" in
        -h|--help)
            completionHelp
            return 0
        ;;
        --)
            shift
            break
        ;;
        *)
            echo Error: unknown flag "'$1'" for "$Command"
            echo "Run '$Command --help' for usage."
            exit 1
        ;;
    esac
    done
    
    echo '__powerpuffpenguin_github_apps_completion()
{
    local opts="-h --help"
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}
__powerpuffpenguin_github_apps_list()
{
    local opts="-h --help \
        -v --version -i --install"
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}
__powerpuffpenguin_github_apps_cache()
{
    local opts="-h --help \
        -t --test -d --delete"
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}
__powerpuffpenguin_github_apps_self()
{
    local opts="-h --help \
        -t --test -v --version -y --yes -n --no --skip-checksum \
        -i --install -u --upgrade -r --remove \
        -a --all -c --conf -d --data"
    local previous=${COMP_WORDS[COMP_CWORD-1]}
    case $previous in
        -v|--version)
            COMPREPLY=()
        ;;
        *)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        ;;
    esac
}
__powerpuffpenguin_github_apps_install()
{
    local apps=`github-apps.sh list 2> /dev/null`
    local opts="-h --help \
        -t --test -v --version -y --yes -n --no \
        --skip-checksum $apps"
    local previous=${COMP_WORDS[COMP_CWORD-1]}
    case $previous in
        -v|--version)
            COMPREPLY=()
        ;;
        *)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        ;;
    esac
}
__powerpuffpenguin_github_apps_upgrade()
{
    local apps=`github-apps.sh list -i 2> /dev/null`
    local opts="-h --help \
        -t --test -v --version -y --yes -n --no \
        --skip-checksum $apps"
    local previous=${COMP_WORDS[COMP_CWORD-1]}
    case $previous in
        -v|--version)
            COMPREPLY=()
        ;;
        *)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        ;;
    esac
}
__powerpuffpenguin_github_apps_remove()
{
    local apps=`github-apps.sh list -i 2> /dev/null`
    local opts="-h --help \
        -t --test -a --all -c --conf -d --data \
        $apps"
    local previous=${COMP_WORDS[COMP_CWORD-1]}
    case $previous in
        -v|--version)
            COMPREPLY=()
        ;;
        *)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        ;;
    esac
}
__powerpuffpenguin_github_apps()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ 1 == $COMP_CWORD ];then
        local opts="-h --help -v --version \
            completion list cache self \
            install upgrade remove "
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    else
        case ${COMP_WORDS[1]} in
            completion)
                __powerpuffpenguin_github_apps_completion
            ;;
            list)
                __powerpuffpenguin_github_apps_list
            ;;
            cache)
                __powerpuffpenguin_github_apps_cache
            ;;
            self)
                __powerpuffpenguin_github_apps_self
            ;;
            install)
                __powerpuffpenguin_github_apps_install
            ;;
            upgrade)
                __powerpuffpenguin_github_apps_upgrade
            ;;
            remove)
                __powerpuffpenguin_github_apps_remove
            ;;
        esac
    fi
}

complete -F __powerpuffpenguin_github_apps github-apps.sh
'
}
######    src/github-apps.sh/199.sh   ######
######    list   ######
function listHelp
{
    echo "List apps"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    echo "  -i, --install       only list installed apps"
    echo "  -v, --version       list apps installed version"
    echo "  -h, --help          help for $Command"
}
function appListOne
{
    CallbackClear
    FlagsPush
    local app="$1"
    local flag="$2"
    local install="$3"
    source "$Configure/$app.sh"
    AppsPlatform
    if [[ "$FlagPlatformError" == "" ]];then
        AppsVersion "$app"
        if [[ "$install" == 1 && "$AppsVersionValue" == "" ]];then
            FlagsPop
            return
        elif [[ "$flag" == 1 ]];then
            echo "$app $AppsVersionValue"
        else
            echo "$app"
        fi
    fi
    FlagsPop
}
function appsList
{
    local version=0
    local install=0
    local ARGS
    ARGS=`getopt -o hiv --long help,install,version -n "$Command" -- "$@"`
    eval set -- "${ARGS}"
    while true
    do
    case "$1" in
        -h|--help)
            listHelp
            return 0
        ;;
        -i|--install)
            install=1
            shift
        ;;
        -v|--version)
            version=1
            shift   
        ;;
        --)
            shift
            break
        ;;
        *)
            echo Error: unknown flag "'$1'" for "$Command"
            echo "Run '$Command --help' for usage."
            exit 1
        ;;
    esac
    done
    
    if [[ $version == 1 ]];then
        local app
        for app in $Apps
        do
            appListOne "$app" 1 $install
        done
    else
        local app
        for app in $Apps
        do
            appListOne "$app" 0 $install
        done
    fi
}
######    src/github-apps.sh/200.sh   ######
######    main   ######
function mainHelp
{
    echo "A bash script to manage apps installed from github"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo "  $Command [command]"
    echo
    echo "Available Commands:"
    echo "  completion        generate the autocompletion script for bash"
    echo "  list              list apps"
    echo "  install           install apps"
    echo "  upgrade           upgrade apps"
    echo "  remove            remove apps"
    echo "  cache             cache manage"
    echo "  self              github-apps.sh self manage"
    echo
    echo "Flags:"
    echo "  -v, --version       show version"
    echo "  -h, --help          help for $Command"
}
GithubAppsSourceSelf=0
function appsMain
{
    # InstallDir=""
    # GithubAppsSelf=1
    case "$1" in
        -h|--help)
            mainHelp
            return 0
        ;;
        -v|--version)
            echo "$Apps_Version"
            return 0
        ;;
        completion)
            shift
            Command="$Command completion"
            appsCompletion "$@"
            return $?
        ;;
        list)
            shift
            Command="$Command list"
            appsList "$@"
            return $?
        ;;
        install)
            shift
            Command="$Command install"
            appsInstall "$@"
            return $?
        ;;
        upgrade)
            shift
            Command="$Command upgrade"
            appsUpgrade "$@"
            return $?
        ;;
        remove)
            shift
            Command="$Command remove"
            appRemove "$@"
            return $?
        ;;
        cache)
            shift
            Command="$Command cache"
            appsCache "$@"
            return $?
        ;;
        self)
            shift
            Command="$Command self"
            appsSelf "$@"
            return $?
        ;;
        *)
            if [[ "$1" == "" ]];then
                mainHelp
            elif [[ "$1" == -* ]];then
                echo Error: unknown flag "'$1'" for "$Command"
                echo "Run '$Command --help' for usage."
            else
                echo Error: unknown command "'$1'" for "$Command"
                echo "Run '$Command --help' for usage."
            fi        
            return 1
        ;;
    esac
    mainHelp
    return 1
}
appsMain "$@"

