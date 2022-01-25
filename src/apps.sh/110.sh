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
    installExecute "$app"

    FlagsPop
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