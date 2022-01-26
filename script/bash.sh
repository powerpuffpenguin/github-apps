#!/usr/bin/env bash
set -e

BashDir=$(cd "$(dirname "$BASH_SOURCE")" && pwd)
source "$BashDir/conf.sh"
if [[ "$Command" == "" ]];then
    Command="$0"
fi

function help(){
    echo "build bash source"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    echo "  -h, --help          help for $Command"
}

ARGS=`getopt -o h --long help -n "$Command" -- "$@"`
eval set -- "${ARGS}"
while true
do
    case "$1" in
        -h|--help)
            help
            exit 0
        ;;
        --)
            shift
            break
        ;;
        *)
            echo Error: unknown flag "$1" for "$Command"
            echo "Run '$Command --help' for usage."
            exit 1
        ;;
    esac
done

Input="$Dir/src"
Output="$Dir/bin"
function build_merge
{
    local dir="$1"
    local root="$2"
    local output
    if [[ "$root" == "" ]];then
        output="$Output/$3"
    else
        output="$Output/$root/$3"
    fi
    # echo dir="$dir"
    # echo root="$root"
    # echo $output
    local str
    str=$(find "$dir" -maxdepth 1 -name "*.sh" -type f | {
        while read file
        do
            name=$(basename "$file")
            if [[ "$name" =~ ^[0-9]+.sh$ ]];then
                echo ${name%.sh}
            else 
                echo "not support merge file: $file" 1>&2
                return 1
            fi
        done
        return 0
    })
    local strs
    strs=$(echo "$str" |sort -n) 
    declare -i offset=${#Dir}+1
    echo "merge ${dir:offset} -> ${output:offset}"
    echo '#!/usr/bin/env bash' > "$output"
    echo "# merge bash" >> "$output"
    for str in $strs
    do
        echo "  * $str.sh"
        echo "######    ${dir:offset}/$str.sh   ######" >> "$output"
        cat "$dir/$str.sh" >> "$output"
        echo "" >> "$output"
    done
    chmod a+x "$output"
}
function build_dir
{
    local root="$2"
    local output
    if [[ "$root" == "" ]];then
        output="$Output"
    else
        output="$Output/$root"
    fi
    if [[ ! -d "$output" ]];then
        echo mkdir "$output"
        mkdir "$output"
    fi
    local dir="$1"
    declare -i offset=${#Dir}+1
    # find sh
    find "$dir" -maxdepth 1 -name "*.sh" -type f | {
        while read file
        do
            name=$(basename "$file")
            src=${file:offset}
            dst="$output/$name"
            dst=${dst:offset}
            echo "cp $src -> $dst" 
            cp "$src" "$dst"
        done
    }
    # find dir
    find "$dir" -maxdepth 1 -type d | {
        while read file
        do
            if [[ "$dir" == "$file" ]];then
                continue
            fi
            name=$(basename "$file")
            if [[ "$name" != *.sh ]];then
                if [[ "$root" == "" ]];then
                    childroot="$name"
                else
                    childroot="$root/$name"
                fi
                echo "$file" "$childroot"
                build_dir "$file" "$childroot"
            fi
        done
    }
    # find merge
    find "$dir" -maxdepth 1 -name "*.sh" -type d | {
        while read file
        do
            if [[ "$dir" == "$file" ]];then
                continue
            fi
            name=$(basename "$file")
            build_merge "$file" "$root" "$name"
        done
    }
}
cd $Dir
version="src/github-apps.sh/2.sh"
echo "Apps_Version=\"$Version\"" > "$version"
build_dir "$Input"