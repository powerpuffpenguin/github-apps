######    upgrade   ######
function upgradeHelp
{
    echo "upgrade apps"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    echo "  -t, --test          test install but won't actually install to hard disk"
    echo "  -v, --version       upgrade version tag, only supported on upgrade one app"
    echo "  -y, --yes           automatic yes to prompts"
    echo "  -n, --no            automatic no to prompts"
    echo "      --no-sum        don't validate archive hash"
    echo "  -h, --help          help for $Command"
}

function appsUpgradeOne
{
    CallbackClear
    FlagsPush

    local app="$1"
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
    source "$Configure/$app.sh"

    AppsPlatform
    if [[ "$FlagInstallDir" == "" ]];then
        echo "FlagInstallDir not set"
        return 1
    fi
    echo "Upgrade '$app' on '$FlagInstallDir'"
    if [[ "$flags" != "" ]];then
        echo "$flags"
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
        appVersionGet "$app"
        if [[ "$appVersionGetValue" != "" ]];then
            appsUpgradeOne "$app"
        fi
    done
}
function appsUpgrade
{
    FlagsClear

    local ARGS=`getopt -o htv:yn --long help,test,version:,yes,no,no-sum -n "$Command" -- "$@"`
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