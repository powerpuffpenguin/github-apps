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