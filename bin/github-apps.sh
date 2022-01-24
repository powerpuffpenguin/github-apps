#!/usr/bin/env bash
set -e
########    configure   ########

# command
core_Command=$(basename $BASH_SOURCE)

# root dir
core_Dir=$(cd $(dirname $BASH_SOURCE) && pwd)
# configure dir
dir="$core_Dir/github-apps"

# apps
core_Apps=$(find "$dir" -maxdepth 1 -iname *.sh -type f | {
    while read file
    do
        name=$(basename "$file")
        for str in $name
        do
            if [[ "$str" == "$name" ]];then
                name=${name%.sh}
                echo -n "$name "
            fi
            break
        done
    done
})

########    implement   ########

# for app in $core_Apps
# do
#     echo $app
# done

########    main   ########
function core_mainHelp
{
    echo "install core.sh"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo "  $Command [command]"
    echo
    echo "Available Commands:"
    
    echo "  install           install apps"
    echo "  list              list apps"
    echo "  upgrade           upgrade apps"
    echo "  remove            remove  apps"
    echo
    echo "Flags:"
    echo "  -h, --help          help for $Command"
}

function core_main
{
    Command="$core_Command"
    case "$1" in
        -h|--help)
            core_mainHelp
            return 0
        ;;
    esac
    core_mainHelp
    return 1
}
core_main "$@"

