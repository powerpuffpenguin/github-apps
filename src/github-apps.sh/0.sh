######    configure   ######
set -e

# DevUrlLatest="http://192.168.251.50/tools/dev/github_coredns_latest.json"
# DevUrlList="http://192.168.251.50/tools/dev/github_coredns_list.json"
# DevUrlTag="http://192.168.251.50/tools/dev/github_coredns_v1.7.1.json"
# DevHash="40a0382681a8133f6612171fc8df0fc3403a28bd11f889c8f82a92039969d0b6"
# DevFile="http://192.168.251.50/tools/dev/coredns_1.8.7_linux_amd64.tgz"

function FlagsClear
{
    # if platform not supported, set error in this
    FlagPlatformError=""

    # if not 0 only test commands don't actually change apps
    FlagTest=0
    # app install dir
    FlagInstallDir=""
    # target version
    FlagVersion=""
    # if not 0 automatic 'yes' to prompts
    FlagYes=0
    # if not 0 automatic 'no' to prompts
    FlagNo=0
    # if 0 not check sum
    FlagSum=1
    
    # if not 0 delete configuration file
    FlagDeleteConf=0
    # if not 0 delete data file
    FlagDeleteData=0

    # download file url
    FlagDownloadFile=""
    # download hash file url
    FlagDownloadHash=""
    # http url return latest version info
    FlagUrlLatest=""
    # http url return list version info
    FlagUrlList=""
    # http url return tag version info
    FlagUrlTag=""

    # if not 0 keep (don't delete) download file
    FlagKeep=0
}
# Command
# Root dir
if [[ "$BASH_SOURCE" == "" ]];then
    Root=$(pwd)
    Command="github-apps.sh"
else
    Root=$(cd $(dirname $BASH_SOURCE) && pwd)
    Command=$(basename $BASH_SOURCE)
fi
# Configure dir
if [[ "$GithubAppsConfigure" != ""  ]];then
    Configure="$GithubAppsConfigure"
else
    Configure="$Root/github-apps.configure"
fi

# Cache dir
if [[ "$GithubAppsCache" != ""  ]];then
    Cache="$GithubAppsCache"
else
    Cache="$Root/github-apps.cache"
fi

# apps
if [[ ! -d "$Configure" ]];then
    mkdir "$Configure"
fi
Apps=$(find "$Configure" -maxdepth 1 -name "*.sh" -type f | {
    while read file
    do
        name=$(basename "$file")
        if [[ "$name" == "lib.sh" ]];then
            continue
        fi
        for str in $name
        do
            if [[ "$str" == "$name" ]];then
                name=${name%.sh}
                echo "$name "
            fi
            break
        done
    done
})
appsLibs=""
if [[ -f "$Root/github-apps.configure/lib.sh" ]];then
    source "$Root/github-apps.configure/lib.sh"
    appsLibs="$Root/github-apps.configure/lib.sh"
fi
if [[ "$GithubAppsConfigure" != "" && "$GithubAppsConfigure" != "$Root/github-apps.configure" ]];then
    if [[ -f "$GithubAppsConfigure/lib.sh" ]];then
        source "$GithubAppsConfigure/lib.sh"
        if [[ "$appsLibs" == "" ]];then
            appsLibs="$GithubAppsConfigure/lib.sh"
        else
            appsLibs="$appsLibs:$GithubAppsConfigure/lib.sh"
        fi
    fi
fi
if [[ ! -d "$Cache" ]];then
    mkdir "$Cache"
    chmod 777 "$Cache" 
fi

FlagsClear
function FlagsPush
{
    __FlagPlatformError=$FlagPlatformError

    __FlagTest=$FlagTest
    __FlagInstallDir=$FlagInstallDir
    __FlagVersion=$FlagVersion
    __FlagYes=$FlagYes
    __FlagNo=$FlagNo
    __FlagSum=$FlagSum

    __FlagDeleteConf=$FlagDeleteConf
    __FlagDeleteData=$FlagDeleteData

    __FlagDownloadFile=$FlagDownloadFile
    __FlagDownloadHash=$FlagDownloadHash
    __FlagUrlLatest=$FlagUrlLatest
    __FlagUrlList=$FlagUrlList
    __FlagUrlTag=$FlagUrlTag

    __FlagKeep=$FlagKeep
}
function FlagsPop
{
    FlagPlatformError=$__FlagPlatformError
    
    FlagTest=$__FlagTest
    FlagInstallDir=$__FlagInstallDir
    FlagVersion=$__FlagVersion
    FlagYes=$__FlagYes
    FlagNo=$__FlagNo
    FlagSum=$__FlagSum

    FlagDeleteConf=$__FlagDeleteConf
    FlagDeleteData=$__FlagDeleteData

    FlagDownloadFile=$__FlagDownloadFile
    FlagDownloadHash=$__FlagDownloadHash
    FlagUrlLatest=$__FlagUrlLatest
    FlagUrlList=$__FlagUrlList
    FlagUrlTag=$__FlagUrlTag

    FlagKeep=$__FlagKeep
}