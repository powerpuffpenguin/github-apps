# * windows
# * darwin
# * linux
lib_OS=""
# * amd64
# * 386
# * arm
# * arm64
lib_ARCH=""
# init lib_OS and lib_ARCH
function lib_Platform
{
    # os
    local platform=$(uname)
    if [[ "$platform" =~ (MINGW)|(MSYS)|(_NT) ]];then
        lib_OS="windows"
    elif [[ "$platform" =~ Darwin ]];then 
        lib_OS="darwin"
    elif [[ "$platform" =~ Linux ]];then 
        lib_OS="linux"
    fi

    # arch
    local arch=$(uname -m)
    if [[ "$arch" == "x86_64" ]];then
        lib_ARCH="amd64"
    fi
}

# $1 groupname
function lib_CreateSystemGroup
{
    case "$lib_OS" in
        linux)
            local exists=$(egrep "^$1:" /etc/group)
            if [[ "$exists" == "" ]];then
                echo groupadd -r "$1"
                if [[ "$FlagTest" == 0 ]];then
                    groupadd -r "$1"
                fi
            fi
        ;;
    esac
}
# * $1 username
# * $2 groupname, if empty same as username
function lib_CreateSystemUser
{
    # create group
    local username="$1"
    local groupname="$2"
    if [[ "$groupname" == "" ]];then
        groupname="$username"
    fi
    lib_CreateSystemGroup "$groupname"

    # create user
    case "$lib_OS" in
        linux)
            local exists=$(egrep "^$username:" /etc/passwd)
            if [[ "$exists" == "" ]];then
                echo useradd -r -g "$username" "$groupname"
                if [[ "$FlagTest" == 0 ]];then
                    useradd -r -g "$username" "$groupname"
                fi
            fi
        ;;
    esac
}
# $1 groupname
function lib_DeleteGroup
{
    case "$lib_OS" in
        linux)
            local exists=$(egrep "^$1:" /etc/group)
            if [[ "$exists" != "" ]];then
                echo groupdel "$1"
                if [[ "$FlagTest" == 0 ]];then
                    groupdel "$1"
                fi
            fi
        ;;
    esac
}
# * $1 username
# * $2 groupname, if not empty also delete group
function lib_DeleteUser
{
    local username="$1"
    local groupname="$2"

    case "$lib_OS" in
        linux)
            local exists=$(egrep "^$username:" /etc/passwd)
            if [[ "$exists" != "" ]];then
                echo userdel "$username"
                if [[ "$FlagTest" == 0 ]];then
                    userdel "$username"
                fi
            fi
        ;;
    esac

    # delete group
    if [[ "$groupname" != "" ]];then
        lib_DeleteGroup "$groupname"
    fi
}
# * $1 path
# * $2 who, chown "$who" "$path"
function lib_Chown
{
    local path="$1"
    local who="$2"
    case "$lib_OS" in
        linux)
            echo chown "$who" "$path"
            if [[ "$FlagTest" == 0 ]];then
                chown "$who" "$path"
            fi
        ;;
    esac
}
# * $1 path
# * $2 who, if not empty chown "$who" "$path"
function lib_MkdirAll
{
    local path="$1"
    local who="$2"
    if [[ ! -d "$path" ]];then
        echo mkdir "$path" -p
        if [[ "$FlagTest" == 0 ]];then
            mkdir "$path" -p
        fi
        if [[ "$who" != "" ]];then
            lib_Chown "$path" "$who"
        fi
    fi
}
# * $1 path
# * $2 who, if not empty chown "$who" "$path"
function lib_Mkdir
{
    local path="$1"
    local who="$2"
    if [[ ! -d "$path" ]];then
        echo mkdir "$path"
        if [[ "$FlagTest" == 0 ]];then
            mkdir "$path"
        fi
        if [[ "$who" != "" ]];then
            lib_Chown "$path" "$who"
        fi
    fi
}

# * $1 tag
# * $2 path
# * $3 data
# * $4 who, if not empty chown "$who" "$path"
function lib_FirstFile
{
    local tag="$1"
    local path="$2"
    local data="$3"
    local who="$4"

    if [[ -f "$1" ]];then
        return
    fi
    echo "$tag: $path"
    if [[ "$FlagTest" == 0 ]];then
        echo "$data" > "$path"
    fi
    if [[ "$who" != "" ]];then
        lib_Chown "$path" "$who"
    fi
}

# lib_TarUnpack console.tar.gz "./abc" -zv
# * $1 path
# * $2 output
# * $3... flags
function lib_TarUnpack
{
    local path="$1"
    local output="$2"
    shift 2

    echo tar "$@" "-xf" "$path" -C "$output"
    if [[ "$FlagTest" == 0 ]];then
        tar "$@" "-xf" "$path" -C "$output"
    fi
}
# lib_ZipUnpack console.zip "./abc" -o
# * $1 path
# * $2 output
# * $3... flags
function lib_ZipUnpack
{
    local path="$1"
    local output="$2"
    shift 2

    echo unzip  "$@" "-d" "$output" "$path"
    if [[ "$FlagTest" == 0 ]];then
        unzip "$@" "-d" "$output" "$path"
    fi
}

# lib_7ZUnpack console.7z "./abc" -y
# * $1 path
# * $2 output
# * $3... flags
function lib_7ZUnpack
{
    local path="$1"
    local output="$2"
    shift 2

    echo 7z e "$@" "-o$output" "$path"
    if [[ "$FlagTest" == 0 ]];then
        7z e "$@" "-o$output" "$path"
    fi
}
# * $1 path
function lib_DeleteFile
{
    if [[ ! -f "$1" ]];then
        return
    fi
    echo rm "$1"
    if [[ "$FlagTest" == 0 ]];then
        rm "$1"
    fi
}
# * $1 path
function lib_DeleteDir
{
    if [[ ! -d "$1" ]];then
        return
    fi
    if [[ "$(ls -A $1)" != "" ]];then
        return
    fi
    echo rmdir "$1"
    if [[ "$FlagTest" == 0 ]];then
        rmdir "$1"
    fi
}
function lib_DeleteAll
{
    if [[  -f "$1" ]];then
        echo rm "$1"
        if [[ "$FlagTest" == 0 ]];then
            rm "$1"
        fi
    elif [[ -d "$1" ]];then
        echo rm "$1" -rf
        if [[ "$FlagTest" == 0 ]];then
            rm "$1" -rf
        fi
    fi
}
# lib_GithubSetUrl "owner/repo"
# * $1 owner/repo
function lib_GithubSetUrl
{
    local owner_repo="$1"
    FlagUrlLatest="https://api.github.com/repos/$owner_repo/releases/latest"
    FlagUrlList="https://api.github.com/repos/$owner_repo/releases"
    if [[ "$FlagVersion" != "" ]];then
        FlagUrlTag="https://api.github.com/repos/$owner_repo/releases/tags/$FlagVersion"
    fi
}

# lib_CopyFile  src dst
# * $1 src
# * $2 dst
function lib_CopyFile
{
    echo cp "\"$1\"" "\"$2\""
    if [[ "$FlagTest" == 0 ]];then
        cp "$1" "$2"
    fi
}