#!/bin/bash
function import_database
{
    install_database_packages

    clear

    printf "${COLOR_GREEN}Importing database files${COLOR_END}\n"

    echo "[client]" > $MYSQL_CONFIG
    echo "host=\"$MYSQL_HOSTNAME\"" >> $MYSQL_CONFIG
    echo "port=\"$MYSQL_PORT\"" >> $MYSQL_CONFIG
    echo "user=\"$MYSQL_USERNAME\"" >> $MYSQL_CONFIG
    echo "password=\"$MYSQL_PASSWORD\"" >> $MYSQL_CONFIG

    if [[ $1 == 0 || $1 == 1 && -z $2 ]] || [[ $1 == 1 && $2 == 1 ]]; then
        if [ ! -z `mysql --defaults-extra-file=$MYSQL_CONFIG --skip-column-names -e "SHOW DATABASES LIKE '$MYSQL_DATABASE_AUTH'"` ]; then
            if [ -d $CORE_DIRECTORY/data/sql/base/db_auth ]; then
                for f in $CORE_DIRECTORY/data/sql/base/db_auth/*.sql; do
                    if [ ! -z `mysql --defaults-extra-file=$MYSQL_CONFIG --skip-column-names $MYSQL_DATABASE_AUTH -e "SHOW TABLES LIKE '$(basename $f .sql)'"` ]; then
                        printf "${COLOR_ORANGE}Skipping "$(basename $f)"${COLOR_END}\n"
                        continue;
                    fi

                    printf "${COLOR_ORANGE}Importing "$(basename $f)"${COLOR_END}\n"
                    mysql --defaults-extra-file=$MYSQL_CONFIG $MYSQL_DATABASE_AUTH < $f
                    if [ $? -ne 0 ]; then
                        rm -rf $MYSQL_CONFIG
                        exit $?
                    fi
                done
            fi
        fi
    fi

    if [[ $1 == 0 || $1 == 2 && -z $2 ]] || [[ $1 == 2 && $2 == 1 ]]; then
        if [ ! -z `mysql --defaults-extra-file=$MYSQL_CONFIG --skip-column-names -e "SHOW DATABASES LIKE '$MYSQL_DATABASE_CHARACTERS'"` ]; then
            if [ -d $CORE_DIRECTORY/data/sql/base/db_characters ]; then
                for f in $CORE_DIRECTORY/data/sql/base/db_characters/*.sql; do
                    if [ ! -z `mysql --defaults-extra-file=$MYSQL_CONFIG --skip-column-names $MYSQL_DATABASE_CHARACTERS -e "SHOW TABLES LIKE '$(basename $f .sql)'"` ]; then
                        printf "${COLOR_ORANGE}Skipping "$(basename $f)"${COLOR_END}\n"
                        continue;
                    fi

                    printf "${COLOR_ORANGE}Importing "$(basename $f)"${COLOR_END}\n"
                    mysql --defaults-extra-file=$MYSQL_CONFIG $MYSQL_DATABASE_CHARACTERS < $f
                    if [ $? -ne 0 ]; then
                        rm -rf $MYSQL_CONFIG
                        exit $?
                    fi
                done
            fi
        fi
    fi

    if [[ $1 == 0 || $1 == 2 && -z $2 ]] || [[ $1 == 3 && $2 == 1 ]]; then
        if [ ! -z `mysql --defaults-extra-file=$MYSQL_CONFIG --skip-column-names -e "SHOW DATABASES LIKE '$MYSQL_DATABASE_WORLD'"` ]; then
            if [ -d $CORE_DIRECTORY/data/sql/base/db_world ]; then
                for f in $CORE_DIRECTORY/data/sql/base/db_world/*.sql; do
                    if [ ! -z `mysql --defaults-extra-file=$MYSQL_CONFIG --skip-column-names $MYSQL_DATABASE_WORLD -e "SHOW TABLES LIKE '$(basename $f .sql)'"` ]; then
                        printf "${COLOR_ORANGE}Skipping "$(basename $f)"${COLOR_END}\n"
                        continue;
                    fi

                    printf "${COLOR_ORANGE}Importing "$(basename $f)"${COLOR_END}\n"
                    mysql --defaults-extra-file=$MYSQL_CONFIG $MYSQL_DATABASE_WORLD < $f
                    if [ $? -ne 0 ]; then
                        rm -rf $MYSQL_CONFIG
                        exit $?
                    fi
                done
            fi
        fi
    fi

    rm -rf $MYSQL_CONFIG
}

function update_database
{
    install_database_packages

    clear

    printf "${COLOR_GREEN}Importing database files${COLOR_END}\n"

    echo "[client]" > $MYSQL_CONFIG
    echo "host=\"$MYSQL_HOSTNAME\"" >> $MYSQL_CONFIG
    echo "port=\"$MYSQL_PORT\"" >> $MYSQL_CONFIG
    echo "user=\"$MYSQL_USERNAME\"" >> $MYSQL_CONFIG
    echo "password=\"$MYSQL_PASSWORD\"" >> $MYSQL_CONFIG

    if [[ $1 == 0 || $1 == 1 && -z $2 ]] || [[ $1 == 1 && $2 == 2 ]]; then
        if [ ! -z `mysql --defaults-extra-file=$MYSQL_CONFIG --skip-column-names -e "SHOW DATABASES LIKE '$MYSQL_DATABASE_AUTH'"` ]; then
            if [ -d $CORE_DIRECTORY/data/sql/updates/db_auth ]; then
                for f in $CORE_DIRECTORY/data/sql/updates/db_auth/*.sql; do
                    printf "${COLOR_ORANGE}Importing "$(basename $f)"${COLOR_END}\n"
                    mysql --defaults-extra-file=$MYSQL_CONFIG $MYSQL_DATABASE_AUTH < $f
                    if [ $? -ne 0 ]; then
                        rm -rf $MYSQL_CONFIG
                        exit $?
                    fi
                done
            fi
        fi
    fi

    if [[ $1 == 0 || $1 == 2 && -z $2 ]] || [[ $1 == 2 && $2 == 2 ]]; then
        if [ ! -z `mysql --defaults-extra-file=$MYSQL_CONFIG --skip-column-names -e "SHOW DATABASES LIKE '$MYSQL_DATABASE_CHARACTERS'"` ]; then
            if [ -d $CORE_DIRECTORY/data/sql/updates/db_characters ]; then
                for f in $CORE_DIRECTORY/data/sql/updates/db_characters/*.sql; do
                    printf "${COLOR_ORANGE}Importing "$(basename $f)"${COLOR_END}\n"
                    mysql --defaults-extra-file=$MYSQL_CONFIG $MYSQL_DATABASE_CHARACTERS < $f
                    if [ $? -ne 0 ]; then
                        rm -rf $MYSQL_CONFIG
                        exit $?
                    fi
                done
            fi
        fi
    fi

    if [[ $1 == 0 || $1 == 2 && -z $2 ]] || [[ $1 == 3 && $2 == 2 ]]; then
        if [ ! -z `mysql --defaults-extra-file=$MYSQL_CONFIG --skip-column-names -e "SHOW DATABASES LIKE '$MYSQL_DATABASE_WORLD'"` ]; then
            if [ -d $CORE_DIRECTORY/data/sql/updates/db_world ]; then
                for f in $CORE_DIRECTORY/data/sql/updates/db_world/*.sql; do
                    printf "${COLOR_ORANGE}Importing "$(basename $f)"${COLOR_END}\n"
                    mysql --defaults-extra-file=$MYSQL_CONFIG $MYSQL_DATABASE_WORLD < $f
                    if [ $? -ne 0 ]; then
                        rm -rf $MYSQL_CONFIG
                        exit $?
                    fi
                done
            fi
        fi
    fi

    if [[ $1 == 0 || $1 == 2 && -z $2 ]] || [[ $1 == 3 && $2 == 3 ]]; then
        if [[ -d $ROOT/sql/world ]]; then
            if [[ ! -z "$(ls -A $ROOT/sql/world/)" ]]; then
                for f in $ROOT/sql/world/*; do
                    if [ -d "$f" ]; then
                        if [[ ! -z "$(ls -A $f)" ]]; then
                            for d in $f/*.sql; do
                                printf "${COLOR_ORANGE}Importing "$(basename $d)"${COLOR_END}\n"
                                mysql --defaults-extra-file=$MYSQL_CONFIG $MYSQL_DATABASE_WORLD < $d
                                if [ $? -ne 0 ]; then
                                    rm -rf $MYSQL_CONFIG
                                    exit $?
                                fi
                            done
                        fi
                    else
                        printf "${COLOR_ORANGE}Importing "$(basename $f)"${COLOR_END}\n"
                        mysql --defaults-extra-file=$MYSQL_CONFIG $MYSQL_DATABASE_WORLD < $f
                        if [ $? -ne 0 ]; then
                            rm -rf $MYSQL_CONFIG
                            exit $?
                        fi
                    fi
                done
            fi
        fi
    fi

    if [[ $1 == 0 || $1 == 2 && -z $2 ]] || [[ $1 == 3 && $2 == 4 ]]; then
        printf "${COLOR_ORANGE}Updating realmlist (id: $WORLD_ID, name: $WORLD_NAME, address: $WORLD_IP)${COLOR_END}\n"
        mysql --defaults-extra-file=$MYSQL_CONFIG $MYSQL_DATABASE_AUTH -e "DELETE FROM realmlist WHERE id='$WORLD_ID';INSERT INTO realmlist (id, name, address, localAddress, localSubnetMask, port) VALUES ('$WORLD_ID', '$WORLD_NAME', '$WORLD_IP', '$WORLD_IP', '255.255.255.0', '8085')"
        if [ $? -ne 0 ]; then
            rm -rf $MYSQL_CONFIG
            exit $?
        fi
    fi

    rm -rf $MYSQL_CONFIG
}
