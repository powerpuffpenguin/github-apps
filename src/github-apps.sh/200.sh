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
    echo "  completion        generate the autocompletion script for bash"
    echo "  list              list apps"
    echo "  install           install apps"
    echo "  upgrade           upgrade apps"
    echo "  remove            remove apps"
    echo "  cache             cache manage"
    echo "  self              github-apps.sh self manage"
    echo
    echo "Flags:"
    echo "  -v, --version       show version"
    echo "  -h, --help          help for $Command"
}
GithubAppsSourceSelf=0
function appsMain
{
    # InstallDir=""
    # GithubAppsSelf=1
    case "$1" in
        -h|--help)
            mainHelp
            return 0
        ;;
        -v|--version)
            echo "$Apps_Version"
            return 0
        ;;
        completion)
            shift
            Command="$Command completion"
            appsCompletion "$@"
            return $?
        ;;
        list)
            shift
            Command="$Command list"
            appsList "$@"
            return $?
        ;;
        install)
            shift
            Command="$Command install"
            appsInstall "$@"
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
            appRemove "$@"
            return $?
        ;;
        cache)
            shift
            Command="$Command cache"
            appsCache "$@"
            return $?
        ;;
        self)
            shift
            Command="$Command self"
            appsSelf "$@"
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
