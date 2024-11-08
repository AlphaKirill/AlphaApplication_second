#!/bin/bash

run_sql() {
    local file_path="$1"

    if [ ! -f "$file_path" ]; then
        echo "Файла не существует: $file_path"
        exit 1
    else
        psql -U postgres -d application -p 5432 -f "$file_path"

        if [ $? -eq 0 ]; then
            echo "Выполнено успешно: $file_path"
        else
            echo "Ошибка при выполнении: $file_path"
            exit 1
        fi
    fi
}

execute_query() {
    local query="$1"
    psql -U postgres -d application -p 5432 -t -c "$query" | xargs
}

get_applied_migrations() {
    execute_query "SELECT trim(migration_name) FROM migrations;"
}

record_migration() {
    local migration_name="$1"

    migration_name=$(echo "$migration_name" | xargs)
    
    existing_migration=$(psql -U postgres -d application -p 5432 -t -c "SELECT 1 FROM migrations WHERE trim(migration_name) = '$migration_name' LIMIT 1;")
    
    if [[ -z "$existing_migration" ]]; then
        local escaped_name=$(printf "%q" "$migration_name")
        local insert_query="INSERT INTO migrations (migration_name) VALUES ('$escaped_name');"
        psql -U postgres -d application -p 5432 -c "$insert_query"
    else
        echo "Миграция с именем $migration_name уже задействована."
    fi
}

apply_migrations() {
    local migrations_dir="./migrations"

    if [ ! -d "$migrations_dir" ]; then
        echo "Директория миграций не найдена: $migrations_dir"
        exit 1
    fi

    applied_migrations=$(get_applied_migrations)

    for migration in "$migrations_dir"/*.sql; do
        migration_name=$(basename "$migration")
        
        normalized_name=$(echo "$migration_name" | xargs)

        if ! echo "$applied_migrations" | grep -q "$normalized_name"; then
            echo "Выполняется миграция: $migration_name"
            run_sql "$migration"
            record_migration "$migration_name"
        else
            echo "Миграция уже выполнена: $migration_name"
        fi
    done
}

apply_migrations