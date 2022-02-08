selfName=""
selfService="/etc/systemd/system/v2fly.service"
selfExt=""
function AppsPlatform
{
    AppsBody="Project V is a set of network tools that helps you to build your own computer network. It secures your network connections and thus protects your privacy."

    lib_Platform

    # check os
    local os
    case $lib_OS in
        windows)
            selfExt=".exe"
            os=$lib_OS
        ;;
        darwin|linux)
            selfExt=""
            os=$lib_OS
        ;;
        *)
            FlagPlatformError="Not Supported: v2fly on $lib_OS $lib_ARCH"
            return
        ;;
    esac
    # check arch
    local arch
    case $lib_ARCH in
        amd64)
            arch=64
        ;;
        *)
            FlagPlatformError="Not Supported: v2fly on $lib_OS $lib_ARCH"
            return
        ;;
    esac

    # set install dir
    selfName="${os}-${arch}"
    FlagInstallDir="/opt/v2fly"
}
function AppsSetUrl
{
    lib_GithubSetUrl "v2fly/v2ray-core"
}
function AppsSetFile
{
    local name="$1"
    local url="$2"
    if [[ "$name" == *$selfName.zip ]];then
        FlagDownloadFile=$url
    elif [[ "$name" == *$selfName.zip.dgst ]];then
        FlagDownloadHash=$url
    fi
}
function AppsRequestHash
{
    if [[ "$FlagDownloadHash" == "" ]];then
        return
    fi
    echo curl -sL "$FlagDownloadHash"
    local hash=$(curl -sL "$FlagDownloadHash" | {
        while read line
        do
            if [[ $line == SHA256=* ]];then
                line=${line:7}
                echo $line
            fi
        done
    })
    RequestHashValue=$hash
}
function AppsVersion
{
    # local app="$1"
    local version="$2"
    if [[ "$version" == "" ]];then
        local exe="$FlagInstallDir/v2ray$selfExt"
        if [[ -f "$exe" ]];then
            local str=$("$exe" -version )
            local tmp
            for tmp in $str
            do
                if [[ "$tmp" == "V2Ray" ]];then
                    continue
                fi
                AppsVersionValue=v$tmp
                break
            done
        fi
    else
        echo write version "'$version'"
    fi
}
function AppsUnpack
{
    lib_MkdirAll "$FlagInstallDir"
    local tmp="$Cache/v2flay.tmp"
    if [[ ! -d "$tmp" ]];then
        echo mkdir "$tmp"
        mkdir "$tmp"
    fi

    echo unzip  -o -d "$tmp" "$1"
    unzip  -o -d "$tmp" "$1"

    local name
    local items=(v2ray v2ctl)
    for name in "${items[@]}"
    do
        name="$name$selfExt"
        lib_CopyFile "$tmp/$name" "$FlagInstallDir/$name"
    done
    
    items=(geosite.dat geoip.dat)
    for name in "${items[@]}"
    do
        lib_CopyFile "$tmp/$name" "$FlagInstallDir/$name"
    done

    if [[ ! -f "$FlagInstallDir/config.json" ]];then
        lib_CopyFile "$tmp/config.json" "$FlagInstallDir/config.json"
    fi

    # create service
    case $lib_OS in
        linux)
            lib_FirstFile "service" "$selfService" '[Unit]
Description=V2Ray Service
Documentation=https://www.v2fly.org/
After=network.target nss-lookup.target

[Service]
User=nobody
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/opt/v2fly/v2ray -config /opt/v2fly/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target'
        ;;
    esac

    echo rm "$tmp" -rf
    rm "$tmp" -rf
}
function AppsRemove
{
    lib_DeleteFile "$FlagInstallDir/v2ray$selfExt"
    lib_DeleteFile "$FlagInstallDir/v2ctl$selfExt"
    if [[ "$FlagDeleteConf" != 0 ]];then
        lib_DeleteFile "$FlagInstallDir/config.json"
    fi

    lib_DeleteFile "$FlagInstallDir/geosite.dat"
    lib_DeleteFile "$FlagInstallDir/geoip.dat"

    lib_DeleteDir "$FlagInstallDir"

    lib_DeleteFile "$selfService"
}