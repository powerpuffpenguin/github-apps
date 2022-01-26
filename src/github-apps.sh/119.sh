function upgradeExecute
{
    local app="$1"
    # load current version
    local versionFile="$FlagInstallDir/apps.version"
    if [[ ! -f "$versionFile" ]];then
        echo "version file not exists: $versionFile"
        return 1
    fi
    local current=$(cat "$versionFile")
    VersionCurreant "${current}"
    if [[ "$VersionCurreantOk" == 0 ]];then
        echo parse current version error
        return 1
    fi
    # request remote version
    local target=$FlagVersion
    AppsRequestVersion
    VersionCompare
    case $VersionCompareValue in
        0)
            echo "'$app' no new version"
            echo "upgraded '$app' completed"
            return
        ;;
        1)
            echo "'$app' found a new version: $FlagVersion"
        ;;
        2)
            if [[ "$target" == "" ]];then
                # not matched so reset
                FlagVersion=""
                FlagDownloadFile=""
                FlagDownloadHash=""
                AppsRequestVersionList
            else
                echo "target version not matched: $current -> $target"
                return 1
            fi
        ;;
        3)
            echo "a newer version is already installed locally"
            echo "upgraded '$app' completed"
            return
        ;;
        *)
            echo "VersionCompare return unknow value: $VersionCompareValue"
            return 1
        ;;
    esac

    echo "upgrade: $current -> $FlagVersion"
    if [[ "$FlagNo" != 0 ]];then
        echo automatic canceled
        return 1
    elif [[ "$FlagYes" == 0 ]];then
        InputPrompts "do you want to upgrade?"
        if [[ $InputPromptsOk == 0 ]];then
            echo user canceled
            return
        fi
    fi

    # get hash
    RequestHash
    local hash=$RequestHashValue

    # download
    local file="$Cache/$app"
    RequestDownload "$file"
    if [[ $hash != "" ]];then
        local str
        str=$(AppsHash "$file")
        for tmp in $str
        do
            str=$tmp
            break
        done
        if [[ "$hash" != "$str" ]];then
            echo "hash not matched"
            echo "remote: $hash" 
            echo "download: $str" 
            return 1
        fi
    fi

    # AppsUnpack
    AppsUnpack "$file"

    # Wriete version
    AppsVersion "$app" "$FlagVersion"
    
    echo rm "$file"
    rm "$file"
    echo "Successfully upgraded '$app' to '$FlagInstallDir'. $current -> $FlagVersion"
}