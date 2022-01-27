######    cache   ######
function cacheHelp
{
    echo "Cache manage"
    echo
    echo "Example:"
    echo "  # print buffer size"
    echo "  $ $Command"
    echo
    echo "  # clear cache"
    echo "  $ $Command -d"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    echo "  -t, --test          test delete cache but won't actually delete from hard disk"
    echo "  -d, --delete        delete cache"
    echo "  -h, --help          help for $Command"
}
function appsCache
{
    local delete=0
    local ARGS
    ARGS=`getopt -o htd --long help,test,delete -n "$Command" -- "$@"`
    eval set -- "${ARGS}"
    while true
    do
    case "$1" in
        -h|--help)
            cacheHelp
            return 0
        ;;
        -t|--test)
            FlagTest=1
            shift
        ;;
        -d|--delete)
            delete=1
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
    
    if [[ $delete == 0 ]];then
        echo du -sh "$Cache"
        du -sh "$Cache"
    else
        find "$Cache" -maxdepth 1| {
            clean=0
            while read file
            do
                if [[ "$file" == "$Cache" ]];then
                    continue
                fi
                clean=1
                echo rm "$file" -rf
                if [[ "$FlagTest" == 0 ]];then
                    rm "$file" -rf
                fi
            done
            if [[ $clean == 0 ]];then
                echo clean
            fi
        }
    fi
}