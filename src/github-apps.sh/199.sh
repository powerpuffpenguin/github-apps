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
    echo "  -d, --dir              print install dir"
    echo "  -v, --verbose          list apps verbose info"
    echo "  -h, --help             help for $Command"
}
function appListOne
{
    local format="$1"
    local i="$2"
    local install="$3"
    local width="$4"
    local dir="$5"
    local app=${apps[$i]}
    local body=${appsBody[$i]}

    CallbackClear
    FlagsPush

    sourceApp "$app"
    AppsPlatform
    if [[ "$FlagPlatformError" == "" ]];then
        if [[ "$install" == 1 || "$format" != "" ]];then
            AppsVersion "$app"
            if [[ "$AppsVersionValue" == "" && "$install" == 1 ]];then
                FlagsPop
                return
            fi
        fi
        local str
        if [[ "$format" == "" ]];then
            str=$app
        else
            str=$(printf "$format" "$app" "$AppsVersionValue" "$body")
        fi
        if (($width>0));then
            if ((${#str}>$width));then
                str=${str:0:$width}
            fi
        fi
        echo "$str"
        if [[ $dir == 1 ]];then
            echo "  install dir: $FlagInstallDir"
        fi
    fi
    FlagsPop
}
function appsList
{
    local verbose=0
    local install=0
    local dir=0
    local ARGS
    ARGS=`getopt -o hivd --long help,install,verbose,dir -n "$Command" -- "$@"`
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
        -v|--verbose)
            verbose=1
            shift   
        ;;
        -d|--dir)
            dir=1
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

    local width=$(stty size|awk '{print $2}')

    local format=""
    if [[ $verbose == 1 ]];then
        declare -i max=0
        local app
        for app in "${apps[@]}"
        do
            local n=${#app}
            if (($max<$n));then
                max=$n
            fi
        done
        max=max+3
        format="%-${max}s %-9s %5s"
    fi   
    local i
    for i in ${!apps[@]}
    do
        appListOne "$format" $i $install "$width" "$dir"
    done
}