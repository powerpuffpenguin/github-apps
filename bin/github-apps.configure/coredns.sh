selfName=""
selfOS=""
# Callback before install or upgrade or remove
#
# Usually here it is checked whether the platform is supported and a platform dependent variable can be set
#  * FlagPlatformError
#  * FlagInstallDir
function AppsPlatform
{
    local os="linux"
    local arch=$(uname -m)
    local platform=$(uname)
    if [[ "$platform" =~ (MINGW)|(MSYS)|(_NT) ]];then
        os="windows"
    elif [[ "$platform" =~ Darwin ]];then 
        os="darwin"
    elif [[ "$platform" =~ Linux ]];then 
        os="linux"
    else
        # not support
        FlagPlatformError="Not Supported: coredns on $platform $arch"
        return 
    fi
    if [[ "$arch" == "x86_64" ]];then
        arch=amd64
    else
        FlagPlatformError="Not Supported: coredns on $platform $arch"
        return
    fi

    selfName="${os}_${arch}"
    selfOS="$os"
    
    # set install dir
    FlagInstallDir="/opt/coredns"
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
# Callback in foreach assets, before install or upgrade, after AppsSetUrl
#
# Set the name of the compressed package resource to download
#  * FlagDownloadFile
#  * FlagDownloadHash  if empty skip checksum
function AppsSetFile
{
    local name="$1"
    local url="$2"
    if [[ "$name" == *$selfName.tgz ]];then
        FlagDownloadFile=$url
    elif [[ "$name" == *$selfName.tgz.sha256 ]];then
        FlagDownloadHash=$url
    fi
}
function AppsVersion
{
    # local app="$1"
    local version="$2"
    if [[ "$version" == "" ]];then
        local exe="$FlagInstallDir/coredns"
        if [[ -f "$exe" ]];then
            local str=$("$exe" -version )
            for str in $str
            do
                break
            done
            str=v${str#CoreDNS-}
            AppsVersionValue=$str
        fi
    else
        echo write version "'$version'"
    fi
}

# Unzip the package to the installation path
# 
# The FlagTest flag should be evaluated to determine whether to actually operate
function AppsUnpack
{
    local file="$1"
    if [[ ! -d "$FlagInstallDir" ]];then
        echo mkdir "$FlagInstallDir"
        if [[ "$FlagTest" == 0 ]];then
            mkdir "$FlagInstallDir"
        fi
    fi
    echo tar -zxvf "$1" -C "$FlagInstallDir"
    if [[ "$FlagTest" == 0 ]];then
        tar -zxvf "$1" -C "$FlagInstallDir"
    fi

    if [[ ! -f "$file" ]];then
        echo "create default configure: $FlagInstallDir/Corefile"
        if [[ "$FlagTest" == 0 ]];then
            local file="$FlagInstallDir/Corefile"
            echo '.:10053 {
	cache
	forward . 127.0.0.1:10054 {
	}
}' > "$file"
        fi
    fi
}
function RemoveUnpack
{
    local dir=$FlagInstallDir
    local file="$dir/coredns"
    if [[ -f "$file" ]];then
        echo rm "$file"
        if [[ "$FlagTest" == 0 ]];then
            rm "$file"
        fi
    fi
    if [[ "$FlagDeleteConf" != 0 ]];then
        local conf="$dir/Corefile"
        if [[ -f "$conf" ]];then
            echo rm "$conf"
            if [[ "$FlagTest" == 0 ]];then
                rm "$conf"
            fi
        fi
    fi
}