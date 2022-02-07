function AppsPlatform
{
    AppsBody="AriaNg is a modern web frontend making aria2 easier to use"

    lib_Platform
    FlagInstallDir="/opt/ariang"
}
function AppsSetUrl
{
    lib_GithubSetUrl "mayswind/AriaNg"
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
    lib_MkdirAll "$FlagInstallDir"
    lib_ZipUnpack "$1" "$FlagInstallDir" -o
}
function AppsRemove
{
    lib_DeleteAll "$FlagInstallDir"
}