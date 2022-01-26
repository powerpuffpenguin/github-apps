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
    echo "      --no-sum        don't validate archive hash"
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
        flags="${flags}no-sum "
    fi
    if [[ $FlagTest != 0 ]];then
        flags="${flags}test "
    fi
   
    source "$Configure/$app.sh"

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
    ARGS=`getopt -o htv:yn --long help,test,version:,yes,no,no-sum -n "$Command" -- "$@"`
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