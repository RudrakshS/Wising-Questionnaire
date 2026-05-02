import asyncio
import asyncpg

DB_URL = "postgresql://postgres:FVhaxgNwMngwjVZwSVoyHrAVvWDqgDXj@switchyard.proxy.rlwy.net:28643/railway"

async def force_setup():
    print("🛰️ Connecting to Railway Database...")
    conn = await asyncpg.connect(DB_URL)
    
    try:
        # 1. Read the DDL
        print("📖 Reading DDL...")
        with open("wising_backend/migrations/sprint1_migration_DDL_ONLY.sql", "r", encoding="utf-8") as f:
            ddl_content = f.read()
        
        # 2. Execute the DDL (Creating tables)
        print("🔨 Creating tables (tax_state_snapshots, field_registry, etc.)...")
        await conn.execute(ddl_content)
        print("✅ Tables created.")

        # 3. Read the Seed
        print("📖 Reading Seed data...")
        with open("wising_backend/seeds/seed_output.sql", "r", encoding="utf-8") as f:
            seed_content = f.read()
            
        print("🌱 Seeding tax questions (this takes about 5 seconds)...")
        await conn.execute(seed_content)
        print("✅ Data seeded.")

        # 4. Final Verification
        print("🔎 Verifying table existence...")
        tables = await conn.fetch("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'")
        table_names = [t['table_name'] for t in tables]
        print(f"📦 Tables found in DB: {', '.join(table_names)}")
        
        if "tax_state_snapshots" in table_names:
            print("\n🔥 SUCCESS! The missing table is now present.")
        else:
            print("\n❌ FAILED: The table is still missing. Check permissions.")

    except Exception as e:
        print(f"\n💥 ERROR: {e}")
    finally:
        await conn.close()

if __name__ == "__main__":
    asyncio.run(force_setup())
