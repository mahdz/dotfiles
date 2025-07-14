import sqlite3

DB_PATH = "/Users/mh/.local/share/basic-memory/.basic-memory/memory.db"

# Define your entity type mapping
TYPE_MAPPING = {
    'Professional': ['Person', 'Journey', 'Network', 'Professional Achievement', 'Professional Journey'],
    'Project': ['Creative Project', 'Technical Project', 'Project'],
    'Knowledge': ['Note', 'Technical Document', 'Technical Documentation'],
    # Add more categories if needed
}

# Define relation types and descriptions
RELATION_TYPES = {
    'related_to': 'Related to',
    'created_by': 'Created by',
    'employs': 'Employs',
    'collaborated_with': 'Collaborated with',
    'mentored': 'Mentored',
    'inspired_by': 'Inspired by',
    'part_of': 'Part of',
    'related_to': 'Related to',
    'developed_by': 'Developed by',
    'references': 'References',
    'owns': 'Owns',
    'implemented_in': 'Implemented in',
    'documents': 'Documents',
    'visual_asset': 'Visual asset for'
}

def classify_entity(entity_type):
    for category, types in TYPE_MAPPING.items():
        if entity_type in types:
            return category
    return 'Uncategorized'

def fetch_entities():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT id, title, entity_type FROM entity")
    entities = [{'id': row[0], 'title': row[1], 'type': row[2]} for row in cursor.fetchall()]
    conn.close()
    return entities

def find_potential_links(entities):
    # Group entities by category
    category_groups = {}
    for e in entities:
        cat = classify_entity(e['type'])
        category_groups.setdefault(cat, []).append(e)

    links = []
    # For each category, link entities with others in the same category
    for cat, group in category_groups.items():
        for i in range(len(group)):
            for j in range(i + 1, len(group)):
                e1 = group[i]
                e2 = group[j]
                # Example relation: e1 related to e2
                links.append((e1['id'], e2['id'], 'related_to', f'{e1["title"]} related to {e2["title"]}'))
    return links

def insert_relations(links):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    for from_id, to_id, rel_type, to_name in links:
        try:
            cursor.execute(
                "INSERT INTO relation (from_id, to_id, relation_type, to_name, context) VALUES (?, ?, ?, ?, ?)",
                (from_id, to_id, rel_type, to_name, 'Automated relation insertion')
            )
            print(f"Inserted: {from_id} -> {to_id} ({rel_type})")
        except sqlite3.IntegrityError as e:
            print(f"Failed to insert relation ({from_id} -> {to_id}): {e}")
    conn.commit()
    conn.close()

def main():
    entities = fetch_entities()
    print(f"Fetched {len(entities)} entities.")
    # Classify and find links
    links = find_potential_links(entities)
    print(f"Identified {len(links)} potential links.")
    # Insert links
    insert_relations(links)
    print("Relation insertion complete.")

if __name__ == "__main__":
    main()
