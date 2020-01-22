#!/bin/bash

#add your args here, a colon after the arg represents a REQUIRED argument.
declare -A options=(
    ["n"]="Favorite icecream is neopolitan."
    ["c"]="Favorite icecream is chocolate."
    ["v"]="Favorite icecream is vanilla."
    ["s"]="Favorite icecream is strawberry."
    ["--flavor:"]="[value required] Set to custom flavor."
    ["z:"]="[value required] Set to custom flavor."
)

main() {
    while getopts ":h--help$(join \"\" \"${!options[@]}\")" opt; do
        #Add your cases here.
        case "$1" in
            -n)
                FLAVOR="neopolitan"
            ;;
            -c)
                FLAVOR="chocolate"
            ;;
            -v)
                FLAVOR="vanilla"
            ;;
            -s)
                FLAVOR="strawberry"
            ;;
            -z | --flavor)
                shift; #shift arg to put value in $1
                FLAVOR=$1
            ;;
            #Leave these unless you want to remove the help screen.
            -h | --help)
                usage
            ;;
            *)
                error_invalide_argument $1
            ;;
        esac
        shift
    done
}

error_invalide_argument () {
    say error "Invalide argument \"$1\"."
    usage
    exit 1
}

#usage()
#Prints usage screen based on the args and descriptions defined in the $options
#associated array. 
usage () {
    say yellow "$0 [option] [value]"
    max_columns=0
    for i in "${!options[@]}"
    do
        option="${i//:}"        
        if [ "${#option}" -eq "1" ]
        then
            option="-$option"
        fi        
        if [ "${#option}" -gt "$max_columns" ]
        then
            max_columns="$((${#option}+1))"
        fi
    done
    for i in "${!options[@]}"
    do
        option="${i//:}"        
        if [ "${#option}" -eq "1" ]
        then
            option="-$option"
        fi
        msg=$(eval "$(echo printf \"%$((max_columns))s : %s\" "$option" \"${options[$i]}\")")
        say yellow "$msg"
    done
}

#say()
#If 3 arguments provided; $1 is foreground, $2 is background and $3 is text.
#If 2 arguments provided; $1 is foreground and $2 is text.
#If 1 argument is provided; $1 is just text.
#Also if 2 arguments provided, $1 can be one of 3 templates listed below;
#    error - Prepends "ERROR: " at the beginning of message and fg is default
#            and bg is light red. Text is bold.
#    warn  - Prepends "WARN: " at the beginning of message and fg is light red
#            and text is bold.
#    info  - Prepend "INFO: " at the beginning of message and fg is light cyan
#            and text is bold.
#If no formatting argument is provided, text will just be light gray and "LOG: "
#will be prepended to the beginning of the text.
say () {    
    declare -A fgcolors=(
        ["reset"]="0"
        ["bold"]="1"
        ["dim"]="2"
        ["default"]="39"
        ["black"]="30"
        ["red"]="31"
        ["green"]="32"
        ["yellow"]="33"
        ["blue"]="34"
        ["magenta"]="35"
        ["cyan"]="36"
        ["light_gray"]="37"
        ["dark_gray"]="90"
        ["light_red"]="91"
        ["light_green"]="92"
        ["light_yellow"]="93"
        ["light_blue"]="94"
        ["light_magenta"]="95"
        ["light_cyan"]="96"
        ["white"]="97"
    );
    
    declare -A bgcolors=(
        ["default"]="49"
        ["black"]="40"
        ["red"]="41"
        ["green"]="42"
        ["yellow"]="43"
        ["blue"]="44"
        ["magenta"]="45"
        ["cyan"]="46"
        ["light_gray"]="47"
        ["dark_gray"]="100"
        ["light_red"]="101"
        ["light_green"]="102"
        ["light_yellow"]="103"
        ["light_blue"]="104"
        ["light_magenta"]="105"
        ["light_cyan"]="106"
        ["white"]="107"
    );
    
    case $1 in
        info)
            if [ ! -z "$2" ]
            then
                say light_cyan "\e[${fgcolors[bold]}mINFO: $2"
            fi
        ;;
        warn)
            if [ ! -z "$2" ]
            then
                say light_red "\e[${fgcolors[bold]}mWARN: $2"
            fi
        ;;
        error)
            if [ ! -z "$2" ]
            then
                say default light_red "\e[${fgcolors[bold]}mERROR: $2"
            fi
        ;;
        *)
            if [ ! -z "fgcolors[$1]" ] && [ ! -z "fgcolors[$2]" ] && [ ! -z "$3" ]
            then
                echo -e "\e[${fgcolors[$1]}m\e[${bgcolors[$2]}m$3\e[${fgcolors[reset]}m"
            elif [ ! -z "fgcolors[$1]" ] && [ ! -z "$2" ]
            then
                echo -e "\e[${fgcolors[$1]}m$2\e[${fgcolors[reset]}m"
            else
                echo -e "LOG: \e[${fgcolors[light_gray]}m$1"
            fi
        ;;
    esac
}

#get_input()
#Gets regular text input.
#Is called via a subshell
#example: username=$(get_input "Input username.")
get_input () { read -p "$1 : " input; echo $input; }

#get_password()
#Gets regular text input but it is obscured for safety.
#Is called via a subshell
#example: password=$(get_password "Input password.")
get_password () { read -s -p "$1 : " input; echo $input; }

#join()
#Joins an array. $1 is the seperator.
#Is called via subshell
#ex: my_array=( "item1" "item2" "item3")
#    my_joined_array="$(join , ${my_array[@]})"
join () { local IFS="$1"; shift; echo "$*"; }

#substring()
#Returns value in a string from position to position
#Called via subshell
#$3 is the string, $1 is the starting position, $2 is ending position
#ex: SUBSTRING=$(substring 2 6 "1234567890")
#    say $SUBSTRING
#The example will display "23456" from "1234567890"
substring () { echo "$3" | cut -c$1-$2; }


#run arg parser in main(). Ideally I put my code after main()
#but code can also be appended in main() if desired.
main "$@";

say light_yellow dark_gray "Favorite icecream is $FLAVOR"
say error "This is an error."
say warn "This is a warning."
say info "This is some useful info."
say "This is just whatever."

exit 0;