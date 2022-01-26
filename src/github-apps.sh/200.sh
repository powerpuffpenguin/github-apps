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
    echo "  list              list apps"
    echo "  install           install apps"
    echo "  upgrade           upgrade apps"
    echo "  remove            remove apps"
    echo "  cache             cache manage"
    echo
    echo "Flags:"
    echo "  -v, --version       show version"
    echo "  -h, --help          help for $Command"
}

function appsMain
{
    case "$1" in
        -h|--help)
            mainHelp
            return 0
        ;;
        -v|--version)
            echo "v1.0.0"
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
        upgrade)
            shift
            Command="$Command upgrade"
            appsUpgrade "$@"
            return $?
        ;;
        remove)
            shift
            Command="$Command remove"
            appsRemove "$@"
            return $?
        ;;
        cache)
            shift
            Command="$Command cache"
            appsCache "$@"
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
