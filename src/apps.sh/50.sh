######    net request   ######
function RequestDownload
{
    local file="$1"
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