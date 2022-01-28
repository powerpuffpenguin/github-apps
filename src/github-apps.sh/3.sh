######    callback   ######
function CallbackClear
{
    eval 'function AppsPlatform
{
    FlagPlatformError="function AppsPlatform not implemented"
}
function AppsSetUrl
{
    echo function SetUrl not implemented
    return 1
}
function AppsSetFile
{
    echo function AppsSetFile not implemented
    return 1
}
function AppsUnpack
{
    echo function AppsUnpack not implemented
    return 1
}
function AppsRemove
{
    echo function AppsRemove not implemented
    return 1
}
function AppsHash
{
    sha256sum "$1"
}
function AppsVersion
{
    if [[ "$2" == "" ]];then
        AppsVersionValue=""
        appVersionGet "$1"
    else
        appVersionSet "$1" "$2"
    fi
}
# set download url
# FlagVersion
# FlagDownloadFile
# FlagDownloadHash
function AppsRequestVersion
{
    RequestVersion
}
# set download url
# FlagVersion
# FlagDownloadFile
# FlagDownloadHash
function AppsRequestVersionList
{
    RequestVersionList
}
'
}
