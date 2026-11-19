import sys

with open(r'C:\projects\Elder-App\database\senior_profiles_dump.sql', 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

in_copy = False
uids = []
for line in lines:
    if line.startswith('COPY public.senior_profiles'):
        in_copy = True
        continue
    if in_copy:
        if line.strip() == r'\.':
            break
        parts = line.rstrip('\n').split('\t')
        if len(parts) >= 2:
            uids.append(f"'{parts[1]}'")

sql = f"SELECT count(*) as matching_users FROM users WHERE id IN ({','.join(uids)});"
with open(r'C:\projects\Elder-App\database\check_fks.sql', 'w', encoding='utf-8') as out:
    out.write(sql)
print(f"Generated check_fks.sql with {len(uids)} user IDs.")
