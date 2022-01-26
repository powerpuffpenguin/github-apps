function AppsPlatform
{
    FlagInstallDir="/opt/ariang"
}
function AppsSetUrl
{
    local owner_repo="mayswind/AriaNg"
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
    if [[ "$name" == "AriaNg-${FlagVersion}.zip" ]];then
        FlagDownloadFile=$url
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
    echo unzip -d "$FlagInstallDir" -o "$file"
    if [[ "$FlagTest" == 0 ]];then
        unzip -d "$FlagInstallDir" -o "$file"
    fi
}
function RemoveUnpack
{
    if [[ -d "$FlagInstallDir" ]];then
        echo rm "$FlagInstallDir" -rf
        if [[ "$FlagTest" == 0 ]];then
            rm "$FlagInstallDir" -rf
        fi
    fi
}