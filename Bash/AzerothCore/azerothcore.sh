#!/bin/bash
INCLUDES=("distribution" "packages" "configuration" "source" "database" "process")

clear

if [ -f "includes/color.sh" ]; then
    source "includes/color.sh"
fi

printf "${COLOR_GREEN}Initializing...${COLOR_END}\n"

for i in "${INCLUDES[@]}"; do
    if [ -f "includes/$i.sh" ]; then
        printf "${COLOR_ORANGE}Loading includes/$i.sh${COLOR_END}\n"
        source "includes/$i.sh"
    else
        printf "${COLOR_ORANGE}Unable to access includes/$i.sh${COLOR_END}\n"
        exit 1
    fi
done

if [ $# -gt 0 ]; then
    if [ $# -eq 1 ]; then
        if [ $1 == "start" ]; then
            start_process
        elif [ $1 == "stop" ]; then
            stop_process
        else
            printf "\n${COLOR_GREEN}Invalid arguments${COLOR_END}\n"
            printf "${COLOR_ORANGE}The supplied arguments are invalid.${COLOR_END}\n"
        fi
    elif [ $# -eq 2 ]; then
        if [ $1 == "auth" ] || [ $1 == "world" ] || [ $1 == "all" ]; then
            [ $1 == "all" ] && TYPE=0
            [ $1 == "auth" ] && TYPE=1
            [ $1 == "world" ] && TYPE=2

            if [ $2 == "setup" ] || [ $2 == "install" ] || [ $2 == "update" ]; then
                stop_process
                clone_source
                compile_source $TYPE
                fetch_client_data
            elif [ $2 == "database" ] || [ $2 == "db" ]; then
                import_database $TYPE
                update_database $TYPE
            elif [ $2 == "cfg" ] || [ $2 == "conf" ] || [ $2 == "config" ] || [ $2 == "configuration" ]; then
                update_configuration $TYPE
            elif [ $2 == "all" ]; then
                stop_process
                clone_source
                compile_source $TYPE
                fetch_client_data
                import_database $TYPE
                update_database $TYPE
                update_configuration $TYPE
                start_process
            else
                printf "\n${COLOR_GREEN}Invalid arguments${COLOR_END}\n"
                printf "${COLOR_ORANGE}The supplied arguments are invalid.${COLOR_END}\n"
            fi

            clear
            printf "${COLOR_GREEN}Finished${COLOR_END}\n"
            printf "${COLOR_ORANGE}All actions completed successfully${COLOR_END}\n"
        else
            printf "\n${COLOR_GREEN}Invalid arguments${COLOR_END}\n"
            printf "${COLOR_ORANGE}The supplied arguments are invalid.${COLOR_END}\n"
        fi
    else
        printf "\n${COLOR_GREEN}Invalid arguments${COLOR_END}\n"
        printf "${COLOR_ORANGE}The supplied arguments are invalid.${COLOR_END}\n"
    fi
else
    printf "\n${COLOR_GREEN}Invalid arguments${COLOR_END}\n"
    printf "${COLOR_ORANGE}The supplied arguments are invalid.${COLOR_END}\n"
fi
