######    callback   ######
function CallbackClear
{
    eval 'function AppsPlatform
{
    echo function AppsPlatform not implemented
    return 1
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
function AppsHash
{
    sha256sum "$1"
}
function AppsUnpack
{
    echo function AppsUnpack not implemented
    return 1
}
'
}
