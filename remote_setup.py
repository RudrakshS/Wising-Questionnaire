import asyncio
import asyncpg
import os

DB_URL = "postgresql://postgres:FVhaxgNwMngwjVZwSVoyHrAVvWDqgDXj@switchyard.proxy.rlwy.net:28643/railway"

async def setup():
    print("🚀 Connecting to Railway Database...")
    conn = await asyncpg.connect(DB_URL)
    
    try:
        # 1. Run DDL (Tables)
        print("📁 Reading DDL (Tables)...")
        ddl_path = "wising_backend/migrations/sprint1_migration_DDL_ONLY.sql"
        with open(ddl_path, 'r') as f:
            ddl_sql = f.read()
        
        print("⏳ Executing DDL...")
        await conn.execute(ddl_sql)
        print("✅ Tables created successfully.")

        # 2. Run Seed (Questions)
        print("📁 Reading Seed (241 Questions)...")
        seed_path = "wising_backend/seeds/seed_output.sql"
        with open(seed_path, 'r', encoding='utf-8') as f:
            seed_sql = f.read()
            
        print("⏳ Executing Seed (this may take a few seconds)...")
        # The seed file might contain multiple statements, asyncpg handles it in execute()
        await conn.execute(seed_sql)
        print("✅ Tax questions seeded successfully.")

        print("\n🎉 DATABASE SETUP COMPLETE!")
        print("Your Railway backend is now ready to serve the frontend.")

    except Exception as e:
        print(f"❌ ERROR: {e}")
    finally:
        await conn.close()

if __name__ == "__main__":
    asyncio.run(setup())
