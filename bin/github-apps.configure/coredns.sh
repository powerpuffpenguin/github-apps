selfName=""
selfService="/etc/systemd/system/coredns.service"
selfExec=""
# Callback before install or upgrade or remove
#
# Usually here it is checked whether the platform is supported and a platform dependent variable can be set
#  * FlagPlatformError
#  * FlagInstallDir
function AppsPlatform
{
    AppsBody="CoreDNS is a DNS server/forwarder, written in Go, that chains plugins. Each plugin performs a (DNS) function."

    # call lib identify the platform
    lib_Platform

    # check os
    local os
    case $lib_OS in
        windows)
            selfExec="coredns.exe"
            os=$lib_OS
        ;;
        darwin|linux)
            selfExec="coredns"
            os=$lib_OS
        ;;
        *)
            FlagPlatformError="Not Supported: coredns on $lib_OS $lib_ARCH"
            return
        ;;
    esac
    # check arch
    local arch
    case $lib_ARCH in
        amd64)
            arch=$lib_ARCH
        ;;
        *)
            FlagPlatformError="Not Supported: coredns on $lib_OS $lib_ARCH"
            return
        ;;
    esac

    # set install dir
    selfName="${os}_${arch}"
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
    # call lib to set FlagUrlLatest FlagUrlList FlagUrlTag
    lib_GithubSetUrl "coredns/coredns"
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
        local exe="$FlagInstallDir/$selfExec"
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
    local who="coredns.coredns"
    lib_CreateSystemUser coredns
    lib_MkdirAll "$FlagInstallDir" "$who"

    # unpack
    lib_TarUnpack "$1" "$FlagInstallDir" -zv

    # create configure
    lib_FirstFile "configure" "$FlagInstallDir/Corefile" '.:10053 {
    cache
    forward . 127.0.0.1:10054 {
    }
}' "$who"

    # create service
    case $lib_OS in
        linux)
            lib_FirstFile "service" "$selfService" '[Unit]
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
WantedBy=multi-user.target'
        ;;
    esac
}

# Delete app from disk
# 
# The FlagTest flag should be evaluated to determine whether to actually operate
function AppsRemove
{
    lib_DeleteFile "$FlagInstallDir/$selfExec"
    if [[ "$FlagDeleteConf" != 0 ]];then
        lib_DeleteFile "$FlagInstallDir/Corefile"
    fi

    lib_DeleteDir "$FlagInstallDir"
    lib_DeleteFile "$selfService"

    if [[ "$FlagDeleteData" != 0 ]];then
        lib_DeleteUser coredns coredns
    fi
}