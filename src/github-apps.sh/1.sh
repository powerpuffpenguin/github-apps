######    info   ######
apps=()
appsSource=()
appsBody=()
declare -i appsOffset=0
appExits=0
function appIsExits
{
    appExits=0
    local app
    for app in "${apps[@]}"
    do
        if [[ "$app" == "$1" ]];then
            appExits=1
            return
        fi
    done
}
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
    local items=$(find "$dir" -maxdepth 1 -name "*.sh" -type f | {
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
    for app in $items
    do
        file="$dir/$app.sh"
        if [[ ! -f "$file" ]];then
            continue  
        fi
        appIsExits "$app"
        if [[ $appExits == 1 ]];then
            continue
        fi
        eval 'function AppsPlatform
{
    FlagPlatformError="function AppsPlatform not implemented"
}
AppsBody=""'
        source "$file"
        AppsPlatform
        if [[ $? != 0 || "$FlagPlatformError" != "" || "$FlagInstallDir" == "" ]];then
            continue
        fi
        apps[$appsOffset]="$app"
        appsSource[$appsOffset]="$file"
        appsBody[$appsOffset]="$AppsBody"
        appsOffset=appsOffset+1
    done
}
set +e
if [[ "$GithubAppsConfigure" != "" && -d "$GithubAppsConfigure" ]];then
    appsFind "$GithubAppsConfigure"
fi
appsFind "$Root/github-apps.configure"
set -e

function sourceApp
{
    local i=0
    for i in "${!apps[@]}"
    do
        local app=${apps[$i]}
        if [[ "$app" == "$1" ]];then
            source ${appsSource[$i]}
            return
        fi
    done
    echo "load configure error: $1"
    return 1
}