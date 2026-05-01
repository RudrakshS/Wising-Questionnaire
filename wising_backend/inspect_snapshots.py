import psycopg2
conn = psycopg2.connect(host="localhost", port=5432, user="postgres", password="wising@123", dbname="wising_tax")
cur = conn.cursor()
cur.execute("SELECT id, user_id, tax_year_id, status, created_at FROM tax_state_snapshots ORDER BY created_at DESC LIMIT 5")
print("=== Recent Snapshots ===")
for r in cur.fetchall():
    print(r)

# Check specific ID
cur.execute("SELECT id FROM tax_state_snapshots WHERE id = '8b91a3ff-edf3-4e16-9eaa-a015df1ac950'")
row = cur.fetchone()
print(f"\nLookup 8b91a3ff: {row}")

cur.execute("SELECT COUNT(*) FROM tax_state_snapshots")
print(f"Total snapshots: {cur.fetchone()[0]}")
cur.close()
conn.close()
