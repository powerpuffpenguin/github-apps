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
