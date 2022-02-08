selfName=""
selfService="/etc/systemd/system/v2ray-web.service"
selfExec=""
function AppsPlatform
{
    AppsBody="v2ray-web is a v2ray web view."

    # call lib identify the platform
    lib_Platform

    # check os
    local os
    case $lib_OS in
        windows)
            selfExec="v2ray-web.exe"
            os=$lib_OS
        ;;
        darwin|linux)
            selfExec="v2ray-web"
            os=$lib_OS
        ;;
        *)
            FlagPlatformError="Not Supported: v2ray-web on $lib_OS $lib_ARCH"
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
            FlagPlatformError="Not Supported: v2ray-web on $lib_OS $lib_ARCH"
            return
        ;;
    esac

    # set install dir
    selfName="${os}.${arch}"
    FlagInstallDir="/opt/v2ray-web"
}
function AppsSetUrl
{
    lib_GithubSetUrl "zuiwuchang/v2ray-web"
}
function AppsSetFile
{
    local name="$1"
    local url="$2"
    if [[ "$name" == $selfName.tar.gz ]];then
        FlagDownloadFile=$url
    elif [[ "$name" == $selfName.tar.gz.sha256 ]];then
        FlagDownloadHash=$url
    fi
}
function AppsVersion
{
    # local app="$1"
    local version="$2"
    if [[ "$version" == "" ]];then
        local exe="$FlagInstallDir/$selfExec"
        if [[ -f "$exe" ]];then
            local str=$("$exe" -v | {
                local first=1
                while read line
                do
                    if [[ $first == 1 ]];then
                        first=0
                    else
                        echo "$line"
                        break
                    fi
                done
            })
            AppsVersionValue=$str
        fi
    else
        echo write version "'$version'"
    fi
}
function AppsUnpack
{
    lib_MkdirAll "$FlagInstallDir"
    local tmp="$Cache/v2ray-web.tmp"
    if [[ ! -d "$tmp" ]];then
        echo mkdir "$tmp"
        mkdir "$tmp"
    fi
    echo tar -zxvf "$1" -C "$tmp"
    tar -zxvf "$1" -C "$tmp"
    local name
    local items=("$selfExec" geosite.dat geoip.dat)
    for name in "${items[@]}"
    do
        lib_CopyFile "$tmp/$name" "$FlagInstallDir/$name"
    done

    items=(v2ray-web.jsonnet run.sh 
        v2ray-web-service.exe v2ray-web-service.xml
        run.bat install.bat
    )
    for name in "${items[@]}"
    do
        if [[ ! -f "$tmp/$name" ]];then
            continue
        fi
        if [[ ! -f "$FlagInstallDir/$name" ]];then
            lib_CopyFile "$tmp/$name" "$FlagInstallDir/$name"
        fi
    done

    # create service
    case $lib_OS in
        linux)
            lib_FirstFile "service" "$selfService" '[Unit]
Description=V2ray Web Service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/opt/v2ray-web/v2ray-web web
KillMode=control-group
Restart=on-failure
LimitNOFILE=40960

[Install]
WantedBy=multi-user.target'
        ;;
    esac

    echo rm "$tmp" -rf
    rm "$tmp" -rf
}
function AppsRemove
{
    local items=("$selfExec"
        run.sh 
        v2ray-web-service.exe v2ray-web-service.xml
        run.bat install.bat)
    for name in "${items[@]}"
    do
        lib_DeleteFile "$FlagInstallDir/$name"
    done

    if [[ "$FlagDeleteConf" != 0 ]];then
        lib_DeleteFile "$FlagInstallDir/v2ray-web.jsonnet"
    fi
    if [[ "$FlagDeleteData" != 0 ]];then
        lib_DeleteFile "$FlagInstallDir/v2ray-web.db"
    fi
    lib_DeleteFile "$FlagInstallDir/geosite.dat"
    lib_DeleteFile "$FlagInstallDir/geoip.dat"

    lib_DeleteDir "$FlagInstallDir"

    lib_DeleteFile "$selfService"
}