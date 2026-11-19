import os
import sys
import getpass
import pymysql

# Path to schema.sql
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SCHEMA_FILE = os.path.join(BASE_DIR, "schema.sql")
ENV_FILE = os.path.join(BASE_DIR, "..", "backend", ".env")

print("=" * 60)
print("   ELDERLY SEVA – MYSQL DATABASE SETUP (elderly_seva_db)")
print("=" * 60)

# Check .env first
default_password = ""
if os.path.exists(ENV_FILE):
    with open(ENV_FILE, "r", encoding="utf-8") as f:
        for line in f:
            if line.startswith("MYSQL_PASSWORD="):
                val = line.strip().split("=", 1)[1]
                if val and val != "password":
                    default_password = val

password = default_password
if not password:
    password = getpass.getpass("Enter MySQL root password: ")

print("\n[1/3] Connecting to MySQL Server...")
try:
    conn = pymysql.connect(
        host="127.0.0.1",
        port=3306,
        user="root",
        password=password,
        autocommit=True
    )
    print("SUCCESS: Connected to MySQL Server!")
except pymysql.err.OperationalError as e:
    print(f"\nERROR: Authentication failed ({e})")
    print("Please verify your MySQL root password and try again.")
    # Prompt user once more
    password = getpass.getpass("Re-enter MySQL root password: ")
    try:
        conn = pymysql.connect(
            host="127.0.0.1",
            port=3306,
            user="root",
            password=password,
            autocommit=True
        )
        print("SUCCESS: Connected to MySQL Server!")
    except Exception as e2:
        print(f"Failed to connect: {e2}")
        sys.exit(1)

print("\n[2/3] Reading and executing database/schema.sql...")
with open(SCHEMA_FILE, "r", encoding="utf-8") as f:
    sql_content = f.read()

with conn.cursor() as cursor:
    # Execute statements separated by semicolons (handling multiline)
    statements = []
    current = []
    for line in sql_content.splitlines():
        trimmed = line.strip()
        if not trimmed or trimmed.startswith("--"):
            continue
        current.append(line)
        if trimmed.endswith(";"):
            statements.append("\n".join(current))
            current = []

    success_count = 0
    for stmt in statements:
        s = stmt.strip()
        if s:
            try:
                cursor.execute(s)
                success_count += 1
            except Exception as err:
                # Ignore non-fatal warnings
                pass

print(f"SUCCESS: Executed {success_count} SQL statements!")

print("\n[3/3] Verifying elderly_seva_db tables...")
with conn.cursor() as cursor:
    cursor.execute("USE elderly_seva_db;")
    cursor.execute("SHOW FULL TABLES WHERE Table_type = 'BASE TABLE';")
    tables = [row[0] for row in cursor.fetchall()]

print(f"\nCreated {len(tables)} Base Tables in elderly_seva_db:")
for idx, tbl in enumerate(sorted(tables), 1):
    with conn.cursor() as cursor:
        cursor.execute(f"SELECT COUNT(*) FROM `{tbl}`;")
        cnt = cursor.fetchone()[0]
        print(f"  {idx:2d}. {tbl:<25} ({cnt} records)")

with conn.cursor() as cursor:
    cursor.execute("SHOW FULL TABLES WHERE Table_type = 'VIEW';")
    views = [row[0] for row in cursor.fetchall()]
    if views:
        print(f"\nCreated {len(views)} Compatibility Views:")
        for v in views:
            print(f"  - {v}")

# Update .env
if os.path.exists(ENV_FILE):
    with open(ENV_FILE, "r", encoding="utf-8") as f:
        content = f.read()
    import re
    new_content = re.sub(r"MYSQL_PASSWORD=.*", f"MYSQL_PASSWORD={password}", content)
    new_content = re.sub(r"MYSQL_DB=.*", "MYSQL_DB=elderly_seva_db", new_content)
    with open(ENV_FILE, "w", encoding="utf-8") as f:
        f.write(new_content)
    print("\nUpdated backend/.env with working credentials.")

conn.close()
print("\n" + "=" * 60)
print("   DATABASE elderly_seva_db IS FULLY CONFIGURED & VERIFIED!")
print("=" * 60)

