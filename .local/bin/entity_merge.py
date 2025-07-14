import sqlite3

DB_PATH = "/Users/mh/.local/share/basic-memory/.basic-memory/memory.db"

def merge_entities(canonical_id, duplicate_id):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Transfer relations: from_id
    cursor.execute("SELECT from_id, to_id, relation_type, to_name FROM relation WHERE from_id = ?", (duplicate_id,))
    relations = cursor.fetchall()
    for from_id, to_id, rel_type, to_name in relations:
        # Check if relation already exists
        cursor.execute(
            "SELECT 1 FROM relation WHERE from_id = ? AND to_id = ? AND relation_type = ?",
            (canonical_id, to_id, rel_type)
        )
        if not cursor.fetchone():
            cursor.execute(
                "UPDATE relation SET from_id = ? WHERE from_id = ? AND to_id = ? AND relation_type = ?",
                (canonical_id, from_id, to_id, rel_type)
            )

    # Transfer relations: to_id
    cursor.execute("SELECT from_id, to_id, relation_type, to_name FROM relation WHERE to_id = ?", (duplicate_id,))
    relations = cursor.fetchall()
    for from_id, to_id, rel_type, to_name in relations:
        # Check if relation already exists
        cursor.execute(
            "SELECT 1 FROM relation WHERE from_id = ? AND to_id = ? AND relation_type = ?",
            (from_id, canonical_id, rel_type)
        )
        if not cursor.fetchone():
            cursor.execute(
                "UPDATE relation SET to_id = ? WHERE from_id = ? AND to_id = ? AND relation_type = ?",
                (canonical_id, from_id, to_id, rel_type)
            )

    # Transfer observations
    cursor.execute("UPDATE observation SET entity_id = ? WHERE entity_id = ?", (canonical_id, duplicate_id))
    # Delete duplicate entity
    cursor.execute("DELETE FROM entity WHERE id = ?", (duplicate_id,))
    conn.commit()
    conn.close()
    print(f"Merged entity {duplicate_id} into {canonical_id}")

# Fill this list with your pairs: (canonical_id, duplicate_id)
merge_pairs = [
    # Example:
    # (101, 202),
    # (14, 32),
]

def main():
    for canonical_id, duplicate_id in merge_pairs:
        print(f"Merging {duplicate_id} into {canonical_id}...")
        merge_entities(canonical_id, duplicate_id)

if __name__ == "__main__":
    main()
