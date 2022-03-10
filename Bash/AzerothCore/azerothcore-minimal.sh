#!/bin/bash
DISTRIBUTION=("debian11" "ubuntu20.04" "ubuntu20.10" "ubuntu21.04" "ubuntu21.10")

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID

    if [[ ! " ${DISTRIBUTION[@]} " =~ " ${OS}${VERSION} " ]]; then
        echo -e "\e[0;31mThis distribution is currently not supported\e[0m"
        exit $?
    fi
fi

# Define colors for easier access
COLOR_BLACK="\e[0;30m"
COLOR_RED="\e[0;31m"
COLOR_GREEN="\e[0;32m"
COLOR_ORANGE="\e[0;33m"
COLOR_BLUE="\e[0;34m"
COLOR_PURPLE="\e[0;35m"
COLOR_CYAN="\e[0;36m"
COLOR_LIGHT_GRAY="\e[0;37m"
COLOR_DARK_GRAY="\e[1;30m"
COLOR_LIGHT_RED="\e[1;31m"
COLOR_LIGHT_GREEN="\e[1;32m"
COLOR_YELLOW="\e[1;33m"
COLOR_LIGHT_BLUE="\e[1;34m"
COLOR_LIGHT_PURPLE="\e[1;35m"
COLOR_LIGHT_CYAN="\e[1;36m"
COLOR_WHITE="\e[1;37m"
COLOR_END="\e[0m"

ROOT=$(pwd)

# A function to install the options package
function options_package
{
    # Different distributions are handled in their own way. This is unnecessary but will help if other distributions are added in the future
    if [[ $OS == "ubuntu" ]] || [[ $OS == "debian" ]]; then
        # Check if the package is installed
        if [ $(dpkg-query -W -f='${Status}' libxml2-utils 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
            clear

            # Perform an update to make sure nothing is missing
            apt-get --yes update
            if [ $? -ne 0 ]; then
                exit $?
            fi

            # Install the package that is missing
            apt-get --yes install libxml2-utils
            if [ $? -ne 0 ]; then
                exit $?
            fi
        fi
    fi
}

# A function to install the git package
function git_package
{
    # Different distributions are handled in their own way. This is unnecessary but will help if other distributions are added in the future
    if [[ $OS == "ubuntu" ]] || [[ $OS == "debian" ]]; then
        # Check if the package is installed
        if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
            clear

            # Perform an update to make sure nothing is missing
            apt-get --yes update
            if [ $? -ne 0 ]; then
                exit $?
            fi

            # Install the package that is missing
            apt-get --yes install git
            if [ $? -ne 0 ]; then
                exit $?
            fi
        fi
    fi
}

# A function to install all required packages for compilation of and to run the core
function source_packages
{
    # Different distributions are handled in their own way. This is unnecessary but will help if other distributions are added in the future
    if [[ $OS == "ubuntu" ]] || [[ $OS == "debian" ]]; then
        # An array of all required packages
        PACKAGES=("cmake" "make" "gcc" "clang" "screen" "curl" "unzip" "g++" "libssl-dev" "libbz2-dev" "libreadline-dev" "libncurses-dev" "libace-6.*" "libace-dev" "libmariadb-dev-compat" "mariadb-client")

        # Handle each distribution properly as some require different packages
        if [[ $OS == "ubuntu" ]]; then
            PACKAGES="${PACKAGES} libboost1.71-all-dev"

            if [[ $VERSION == "20.04" ]] || [[ $VERSION == "20.10" ]]; then
                PACKAGES="${PACKAGES} libmariadbclient-dev"
            fi
        elif [[ $OS == "debian" ]]; then
            PACKAGES="${PACKAGES} libboost1.74-all-dev"
        fi

        # Loop through each member of the array and add them to the list of packages to be installed
        for p in "${PACKAGES[@]}"; do
            # Check if the package is installed
            if [ $(dpkg-query -W -f='${Status}' $p 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
                INSTALL+=($p)
            fi
        done

        # Check if there actually are packages to install
        if [ ${#INSTALL[@]} -gt 0 ]; then
            clear

            # Perform an update to make sure nothing is missing
            apt-get --yes update
            if [ $? -ne 0 ]; then
                exit $?
            fi

            # Install all packages that are missing
            apt-get --yes install ${INSTALL[*]}
            if [ $? -ne 0 ]; then
                exit $?
            fi
        fi
    fi
}

# A function to install the mariadb client package
function database_package
{
    # Different distributions are handled in their own way. This is unnecessary but will help if other distributions are added in the future
    if [[ $OS == "ubuntu" ]] || [[ $OS == "debian" ]]; then
        # Check if the package is installed
        if [ $(dpkg-query -W -f='${Status}' mariadb-client 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
            clear

            # Perform an update to make sure nothing is missing
            apt-get --yes update
            if [ $? -ne 0 ]; then
                exit $?
            fi

            # Install the package that is missing
            apt-get --yes install mariadb-client
            if [ $? -ne 0 ]; then
                exit $?
            fi
        fi
    fi
}

# A function to save all options to the file
function store_options
{
    echo "<?xml version=\"1.0\"?>
    <options>
        <mysql>
            <!-- The ip-address or hostname used to connect to the database server -->
            <hostname>${1:-127.0.0.1}</hostname>
            <!-- The port used to connect to the database server -->
            <port>${2:-3306}</port>
            <!-- The username used to connect to the database server -->
            <username>${3:-acore}</username>
            <!-- The password used to connect to the database server -->
            <password>${4:-acore}</password>
            <databases>
                <!-- The name of the auth database -->
                <auth>${5:-acore_auth}</auth>
                <!-- The name of the characters database -->
                <characters>${6:-acore_characters}</characters>
                <!-- The name of the world database -->
                <world>${7:-acore_world}</world>
            </databases>
        </mysql>
        <source>
            <!-- The location where the source is located -->
            <location>${8:-/opt/azerothcore}</location>
            <!-- The required client data version -->
            <required_client_data>${9:-12}</required_client_data>
            <!-- The installed client data version. WARNING: DO NOT EDIT -->
            <installed_client_data>${10:-0}</installed_client_data>
        </source>
        <world>
            <!-- The name of the realm as seen in the list -->
            <name>${11:-AzerothCore}</name>
            <!-- Message of the Day, displayed at login. Use '@' for a newline and make sure to escape special characters -->
            <motd>${12:-Welcome to AzerothCore.}</motd>
            <!-- The id of the realm -->
            <id>${13:-1}</id>
            <!-- The ip or hostname used to connect to the world server. Use external ip if required -->
            <address>${14:-127.0.0.1}</address>
            <!-- Server game type. 0 = normal, 1 = pvp, 6 = rp, 8 = rppvp -->
            <game_type>${15:-0}</game_type>
            <!-- Server realm zone. Set allowed alphabet in character names etc. 1 = development, 2 = united states, 6 = korea, 9 = german, 10 = french, 11 = spanish, 12 = russian, 14 = taiwan, 16 = china, 26 = test server -->
            <realm_zone>${16:-1}</realm_zone>
            <!-- Allow server to use content from expansions. Checks for expansion-related map files, client compatibility and class/race character creation. 0 = none, 1 = tbc, 2 = wotlk -->
            <expansion>${17:-2}</expansion>
            <!-- Maximum number of players in the world. Excluding Mods, GMs and Admins -->
            <player_limit>${18:-1000}</player_limit>
            <!-- Disable cinematic intro at first login after character creation. Prevents buggy intros in case of custom start location coordinates. 0 = Show intro for each new character, 1 = Show intro only for first character of selected race, 2 = Disable intro for all classes -->
            <skip_cinematics>${19:-0}</skip_cinematics>
            <!-- Maximum level that can be reached by players. Levels below 1 and above 80 will reset to 80 -->
            <max_level>${20:-80}</max_level>
            <!-- Starting level for characters after creation. Levels below 1 and above 80 will reset to 1 -->
            <start_level>${21:-1}</start_level>
            <!-- Amount of money (in Copper) that a character has after creation -->
            <start_money>${22:-0}</start_money>
            <!-- Players will automatically gain max skill level when logging in or leveling up. false = disabled, true = enabled -->
            <always_max_skill>${23:-false}</always_max_skill>
            <!-- Character knows all flight paths (of both factions) after creation. false = disabled, true = enabled -->
            <all_flight_paths>${24:-false}</all_flight_paths>
            <!-- Characters start with all maps explored. false = disabled, true = enabled -->
            <maps_explored>${25:-false}</maps_explored>
            <!-- Allow players to use commands. false = disabled, true = enabled -->
            <allow_commands>${26:-true}</allow_commands>
            <!-- Allow non-raid quests to be completed while in a raid group. false = disabled, true = enabled -->
            <quest_ignore_raid>${27:-false}</quest_ignore_raid>
            <!-- Prevent players AFK from being logged out. false = disabled, true = enabled -->
            <prevent_afk_logout>${28:-false}</prevent_afk_logout>
            <!-- Highest level up to which a character can benefit from the Recruit-A-Friend experience multiplier -->
            <raf_max_level>${29:-60}</raf_max_level>
            <!-- Preload all grids on all non-instanced maps. This will take a great amount of additional RAM (ca. 9 GB) and causes the server to take longer to start, but can increase performance if used on a server with a high amount of players. It will also activate all creatures which are set active (e.g. the Fel Reavers in Hellfire Peninsula) on server start. false = disabled, true = enabled -->
            <preload_map_grids>${30:-false}</preload_map_grids>
            <!-- Set all creatures with waypoint movement active. This means that they will start movement once they are loaded (which happens on grid load) and keep moving even when no player is near. This will increase CPU usage significantly and can be used with enabled preload_map_grids to start waypoint movement on server startup. false = disabled, true = enabled -->
            <set_all_waypoints_active>${31:-false}</set_all_waypoints_active>
            <!-- Enable/Disable Minigob Manabonk in Dalaran. false = disabled, true = enabled -->
            <enable_minigob_manabonk>${32:-true}</enable_minigob_manabonk>
            <!-- Enable Warden anti-cheat system. false = disabled, true = enabled -->
            <enable_warden>${33:-true}</enable_warden>
            <rates>
                <!-- Experience rates (outside battleground) -->
                <experience>${34:-1}</experience>
                <!-- Resting points grow rates -->
                <rested_experience>${35:-1}</rested_experience>
                <!-- Reputation gain rate -->
                <reputation>${36:-1}</reputation>
                <!-- Drop rates for money -->
                <money>${37:-1}</money>
                <!-- Crafting skills gain rate -->
                <crafting>${38:-1}</crafting>
                <!-- Gathering skills gain rate -->
                <gathering>${39:-1}</gathering>
                <!-- Weapon skills gain rate -->
                <weapon_skill>${40:-1}</weapon_skill>
                <!-- Defense skills gain rate -->
                <defense_skill>${41:-1}</defense_skill>
            </rates>
            <gm>
                <!-- Set GM state when a GM character enters the world. false = disabled, true = enabled -->
                <login_state>${42:-true}</login_state>
                <!-- GM visibility at login. false = disabled, true = enabled -->
                <enable_visibility>${43:-false}</enable_visibility>
                <!-- GM chat mode at login. false = disabled, true = enabled -->
                <enable_chat>${44:-true}</enable_chat>
                <!-- Is GM accepting whispers from player by default or not. false = disabled, true = enabled -->
                <enable_whisper>${45:-false}</enable_whisper>
                <!-- Maximum GM level shown in GM list (if enabled) in non-GM state. 0 = only players, 1 = only moderators, 2 = only gamemasters, 3 = anyone -->
                <show_gm_list>${46:-1}</show_gm_list>
                <!-- Max GM level showed in who list (if visible). 0 = only players, 1 = only moderators, 2 = only gamemasters, 3 = anyone -->
                <show_who_list>${47:-0}</show_who_list>
                <!-- Allow players to add GM characters to their friends list. false = disabled, true = enabled -->
                <allow_friend>${48:-false}</allow_friend>
                <!-- Allow players to invite GM characters. false = disabled, true = enabled -->
                <allow_invite>${49:-false}</allow_invite>
                <!-- Allow lower security levels to use commands on higher security level characters. false = disabled, true = enabled -->
                <allow_lower_security>${50:-false}</allow_lower_security>
            </gm>
        </world>
    </options>" | xmllint --format - > $OPTIONS
}

# A function that sends all variables to the store_options function
function save_options
{
    store_options \
    $OPTION_MYSQL_HOSTNAME \
    $OPTION_MYSQL_PORT \
    $OPTION_MYSQL_USERNAME \
    $OPTION_MYSQL_PASSWORD \
    $OPTION_MYSQL_DATABASES_AUTH \
    $OPTION_MYSQL_DATABASES_CHARACTERS \
    $OPTION_MYSQL_DATABASES_WORLD \
    "$OPTION_SOURCE_LOCATION" \
    $OPTION_SOURCE_REQUIRED_CLIENT_DATA \
    $OPTION_SOURCE_INSTALLED_CLIENT_DATA \
    "$OPTION_WORLD_NAME" \
    "$OPTION_WORLD_MOTD" \
    $OPTION_WORLD_ID \
    $OPTION_WORLD_ADDRESS \
    $OPTION_WORLD_GAME_TYPE \
    $OPTION_WORLD_REALM_ZONE \
    $OPTION_WORLD_EXPANSION \
    $OPTION_WORLD_PLAYER_LIMIT \
    $OPTION_WORLD_SKIP_CINEMATICS \
    $OPTION_WORLD_MAX_LEVEL \
    $OPTION_WORLD_START_LEVEL \
    $OPTION_WORLD_START_MONEY \
    $OPTION_WORLD_ALWAYS_MAX_SKILL \
    $OPTION_WORLD_ALL_FLIGHT_PATHS \
    $OPTION_WORLD_MAPS_EXPLORED \
    $OPTION_WORLD_ALLOW_COMMANDS \
    $OPTION_WORLD_QUEST_IGNORE_RAID \
    $OPTION_WORLD_PREVENT_AFK_LOGOUT \
    $OPTION_WORLD_RAF_MAX_LEVEL \
    $OPTION_WORLD_PRELOAD_MAP_GRIDS \
    $OPTION_WORLD_SET_ALL_WAYPOINTS_ACTIVE \
    $OPTION_WORLD_ENABLE_MINIGOB_MANABONK \
    $OPTION_WORLD_ENABLE_WARDEN \
    $OPTION_WORLD_RATES_EXPERIENCE \
    $OPTION_WORLD_RATES_RESTED_EXPERIENCE \
    $OPTION_WORLD_RATES_REPUTATION \
    $OPTION_WORLD_RATES_MONEY \
    $OPTION_WORLD_RATES_CRAFTING \
    $OPTION_WORLD_RATES_GATHERING \
    $OPTION_WORLD_RATES_WEAPON_SKILL \
    $OPTION_WORLD_RATES_DEFENSE_SKILL \
    $OPTION_WORLD_GM_LOGIN_STATE \
    $OPTION_WORLD_GM_ENABLE_VISIBILITY \
    $OPTION_WORLD_GM_ENABLE_CHAT \
    $OPTION_WORLD_GM_ENABLE_WHISPER \
    $OPTION_WORLD_GM_SHOW_GM_LIST \
    $OPTION_WORLD_GM_SHOW_WHO_LIST \
    $OPTION_WORLD_GM_ALLOW_FRIEND \
    $OPTION_WORLD_GM_ALLOW_INVITE \
    $OPTION_WORLD_GM_ALLOW_LOWER_SECURITY
}

# A function that loads options from the file
function load_options
{
    # Install required package
    options_package

    # The file where all options are stored
    OPTIONS="$ROOT/options-minimal.xml"

    # Check if the file is missing
    if [ ! -f $OPTIONS ]; then
        # Create the file with the default options
        printf "${COLOR_RED}The options file is missing. Creating one with the default options.${COLOR_END}\n"
        printf "${COLOR_RED}Make sure to edit it to prevent issues that might occur otherwise.${COLOR_END}\n"
        store_options
        exit $?
    fi

    # Load the /options/mysql/hostname option
    OPTION_MYSQL_HOSTNAME="$(echo "cat /options/mysql/hostname/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [ -z $OPTION_MYSQL_HOSTNAME ] || [[ $OPTION_MYSQL_HOSTNAME == "" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/mysql/hostname is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_MYSQL_HOSTNAME="127.0.0.1"
        RESET=true
    fi

    # Load the /options/mysql/port option
    OPTION_MYSQL_PORT="$(echo "cat /options/mysql/port/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_MYSQL_PORT =~ ^[0-9]+$ ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/mysql/port is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_MYSQL_PORT="3306"
        RESET=true
    fi

    # Load the /options/mysql/username option
    OPTION_MYSQL_USERNAME="$(echo "cat /options/mysql/username/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [ -z $OPTION_MYSQL_USERNAME ] || [[ $OPTION_MYSQL_USERNAME == "" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/mysql/username is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_MYSQL_USERNAME="acore"
        RESET=true
    fi

    # Load the /options/mysql/password option
    OPTION_MYSQL_PASSWORD="$(echo "cat /options/mysql/password/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [ -z $OPTION_MYSQL_PASSWORD ] || [[ $OPTION_MYSQL_PASSWORD == "" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/mysql/password is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_MYSQL_PASSWORD="acore"
        RESET=true
    fi

    # Load the /options/mysql/databases/auth option
    OPTION_MYSQL_DATABASES_AUTH="$(echo "cat /options/mysql/databases/auth/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [ -z $OPTION_MYSQL_DATABASES_AUTH ] || [[ $OPTION_MYSQL_DATABASES_AUTH == "" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/mysql/databases/auth is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_MYSQL_DATABASES_AUTH="acore_auth"
        RESET=true
    fi

    # Load the /options/mysql/databases/characters option
    OPTION_MYSQL_DATABASES_CHARACTERS="$(echo "cat /options/mysql/databases/characters/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [ -z $OPTION_MYSQL_DATABASES_CHARACTERS ] || [[ $OPTION_MYSQL_DATABASES_CHARACTERS == "" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/mysql/databases/characters is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_MYSQL_DATABASES_CHARACTERS="acore_characters"
        RESET=true
    fi

    # Load the /options/mysql/databases/world option
    OPTION_MYSQL_DATABASES_WORLD="$(echo "cat /options/mysql/databases/world/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [ -z $OPTION_MYSQL_DATABASES_WORLD ] || [[ $OPTION_MYSQL_DATABASES_WORLD == "" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/mysql/databases/world is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_MYSQL_DATABASES_WORLD="acore_world"
        RESET=true
    fi

    # Load the /options/source/location option
    OPTION_SOURCE_LOCATION="$(echo "cat /options/source/location/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [ -z $OPTION_SOURCE_LOCATION ] || [[ $OPTION_SOURCE_LOCATION == "" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/source/location is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_SOURCE_LOCATION="/opt/azerothcore"
        RESET=true
    fi

    # Load the /options/source/required_client_data option
    OPTION_SOURCE_REQUIRED_CLIENT_DATA="$(echo "cat /options/source/required_client_data/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_SOURCE_REQUIRED_CLIENT_DATA =~ ^[0-9]+$ ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/source/required_client_data is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_SOURCE_REQUIRED_CLIENT_DATA="12"
        RESET=true
    fi

    # Load the /options/source/installed_client_data option
    OPTION_SOURCE_INSTALLED_CLIENT_DATA="$(echo "cat /options/source/installed_client_data/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_SOURCE_INSTALLED_CLIENT_DATA =~ ^[0-9]+$ ]] || [ $OPTION_SOURCE_INSTALLED_CLIENT_DATA -gt $OPTION_SOURCE_REQUIRED_CLIENT_DATA ]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/source/installed_client_data is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_SOURCE_INSTALLED_CLIENT_DATA="0"
        RESET=true
    fi

    # Load the /options/world/name option
    OPTION_WORLD_NAME="$(echo "cat /options/world/name/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ -z $OPTION_WORLD_NAME ]] || [[ $OPTION_WORLD_NAME == "" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/name is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_NAME="AzerothCore"
        RESET=true
    fi

    # Load the /options/world/motd option
    OPTION_WORLD_MOTD="$(echo "cat /options/world/motd/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ -z $OPTION_WORLD_MOTD ]] || [[ $OPTION_WORLD_MOTD == "" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/motd is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_MOTD="Welcome to AzerothCore."
        RESET=true
    fi

    # Load the /options/world/id option
    OPTION_WORLD_ID="$(echo "cat /options/world/id/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_ID =~ ^[0-9]+$ ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/id is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_ID="1"
        RESET=true
    fi

    # Load the /options/world/address option
    OPTION_WORLD_ADDRESS="$(echo "cat /options/world/address/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ -z $OPTION_WORLD_ADDRESS ]] || [[ $OPTION_WORLD_ADDRESS == "" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/address is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_ADDRESS="127.0.0.1"
        RESET=true
    fi

    # Load the /options/world/game_type option
    OPTION_WORLD_GAME_TYPE="$(echo "cat /options/world/game_type/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_GAME_TYPE =~ ^[0-9]+$ ]] || [[ $OPTION_WORLD_GAME_TYPE != 0 && $OPTION_WORLD_GAME_TYPE != 1 && $OPTION_WORLD_GAME_TYPE != 6 && $OPTION_WORLD_GAME_TYPE != 8 ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/game_type is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_GAME_TYPE="0"
        RESET=true
    fi

    # Load the /options/world/realm_zone option
    OPTION_WORLD_REALM_ZONE="$(echo "cat /options/world/realm_zone/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_REALM_ZONE =~ ^[0-9]+$ ]] || [[ $OPTION_WORLD_REALM_ZONE != 1 && $OPTION_WORLD_REALM_ZONE != 2 && $OPTION_WORLD_REALM_ZONE != 6 && $OPTION_WORLD_REALM_ZONE != 9 && $OPTION_WORLD_REALM_ZONE != 10 && $OPTION_WORLD_REALM_ZONE != 11 && $OPTION_WORLD_REALM_ZONE != 12 && $OPTION_WORLD_REALM_ZONE != 14 && $OPTION_WORLD_REALM_ZONE != 16 && $OPTION_WORLD_REALM_ZONE != 26 ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/realm_zone is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_REALM_ZONE="1"
        RESET=true
    fi

    # Load the /options/world/expansion option
    OPTION_WORLD_EXPANSION="$(echo "cat /options/world/expansion/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_EXPANSION =~ ^[0-9]+$ ]] || [[ $OPTION_WORLD_EXPANSION != 0 && $OPTION_WORLD_EXPANSION != 1 && $OPTION_WORLD_EXPANSION != 2 ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/expansion is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_EXPANSION="2"
        RESET=true
    fi

    # Load the /options/world/player_limit option
    OPTION_WORLD_PLAYER_LIMIT="$(echo "cat /options/world/player_limit/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_PLAYER_LIMIT =~ ^[0-9]+$ ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/player_limit is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_PLAYER_LIMIT="1000"
        RESET=true
    fi

    # Load the /options/world/skip_cinematics option
    OPTION_WORLD_SKIP_CINEMATICS="$(echo "cat /options/world/skip_cinematics/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_SKIP_CINEMATICS =~ ^[0-9]+$ ]] || [[ $OPTION_WORLD_SKIP_CINEMATICS != 0 && $OPTION_WORLD_SKIP_CINEMATICS != 1 && $OPTION_WORLD_SKIP_CINEMATICS != 2 ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/skip_cinematics is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_SKIP_CINEMATICS="0"
        RESET=true
    fi

    # Load the /options/world/max_level option
    OPTION_WORLD_MAX_LEVEL="$(echo "cat /options/world/max_level/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_MAX_LEVEL =~ ^[0-9]+$ ]] || [[ $OPTION_WORLD_MAX_LEVEL < 1 || $OPTION_WORLD_MAX_LEVEL > 80 ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/max_level is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_MAX_LEVEL="1"
        RESET=true
    fi

    # Load the /options/world/start_level option
    OPTION_WORLD_START_LEVEL="$(echo "cat /options/world/start_level/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_START_LEVEL =~ ^[0-9]+$ ]] || [[ $OPTION_WORLD_START_LEVEL < 1 || $OPTION_WORLD_START_LEVEL > 80 ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/start_level is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_START_LEVEL="1"
        RESET=true
    fi

    # Load the /options/world/start_money option
    OPTION_WORLD_START_MONEY="$(echo "cat /options/world/start_money/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_START_MONEY =~ ^[0-9]+$ ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/start_money is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_START_MONEY="0"
        RESET=true
    fi

    # Load the /options/world/always_max_skill option
    OPTION_WORLD_ALWAYS_MAX_SKILL="$(echo "cat /options/world/always_max_skill/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ $OPTION_WORLD_ALWAYS_MAX_SKILL != "true" && $OPTION_WORLD_ALWAYS_MAX_SKILL != "false" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/always_max_skill is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_ALWAYS_MAX_SKILL="false"
        RESET=true
    fi

    # Load the /options/world/all_flight_paths option
    OPTION_WORLD_ALL_FLIGHT_PATHS="$(echo "cat /options/world/all_flight_paths/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ $OPTION_WORLD_ALL_FLIGHT_PATHS != "true" && $OPTION_WORLD_ALL_FLIGHT_PATHS != "false" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/all_flight_paths is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_ALL_FLIGHT_PATHS="false"
        RESET=true
    fi

    # Load the /options/world/maps_explored option
    OPTION_WORLD_MAPS_EXPLORED="$(echo "cat /options/world/maps_explored/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ $OPTION_WORLD_MAPS_EXPLORED != "true" && $OPTION_WORLD_MAPS_EXPLORED != "false" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/maps_explored is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_MAPS_EXPLORED="false"
        RESET=true
    fi

    # Load the /options/world/allow_commands option
    OPTION_WORLD_ALLOW_COMMANDS="$(echo "cat /options/world/allow_commands/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ $OPTION_WORLD_ALLOW_COMMANDS != "true" && $OPTION_WORLD_ALLOW_COMMANDS != "false" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/allow_commands is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_ALLOW_COMMANDS="true"
        RESET=true
    fi

    # Load the /options/world/quest_ignore_raid option
    OPTION_WORLD_QUEST_IGNORE_RAID="$(echo "cat /options/world/quest_ignore_raid/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ $OPTION_WORLD_QUEST_IGNORE_RAID != "true" && $OPTION_WORLD_QUEST_IGNORE_RAID != "false" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/quest_ignore_raid is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_QUEST_IGNORE_RAID="false"
        RESET=true
    fi

    # Load the /options/world/prevent_afk_logout option
    OPTION_WORLD_PREVENT_AFK_LOGOUT="$(echo "cat /options/world/prevent_afk_logout/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ $OPTION_WORLD_PREVENT_AFK_LOGOUT != "true" && $OPTION_WORLD_PREVENT_AFK_LOGOUT != "false" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/prevent_afk_logout is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_PREVENT_AFK_LOGOUT="false"
        RESET=true
    fi

    # Load the /options/world/raf_max_level option
    OPTION_WORLD_RAF_MAX_LEVEL="$(echo "cat /options/world/raf_max_level/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_RAF_MAX_LEVEL =~ ^[0-9]+$ ]] || [[ $OPTION_WORLD_RAF_MAX_LEVEL < 1 || $OPTION_WORLD_RAF_MAX_LEVEL > 80 ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/raf_max_level is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_RAF_MAX_LEVEL="60"
        RESET=true
    fi

    # Load the /options/world/preload_map_grids option
    OPTION_WORLD_PRELOAD_MAP_GRIDS="$(echo "cat /options/world/preload_map_grids/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ $OPTION_WORLD_PRELOAD_MAP_GRIDS != "true" && $OPTION_WORLD_PRELOAD_MAP_GRIDS != "false" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/preload_map_grids is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_PRELOAD_MAP_GRIDS="false"
        RESET=true
    fi

    # Load the /options/world/set_all_waypoints_active option
    OPTION_WORLD_SET_ALL_WAYPOINTS_ACTIVE="$(echo "cat /options/world/set_all_waypoints_active/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ $OPTION_WORLD_SET_ALL_WAYPOINTS_ACTIVE != "true" && $OPTION_WORLD_SET_ALL_WAYPOINTS_ACTIVE != "false" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/set_all_waypoints_active is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_SET_ALL_WAYPOINTS_ACTIVE="false"
        RESET=true
    fi

    # Load the /options/world/enable_minigob_manabonk option
    OPTION_WORLD_ENABLE_MINIGOB_MANABONK="$(echo "cat /options/world/enable_minigob_manabonk/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ $OPTION_WORLD_ENABLE_MINIGOB_MANABONK != "true" && $OPTION_WORLD_ENABLE_MINIGOB_MANABONK != "false" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/enable_minigob_manabonk is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_ENABLE_MINIGOB_MANABONK="true"
        RESET=true
    fi

    # Load the /options/world/enable_warden option
    OPTION_WORLD_ENABLE_WARDEN="$(echo "cat /options/world/enable_warden/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ $OPTION_WORLD_ENABLE_WARDEN != "true" && $OPTION_WORLD_ENABLE_WARDEN != "false" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/enable_warden is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_ENABLE_WARDEN="true"
        RESET=true
    fi

    # Load the /options/world/rates/experience option
    OPTION_WORLD_RATES_EXPERIENCE="$(echo "cat /options/world/rates/experience/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_RATES_EXPERIENCE =~ ^[0-9]+$ ]] || [[ $OPTION_WORLD_RATES_EXPERIENCE < 1 ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/rates/experience is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_RATES_EXPERIENCE="1"
        RESET=true
    fi

    # Load the /options/world/rates/rested_experience option
    OPTION_WORLD_RATES_RESTED_EXPERIENCE="$(echo "cat /options/world/rates/rested_experience/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_RATES_RESTED_EXPERIENCE =~ ^[0-9]+$ ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/rates/rested_experience is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_RATES_RESTED_EXPERIENCE="1"
        RESET=true
    fi

    # Load the /options/world/rates/reputation option
    OPTION_WORLD_RATES_REPUTATION="$(echo "cat /options/world/rates/reputation/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_RATES_REPUTATION =~ ^[0-9]+$ ]] || [[ $OPTION_WORLD_RATES_REPUTATION < 1 ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/rates/reputation is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_RATES_REPUTATION="1"
        RESET=true
    fi

    # Load the /options/world/rates/money option
    OPTION_WORLD_RATES_MONEY="$(echo "cat /options/world/rates/money/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_RATES_MONEY =~ ^[0-9]+$ ]] || [[ $OPTION_WORLD_RATES_MONEY < 1 ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/rates/money is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_RATES_MONEY="1"
        RESET=true
    fi

    # Load the /options/world/rates/crafting option
    OPTION_WORLD_RATES_CRAFTING="$(echo "cat /options/world/rates/crafting/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_RATES_CRAFTING =~ ^[0-9]+$ ]] || [[ $OPTION_WORLD_RATES_CRAFTING < 1 ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/rates/crafting is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_RATES_CRAFTING="1"
        RESET=true
    fi

    # Load the /options/world/rates/gathering option
    OPTION_WORLD_RATES_GATHERING="$(echo "cat /options/world/rates/gathering/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_RATES_GATHERING =~ ^[0-9]+$ ]] || [[ $OPTION_WORLD_RATES_GATHERING < 1 ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/rates/gathering is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_RATES_GATHERING="1"
        RESET=true
    fi

    # Load the /options/world/rates/weapon_skill option
    OPTION_WORLD_RATES_WEAPON_SKILL="$(echo "cat /options/world/rates/weapon_skill/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_RATES_WEAPON_SKILL =~ ^[0-9]+$ ]] || [[ $OPTION_WORLD_RATES_WEAPON_SKILL < 1 ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/rates/weapon_skill is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_RATES_WEAPON_SKILL="1"
        RESET=true
    fi

    # Load the /options/world/rates/defense_skill option
    OPTION_WORLD_RATES_DEFENSE_SKILL="$(echo "cat /options/world/rates/defense_skill/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_RATES_DEFENSE_SKILL =~ ^[0-9]+$ ]] || [[ $OPTION_WORLD_RATES_DEFENSE_SKILL < 1 ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/rates/defense_skill is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_RATES_DEFENSE_SKILL="1"
        RESET=true
    fi

    # Load the /options/world/gm/login_state option
    OPTION_WORLD_GM_LOGIN_STATE="$(echo "cat /options/world/gm/login_state/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ $OPTION_WORLD_GM_LOGIN_STATE != "true" && $OPTION_WORLD_GM_LOGIN_STATE != "false" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/gm/login_state is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_GM_LOGIN_STATE="true"
        RESET=true
    fi

    # Load the /options/world/gm/enable_visibility option
    OPTION_WORLD_GM_ENABLE_VISIBILITY="$(echo "cat /options/world/gm/enable_visibility/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ $OPTION_WORLD_GM_ENABLE_VISIBILITY != "true" && $OPTION_WORLD_GM_ENABLE_VISIBILITY != "false" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/gm/enable_visibility is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_GM_ENABLE_VISIBILITY="false"
        RESET=true
    fi

    # Load the /options/world/gm/enable_chat option
    OPTION_WORLD_GM_ENABLE_CHAT="$(echo "cat /options/world/gm/enable_chat/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ $OPTION_WORLD_GM_ENABLE_CHAT != "true" && $OPTION_WORLD_GM_ENABLE_CHAT != "false" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/gm/enable_chat is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_GM_ENABLE_CHAT="true"
        RESET=true
    fi

    # Load the /options/world/gm/enable_whisper option
    OPTION_WORLD_GM_ENABLE_WHISPER="$(echo "cat /options/world/gm/enable_whisper/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ $OPTION_WORLD_GM_ENABLE_WHISPER != "true" && $OPTION_WORLD_GM_ENABLE_WHISPER != "false" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/gm/enable_whisper is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_GM_ENABLE_WHISPER="false"
        RESET=true
    fi

    # Load the /options/world/gm/show_gm_list option
    OPTION_WORLD_GM_SHOW_GM_LIST="$(echo "cat /options/world/gm/show_gm_list/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_GM_SHOW_GM_LIST =~ ^[0-9]+$ ]] || [[ $OPTION_WORLD_GM_SHOW_GM_LIST != 0 && $OPTION_WORLD_GM_SHOW_GM_LIST != 1 && $OPTION_WORLD_GM_SHOW_GM_LIST != 2 && $OPTION_WORLD_GM_SHOW_GM_LIST != 3 ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/gm/show_gm_list is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_GM_SHOW_GM_LIST="1"
        RESET=true
    fi

    # Load the /options/world/gm/show_who_list option
    OPTION_WORLD_GM_SHOW_WHO_LIST="$(echo "cat /options/world/gm/show_who_list/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ ! $OPTION_WORLD_GM_SHOW_WHO_LIST =~ ^[0-9]+$ ]] || [[ $OPTION_WORLD_GM_SHOW_WHO_LIST != 0 && $OPTION_WORLD_GM_SHOW_WHO_LIST != 1 && $OPTION_WORLD_GM_SHOW_WHO_LIST != 2 && $OPTION_WORLD_GM_SHOW_WHO_LIST != 3 ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/gm/show_who_list is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_GM_SHOW_WHO_LIST="0"
        RESET=true
    fi

    # Load the /options/world/gm/allow_friend option
    OPTION_WORLD_GM_ALLOW_FRIEND="$(echo "cat /options/world/gm/allow_friend/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ $OPTION_WORLD_GM_ALLOW_FRIEND != "true" && $OPTION_WORLD_GM_ALLOW_FRIEND != "false" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/gm/allow_friend is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_GM_ALLOW_FRIEND="false"
        RESET=true
    fi

    # Load the /options/world/gm/allow_invite option
    OPTION_WORLD_GM_ALLOW_INVITE="$(echo "cat /options/world/gm/allow_invite/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ $OPTION_WORLD_GM_ALLOW_INVITE != "true" && $OPTION_WORLD_GM_ALLOW_INVITE != "false" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/gm/allow_invite is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_GM_ALLOW_INVITE="false"
        RESET=true
    fi

    # Load the /options/world/gm/allow_lower_security option
    OPTION_WORLD_GM_ALLOW_LOWER_SECURITY="$(echo "cat /options/world/gm/allow_lower_security/text()" | xmllint --nocdata --shell $OPTIONS | sed '1d;$d')"
    if [[ $OPTION_WORLD_GM_ALLOW_LOWER_SECURITY != "true" && $OPTION_WORLD_GM_ALLOW_LOWER_SECURITY != "false" ]]; then
        # The value is invalid so it will be reset to the default value
        printf "${COLOR_RED}The option at /options/world/gm/allow_lower_security is invalid. It has been reset to the default value.${COLOR_END}\n"
        OPTION_WORLD_GM_ALLOW_LOWER_SECURITY="false"
        RESET=true
    fi

    # Check if any option calls for a reset
    if [ $RESET ]; then
        # Tell the user that the invalid options should be changed, then terminate the script
        printf "${COLOR_RED}Make sure to change the options listed above to prevent any unwanted issues.${COLOR_END}\n"
        save_options
        exit $?
    fi
}

# A function that downloads the latest version of the source code
function get_source
{
    # Make sure all required packages are installed
    git_package

    printf "${COLOR_GREEN}Downloading the source code...${COLOR_END}\n"

    # Check if the source is already downloaded
    if [ ! -d $OPTION_SOURCE_LOCATION ]; then
        # Download the source code
        git clone --recursive --branch master https://github.com/azerothcore/azerothcore-wotlk.git $OPTION_SOURCE_LOCATION

        # Check to make sure there weren't any errors
        if [ $? -ne 0 ]; then
            # Terminate script on errors
            exit $?
        fi
    else
        # Go into the source folder to update it
        cd $OPTION_SOURCE_LOCATION

        # Fetch all available updates
        git fetch --all

        # Check to make sure there weren't any errors
        if [ $? -ne 0 ]; then
            # Terminate script on errors
            exit $?
        fi

        # Reset the source code, removing all local changes
        git reset --hard origin/master

        # Check to make sure there weren't any errors
        if [ $? -ne 0 ]; then
            # Terminate script on errors
            exit $?
        fi

        # Update any submodule
        git submodule update

        # Check to make sure there weren't any errors
        if [ $? -ne 0 ]; then
            # Terminate script on errors
            exit $?
        fi
    fi

    printf "${COLOR_GREEN}Finished downloading the source code...${COLOR_END}\n"
}

# A function that compiles the source code into binaries
function compile_source
{
    # Make sure all required packages are installed
    source_packages

    printf "${COLOR_GREEN}Compiling the source code...${COLOR_END}\n"

    # Create the build folder and cd into it
    mkdir -p $OPTION_SOURCE_LOCATION/build && cd $_

    # Generate the build files
    cmake ../ -DCMAKE_INSTALL_PREFIX=$OPTION_SOURCE_LOCATION -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DWITH_WARNINGS=1 -DTOOLS=0 -DSCRIPTS=static

    # Check to make sure there weren't any errors
    if [ $? -ne 0 ]; then
        # Terminate script on errors
        exit $?
    fi

    # Build the source code
    make -j $(nproc)

    # Check to make sure there weren't any errors
    if [ $? -ne 0 ]; then
        # Terminate script on errors
        exit $?
    fi

    # Copy the binaries and other required files to their designated directories
    make install

    # Check to make sure there weren't any errors
    if [ $? -ne 0 ]; then
        # Terminate script on errors
        exit $?
    fi

    # Create the scripts used to start and stop the server
    echo "#!/bin/bash" > $OPTION_SOURCE_LOCATION/bin/start.sh
    echo "#!/bin/bash" > $OPTION_SOURCE_LOCATION/bin/stop.sh

    # Check if the authserver should be enabled
    if [[ $1 == "both" ]] || [[ $1 == "auth" ]]; then
        # Add authserver to the start and stop scripts
        echo "screen -AmdS auth ./auth.sh" >> $OPTION_SOURCE_LOCATION/bin/start.sh
        echo "screen -X -S \"auth\" quit" >> $OPTION_SOURCE_LOCATION/bin/stop.sh

        # Create the script used to start and stop the authserver
        echo "#!/bin/bash" > $OPTION_SOURCE_LOCATION/bin/auth.sh
        echo "while :; do" >> $OPTION_SOURCE_LOCATION/bin/auth.sh
        echo "./authserver" >> $OPTION_SOURCE_LOCATION/bin/auth.sh
        echo "sleep 5" >> $OPTION_SOURCE_LOCATION/bin/auth.sh
        echo "done" >> $OPTION_SOURCE_LOCATION/bin/auth.sh

        # Make the script runnable
        chmod +x $OPTION_SOURCE_LOCATION/bin/auth.sh
    else
        # Check if the script for authserver already exists
        if [ -f $OPTION_SOURCE_LOCATION/bin/auth.sh ]; then
            # Remove the script if authserver is not used
            rm -rf $OPTION_SOURCE_LOCATION/bin/auth.sh
        fi
    fi

    # Check if the worldserver should be enabled
    if [[ $1 == "both" ]] || [[ $1 == "world" ]]; then
        # Add worldserver to the start and stop scripts
        echo "screen -AmdS world ./world.sh" >> $OPTION_SOURCE_LOCATION/bin/start.sh
        echo "screen -X -S \"world\" quit" >> $OPTION_SOURCE_LOCATION/bin/stop.sh

        # Create the script used to start and stop the worldserver
        echo "#!/bin/bash" > $OPTION_SOURCE_LOCATION/bin/world.sh
        echo "while :; do" >> $OPTION_SOURCE_LOCATION/bin/world.sh
        echo "./worldserver" >> $OPTION_SOURCE_LOCATION/bin/world.sh
        echo "if [[ \$? == 0 ]]; then" >> $OPTION_SOURCE_LOCATION/bin/world.sh
        echo "break" >> $OPTION_SOURCE_LOCATION/bin/world.sh
        echo "fi" >> $OPTION_SOURCE_LOCATION/bin/world.sh
        echo "sleep 5" >> $OPTION_SOURCE_LOCATION/bin/world.sh
        echo "done" >> $OPTION_SOURCE_LOCATION/bin/world.sh

        # Make the script runnable
        chmod +x $OPTION_SOURCE_LOCATION/bin/world.sh
    else
        # Check if the script for worldserver already exists
        if [ -f $OPTION_SOURCE_LOCATION/bin/world.sh ]; then
            # Remove the script if worldserver is not used
            rm -rf $OPTION_SOURCE_LOCATION/bin/world.sh
        fi
    fi

    # Make the start and stop scripts runnable
    chmod +x $OPTION_SOURCE_LOCATION/bin/start.sh
    chmod +x $OPTION_SOURCE_LOCATION/bin/stop.sh

    printf "${COLOR_GREEN}Finished compiling the source code...${COLOR_END}\n"
}

# A function that downloads the client data files
function get_client_files
{
    # Make sure this is only used with the both or world subparameters
    if [[ $1 == "both" ]] || [[ $1 == "world" ]]; then
        # Check if any of the folders are missing
        if [ ! -d $OPTION_SOURCE_LOCATION/bin/Cameras ] || [ ! -d $OPTION_SOURCE_LOCATION/bin/dbc ] || [ ! -d $OPTION_SOURCE_LOCATION/bin/maps ] || [ ! -d $OPTION_SOURCE_LOCATION/bin/mmaps ] || [ ! -d $OPTION_SOURCE_LOCATION/bin/vmaps ]; then
            # Set installed client data to 0 if any folder is missing
            OPTION_SOURCE_INSTALLED_CLIENT_DATA=0
        fi

        # Grab the latest version available on github
        AVAILABLE_VERSION=$(git ls-remote --tags --sort="v:refname" https://github.com/wowgaming/client-data.git | tail -n1 | cut --delimiter='/' --fields=3 | sed 's/v//')

        # Check if the latest version differ from the required version
        if [ $OPTION_SOURCE_REQUIRED_CLIENT_DATA != $AVAILABLE_VERSION ]; then
            # Update the required version with this version
            OPTION_SOURCE_REQUIRED_CLIENT_DATA=$AVAILABLE_VERSION

            # Save the required version to the options file
            save_options
        fi

        # Check if the installed version differ from the required version
        if [ $OPTION_SOURCE_INSTALLED_CLIENT_DATA != $OPTION_SOURCE_REQUIRED_CLIENT_DATA ]; then
            printf "${COLOR_GREEN}Downloading the client data files...${COLOR_END}\n"

            # Check all folders included in the data files and remove them
            if [ -d $OPTION_SOURCE_LOCATION/bin/Cameras ]; then
                rm -rf $OPTION_SOURCE_LOCATION/bin/Cameras
            fi
            if [ -d $OPTION_SOURCE_LOCATION/bin/dbc ]; then
                rm -rf $OPTION_SOURCE_LOCATION/bin/dbc
            fi
            if [ -d $OPTION_SOURCE_LOCATION/bin/maps ]; then
                rm -rf $OPTION_SOURCE_LOCATION/bin/maps
            fi
            if [ -d $OPTION_SOURCE_LOCATION/bin/mmaps ]; then
                rm -rf $OPTION_SOURCE_LOCATION/bin/mmaps
            fi
            if [ -d $OPTION_SOURCE_LOCATION/bin/vmaps ]; then
                rm -rf $OPTION_SOURCE_LOCATION/bin/vmaps
            fi

            # Download the client data files archive
            curl -L https://github.com/wowgaming/client-data/releases/download/v${OPTION_SOURCE_REQUIRED_CLIENT_DATA}/data.zip > $OPTION_SOURCE_LOCATION/bin/data.zip

            # Check to make sure there weren't any errors
            if [ $? -ne 0 ]; then
                # Terminate script on errors
                exit $?
            fi

            # Unzip the archive into the proper folders
            unzip -o "$OPTION_SOURCE_LOCATION/bin/data.zip" -d "$OPTION_SOURCE_LOCATION/bin/"

            # Check to make sure there weren't any errors
            if [ $? -ne 0 ]; then
                # Terminate script on errors
                exit $?
            fi

            # Remove the archive since it's no longer needed
            rm -rf $OPTION_SOURCE_LOCATION/bin/data.zip

            # Set the installed version to the same as the required version
            OPTION_SOURCE_INSTALLED_CLIENT_DATA=$OPTION_SOURCE_REQUIRED_CLIENT_DATA

            # Save the version to the options file
            save_options

            printf "${COLOR_GREEN}Finished downloading the client data files...${COLOR_END}\n"
        fi
    fi
}

# A function that imports all database files
function import_database
{
    # Create the mysql.cnf file to prevent warnings during import
    MYSQL_CNF="$ROOT/mysql.cnf"
    echo "[client]" > $MYSQL_CNF
    echo "host=\"$OPTION_MYSQL_HOSTNAME\"" >> $MYSQL_CNF
    echo "port=\"$OPTION_MYSQL_PORT\"" >> $MYSQL_CNF
    echo "user=\"$OPTION_MYSQL_USERNAME\"" >> $MYSQL_CNF
    echo "password=\"$OPTION_MYSQL_PASSWORD\"" >> $MYSQL_CNF

    # Make sure the auth database exists and is accessible
    if [ -z `mysql --defaults-extra-file=$MYSQL_CNF --skip-column-names -e "SHOW DATABASES LIKE '$OPTION_MYSQL_DATABASES_AUTH'"` ]; then
        # We can't access the required database, so terminate the script
        printf "${COLOR_RED}The database named $OPTION_MYSQL_DATABASES_AUTH is inaccessible by the user named $OPTION_MYSQL_USERNAME.${COLOR_END}\n"

        # Remove the mysql conf
        rm -rf $MYSQL_CNF

        # Terminate script on error
        exit $?
    fi

    # Check if either both or auth is used as the first parameter
    if [[ $1 == "both" ]] || [[ $1 == "auth" ]]; then
        # Make sure the database folders exists
        if [ ! -d $OPTION_SOURCE_LOCATION/data/sql/base/db_auth ] || [ ! -d $OPTION_SOURCE_LOCATION/data/sql/updates/db_auth ]; then
            # The files are missing, so terminate the script
            printf "${COLOR_RED}There are no database files where there should be.${COLOR_END}\n"
            printf "${COLOR_RED}Please make sure to install the server first.${COLOR_END}\n"

            # Remove the mysql conf
            rm -rf $MYSQL_CNF

            # Terminate script on error
            exit $?
        fi
    fi

    # Check if either both or world is used as the first parameter
    if [[ $1 == "both" ]] || [[ $1 == "world" ]]; then
        # Make sure the characters database exists and is accessible
        if [ -z `mysql --defaults-extra-file=$MYSQL_CNF --skip-column-names -e "SHOW DATABASES LIKE '$OPTION_MYSQL_DATABASES_CHARACTERS'"` ]; then
            # We can't access the required database, so terminate the script
            printf "${COLOR_RED}The database named $OPTION_MYSQL_DATABASES_CHARACTERS is inaccessible by the user named $OPTION_MYSQL_USERNAME.${COLOR_END}\n"

            # Remove the mysql conf
            rm -rf $MYSQL_CNF

            # Terminate script on error
            exit $?
        fi

        # Make sure the world database exists and is accessible
        if [ -z `mysql --defaults-extra-file=$MYSQL_CNF --skip-column-names -e "SHOW DATABASES LIKE '$OPTION_MYSQL_DATABASES_WORLD'"` ]; then
            # We can't access the required database, so terminate the script
            printf "${COLOR_RED}The database named $OPTION_MYSQL_DATABASES_WORLD is inaccessible by the user named $OPTION_MYSQL_USERNAME.${COLOR_END}\n"

            # Remove the mysql conf
            rm -rf $MYSQL_CNF

            # Terminate script on error
            exit $?
        fi

        # Make sure the database folders exists
        if [ ! -d $OPTION_SOURCE_LOCATION/data/sql/base/db_characters ] || [ ! -d $OPTION_SOURCE_LOCATION/data/sql/updates/db_characters ] || [ ! -d $OPTION_SOURCE_LOCATION/data/sql/base/db_world ] || [ ! -d $OPTION_SOURCE_LOCATION/data/sql/updates/db_world ]; then
            # The files are missing, so terminate the script
            printf "${COLOR_RED}There are no database files where there should be.${COLOR_END}\n"
            printf "${COLOR_RED}Please make sure to install the server first.${COLOR_END}\n"

            # Remove the mysql conf
            rm -rf $MYSQL_CNF

            # Terminate script on error
            exit $?
        fi
    fi

    # No errors occured so we can proceed
    printf "${COLOR_GREEN}Importing the database files...${COLOR_END}\n"

    # Check if either both or auth is used as the first parameter
    if [[ $1 == "both" ]] || [[ $1 == "auth" ]]; then
        # Loop through all sql files inside the auth base folder
        for f in $OPTION_SOURCE_LOCATION/data/sql/base/db_auth/*.sql; do
            # Check if the table already exists
            if [ ! -z `mysql --defaults-extra-file=$MYSQL_CNF --skip-column-names $OPTION_MYSQL_DATABASES_AUTH -e "SHOW TABLES LIKE '$(basename $f .sql)'"` ]; then
                printf "${COLOR_ORANGE}Skipping "$(basename $f)"${COLOR_END}\n"

                # Skip the file since it's already imported
                continue;
            fi

            # Check to make sure there weren't any errors
            if [ $? -ne 0 ]; then
                # Remove the mysql conf
                rm -rf $MYSQL_CNF

                # Terminate script on error
                exit $?
            fi

            # Import the sql file
            printf "${COLOR_ORANGE}Importing "$(basename $f)"${COLOR_END}\n"
            mysql --defaults-extra-file=$MYSQL_CNF $OPTION_MYSQL_DATABASES_AUTH < $f

            # Check to make sure there weren't any errors
            if [ $? -ne 0 ]; then
                # Remove the mysql conf
                rm -rf $MYSQL_CNF

                # Terminate script on error
                exit $?
            fi
        done

        # Loop through all sql files inside the auth updates folder
        for f in $OPTION_SOURCE_LOCATION/data/sql/updates/db_auth/*.sql; do
            printf "${COLOR_ORANGE}Importing "$(basename $f)"${COLOR_END}\n"

            # Import the sql file
            mysql --defaults-extra-file=$MYSQL_CNF $OPTION_MYSQL_DATABASES_AUTH < $f

            # Check to make sure there weren't any errors
            if [ $? -ne 0 ]; then
                # Remove the mysql conf
                rm -rf $MYSQL_CNF

                # Terminate script on error
                exit $?
            fi
        done
    fi

    # Check if either both or world is used as the first parameter
    if [[ $1 == "both" ]] || [[ $1 == "world" ]]; then
        # Loop through all sql files inside the characters base folder
        for f in $OPTION_SOURCE_LOCATION/data/sql/base/db_characters/*.sql; do
            # Check if the table already exists
            if [ ! -z `mysql --defaults-extra-file=$MYSQL_CNF --skip-column-names $OPTION_MYSQL_DATABASES_CHARACTERS -e "SHOW TABLES LIKE '$(basename $f .sql)'"` ]; then
                printf "${COLOR_ORANGE}Skipping "$(basename $f)"${COLOR_END}\n"

                # Skip the file since it's already imported
                continue;
            fi

            # Check to make sure there weren't any errors
            if [ $? -ne 0 ]; then
                # Remove the mysql conf
                rm -rf $MYSQL_CNF

                # Terminate script on error
                exit $?
            fi

            # Import the sql file
            printf "${COLOR_ORANGE}Importing "$(basename $f)"${COLOR_END}\n"
            mysql --defaults-extra-file=$MYSQL_CNF $OPTION_MYSQL_DATABASES_CHARACTERS < $f

            # Check to make sure there weren't any errors
            if [ $? -ne 0 ]; then
                # Remove the mysql conf
                rm -rf $MYSQL_CNF

                # Terminate script on error
                exit $?
            fi
        done

        # Loop through all sql files inside the characters updates folder
        for f in $OPTION_SOURCE_LOCATION/data/sql/updates/db_characters/*.sql; do
            printf "${COLOR_ORANGE}Importing "$(basename $f)"${COLOR_END}\n"

            # Import the sql file
            mysql --defaults-extra-file=$MYSQL_CNF $OPTION_MYSQL_DATABASES_CHARACTERS < $f

            # Check to make sure there weren't any errors
            if [ $? -ne 0 ]; then
                # Remove the mysql conf
                rm -rf $MYSQL_CNF

                # Terminate script on error
                exit $?
            fi
        done

        # Loop through all sql files inside the world base folder
        for f in $OPTION_SOURCE_LOCATION/data/sql/base/db_world/*.sql; do
            # Check if the table already exists
            if [ ! -z `mysql --defaults-extra-file=$MYSQL_CNF --skip-column-names $OPTION_MYSQL_DATABASES_WORLD -e "SHOW TABLES LIKE '$(basename $f .sql)'"` ]; then
                printf "${COLOR_ORANGE}Skipping "$(basename $f)"${COLOR_END}\n"

                # Skip the file since it's already imported
                continue;
            fi

            # Check to make sure there weren't any errors
            if [ $? -ne 0 ]; then
                # Remove the mysql conf
                rm -rf $MYSQL_CNF

                # Terminate script on error
                exit $?
            fi

            # Import the sql file
            printf "${COLOR_ORANGE}Importing "$(basename $f)"${COLOR_END}\n"
            mysql --defaults-extra-file=$MYSQL_CNF $OPTION_MYSQL_DATABASES_WORLD < $f

            # Check to make sure there weren't any errors
            if [ $? -ne 0 ]; then
                # Remove the mysql conf
                rm -rf $MYSQL_CNF

                # Terminate script on error
                exit $?
            fi
        done

        # Loop through all sql files inside the world updates folder
        for f in $OPTION_SOURCE_LOCATION/data/sql/updates/db_world/*.sql; do
            printf "${COLOR_ORANGE}Importing "$(basename $f)"${COLOR_END}\n"

            # Import the sql file
            mysql --defaults-extra-file=$MYSQL_CNF $OPTION_MYSQL_DATABASES_WORLD < $f

            # Check to make sure there weren't any errors
            if [ $? -ne 0 ]; then
                # Remove the mysql conf
                rm -rf $MYSQL_CNF

                # Terminate script on error
                exit $?
            fi
        done

        printf "${COLOR_ORANGE}Adding to the realmlist (id: $OPTION_WORLD_ID, name: $OPTION_WORLD_NAME, address $OPTION_WORLD_ADDRESS)${COLOR_END}\n"
        # Update the realmlist with the id, name and address specified
        mysql --defaults-extra-file=$MYSQL_CNF $OPTION_MYSQL_DATABASES_AUTH -e "DELETE FROM realmlist WHERE id='$OPTION_WORLD_ID';INSERT INTO realmlist (id, name, address, localAddress, localSubnetMask, port) VALUES ('$OPTION_WORLD_ID', '$OPTION_WORLD_NAME', '$OPTION_WORLD_ADDRESS', '$OPTION_WORLD_ADDRESS', '255.255.255.0', '8085')"

        # Check to make sure there weren't any errors
        if [ $? -ne 0 ]; then
            # Remove the mysql conf
            rm -rf $MYSQL_CNF

            # Terminate script on error
            exit $?
        fi

        # Check if there is a folder for custom content
        if [ -d $ROOT/sql/world ]; then
            # Check if the folder is empty
            if [[ ! -z "$(ls -A $ROOT/sql/world/)" ]]; then
                # Loop through all sql files inside the folder
                for f in $ROOT/sql/world/*.sql; do
                    printf "${COLOR_ORANGE}Importing "$(basename $f)"${COLOR_END}\n"

                    # Import the sql file
                    mysql --defaults-extra-file=$MYSQL_CNF $OPTION_MYSQL_DATABASES_WORLD < $f

                    # Check to make sure there weren't any errors
                    if [ $? -ne 0 ]; then
                        # Remove the mysql conf
                        rm -rf $MYSQL_CNF

                        # Terminate script on error
                        exit $?
                    fi
                done
            fi
        fi
    fi

    # Remove the mysql conf
    rm -rf $MYSQL_CNF

    printf "${COLOR_GREEN}Finished importing the database files...${COLOR_END}\n"
}

# A function that changes config files to values specified in the options
function set_config
{
    printf "${COLOR_GREEN}Updating the config files...${COLOR_END}\n"

    # Check if either both or auth is used as the first parameter
    if [[ $1 == "both" ]] || [[ $1 == "auth" ]]; then
        # Check to make sure the config file exists
        if [ ! -f $OPTION_SOURCE_LOCATION/etc/authserver.conf.dist ]; then
            # The file is missing, so terminate the script
            printf "${COLOR_RED}The config file authserver.conf.dist is missing.${COLOR_END}\n"
            printf "${COLOR_RED}Please make sure to install the server first.${COLOR_END}\n"

            # Remove the mysql conf
            rm -rf $MYSQL_CNF

            # Terminate script on error
            exit $?
        fi

        printf "${COLOR_ORANGE}Updating authserver.conf${COLOR_END}\n"

        # Copy the file before editing it
        cp $OPTION_SOURCE_LOCATION/etc/authserver.conf.dist $OPTION_SOURCE_LOCATION/etc/authserver.conf

        # Update authserver.conf with values specified in the options
        sed -i 's/LoginDatabaseInfo =.*/LoginDatabaseInfo = "'$OPTION_MYSQL_HOSTNAME';'$OPTION_MYSQL_PORT';'$OPTION_MYSQL_USERNAME';'$OPTION_MYSQL_PASSWORD';'$OPTION_MYSQL_DATABASES_AUTH'"/g' $OPTION_SOURCE_LOCATION/etc/authserver.conf
        sed -i 's/Updates.EnableDatabases =.*/Updates.EnableDatabases = 0/g' $OPTION_SOURCE_LOCATION/etc/authserver.conf
    fi

    # Check if either both or world is used as the first parameter
    if [[ $1 == "both" ]] || [[ $1 == "world" ]]; then
        # Check to make sure the config file exists
        if [ ! -f $OPTION_SOURCE_LOCATION/etc/worldserver.conf.dist ]; then
            # The file is missing, so terminate the script
            printf "${COLOR_RED}The config file worldserver.conf.dist is missing.${COLOR_END}\n"
            printf "${COLOR_RED}Please make sure to install the server first.${COLOR_END}\n"

            # Remove the mysql conf
            rm -rf $MYSQL_CNF

            # Terminate script on error
            exit $?
        fi

        printf "${COLOR_ORANGE}Updating worldserver.conf${COLOR_END}\n"

        # Convert boolean values to integers
        [ $OPTION_WORLD_ALWAYS_MAX_SKILL == "true" ] && WORLD_ALWAYS_MAX_SKILL=1 || WORLD_ALWAYS_MAX_SKILL=0
        [ $OPTION_WORLD_ALL_FLIGHT_PATHS == "true" ] && WORLD_ALL_FLIGHT_PATHS=1 || WORLD_ALL_FLIGHT_PATHS=0
        [ $OPTION_WORLD_MAPS_EXPLORED == "true" ] && WORLD_MAPS_EXPLORED=1 || WORLD_MAPS_EXPLORED=0
        [ $OPTION_WORLD_ALLOW_COMMANDS == "true" ] && WORLD_ALLOW_COMMANDS=1 || WORLD_ALLOW_COMMANDS=0
        [ $OPTION_WORLD_QUEST_IGNORE_RAID == "true" ] && WORLD_QUEST_IGNORE_RAID=1 || WORLD_QUEST_IGNORE_RAID=0
        [ $OPTION_WORLD_PREVENT_AFK_LOGOUT == "true" ] && WORLD_PREVENT_AFK_LOGOUT=1 || WORLD_PREVENT_AFK_LOGOUT=0
        [ $OPTION_WORLD_PRELOAD_MAP_GRIDS == "true" ] && WORLD_PRELOAD_MAP_GRIDS=1 || WORLD_PRELOAD_MAP_GRIDS=0
        [ $OPTION_WORLD_SET_ALL_WAYPOINTS_ACTIVE == "true" ] && WORLD_SET_ALL_WAYPOINTS_ACTIVE=1 || WORLD_SET_ALL_WAYPOINTS_ACTIVE=0
        [ $OPTION_WORLD_ENABLE_MINIGOB_MANABONK == "true" ] && WORLD_ENABLE_MINIGOB_MANABONK=1 || WORLD_ENABLE_MINIGOB_MANABONK=0
        [ $OPTION_WORLD_ENABLE_WARDEN == "true" ] && WORLD_ENABLE_WARDEN=1 || WORLD_ENABLE_WARDEN=0
        [ $OPTION_WORLD_GM_LOGIN_STATE == "true" ] && WORLD_GM_LOGIN_STATE=1 || WORLD_GM_LOGIN_STATE=0
        [ $OPTION_WORLD_GM_ENABLE_VISIBILITY == "true" ] && WORLD_GM_ENABLE_VISIBILITY=1 || WORLD_GM_ENABLE_VISIBILITY=0
        [ $OPTION_WORLD_GM_ENABLE_CHAT == "true" ] && WORLD_GM_ENABLE_CHAT=1 || WORLD_GM_ENABLE_CHAT=0
        [ $OPTION_WORLD_GM_ENABLE_WHISPER == "true" ] && WORLD_GM_ENABLE_WHISPER=1 || WORLD_GM_ENABLE_WHISPER=0
        [ $OPTION_WORLD_GM_ALLOW_INVITE == "true" ] && WORLD_GM_ALLOW_INVITE=1 || WORLD_GM_ALLOW_INVITE=0
        [ $OPTION_WORLD_GM_ALLOW_FRIEND == "true" ] && WORLD_GM_ALLOW_FRIEND=1 || WORLD_GM_ALLOW_FRIEND=0
        [ $OPTION_WORLD_GM_ALLOW_LOWER_SECURITY == "true" ] && WORLD_GM_ALLOW_LOWER_SECURITY=1 || WORLD_GM_ALLOW_LOWER_SECURITY=0

        # Copy the file before editing it
        cp $OPTION_SOURCE_LOCATION/etc/worldserver.conf.dist $OPTION_SOURCE_LOCATION/etc/worldserver.conf

        # Update worldserver.conf with values specified in the options
        sed -i 's/LoginDatabaseInfo     =.*/LoginDatabaseInfo     = "'$OPTION_MYSQL_HOSTNAME';'$OPTION_MYSQL_PORT';'$OPTION_MYSQL_USERNAME';'$OPTION_MYSQL_PASSWORD';'$OPTION_MYSQL_DATABASES_AUTH'"/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/WorldDatabaseInfo     =.*/WorldDatabaseInfo     = "'$OPTION_MYSQL_HOSTNAME';'$OPTION_MYSQL_PORT';'$OPTION_MYSQL_USERNAME';'$OPTION_MYSQL_PASSWORD';'$OPTION_MYSQL_DATABASES_WORLD'"/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/CharacterDatabaseInfo =.*/CharacterDatabaseInfo = "'$OPTION_MYSQL_HOSTNAME';'$OPTION_MYSQL_PORT';'$OPTION_MYSQL_USERNAME';'$OPTION_MYSQL_PASSWORD';'$OPTION_MYSQL_DATABASES_CHARACTERS'"/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/Updates.EnableDatabases =.*/Updates.EnableDatabases = 0/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/RealmID =.*/RealmID = '$OPTION_WORLD_ID'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/GameType =.*/GameType = '$OPTION_WORLD_GAME_TYPE'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/RealmZone =.*/RealmZone = '$OPTION_WORLD_REALM_ZONE'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/Expansion =.*/Expansion = '$OPTION_WORLD_EXPANSION'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/PlayerLimit =.*/PlayerLimit = '$OPTION_WORLD_PLAYER_LIMIT'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/StrictPlayerNames =.*/StrictPlayerNames = 3/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/StrictCharterNames =.*/StrictCharterNames = 3/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/StrictPetNames =.*/StrictPetNames = 3/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/Motd =.*/Motd = "'"$OPTION_WORLD_MOTD"'"/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/SkipCinematics =.*/SkipCinematics = '$OPTION_WORLD_SKIP_CINEMATICS'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/MaxPlayerLevel =.*/MaxPlayerLevel = '$OPTION_WORLD_MAX_LEVEL'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/StartPlayerLevel =.*/StartPlayerLevel = '$OPTION_WORLD_START_LEVEL'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/StartPlayerMoney =.*/StartPlayerMoney = '$OPTION_WORLD_START_MONEY'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/AllFlightPaths =.*/AllFlightPaths = '$WORLD_ALL_FLIGHT_PATHS'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/AlwaysMaxSkillForLevel =.*/AlwaysMaxSkillForLevel = '$WORLD_ALWAYS_MAX_SKILL'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/PlayerStart.MapsExplored =.*/PlayerStart.MapsExplored = '$WORLD_MAPS_EXPLORED'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/AllowPlayerCommands =.*/AllowPlayerCommands = '$WORLD_ALLOW_COMMANDS'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/Quests.IgnoreRaid =.*/Quests.IgnoreRaid = '$WORLD_QUEST_IGNORE_RAID'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/PreventAFKLogout =.*/PreventAFKLogout = '$WORLD_PREVENT_AFK_LOGOUT'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/RecruitAFriend.MaxLevel =.*/RecruitAFriend.MaxLevel = '$OPTION_WORLD_RAF_MAX_LEVEL'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/PreloadAllNonInstancedMapGrids =.*/PreloadAllNonInstancedMapGrids = '$WORLD_PRELOAD_MAP_GRIDS'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/SetAllCreaturesWithWaypointMovementActive =.*/SetAllCreaturesWithWaypointMovementActive = '$WORLD_SET_ALL_WAYPOINTS_ACTIVE'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/Minigob.Manabonk.Enable =.*/Minigob.Manabonk.Enable = '$WORLD_ENABLE_MINIGOB_MANABONK'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/Rate.Drop.Money                 =.*/Rate.Drop.Money                 = '$OPTION_WORLD_RATES_MONEY'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/Rate.XP.Kill      =.*/Rate.XP.Kill      = '$OPTION_WORLD_RATES_EXPERIENCE'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/Rate.XP.Quest     =.*/Rate.XP.Quest     = '$OPTION_WORLD_RATES_EXPERIENCE'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/Rate.XP.Quest.DF  =.*/Rate.XP.Quest.DF  = '$OPTION_WORLD_RATES_EXPERIENCE'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/Rate.XP.Explore   =.*/Rate.XP.Explore   = '$OPTION_WORLD_RATES_EXPERIENCE'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/Rate.XP.Pet       =.*/Rate.XP.Pet       = '$OPTION_WORLD_RATES_EXPERIENCE'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/Rate.Reputation.Gain =.*/Rate.Reputation.Gain = '$OPTION_WORLD_RATES_REPUTATION'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/SkillGain.Crafting  =.*/SkillGain.Crafting  = '$OPTION_WORLD_RATES_CRAFTING'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/SkillGain.Defense   =.*/SkillGain.Defense   = '$OPTION_WORLD_RATES_DEFENSE_SKILL'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/SkillGain.Gathering =.*/SkillGain.Gathering = '$OPTION_WORLD_RATES_GATHERING'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/SkillGain.Weapon    =.*/SkillGain.Weapon    = '$OPTION_WORLD_RATES_WEAPON_SKILL'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/Rate.Rest.InGame                 =.*/Rate.Rest.InGame                 = '$OPTION_WORLD_RATES_RESTED_EXPERIENCE'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/Rate.Rest.Offline.InTavernOrCity =.*/Rate.Rest.Offline.InTavernOrCity = '$OPTION_WORLD_RATES_RESTED_EXPERIENCE'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/Rate.Rest.Offline.InWilderness   =.*/Rate.Rest.Offline.InWilderness   = '$OPTION_WORLD_RATES_RESTED_EXPERIENCE'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/GM.LoginState =.*/GM.LoginState = '$WORLD_GM_LOGIN_STATE'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/GM.Visible =.*/GM.Visible = '$WORLD_GM_ENABLE_VISIBILITY'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/GM.Chat =.*/GM.Chat = '$WORLD_GM_ENABLE_CHAT'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/GM.WhisperingTo =.*/GM.WhisperingTo = '$WORLD_GM_ENABLE_WHISPER'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/GM.InGMList.Level =.*/GM.InGMList.Level = '$OPTION_WORLD_GM_SHOW_GM_LIST'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/GM.InWhoList.Level =.*/GM.InWhoList.Level = '$OPTION_WORLD_GM_SHOW_WHO_LIST'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/GM.StartLevel = .*/GM.StartLevel = '$OPTION_WORLD_START_LEVEL'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/GM.AllowInvite =.*/GM.AllowInvite = '$WORLD_GM_ALLOW_INVITE'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/GM.AllowFriend =.*/GM.AllowFriend = '$WORLD_GM_ALLOW_FRIEND'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/GM.LowerSecurity =.*/GM.LowerSecurity = '$WORLD_GM_ALLOW_LOWER_SECURITY'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
        sed -i 's/Warden.Enabled =.*/Warden.Enabled = '$WORLD_ENABLE_WARDEN'/g' $OPTION_SOURCE_LOCATION/etc/worldserver.conf
    fi

    printf "${COLOR_GREEN}Finished updating the config files...${COLOR_END}\n"
}

# A function that starts the compiled server
function start_server
{
    printf "${COLOR_GREEN}Starting the server...${COLOR_END}\n"

    # Check if the required binaries exist
    if [ ! -f $OPTION_SOURCE_LOCATION/bin/start.sh ] || [ ! -f $OPTION_SOURCE_LOCATION/bin/stop.sh ] || [ ! -f $OPTION_SOURCE_LOCATION/bin/authserver ] || [ ! -f $OPTION_SOURCE_LOCATION/bin/worldserver ]; then
        printf "${COLOR_RED}The required binaries are missing.${COLOR_END}\n"
        printf "${COLOR_RED}Please make sure to install the server first.${COLOR_END}\n"

        # Terminate the script
        exit $?
    fi

    # Check if the process is already running
    if [[ ! -z `screen -list | grep -E "auth"` ]] || [[ ! -z `screen -list | grep -E "world"` ]]; then
        printf "${COLOR_RED}The server is already running.${COLOR_END}\n"

        # Terminate the script
        exit $?
    fi

    # Start the server
    cd $OPTION_SOURCE_LOCATION/bin && ./start.sh

    # Check of the authserver is running
    if [[ ! -z `screen -list | grep -E "auth"` ]]; then
        # Give some information about accessing the screen
        printf "${COLOR_ORANGE}To access the screen of the authserver, use the command ${COLOR_BLUE}screen -r auth${COLOR_ORANGE}.${COLOR_END}\n"
    fi

    # Check of the worldserver is running
    if [[ ! -z `screen -list | grep -E "world"` ]]; then
        # Give some information about accessing the screen
        printf "${COLOR_ORANGE}To access the screen of the worldserver, use the command ${COLOR_BLUE}screen -r world${COLOR_ORANGE}.${COLOR_END}\n"
    fi

    printf "${COLOR_GREEN}Finished starting the server...${COLOR_END}\n"
}

# A function that stops the running server
function stop_server
{
    printf "${COLOR_GREEN}Stopping the server...${COLOR_END}\n"

    # Check if the process is running
    if [[ -z `screen -list | grep -E "auth"` ]] && [[ -z `screen -list | grep -E "world"` ]]; then
        printf "${COLOR_RED}The server is not running.${COLOR_END}\n"
    fi

    # Check if the worldserver is running
    if [[ ! -z `screen -list | grep -E "world"` ]]; then
        printf "${COLOR_ORANGE}Telling the world server to save before shutting down.${COLOR_END}\n"

        # Send the saveall command to the worldserver
        screen -S world -p 0 -X stuff "saveall^m"

        # Sleep for 3 seconds to let the server save
        sleep 3
    fi

    # Check if the file exists
    if [ -f $OPTION_SOURCE_LOCATION/bin/stop.sh ]; then
        # Check if the server is running
        if [[ ! -z `screen -list | grep -E "auth"` ]] || [[ ! -z `screen -list | grep -E "world"` ]]; then
            # Stop the server
            cd $OPTION_SOURCE_LOCATION/bin && ./stop.sh
        fi
    fi

    printf "${COLOR_GREEN}Finished stopping the server...${COLOR_END}\n"
}

# A function that prints available parameters and subparameters when none are supplied or if they are invalid
function parameters
{
    printf "${COLOR_GREEN}Available parameters${COLOR_END}\n"
    printf "${COLOR_ORANGE}both           ${COLOR_WHITE}| ${COLOR_BLUE}Use chosen subparameters for the auth and worldserver${COLOR_END}\n"
    printf "${COLOR_ORANGE}auth           ${COLOR_WHITE}| ${COLOR_BLUE}Use chosen subparameters only for the authserver${COLOR_END}\n"
    printf "${COLOR_ORANGE}world          ${COLOR_WHITE}| ${COLOR_BLUE}Use chosen subparameters only for the worldserver${COLOR_END}\n"
    printf "${COLOR_ORANGE}start          ${COLOR_WHITE}| ${COLOR_BLUE}Starts the compiled processes, based off of the choice for compilation${COLOR_END}\n"
    printf "${COLOR_ORANGE}stop           ${COLOR_WHITE}| ${COLOR_BLUE}Stops the compiled processes, based off of the choice for compilation${COLOR_END}\n"
    printf "${COLOR_ORANGE}restart        ${COLOR_WHITE}| ${COLOR_BLUE}Stops and then starts the compiled processes, based off of the choice for compilation${COLOR_END}\n\n"

    printf "${COLOR_GREEN}Available subparameters${COLOR_END}\n"
    printf "${COLOR_ORANGE}install/update ${COLOR_WHITE}| ${COLOR_BLUE}Downloads the source code and compiles it. Also downloads client files${COLOR_END}\n"
    printf "${COLOR_ORANGE}database/db    ${COLOR_WHITE}| ${COLOR_BLUE}Imports all database files to the specified server${COLOR_END}\n"
    printf "${COLOR_ORANGE}config/conf    ${COLOR_WHITE}| ${COLOR_BLUE}Updates all config files with options specified${COLOR_END}\n"
    printf "${COLOR_ORANGE}all            ${COLOR_WHITE}| ${COLOR_BLUE}Run all subparameters listed above, including stop and start${COLOR_END}\n"

    exit $?
}

[[ -f $OPTION_SOURCE_LOCATION/bin/auth.sh && -f $OPTION_SOURCE_LOCATION/bin/authserver ]] && ENABLE_AUTHSERVER=1 || ENABLE_AUTHSERVER=0
[[ -f $OPTION_SOURCE_LOCATION/bin/world.sh && -f $OPTION_SOURCE_LOCATION/bin/worldserver ]] && ENABLE_WORLDSERVER=1 || ENABLE_WORLDSERVER=0
[ ! -f $OPTION_SOURCE_LOCATION/bin/start.sh ] && ENABLE_AUTHSERVER=1 ENABLE_WORLDSERVER=1

QUOTES=("A chain is only as strong as its weakest link." \
        "A fool and his money are soon parted." \
        "A friend is someone who gives you total freedom to be yourself." \
        "A great man is always willing to be little." \
        "A lion doesn’t concern himself with the opinions of the sheep." \
        "A man is but what he knows." \
        "A mind is a terrible thing to waste." \
        "A mind is like a parachute. It doesn’t work if it isn’t open." \
        "A penny saved is a penny earned." \
        "A picture is worth a thousand words." \
        "A successful man is one who can lay a firm foundation with the bricks others have thrown at him." \
        "Ability is of little account without opportunity." \
        "Actions speak louder than words." \
        "All good things must come to an end." \
        "All limitations are self-imposed." \
        "All our dreams can come true if we have the courage to pursue them." \
        "All that we are is the result of what we have thought." \
        "All that we see and seem is but a dream within a dream." \
        "All things come to those who wait." \
        "All's fair in love and war." \
        "All’s well that ends well." \
        "Always forgive your enemies; nothing annoys them so much." \
        "Always remember that you are absolutely unique. Just like everyone else." \
        "An ounce of action is worth a ton of theory." \
        "Arguing with a fool proves there are two." \
        "Be yourself; everyone else is already taken." \
        "Beauty is in the eye of the beholder." \
        "Beggars can’t be choosers." \
        "Challenges are what make life interesting and overcoming them is what makes life meaningful." \
        "Change your thoughts, and you change your world." \
        "Do not go where the path may lead; go instead where there is no path and leave a trail." \
        "Do what you can, with what you have, where you are." \
        "Don't let your friends you made memories with, become the memories." \
        "Don't put the cart before the horse." \
        "Don’t be afraid to give up the good to go for the great." \
        "Don’t count the days, make the days count." \
        "Don’t count your chickens before they hatch." \
        "Dream big and dare to fail." \
        "Early is on time, on time is late and late is unacceptable." \
        "Even a stopped clock is right twice a day." \
        "Every great dream begins with a dreamer. Always remember, you have within you the strength, the patience, and the passion to reach for the stars to change the world." \
        "Every man is guilty of all the good he did not do." \
        "Everyone will be famous for 15 minutes." \
        "Everything you’ve ever wanted is on the other side of fear." \
        "Familiarity breeds contempt." \
        "Fortune favors the bold." \
        "Genius is eternal patience." \
        "Get busy living or get busy dying." \
        "Great geniuses have the shortest biographies." \
        "Great minds discuss ideas; average minds discuss events; small minds discuss people." \
        "Great minds think alike." \
        "Happiness depends upon ourselves." \
        "Happiness is a direction, not a place." \
        "Have no fear of perfection, you'll never reach it." \
        "He that falls in love with himself will have no rivals." \
        "He who angers you conquers you." \
        "Holding onto anger is like drinking poison and expecting the other person to die." \
        "Honesty is the best policy." \
        "Hope for the best, but prepare for the worst." \
        "I alone cannot change the world, but I can cast a stone across the water to create many ripples." \
        "I am, therefore I think." \
        "I came, I saw, I conquered." \
        "I disapprove of what you say, but I will defend to the death your right to say it." \
        "I have no special talent. I am only passionately curious." \
        "I think, therefore I am." \
        "If I have seen further than others, it is by standing upon the shoulders of giants." \
        "If it ain’t broke, don’t fix it." \
        "If you aren’t going all the way, why go at all?" \
        "If you don't stand for something you will fall for anything." \
        "If you judge people, you have no time to love them." \
        "If you tell the truth, you don’t have to remember anything." \
        "If you want to be happy, be." \
        "If you’re going through hell, keep going." \
        "In order to write about life first you must live it." \
        "In the long run, the sharpest weapon of all is a kind and gentle spirit." \
        "In the middle of difficulty lies opportunity." \
        "In three words I can sum up everything I’ve learned about life: It goes on." \
        "Insanity is doing the same thing over and over again and expecting different results." \
        "It always seems impossible until it’s done." \
        "It is better to fail in originality than to succeed in imitation." \
        "It is never too late to be what you might have been." \
        "It is our choices, that show what we truly are, far more than our abilities." \
        "It isn’t where you came from. It’s where you’re going that counts." \
        "It’s never too late to be who you might have been." \
        "I’m selfish, impatient and a little insecure. I make mistakes, I am out of control and at times hard to handle. But if you can’t handle me at my worst, then you sure as hell don’t deserve me at my best." \
        "Keep your face to the sunshine and you can never see the shadow." \
        "Keep your friends close, but your enemies closer." \
        "Knowing yourself is the beginning of all wisdom." \
        "Knowledge is power." \
        "Knowledge makes a man unfit to be a slave." \
        "Leave no stone unturned." \
        "Leave nothing for tomorrow which can be done today." \
        "Life has no limitations, except the ones you make." \
        "Life is like a box of chocolates. You never know what you’re going to get." \
        "Life is not a problem to be solved, but a reality to be experienced." \
        "Life is ten percent what happens to you and ninety percent how you respond to it." \
        "Life is what happens when you’re busy making other plans." \
        "Life itself is the most wonderful fairy tale." \
        "Life would be tragic if it weren’t funny." \
        "Look before you leap." \
        "Love all, trust a few, do wrong to none." \
        "Many of life’s failures are people who did not realize how close they were to success when they gave up." \
        "May you live all the days of your life." \
        "Necessity is the mother of invention." \
        "Never let the fear of striking out keep you from playing the game." \
        "No one can make you feel inferior without your consent." \
        "No pressure, no diamonds." \
        "Nothing is impossible, the word itself says, ‘I’m possible!’" \
        "Once you’ve accepted your flaws, no one can use them against you." \
        "Originality is nothing but judicious imitation." \
        "Our greatest fear should not be of failure… but of succeeding at things in life that don’t really matter." \
        "People are just as happy as they make up their minds to be." \
        "Power tends to corrupt, and absolute power corrupts absolutely." \
        "Practice makes perfect." \
        "Remember that the happiest people are not those getting more, but those giving more." \
        "Science is what you know. Philosophy is what you don’t know." \
        "Shoot for the moon. Even if you miss, you’ll land among the stars." \
        "Simplicity is the ultimate sophistication." \
        "Sing like no one’s listening, love like you’ve never been hurt, dance like nobody’s watching, and live like it’s heaven on earth." \
        "Stay hungry, stay foolish." \
        "Strive not to be a success, but rather to be of value." \
        "Success is not final, failure is not fatal: it is the courage to continue that counts." \
        "That which does not kill us makes us stronger." \
        "That’s one small step for a man, one giant leap for mankind." \
        "The best way out is always through." \
        "The big lesson in life, baby, is never be scared of anyone or anything." \
        "The early bird catches the worm." \
        "The end doesn’t justify the means." \
        "The further a society drifts from the truth, the more it will hate those that speak it." \
        "The future belongs to those who prepare for it today." \
        "The greatest glory in living lies not in never falling, but in rising every time we fall." \
        "The journey of a thousand miles begins with one step." \
        "The more things change, the more they remain the same." \
        "The only impossible journey is the one you never begin." \
        "The only person you are destined to become is the person you decide to be." \
        "The only thing necessary for the triumph of evil is for good men to do nothing." \
        "The opposite of love is not hate; it’s indifference." \
        "The pen is mightier than the sword." \
        "The power of imagination makes us infinite." \
        "The price of greatness is responsibility." \
        "The purpose of our lives is to be happy." \
        "The question isn’t who is going to let me; it’s who is going to stop me." \
        "The secret of getting ahead is getting started." \
        "The successful warrior is the average man, with laser-like focus." \
        "The time is always right to do what is right." \
        "The way to get started is to quit talking and begin doing." \
        "There is nothing impossible to him who will try." \
        "There’s a sucker born every minute." \
        "This above all: to thine own self be true." \
        "Those who cannot remember the past are condemned to repeat it." \
        "Those who dare to fail miserably can achieve greatly." \
        "Those who make you believe absurdities can make you commit atrocities." \
        "Time is money." \
        "Time you enjoy wasting is not wasted time." \
        "Tis better to have loved and lost than to have never loved at all." \
        "Tough times never last but tough people do." \
        "Try to be a rainbow in someone else’s cloud." \
        "Turn your wounds into wisdom." \
        "Twenty years from now you will be more disappointed by the things that you didn’t do than by the ones you did do." \
        "Two heads are better than one." \
        "Two wrongs don’t make a right." \
        "We are what we repeatedly do; excellence, then, is not an act but a habit." \
        "We design our lives through the power of choices." \
        "We don’t stop playing because we grow old; we grow old because we stop playing." \
        "We have nothing to fear but fear itself." \
        "Well done is better than well said." \
        "What you do speaks so loudly that I cannot hear what you say." \
        "Whatever you do, do with all your might." \
        "When I dare to be powerful – to use my strength in the service of my vision, then it becomes less and less important whether I am afraid." \
        "When life gives you lemons, make lemonade." \
        "When the going gets tough, the tough get going." \
        "When we strive to become better than we are, everything around us becomes better too." \
        "When you reach the end of your rope, tie a knot in it and hang on." \
        "Whether you think you can or you think you can’t, you’re right." \
        "Yesterday is history, tomorrow is a mystery, today is a gift of God, which is why we call it the present." \
        "You are never too old to set another goal or to dream a new dream." \
        "You can discover more about a person in an hour of play than in a year of conversation." \
        "You can not excel at anything you do not love." \
        "You can please some of the people all of the time, you can please all of the people some of the time, but you can’t please all of the people all of the time." \
        "You can’t make an omelet without breaking a few eggs." \
        "You know you’re in love when you can’t fall asleep because reality is finally better than your dreams." \
        "You miss 100 percent of the shots you never take." \
        "You must be the change you wish to see in the world." \
        "You only live once, but if you do it right, once is enough." \
        "You will face many defeats in life, but never let yourself be defeated." \
        "You’ll never find a rainbow if you’re looking down."
)

function print_quote
{
    clear
    printf "${COLOR_PURPLE}Have an amazingly wonderful day!${COLOR_END}\n"
    printf "${COLOR_ORANGE}${QUOTES[$(( RANDOM % ${#QUOTES[@]} ))]}${COLOR_END}\n"
}

function show_menu
{
    clear

    if [[ -z $1 ]]; then
        printf "${COLOR_PURPLE}AzerothCore${COLOR_END}\n"
        printf "${COLOR_CYAN}1) ${COLOR_ORANGE}Manage the source code${COLOR_END}\n"
        printf "${COLOR_CYAN}2) ${COLOR_ORANGE}Manage the databases${COLOR_END}\n"
        printf "${COLOR_CYAN}3) ${COLOR_ORANGE}Manage the configuration options${COLOR_END}\n"
        if [[ -f $OPTION_SOURCE_LOCATION/bin/authserver && -f $OPTION_SOURCE_LOCATION/bin/worldserver ]] && [[ -f $OPTION_SOURCE_LOCATION/bin/auth.sh || -f $OPTION_SOURCE_LOCATION/bin/world.sh ]]; then
            if [ $(dpkg-query -W -f='${Status}' screen 2>/dev/null | grep -c "ok installed") -eq 1 ]; then
                if [[ -z `screen -list | grep -E "auth"` ]] && [[ -z `screen -list | grep -E "world"` ]]; then
                    printf "${COLOR_CYAN}4) ${COLOR_ORANGE}Start the compiled binaries${COLOR_END}\n"
                else
                    printf "${COLOR_CYAN}4) ${COLOR_ORANGE}Stop all running processes${COLOR_END}\n"
                fi
            fi
        fi
        printf "${COLOR_CYAN}0) ${COLOR_ORANGE}Exit${COLOR_END}\n"
        printf "${COLOR_GREEN}Choose an option:${COLOR_END}"
        read -s -n 1 s

        case $s in
            [1-3]) show_menu $s;;
            4) if [[ -z `screen -list | grep -E "auth"` ]] && [[ -z `screen -list | grep -E "world"` ]]; then clear; start_server; sleep 3; else clear; stop_server; fi; show_menu;;
            0) print_quote;;
            *) show_menu;;
        esac
    elif [[ $1 == 1 ]]; then
        if [[ -z $2 ]]; then
            printf "${COLOR_PURPLE}Manage the source code${COLOR_END}\n"
            printf "${COLOR_CYAN}1) ${COLOR_ORANGE}Download the latest version of the repository${COLOR_END}\n"
            printf "${COLOR_CYAN}2) ${COLOR_ORANGE}Compile the source code into binaries${COLOR_END}\n"
            printf "${COLOR_CYAN}0) ${COLOR_ORANGE}Return to the previous menu${COLOR_END}\n"
            printf "${COLOR_GREEN}Choose an option:${COLOR_END}"
            read -s -n 1 s

            case $s in
                0) show_menu;;
                *) show_menu $1;;
            esac
        fi
    elif [[ $1 == 2 ]]; then
        if [[ -z $2 ]]; then
            printf "${COLOR_PURPLE}Manage the databases${COLOR_END}\n"
            printf "${COLOR_CYAN}1) ${COLOR_ORANGE}Manage the auth database${COLOR_END}\n"
            printf "${COLOR_CYAN}2) ${COLOR_ORANGE}Manage the characters database${COLOR_END}\n"
            printf "${COLOR_CYAN}3) ${COLOR_ORANGE}Manage the world database${COLOR_END}\n"
            printf "${COLOR_CYAN}0) ${COLOR_ORANGE}Return to the previous menu${COLOR_END}\n"
            printf "${COLOR_GREEN}Choose an option:${COLOR_END}"
            read -s -n 1 s

            case $s in
                0) show_menu;;
                *) show_menu $1;;
            esac
        fi
    elif [[ $1 == 3 ]]; then
        if [[ -z $2 ]]; then
            printf "${COLOR_PURPLE}Manage the configuration options${COLOR_END}\n"
            printf "${COLOR_CYAN}1) ${COLOR_ORANGE}Manage the database options${COLOR_END}\n"
            printf "${COLOR_CYAN}2) ${COLOR_ORANGE}Manage the server options${COLOR_END}\n"
            printf "${COLOR_CYAN}0) ${COLOR_ORANGE}Return to the previous menu${COLOR_END}\n"
            printf "${COLOR_GREEN}Choose an option:${COLOR_END}"
            read -s -n 1 s

            case $s in
                0) show_menu;;
                *) show_menu $1;;
            esac
        fi
    fi
}

# Load all options from the file
load_options

# Check for provided parameters
if [ $# -gt 0 ]; then
    # Check the parameter
    if [[ $1 == "both" ]] || [[ $1 == "auth" ]] || [[ $1 == "world" ]]; then
        # Check the subparameter
        if [[ $2 == "install" ]] || [[ $2 == "update" ]]; then
            # Stop the enabled processes
            stop_server

            # Download the source code
            get_source $1

            # Compile the source code
            compile_source $1

            # Download the client data files
            get_client_files $1
        elif [[ $2 == "database" ]] || [[ $2 == "db" ]]; then
            # Import the database files
            import_database $1
        elif [[ $2 == "config" ]] || [[ $2 == "conf" ]]; then
            # Update the config files
            set_config $1
        elif [[ $2 == "all" ]]; then
            # Stop the enabled processes
            stop_server

            # Download the source code
            get_source $1

            # Compile the source code
            compile_source $1

            # Download the client data files
            get_client_files $1

            # Import the database files
            import_database $1

            # Update the config files
            set_config $1

            # Start the enabled processes
            start_server
        else
            # The provided subparameter is invalid
            parameters
        fi
    elif [[ $1 == "start" ]]; then
        # Start the enabled processes
        start_server
    elif [[ $1 == "stop" ]]; then
        # Stop the enabled processes
        stop_server
    elif [[ $1 == "restart" ]]; then
        # Stop the enabled processes
        stop_server

        # Start the enabled processes
        start_server
    else
        # The provided parameter is invalid
        parameters
    fi
else
    # No parameters provided, show menu
    show_menu
fi
