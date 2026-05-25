#!/bin/bash

SQL_DIR="/db-sql"
SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
SA_PASS="${SA_PASSWORD}"

# Start SQL Server in background
/opt/mssql/bin/sqlservr &
SQLSERVER_PID=$!

echo "Waiting for SQL Server to be ready..."
RETRIES=60
while [ $RETRIES -gt 0 ]; do
    if $SQLCMD -S localhost -U sa -P "$SA_PASS" -C -Q "SELECT 1" -l 2 &>/dev/null; then
        echo "SQL Server is ready."
        break
    fi
    RETRIES=$((RETRIES - 1))
    echo "Still waiting... ($RETRIES retries left)"
    sleep 2
done

if [ $RETRIES -eq 0 ]; then
    echo "ERROR: SQL Server did not become ready in time."
    kill $SQLSERVER_PID
    exit 1
fi

# Check if CrabFood database already exists
DB_EXISTS=$($SQLCMD -S localhost -U sa -P "$SA_PASS" -C -h -1 \
    -Q "SET NOCOUNT ON; SELECT name FROM sys.databases WHERE name='CrabFood'" 2>/dev/null \
    | tr -d ' \r\n')

if [ "$DB_EXISTS" = "CrabFood" ]; then
    echo "CrabFood database already exists. Skipping initialization."
else
    echo "Initializing CrabFood database..."

    run() {
        echo "  -> $1"
        $SQLCMD -S localhost -U sa -P "$SA_PASS" -C -i "$SQL_DIR/$1"
    }

    run_in_db() {
        echo "  -> $1 (in CrabFood)"
        $SQLCMD -S localhost -U sa -P "$SA_PASS" -C -d CrabFood -i "$SQL_DIR/$1"
    }

    run create_db.sql
    run_in_db 01_type/type.sql
    run_in_db 02_sequence/pk_sequence.sql
    run_in_db 03_table/table.sql
    run_in_db 04_constraint/ck_enum.sql
    run_in_db 04_constraint/ck_multicol.sql
    run_in_db 04_constraint/ck_pk_prefix.sql
    run_in_db 04_constraint/ck_range.sql
    run_in_db 04_constraint/pk_multicol.sql
    run_in_db 04_constraint/uq_multicol.sql
    run_in_db 05_relation/relation.sql
    run_in_db 06_function/fn_derived_field.sql
    run_in_db 06_function/fn_get_category_restaurants.sql
    run_in_db 06_function/fn_get_incart_orders.sql
    run_in_db 06_function/fn_search_restaurants.sql
    run_in_db 07_procedure/sp_get_restaurant_menu.sql
    run_in_db 07_procedure/sp_insert_delivery_address.sql
    run_in_db 07_procedure/sp_insert_menu_item.sql
    run_in_db 07_procedure/sp_insert_order.sql
    run_in_db 07_procedure/sp_insert_order_payment.sql
    run_in_db 07_procedure/sp_insert_payment_method.sql
    run_in_db 07_procedure/sp_insert_promotion.sql
    run_in_db 07_procedure/sp_insert_restaurant.sql
    run_in_db 07_procedure/sp_insert_user.sql
    run_in_db 07_procedure/sp_insert_vehicle.sql
    run_in_db 07_procedure/sp_validate_order_items.sql
    run_in_db 08_trigger/trg_business_rule.sql
    run_in_db 08_trigger/trg_derived_field.sql
    run_in_db 09_data/initial_data.sql
    run_in_db 09_data/seed_data.sql

    echo "Database initialization complete!"
fi

# Keep container alive by waiting on SQL Server process
wait $SQLSERVER_PID
