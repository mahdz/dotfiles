#!/bin/sh
# ------------------------------------------------------------------------------------------ #
# Initial Setup
# ------------------------------------------------------------------------------------------ #
# Two Primary Databases for contacts.
# 18A7BB2D-362B-407B-AB3F-22051F93A909
# 271E8A57-3285-40E2-A788-603CFE27DE87
# F2C7180A-7B8D-46B1-A4FB-D4622FBE9347

# Creating a folder to house starter and finisher assets.
mkdir db_assets
mkdir final_assets

# Startup Script
echo "Welcome to the contact/address book cleanser!"
echo "We will need to get some information first."
echo "There are three contact databases on this computer:"
echo "18A7BB2D-362B-407B-AB3F-22051F93A909"
echo "271E8A57-3285-40E2-A788-603CFE27DE87"
echo "F2C7180A-7B8D-46B1-A4FB-D4622FBE9347"
read -p "Enter the contact database you'd like to reference: "  db_to_use
echo "Thanks! Confirming we'll compare records against $db_to_use!"
# Copy chat.db & addressbook db to local folder.
cp ~/Library/Messages/chat.db db_assets/chat.db
cp ~/Library/Application\ Support/AddressBook/Sources/$db_to_use/AddressBook-v22.abcddb db_assets/AddressBook-v22.abcddb
# ------------------------------------------------------------------------------------------ #

# ------------------------------------------------------------------------------------------ #
# Get the complete chat.db table
echo "First, we'll print and save the chat table in a csv so you can keep it for your records."
sqlite3 db_assets/chat.db <<'END_SQL'
.headers on
.mode csv
.output "final_assets/chat-db-complete-table.csv"
select * from message;
.output stdout
END_SQL
echo "Done!"
echo "Saved final_assets/chat-db-complete-table.csv"
# ------------------------------------------------------------------------------------------ #

# ------------------------------------------------------------------------------------------ #
# Get a basic list of tele numbers from chat (without matching address reference).
sqlite3 db_assets/chat.db <<'END_SQL'
.headers on
.mode csv
.output "final_assets/SMS-contacts-basic-list.csv"
select date, id, text
from message
left join handle
on message.handle_id = handle.ROWID
END_SQL
echo "Done!"
echo "Saved final_assets/SMS-contacts-basic-list.csv"
# ------------------------------------------------------------------------------------------ #

# Match across the two databases and return a cleaned list of all the people I've texted from iMessage.
sqlite3 <<'END_SQL'
.timeout 2000
attach "db_assets/chat.db" as cdb;
attach "db_assets/AddressBook-v22.abcddb" as adb;
.headers on
.mode csv
.output "final_assets/Mapped-text-to-contacts-Full-List.csv"
select date, id, ZFIRSTNAME || ' ' || ZLASTNAME, text
from cdb.message
left join cdb.handle
on message.handle_id = handle.ROWID
left join adb.ZABCDPHONENUMBER
on replace(substr(handle.id, 1), ' ', '')
like '%' || substr(replace(ZABCDPHONENUMBER.ZFULLNUMBER, ' ', ''), 1)
left join adb.ZABCDRECORD
on ZABCDPHONENUMBER.ZOWNER = ZABCDRECORD.Z_PK;
.output stdout
END_SQL
echo "Done!"
echo "Saved final_assets/Mapped-text-to-contacts-Full-List.csv"
# ------------------------------------------------------------------------------------------ #
# Cleaning Up
echo "Cleaning up db and other files..."
rm -rf db_assets
mv final_assets ~/Desktop/final_assets
echo "Done!"
echo "This script is complete. You can close now."
# ------------------------------------------------------------------------------------------ #