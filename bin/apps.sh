#!/usr/bin/env bash
# merge bash
######    src/apps.sh/0.sh   ######
######    configure   ######
set -e

function FlagsClear
{
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

    # download file name
    FlagDownloadName=""
    # download hash file name
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
Configure="$Root/apps.configure"
# Cache dir
Cache="$Root/apps.cache"

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
fi
if [[ ! -d "$Cache/data" ]];then
    mkdir "$Cache/data"
fi
if [[ ! -d "$Cache/info" ]];then
    mkdir "$Cache/info"
fi

FlagsClear
function FlagsPush
{
    __FlagTest=$FlagTest
    __FlagInstallDir=$FlagInstallDir
    __FlagVersion=$FlagVersion
    __FlagYes=$FlagYes
    __FlagNo=$FlagNo
    __FlagSum=$FlagSum

    __FlagDownloadName=$FlagDownloadName
    __FlagDownloadHash=$FlagDownloadHash
    __FlagUrlLatest=$FlagUrlLatest
    __FlagUrlList=$FlagUrlList
    __FlagUrlTag=$FlagUrlTag
}
function FlagsPop
{
    FlagTest=$__FlagTest
    FlagInstallDir=$__FlagInstallDir
    FlagVersion=$__FlagVersion
    FlagYes=$__FlagYes
    FlagNo=$__FlagNo
    FlagSum=$__FlagSum

    FlagDownloadName=$__FlagDownloadName
    FlagDownloadHash=$__FlagDownloadHash
    FlagUrlLatest=$__FlagUrlLatest
    FlagUrlList=$__FlagUrlList
    FlagUrlTag=$__FlagUrlTag
}
######    src/apps.sh/1.sh   ######
######    callback   ######
function CallbackClear
{
    eval 'function AppsPlatform
{
    echo function AppsPlatform not implemented
    return 1
}
function AppsSetUrl
{
    echo function SetUrl not implemented
    return 1
}
function AppsSetName
{
    echo function AppsSetName not implemented
    return 1
}
'
}

######    src/apps.sh/50.sh   ######
# request version
function RequestVersion
{
    local version=$FlagVersion
    local url
    if [[ "$version" == "" ]];then
        url=$FlagUrlLatest
    else
        url=$FlagUrlTag
    fi
    echo curl -H "Accept: application/vnd.github.v3+json" "$url"
  
    eval $(curl -H "Accept: application/vnd.github.v3+json" "$url" | {
        local value
        declare -i depth=0
        local assets=0
        declare -i assetsIndex=0
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
    FlagVersion="$tag_name"

    AppsSetName
    echo FlagDownloadName $FlagDownloadName
}
######    src/apps.sh/109.sh   ######
function installExecute
{
    RequestVersion
}
######    src/apps.sh/110.sh   ######
######    install   ######
function installHelp
{
    echo "install apps"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    echo "  -t, --test          test install but won't actually install to hard disk"
    echo "  -d, --dir        install dir"
    echo "  -v, --version       install version tag"
    echo "  -y, --yes           automatic yes to prompts"
    echo "  -n, --no            automatic no to prompts"
    echo "      --no-sum        don't validate archive hash"
    echo "  -h, --help          help for $Command"
}
function appsInstallOne
{
    CallbackClear
    FlagsPush

    local app="$1"
    if [[ "$FlagInstallDir" == "" ]];then
        echo "Install '$app'"
    else
        echo "Install '$app' to '$FlagInstallDir'"
    fi
    local flags=""
    if [[ "$FlagVersion" != "" ]];then
        flags="$FlagVersion "
    fi
    if [[ $FlagSum == 0 ]];then
        flags="${flags}no-sum "
    fi
    if [[ $FlagTest != 0 ]];then
        flags="${flags}test "
    fi
    if [[ "$flags" != "" ]];then
        echo "$flags"
    fi
    source "$Configure/$app.sh"

    AppsPlatform
    AppsSetUrl
    installExecute

    FlagsPop
    echo Success "$app"
}
function appsInstall
{
    FlagsClear

    local ARGS=`getopt -o htd:v:yn --long help,test,dir:,version:,yes,no,no-sum -n "$Command" -- "$@"`
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
        -d|--dir)
            if [[ ! -d "$2" ]];then
                echo "install dir not exists: $2"
                return 1
            fi
            FlagInstallDir=$(cd "$2" && pwd)
            shift 2
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
        --no-sum)
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

    local app
    for app in "$@"
    do
        appsInstallOne "$app"
    done
}
######    src/apps.sh/199.sh   ######
######    list   ######
function listHelp
{
    echo "list apps"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    echo "  -h, --help          help for $Command"
}
function appsList
{
    local ARGS=`getopt -o hl: --long help,lang: -n "$Command" -- "$@"`
    eval set -- "${ARGS}"
    while true
    do
    case "$1" in
        -h|--help)
            listHelp
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
    
    echo $Apps
}
######    src/apps.sh/200.sh   ######
######    main   ######
function mainHelp
{
    echo "a bash script used to apps manage"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo "  $Command [command]"
    echo
    echo "Available Commands:"
    
    echo "  install           install apps"
    echo "  list              list apps"
    echo "  upgrade           upgrade apps"
    echo "  remove            remove apps"
    echo "  cache             cache manage"
    echo
    echo "Flags:"
    echo "  -h, --help          help for $Command"
}

function appsMain
{
    case "$1" in
        -h|--help)
            mainHelp
            return 0
        ;;
        install)
            shift
            Command="$Command install"
            appsInstall "$@"
            return $?
        ;;
        list)
            shift
            Command="$Command list"
            appsList "$@"
            return $?
        ;;
        *)
            if [[ "$1" == -* ]];then
                echo Error: unknown flag "'$1'" for "$Command"
                echo "Run '$Command --help' for usage."
            else
                echo Error: unknown command "'$1'" for "$Command"
                echo "Run '$Command --help' for usage."
            fi        
        exit 1
    ;;
    esac
    mainHelp
    return 1
}
appsMain "$@"


