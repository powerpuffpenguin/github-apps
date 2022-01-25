######    list   ######
function listHelp
{
    echo "list apps"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    echo "  -v, --version       list apps installed version"
    echo "  -h, --help          help for $Command"
}
function appListOne
{
    appVersionGet "$1"
    echo "$1 $appVersionGetValue"
}
function appsList
{
    local version=0
    local ARGS=`getopt -o hv --long help,version -n "$Command" -- "$@"`
    eval set -- "${ARGS}"
    while true
    do
    case "$1" in
        -h|--help)
            listHelp
            return 0
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
            appListOne "$app"
        done
    else
        echo $Apps
    fi
}