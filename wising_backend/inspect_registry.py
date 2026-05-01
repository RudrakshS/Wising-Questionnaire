import psycopg2
conn = psycopg2.connect(host="localhost", port=5432, user="postgres", password="wising@123", dbname="wising_tax")
cur = conn.cursor()
cur.execute("SELECT field_path, section, classification, input_type, wizard_order FROM field_registry WHERE schema_name = 'layer0' ORDER BY wizard_order")
print("=== Layer0 Fields ===")
for r in cur.fetchall():
    print(r)
cur.execute("SELECT DISTINCT section, schema_name FROM field_registry ORDER BY schema_name, section LIMIT 30")
print("\n=== All Sections ===")
for r in cur.fetchall():
    print(r)
cur.close()
conn.close()
