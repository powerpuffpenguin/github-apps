######    list   ######
function listHelp
{
    echo "List apps"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    echo "  -i, --install          only list installed apps"
    echo "  -v, --version          list apps installed version"
    echo "  -h, --help             help for $Command"
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