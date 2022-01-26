__powerpuffpenguin_github_apps_completion()
{
    local opts="-h --help"
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}
__powerpuffpenguin_github_apps_list()
{
    local opts="-h --help \
        -v --version -i --install"
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}
__powerpuffpenguin_github_apps_cache()
{
    local opts="-h --help \
        -t --test -d --delete"
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}
__powerpuffpenguin_github_apps_install()
{
    local apps=`github-apps.sh list 2> /dev/null`
    local opts="-h --help \
        -t --test -v --version -y --yes -n --no \
        --no-sum $apps"
    local previous=${COMP_WORDS[COMP_CWORD-1]}
    case $previous in
        -v|--version)
            COMPREPLY=()
        ;;
        *)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        ;;
    esac
}
__powerpuffpenguin_github_apps_upgrade()
{
    local apps=`github-apps.sh list -i 2> /dev/null`
    local opts="-h --help \
        -t --test -v --version -y --yes -n --no \
        --no-sum $apps"
    local previous=${COMP_WORDS[COMP_CWORD-1]}
    case $previous in
        -v|--version)
            COMPREPLY=()
        ;;
        *)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        ;;
    esac
}
__powerpuffpenguin_github_apps_remove()
{
    local apps=`github-apps.sh list -i 2> /dev/null`
    local opts="-h --help \
        -t --test -a --all -c --conf -d --data \
        $apps"
    local previous=${COMP_WORDS[COMP_CWORD-1]}
    case $previous in
        -v|--version)
            COMPREPLY=()
        ;;
        *)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        ;;
    esac
}
__powerpuffpenguin_github_apps()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ 1 == $COMP_CWORD ];then
        local opts="-h --help -v --version \
            completion list cache \
            install upgrade remove "
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    else
        case ${COMP_WORDS[1]} in
            completion)
                __powerpuffpenguin_github_apps_completion
            ;;
            list)
                __powerpuffpenguin_github_apps_list
            ;;
            cache)
                __powerpuffpenguin_github_apps_cache
            ;;
            install)
                __powerpuffpenguin_github_apps_install
            ;;
            upgrade)
                __powerpuffpenguin_github_apps_upgrade
            ;;
            remove)
                __powerpuffpenguin_github_apps_remove
            ;;
        esac
    fi
}

complete -F __powerpuffpenguin_github_apps github-apps.sh

