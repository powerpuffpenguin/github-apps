######    configure   ######
set -e

DevUrlLatest="http://192.168.251.50/tools/dev/github_coredns_latest.json"
DevUrlList="http://192.168.251.50/tools/dev/github_coredns_list.json"
DevUrlTag="http://192.168.251.50/tools/dev/github_coredns_v1.7.1.json"
DevHash="40a0382681a8133f6612171fc8df0fc3403a28bd11f889c8f82a92039969d0b6"
DevFile="http://192.168.251.50/tools/dev/coredns_1.8.7_linux_amd64.tgz"

function FlagsClear
{
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

    # download file
    FlagDownloadFile=""
    # download hash file
    FlagDownloadHash=""
    # http url return latest version info
    FlagUrlLatest=""
    # http url return list version info
    FlagUrlList=""
    # http url return tag version info
    FlagUrlTag=""
}
# Command
Command=$(basename $BASH_SOURCE)
# Root dir
Root=$(cd $(dirname $BASH_SOURCE) && pwd)
# Configure dir
Configure="$Root/apps.configure"
# Cache dir
Cache="$Root/apps.cache"

# apps
if [[ ! -d "$Configure" ]];then
    mkdir "$Configure"
fi
Apps=$(find "$Configure" -maxdepth 1 -name "*.sh" -type f | {
    while read file
    do
        name=$(basename "$file")
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
if [[ ! -d "$Cache" ]];then
    mkdir "$Cache"
    chmod 777 "$Cache" 
fi

FlagsClear
function FlagsPush
{
    __FlagTest=$FlagTest
    __FlagInstallDir=$FlagInstallDir
    __FlagVersion=$FlagVersion
    __FlagYes=$FlagYes
    __FlagNo=$FlagNo
    __FlagSum=$FlagSum

    __FlagDownloadFile=$FlagDownloadFile
    __FlagDownloadHash=$FlagDownloadHash
    __FlagUrlLatest=$FlagUrlLatest
    __FlagUrlList=$FlagUrlList
    __FlagUrlTag=$FlagUrlTag
}
function FlagsPop
{
    FlagTest=$__FlagTest
    FlagInstallDir=$__FlagInstallDir
    FlagVersion=$__FlagVersion
    FlagYes=$__FlagYes
    FlagNo=$__FlagNo
    FlagSum=$__FlagSum

    FlagDownloadFile=$__FlagDownloadFile
    FlagDownloadHash=$__FlagDownloadHash
    FlagUrlLatest=$__FlagUrlLatest
    FlagUrlList=$__FlagUrlList
    FlagUrlTag=$__FlagUrlTag
}