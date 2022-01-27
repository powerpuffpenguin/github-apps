######    self   ######
function appsSelfHelp
{
    echo "github-apps.sh self manage"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    echo "  -t, --test             test delete cache but won't actually delete from hard disk"
    echo "  -i, --install          reinstall self"
    echo "  -u, --upgrade          upgrade self"
    echo "  -v, --version          specify the install or upgrade version number"
    echo "  -y, --yes              automatic yes to prompts"
    echo "  -n, --no               automatic no to prompts"
    echo "      --skip-checksum    don't validate archive hash"
    echo "  -r, --remove           remove self"
    echo "  -a, --all              also delete the configuration file and data file"
    echo "  -c, --conf             also delete the configuration file"
    echo "  -d, --data             also delete the data file"
    echo "  -h, --help             help for $Command"
}
function appsSelf
{
    FlagsClear
    GithubAppsSourceSelf=1

    local ARGS
    ARGS=`getopt -o htiuv:racdyn --long help,test,install,upgrade,version:,remove,all,conf,data,yes,no,skip-checksum -n "$Command" -- "$@"`
    eval set -- "${ARGS}"
    local install=0
    local upgrade=0
    local remove=0
    local installFlag=""
    local upgradeFlag=""
    local removeFlag=""
    while true
    do
    case "$1" in
        -h|--help)
            appsSelfHelp
            return 0
        ;;
        -t|--test)
            FlagTest=1
            shift
        ;;
        -i|--install)
            installFlag="$1"
            if [[ "$upgradeFlag" != "" ]];then
                echo "Parameters '$installFlag' and '$upgradeFlag' cannot be specified at the same time"
                return 1
            elif [[ "$removeFlag" != "" ]];then
                echo "Parameters '$installFlag' and '$removeFlag' cannot be specified at the same time"
                return 1
            fi
            install=1
            shift
        ;;
        -u|--upgrade)
            upgradeFlag="$1"
            if [[ "$installFlag" != "" ]];then
                echo "Parameters '$upgradeFlag' and '$installFlag' cannot be specified at the same time"
                return 1
            elif [[ "$removeFlag" != "" ]];then
                echo "Parameters '$upgradeFlag' and '$removeFlag' cannot be specified at the same time"
                return 1
            fi
            upgrade=1
            shift
        ;;
        -v|--version)
            FlagVersion="$2"
            shift 2
        ;;
        -r|--remove)
            removeFlag="$1"
            if [[ "$installFlag" != "" ]];then
                echo "Parameters '$removeFlag' and '$installFlag' cannot be specified at the same time"
                return 1
            elif [[ "$upgradeFlag" != "" ]];then
                echo "Parameters '$removeFlag' and '$upgradeFlag' cannot be specified at the same time"
                return 1
            fi
            remove=1
            shift
        ;;
        -a|--all)
            FlagDeleteConf=1
            FlagDeleteData=1
            shift
        ;;
        -c|--conf)
            FlagDeleteConf=1
            shift
        ;;
        -d|--data)
            FlagDeleteData=1
            shift
        ;;
        -y|--yes)
            FlagYes=1
            shift
        ;;
        -n|--no)
            FlagNo=1
            shift
        ;;
        --skip-checksum)
            FlagSum=0
            shift
        ;;
        --)
            shift
            break
        ;;
        *)
            echo Error: unknown flag "'$1'" for "$Command"
            echo "Run '$Command --help' for usage."
            return 1
        ;;
    esac
    done

    if [[ $install == 1 ]];then
        appsInstallOne "github-apps.sh"
        return $?
    elif [[ $upgrade == 1 ]];then
        appsUpgradeOne "github-apps.sh"
        return $?
    elif [[ $remove == 1 ]];then
        appRemoveOne "github-apps.sh"
        return $?
    fi

    appsSelfHelp
    return 1
}