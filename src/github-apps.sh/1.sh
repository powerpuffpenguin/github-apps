######    info   ######
Apps=()
AppsSource=()
AppsBody=()
declare -i appsOffset=0
function appsFind
{
    local dir="$1"
    if [[ "$dir" == "" || ! -d "$dir" ]];then
        return
    fi
    dir=$(cd "$dir" && pwd)
    if [[ "$dir" == "" || ! -d "$dir" ]];then
        return
    fi
    local apps=$(find "$dir" -maxdepth 1 -name "*.sh" -type f | {
        while read file
        do
            name=$(basename "$file")
            if [[ "$name" == "lib.sh" ]];then
                continue
            fi
            for str in $name
            do
                if [[ "$str" == "$name" ]];then
                    name=${name%.sh}
                    echo "$name "
                fi
                break
            done
        done
    })
    local file
    local body
    for app in $apps
    do
        file="$dir/$file"
        source "$file"
        AppsPlatform
        if [[ $? != 0 || "$FlagPlatformError" != "" || "$FlagInstallDir" == "" ]];then
            continue
        fi

    done
}
set +e
appsFind "$GithubAppsConfigure"
appsFind "$Root/github-apps.configure"
set -e