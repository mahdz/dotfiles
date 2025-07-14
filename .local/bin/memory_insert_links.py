import sqlite3

DB_PATH = "/Users/mh/.local/share/basic-memory/.basic-memory/memory.db"

# Populate this list with your selected links
potential_links = [
    # Example:
    # (from_id, to_id, 'relation_type', 'relation_description')
    (128, 150, 'created_by', 'Linking project to its creator'),
    (130, 150, 'created_by', 'Linking project to its creator'),
    (136, 150, 'created_by', 'Linking project to its creator'),
    (144, 150, 'created_by', 'Linking project to its creator'),
    (146, 150, 'created_by', 'Linking project to its creator'),
    (147, 150, 'created_by', 'Linking project to its creator'),
    (165, 150, 'created_by', 'Linking project to its creator'),
    (166, 150, 'created_by', 'Linking project to its creator'),
    (131, 150, 'employs', 'Company employs Person'),
    (142, 150, 'employs', 'Company employs Person'),
    (153, 150, 'employs', 'Company employs Person'),
    (152, 128, 'documents', 'Technical Document related to Project'),
    (152, 130, 'documents', 'Technical Document related to Project'),
    (169, 128, 'visual_asset', 'Canvas linked to Creative Project'),
    (172, 130, 'visual_asset', 'Canvas linked to Creative Project'),
]

def insert_links(links):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    for from_id, to_id, relation_type, to_name in links:
        try:
            cursor.execute(
                "INSERT INTO relation (from_id, to_id, relation_type, to_name, context) VALUES (?, ?, ?, ?, ?)",
                (from_id, to_id, relation_type, to_name, 'Automated link insertion')
            )
            print(f"Inserted relation: {from_id} -> {to_id} ({relation_type})")
        except sqlite3.IntegrityError as e:
            print(f"Failed to insert relation ({from_id} -> {to_id}): {e}")

    conn.commit()
    conn.close()

if __name__ == "__main__":
    insert_links(potential_links)
