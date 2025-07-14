import os
import shutil
import sqlite3

# Paths
CURRENT_DIR = "/Users/mh/.local/share/basic-memory"  # <-- Update this path
TARGET_ROOT = "/Users/mh/.local/share/basic-memory"  # <-- Update this path
DB_PATH = "/Users/mh/.local/share/basic-memory/.basic-memory/memory.db"

# Mapping of keywords in filenames to target folders
folder_map = {
    "project": "Projects/Active",
    "completed": "Projects/Completed",
    "idea": "Ideas & Concepts",
    "concept": "Ideas & Concepts",
    "contact": "People/Contacts",
    "mentor": "People/Mentors",
    "article": "Resources/Articles",
    "book": "Resources/Books",
    "tool": "Resources/Tools",
    "meeting": "Notes/Meeting Notes",
    "research": "Notes/Research",
    "learning": "Notes/Learning",
    "script": "Scripts & Automation",
    "workflow": "Scripts & Automation",
    "archive": "Archive/Old Projects"
}

# Tags for each folder
folder_tags = {
    "Projects/Active": ["project", "active"],
    "Projects/Completed": ["project", "completed"],
    "Ideas & Concepts": ["idea", "concept"],
    "People/Contacts": ["contact"],
    "People/Mentors": ["mentor"],
    "Resources/Articles": ["article"],
    "Resources/Books": ["book"],
    "Resources/Tools": ["tool"],
    "Notes/Meeting Notes": ["meeting"],
    "Notes/Research": ["research"],
    "Notes/Learning": ["learning"],
    "Scripts & Automation": ["script", "automation"],
    "Archive/Old Projects": ["archive"]
}

def move_files():
                    for root, dirs, files in os.walk(CURRENT_DIR):
                        for filename in files:
                            src_path = os.path.join(root, filename)
                            target_subfolder = None
                            for key, folder in folder_map.items():
                                if key.lower() in filename.lower():
                                    target_subfolder = folder
                                    break
                            if target_subfolder:
                                target_dir = os.path.join(TARGET_ROOT, target_subfolder)
                                os.makedirs(target_dir, exist_ok=True)
                                target_path = os.path.join(target_dir, filename)
                                if os.path.exists(target_path):
                                    print(f"File {filename} already exists at destination. Skipping.")
                                else:
                                    shutil.move(src_path, target_dir)
                                    print(f"Moved {filename} to {target_dir}")

def add_tags():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    for folder, tags in folder_tags.items():
        # Assuming your notes have a 'tags' column
        cursor.execute(
            "UPDATE entity SET tags = (tags || ',') || ? WHERE folder = ?",
            (",".join(tags), folder)
        )
        print(f"Added tags {tags} to notes in {folder}")
    conn.commit()
    conn.close()

def main():
    print("Starting file organization...")
    move_files()
    print("Adding tags to notes in database...")
    add_tags()
    print("Process completed.")

if __name__ == "__main__":
    main()
