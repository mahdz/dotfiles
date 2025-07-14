import sqlite3

DB_PATH = "/Users/mh/.local/share/basic-memory/.basic-memory/memory.db"

def classify_entities():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Fetch entities
    cursor.execute("SELECT id, entity_type FROM entity")
    entities = [{'id': row[0], 'type': row[1]} for row in cursor.fetchall()]

    # Define type mapping based on your schema
    type_mapping = {
        'Professional': ['Person', 'Journey', 'Network'],
        'Project': ['Creative Project', 'Technical Project'],
        'Knowledge': ['Note', 'Technical Document']
    }

    # Classify entities
    for entity in entities:
        entity_type = entity['type']
        category = 'Uncategorized'
        for cat, types in type_mapping.items():
            if entity_type in types:
                category = cat
                break
        print(f"Entity ID {entity['id']} of type '{entity_type}' classified as '{category}'.")

    # Find potential links based on shared categories
    for i, entity in enumerate(entities):
        for j, other in enumerate(entities):
            if i != j and entity.get('category') == other.get('category'):
                print(f"Potential link: Entity {entity['id']} <-> Entity {other['id']} (Category: {entity.get('category')})")

    conn.close()

if __name__ == "__main__":
    classify_entities()
