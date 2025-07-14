import sqlite3

DB_PATH = "/Users/mh/.local/share/basic-memory/.basic-memory/memory.db"

def fetch_entities():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT id, title, entity_type FROM entity")
    entities = cursor.fetchall()
    conn.close()
    return entities

def display_entities(entities):
    print("Available Entities:")
    for idx, (entity_id, title, entity_type) in enumerate(entities):
        print(f"{idx}: ID {entity_id} | {title} ({entity_type})")
    print()

def select_entity(prompt, entities):
    while True:
        try:
            choice = int(input(prompt))
            if 0 <= choice < len(entities):
                return entities[choice]
            else:
                print("Invalid choice. Try again.")
        except ValueError:
            print("Please enter a valid number.")

def main():
    entities = fetch_entities()
    display_entities(entities)

    print("Select the first entity for the link:")
    entity1 = select_entity("Enter number: ", entities)

    print("Select the second entity for the link:")
    entity2 = select_entity("Enter number: ", entities)

    relation_type = input("Enter relation type (e.g., 'related_to', 'created_by'): ")
    to_name = input("Enter relation description (to_name): ")

    # Insert the relation
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO relation (from_id, to_id, relation_type, to_name, context) VALUES (?, ?, ?, ?, ?)",
            (entity1[0], entity2[0], relation_type, to_name, 'Interactive link creation')
        )
        print(f"Relation inserted: {entity1[1]} -> {entity2[1]} ({relation_type})")
    except sqlite3.IntegrityError as e:
        print(f"Error inserting relation: {e}")
    conn.commit()
    conn.close()

if __name__ == "__main__":
    main()
