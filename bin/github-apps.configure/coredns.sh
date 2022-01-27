selfName=""
selfOS=""
selfService="/etc/systemd/system/coredns.service"

function selfCreateUser
{
    case "$selfOS" in
        linux)
            local group=$(egrep "^coredns:" /etc/group)
            if [[ "$group" == "" ]];then
                echo groupadd -r coredns
                if [[ "$FlagTest" == 0 ]];then
                    groupadd -r coredns
                fi
            fi
            local user=$(egrep "^coredns:" /etc/passwd)
            if [[ "$user" == "" ]];then
                echo useradd -r -g coredns coredns
                if [[ "$FlagTest" == 0 ]];then
                    useradd -r -g coredns coredns 
                fi
            fi
        ;;
    esac
}
function selfRemoveUser
{
    case "$selfOS" in
        linux)
            local user=$(egrep "^coredns:" /etc/passwd)
            if [[ "$user" != "" ]];then
                echo userdel coredns
                if [[ "$FlagTest" == 0 ]];then
                    userdel coredns
                fi
            fi
            local group=$(egrep "^coredns:" /etc/group)
            if [[ "$group" != "" ]];then
                echo groupdel coredns
                if [[ "$FlagTest" == 0 ]];then
                    groupdel coredns
                fi
            fi
        ;;
    esac
}
function selfChown
{
    case "$selfOS" in
        linux)
            chown coredns.coredns "$1"
        ;;
    esac
}
function selfMkdir
{
    if [[ ! -d "$1" ]];then
        echo mkdir "$1"
        if [[ "$FlagTest" == 0 ]];then
            mkdir "$1"
            selfChown "$1"
        fi
    fi
}
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
# Optional implementation for returning and setting the version number
#
# If not provided this function will create an apps.version file to store the version number
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

function selfCreateConf
{
    if [[ -f "$1" ]];then
        return
    fi

    echo "configure: $1"
    if [[ "$FlagTest" != 0 ]];then
        return
    fi

    echo '.:10053 {
cache
forward . 127.0.0.1:10054 {
}
}' > "$1"
    selfChown "$1"
}
function selfCreateServce
{
    if [[ -f "$1" ]];then
        return
    fi

    echo "service: $1"
    if [[ "$FlagTest" != 0 ]];then
        return
    fi

    echo '[Unit]
Description=CoreDNS Service
After=network-online.target
Wants=network-online.target
 
[Service]
Type=simple
User=coredns
ExecStart=/opt/coredns/coredns -conf /opt/coredns/Corefile
KillMode=control-group
Restart=on-failure
RestartSec=5s
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
' > "$1"
    selfChown "$1"
}
# Unzip the package to the installation path
# 
# The FlagTest flag should be evaluated to determine whether to actually operate
function AppsUnpack
{
    selfCreateUser
    selfMkdir "$FlagInstallDir"

    echo tar -zxvf "$1" -C "$FlagInstallDir"
    if [[ "$FlagTest" == 0 ]];then
        tar -zxvf "$1" -C "$FlagInstallDir"
    fi

    selfCreateConf "$FlagInstallDir/Corefile"
    selfCreateServce "$selfService"
}
function selfRemoveFile
{
    if [[ ! -f "$1" ]];then
        return
    fi
    echo rm "$1"
    if [[ "$FlagTest" != 0 ]];then
        return
    fi
    rm "$1"
}

function selfRemoveDir
{
    if [[ ! -d "$1" ]];then
        return
    fi
    if [[ "$(ls -A $1)" != "" ]];then
        return
    fi
    echo rmdir "$1"
    if [[ "$FlagTest" != 0 ]];then
        return
    fi
    rmdir "$1"
}
# Delete app from disk
# 
# The FlagTest flag should be evaluated to determine whether to actually operate
function AppsRemove
{
    selfRemoveFile "$FlagInstallDir/coredns"
    if [[ "$FlagDeleteConf" != 0 ]];then
        selfRemoveFile "$FlagInstallDir/Corefile"
    fi
    selfRemoveFile "$selfService"
    selfRemoveDir "$FlagInstallDir"
    if [[ "$FlagDeleteData" != 0 ]];then
        selfRemoveUser
    fi
}