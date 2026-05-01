import psycopg2, json

conn = psycopg2.connect(host="localhost", port=5432, user="postgres", password="wising@123", dbname="wising_tax")
cur = conn.cursor()

# Full section breakdown with field counts
cur.execute("""
    SELECT schema_name, section, classification, COUNT(*) as cnt,
           STRING_AGG(field_path, ', ' ORDER BY wizard_order) as fields
    FROM field_registry
    GROUP BY schema_name, section, classification
    ORDER BY schema_name, section, classification
""")

current_schema = None
current_section = None
for schema, section, cls, cnt, fields in cur.fetchall():
    if schema != current_schema:
        print(f"\n{'='*70}")
        print(f"SCHEMA: {schema}")
        print(f"{'='*70}")
        current_schema = schema
    if section != current_section:
        print(f"\n  [{section}]")
        current_section = section
    short_fields = [f.split('.')[-1] for f in fields.split(', ')]
    print(f"    {cls}: {cnt} fields — {', '.join(short_fields[:6])}{'...' if len(short_fields)>6 else ''}")

# Summary counts
print("\n\n=== SUMMARY ===")
cur.execute("""
    SELECT schema_name, COUNT(DISTINCT section) as sections, COUNT(*) as total_fields
    FROM field_registry GROUP BY schema_name ORDER BY schema_name
""")
for r in cur.fetchall():
    print(f"  {r[0]}: {r[1]} sections, {r[2]} total fields")

cur.close()
conn.close()
