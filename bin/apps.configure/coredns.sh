selfName=""
# Callback before install or upgrade or remove
#
# Usually here it is checked whether the platform is supported and a platform dependent variable can be set
function AppsPlatform
{
    local os="linux"
    local arch=$(uname -m)
    local platform=$(uname)
    if [[ "$platform" =~ (MINGW)|(MSYS)|(_NT) ]];then
        os="windows"
    elif [[ "$platform" =~ arwin ]];then 
        os="darwin"
    elif [[ "$platform" =~ inux ]];then 
        os="linux"
    else
        echo "Not Supported: coredns on $platform $arch"
        return 1 # not support
    fi
    if [[ "$arch" == "x86_64" ]];then
        arch=amd64
    else
        echo "Not Supported: coredns on $platform $arch"
        return 1
    fi
    selfName="${os}_${arch}"
    return 0
}
# Callback before install or upgrade, after AppsPlatform
#
# Usually, the release address of the app on github is set here 
#  * FlagUrlLatest
#  * FlagUrlList
#  * FlagUrlTag
function AppsSetUrl
{
    local owner_repo="coredns/coredns"
    FlagUrlLatest="https://api.github.com/repos/$owner_repo/releases/latest"
    FlagUrlList="https://api.github.com/repos/$owner_repo/releases"
    if [[ "$FlagVersion" != "" ]];then
        FlagUrlTag="https://api.github.com/repos/$owner_repo/releases/tags/$FlagVersion"
    fi
    return 0
}
# Callback before install or upgrade, after AppsSetUrl
#
# Set the name of the compressed package resource to download
#  * FlagDownloadName
#  * FlagDownloadHash  if empty skip checksum
function AppsSetName
{
    local version=${FlagVersion#v}

    FlagDownloadName="coredns_${version}_${selfName}.tgz"
    FlagDownloadHash="$FlagDownloadName.sha256"
}