function installExecute
{
    local app="$1"
    AppsRequestVersion

    local success="Successfully installed '$app' to '$FlagInstallDir'. $FlagVersion"

    AppsVersion "$app"
    if [[ "$AppsVersionValue" != "" ]];then
        local current=$AppsVersionValue
        VersionCurreant "${current}"
        if [[ "$VersionCurreantOk" == 0 ]];then
            echo parse current version error
            if [[ "$FlagNo" != 0 ]];then
                 echo automatic canceled
                 return 1
            elif [[ "$FlagYes" == 0 ]];then
                InputPrompts "do you want to reinstall?"
                if [[ $InputPromptsOk == 0 ]];then
                    echo user canceled
                    return
                fi
            fi
            local success="Successfully reinstalled '$app' to '$FlagInstallDir'. $FlagVersion"
        else
            echo "An identical version already exists: $current"
            VersionCompare
            case $VersionCompareValue in
                0)
                    success="Successfully reinstalled '$app' to '$FlagInstallDir'. $FlagVersion"
                    if [[ "$FlagNo" != 0 ]];then
                        echo automatic canceled
                        return 1
                    elif [[ "$FlagYes" == 0 ]];then
                        InputPrompts "do you want to reinstall?"
                        if [[ $InputPromptsOk == 0 ]];then
                            echo user canceled
                            return
                        fi
                    fi
                ;;
                1)
                    success="Successfully upgraded '$app' to '$FlagInstallDir'. $current -> $FlagVersion"
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
                ;;
                2)
                    success="Successfully force upgraded '$app' to '$FlagInstallDir'. $current -> $FlagVersion"
                    echo "no matched upgrade: $current -> $FlagVersion"
                    if [[ "$FlagNo" != 0 ]];then
                        echo automatic canceled
                        return 1
                    elif [[ "$FlagYes" == 0 ]];then
                        InputPrompts "do you want to force upgrade?"
                        if [[ $InputPromptsOk == 0 ]];then
                            echo user canceled
                            return
                        fi
                    fi
                ;;
                3)
                    success="Successfully downgrade '$app' to '$FlagInstallDir'. $current -> $FlagVersion"
                    echo "downgrade: $current -> $FlagVersion"
                    if [[ "$FlagNo" != 0 ]];then
                        echo automatic canceled
                        return 1
                    elif [[ "$FlagYes" == 0 ]];then
                        InputPrompts "do you want to force downgrade?"
                        if [[ $InputPromptsOk == 0 ]];then
                            echo user canceled
                            return
                        fi
                    fi
                ;;
                *)
                    echo "VersionCompare return unknow value: $VersionCompareValue"
                    return 1
                ;;
            esac
        fi
    fi

    # get hash
    RequestHash
    local hash=$RequestHashValue

    # download
    local file="$Cache/$app"
    RequestDownload "$file" "$hash"
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

    if [[ $FlagKeep == 0 ]];then
        echo rm "$file"
        rm "$file"
    fi
    echo "$success"
}