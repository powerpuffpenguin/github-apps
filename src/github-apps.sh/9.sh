######    input   ######
function InputPrompts
{
    local cmd
    while read -p "$1 (y/n): " cmd
    do
        if [[ "$cmd" == "n" ]];then
            InputPromptsOk=0
            break
        elif [[ "$cmd" == "y" ]];then
            InputPromptsOk=1
            break
        fi
    done
}