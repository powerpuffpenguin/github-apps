######    net request   ######
function RequestDownload
{
    local file="$1"
    local hash="$2"
    if [[ -f "$file" && "$hash" != "" ]];then
        local str=$(AppsHash "$file")
        for str in $str
        do
            str=$str
            break
        done
        if [[ "$str" == "$hash" ]];then
            return
        fi
    fi

    local url
    if [[ "$DevFile" == "" ]];then
        url=$FlagDownloadFile
    else
        url=$DevFile
    fi
    echo curl -#Lo "$file" "$url"
    curl -#Lo "$file" "$url"
}
RequestHashValue=""
function RequestHash
{
    RequestHashValue=""
    if [[ "$FlagDownloadHash" == "" ]];then
        return
    fi
    echo curl -sL "$FlagDownloadHash"
    local hash
    if [[ "$DevHash" == "" ]];then
        hash="$(curl -sL "$FlagDownloadHash")"
    else
        hash=$DevHash
    fi
    local str
    for str in $hash
    do
        RequestHashValue=$str
        break
    done
}
# request version
function RequestVersion
{
    local version=$FlagVersion
    local url
    if [[ "$version" == "" ]];then
        if [[ "$DevUrlLatest" == "" ]];then
            url=$FlagUrlLatest
        else
            url=$DevUrlLatest
        fi
    else
        if [[ "$DevUrlTag" == "" ]];then
            url=$FlagUrlTag
        else
            url=$DevUrlTag
        fi
    fi
    echo curl -H "Accept: application/vnd.github.v3+json" "$url"
    eval $(curl -s -H "Accept: application/vnd.github.v3+json" "$url" | {
        local value
        declare -i depth=0
        local assets=0
        declare -i assetsIndex=0
        local line
        while read line
        do
            # trim
            line=$(echo $line)
            if [[ "$line" == "{" || "$line" == "[" ]];then
                depth=depth+1
                continue
            elif [[ "$line" == "}" || "$line" == "}," || "$line" == "]" || "$line" == "]," ]];then
                depth=depth-1
                if [[ $depth == 1 ]];then
                    assets=0
                elif [[ $depth == 2 ]];then
                    if [[ $assets == 1 ]];then
                        assetsIndex=assetsIndex+1
                    fi
                fi
                continue
            fi

            value=${line#\"*\":}
            key=${line::${#line}-${#value}}
            value=${value%,}
            value=$(echo $value)

            if [[ "$key" != \"*\": ]];then
                continue
            fi
            key=${key:1:${#key}-3}
            if [[ $depth == 1 ]];then
                if [[ "$key" == "message" ]];then
                    echo "local error=$value"
                    return 0
                elif [[ "$key" == "tag_name" ]];then
                    echo "local tag_name=$value"
                elif [[ "$key" == "assets" ]];then
                    assets=1 
                fi
            elif [[ $depth == 3 ]];then
                if [[ $assets == 1 ]];then
                    if [[ "$key" == "name" ]];then
                        echo "local name_$assetsIndex=$value"
                    elif [[ "$key" == "size" ]];then
                        echo "local size_$assetsIndex=$value"
                    elif [[ "$key" == "browser_download_url" ]];then
                        echo local "url_$assetsIndex=$value"
                    fi
                fi
            fi
            if [[ "$value" == "{" || "$value" == "[" ]];then
                depth=depth+1
            fi
        done
        echo "local assetsSize=$assetsIndex"
    })
    if [[ "$error" != "" ]];then
        echo "Error: $error"
        return 1
    elif [[ "$tag_name" == "" ]];then
        echo "Parse response tag_name error"
        return 1
    fi
    VersionNext "$tag_name"
    if [[ "$VersionNextOk" == 0 ]];then
        echo "not supported installed version: $tag_name"
        return 1
    fi
    FlagVersion="$tag_name"

    declare -i assets=$assetsSize
    local i=0
    local browser_download_url=""
    local sha256_browser_download_url=""
    for((;i<assets;i++))
    do
        eval "local name=\$name_$i"
        eval "local url=\$url_$i"

        AppsSetFile "$name" "$url"
    done

    if [[ "$FlagDownloadFile" == "" ]];then
        echo "Parse assets not found download file" 
        return 1
    fi
    if [[ "$FlagSum" == 0 ]];then
        FlagDownloadHash=""
    fi
}
# request from version
function RequestVersionList
{
    local url
    if [[ "$DevUrlList" == "" ]];then
        url=$FlagUrlList
    else
        url=$DevUrlList
    fi

    echo curl -H "Accept: application/vnd.github.v3+json" "$url"
    eval $(curl -s -H "Accept: application/vnd.github.v3+json" "$url" | {
        declare -i depth=0
        local line
        declare -i index=0
        local assets=0
        local tag_name=""
        local release=1
        local names=()
        local urls=()
        while read line
        do
            # trim
            line=$(echo $line)
            if [[ "$line" == "{" || "$line" == "[" ]];then
                depth=depth+1
                if [[ "$depth" == 2 && "$line" == "{" ]];then
                    offset=offset+1
                fi
                continue
            elif [[ "$line" == "}" || "$line" == "}," || "$line" == "]" || "$line" == "]," ]];then
                depth=depth-1
                case $depth in
                    1)
                        if [[ $release == 1 && "$tag_name" != "" && $index != "0" ]];then
                            VersionNext "$tag_name"
                            if [[ $VersionNextOk == 1 ]];then
                                VersionCompare
                                FlagDownloadFile=""
                                if [[ $VersionCompareValue == 1 ]];then
                                    local i
                                    for((i=0;i<index;i++))
                                    do
                                        local name=${names[i]}
                                        local url=${urls[i]}
                                        AppsSetFile "$name" "$url"
                                    done
                                    if [[ "$FlagDownloadFile" != "" ]];then
                                        echo "local tag_name=\"$tag_name\""
                                        echo "local assetsSize=$index"
                                        for((i=0;i<index;i++))
                                        do
                                            local name=${names[i]}
                                            local url=${urls[i]}
                                            echo "local name_$i=\"$name\""
                                            echo "local url_$i=\"$url\""
                                        done
                                        return 0
                                    fi
                                fi
                            fi
                        fi
                        # clear
                        assets=0
                        index=0
                        tag_name=""
                        release=1
                        names=()
                        urls=()
                    ;;
                    2)
                        if [[ $assets == 1 ]];then
                            assets=0
                        fi
                    ;;
                    3)
                        if [[ $assets == 1 ]];then
                            index=index+1
                        fi
                    ;;
                esac
                continue
            fi

            value=${line#\"*\":}
            key=${line::${#line}-${#value}}
            value=${value%,}
            value=$(echo $value)

            if [[ "$key" != \"*\": ]];then
                continue
            fi
            key=${key:1:${#key}-3}
            if [[ $depth == 1 ]];then
                if [[ "$key" == "message" ]];then
                    echo "local error=$value"
                    return 0
                fi
            elif [[ $depth == 2 ]];then
                case "$key" in
                    tag_name)
                        tag_name=${value#\"}
                        tag_name=${tag_name%\"}
                    ;;
                    assets)
                        assets=1
                        index=0
                    ;;
                    draft|prerelease)
                        if [[ "$value" == "true" ]];then
                            release=0
                        fi
                    ;;
                esac
            elif [[ $depth == 4 && $assets == 1 ]];then
                case "$key" in
                    name)
                        value=${value#\"}
                        value=${value%\"}
                        names[index]=$value
                    ;;
                    browser_download_url)
                        value=${value#\"}
                        value=${value%\"}
                        urls[index]=$value
                    ;;
                esac
            fi

            case "$value" in
                "{"|"[")
                    depth=depth+1
                ;;
            esac
        done
    })
     if [[ "$error" != "" ]];then
        echo "Error: $error"
        return 1
    elif [[ "$tag_name" == "" ]];then
        echo "Parse response tag_name error"
        return 1
    fi
    VersionNext "$tag_name"
    if [[ "$VersionNextOk" == 0 ]];then
        echo "not supported installed version: $tag_name"
        return 1
    fi
    FlagVersion="$tag_name"

    declare -i assets=$assetsSize
    local i=0
    local browser_download_url=""
    local sha256_browser_download_url=""
    for((;i<assets;i++))
    do
        eval "local name=\$name_$i"
        eval "local url=\$url_$i"

        AppsSetFile "$name" "$url"
    done

    if [[ "$FlagDownloadFile" == "" ]];then
        echo "Parse assets not found download file" 
        return 1
    fi
    if [[ "$FlagSum" == 0 ]];then
        FlagDownloadHash=""
    fi
}