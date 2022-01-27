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
    echo "  -t, --test             test remove but won't actually remove from hard disk"
    echo "  -a, --all              delete the application, also delete the configuration file and data file"
    echo "  -c, --conf             delete the application, also delete the configuration file"
    echo "  -d, --data             delete the application, also delete the data file"
    echo "  -h, --help             help for $Command"
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