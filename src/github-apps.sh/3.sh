######    callback   ######
function CallbackSelf
{
    eval 'function AppsPlatform
{
    FlagInstallDir="$Root"
}
function AppsSetUrl
{
    local owner_repo="powerpuffpenguin/github-apps"
    FlagUrlLatest="https://api.github.com/repos/$owner_repo/releases/latest"
    FlagUrlList="https://api.github.com/repos/$owner_repo/releases"
    if [[ "$FlagVersion" != "" ]];then
        FlagUrlTag="https://api.github.com/repos/$owner_repo/releases/tags/$FlagVersion"
    fi
    return 0
}
function AppsSetFile
{
    local name="$1"
    local url="$2"
    if [[ "$name" == "bin.tar.gz" ]];then
        FlagDownloadFile=$url
    elif [[ "$name" == "bin.tar.gz.sha256" ]];then
        FlagDownloadHash=$url
    fi
}
function AppsVersion
{
    # local app="$1"
    local version="$2"
    if [[ "$version" == "" ]];then
        AppsVersionValue="$Apps_Version"
        return
    else
        echo write version $version
    fi
}
function AppsUnpack
{
    local file="$1"
    if [[ ! -d "$FlagInstallDir" ]];then
        echo mkdir "$FlagInstallDir"
        if [[ "$FlagTest" == 0 ]];then
            mkdir "$FlagInstallDir"
        fi
    fi
    local conf="$FlagInstallDir/github-apps.configure"
    if [[ ! -d "$conf" ]];then
        echo mkdir "$conf"
        if [[ "$FlagTest" == 0 ]];then
            mkdir "$conf"
        fi
    fi

    local tmp="$Cache/self.tmp"
    if [[ ! -d "$tmp" ]];then
        echo mkdir "$tmp"
        mkdir "$tmp"
    fi
    echo tar -zxf "$1" -C "$tmp"
    tar -zxf "$1" -C "$tmp"

    echo cp github-apps.sh "$FlagInstallDir/github-apps.sh"
    if [[ "$FlagTest" == 0 ]];then
        cp "$tmp/github-apps.sh" "$FlagInstallDir/github-apps.sh"
    fi
    local confs="$tmp/github-apps.configure"
    local apps=$(find "$confs" -maxdepth 1 -name "*.sh" -type f | {
        while read file
        do
            name=$(basename "$file")
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
    local app
    for app in $apps
    do
        local dst="$FlagInstallDir/github-apps.configure/$app.sh"
        if [[ -f "$dst" ]];then
            echo "file exists: $dst"
            continue
        fi
        local src="$confs/$app.sh"
        if [[ -f "$src" ]];then
            echo cp "github-apps.configure/$app.sh" "$dst"
            if [[ "$FlagTest" == 0 ]];then
                cp "$src" "$dst"
            fi
        fi
    done

    echo rm "$tmp" -rf
    rm "$tmp" -rf
}
function AppsRemove
{
    local dir=$FlagInstallDir
    local file="$dir/github-apps.sh"
    if [[ -f "$file" ]];then
        echo rm "$file"
        if [[ "$FlagTest" == 0 ]];then
            rm "$file"
        fi
    fi
    local cache="$Cache"
    if [[ -d "$cache" ]];then
        echo rm "$cache" -rf
        if [[ "$FlagTest" == 0 ]];then
            rm "$cache" -rf
        fi
    fi

    if [[ "$FlagDeleteConf" != 0 ]];then
        local conf="$Configure"
        if [[ -d "$conf" ]];then
            echo rm "$conf" -rf
            if [[ "$FlagTest" == 0 ]];then
                rm "$conf" -rf
            fi
        fi
    fi
}
'
}