import shutil
import subprocess
import json
import sys
import csv
import re
import os
from pathlib import Path

# The directories that the script makes sure exist before starting the migration
# These folders are meant for debugging, checking the progress of the script and seeing errors
# that occurred during the migration. They are cleared every time the script runs and they are all
# in the .gitignore
FOLDERS = ["debug", "destinationorg", "destinationorg/data", "destinationorg/describe", "errors", 
            "sourceorg", "sourceorg/data", "sourceorg/describe"]

# These keywords are used to skip any objects that contain these words (object to lower case .contains)
BANNED_KEYWORDS = ["apex", "profile", "user", "permission", "prompt", "flow", "queue", 
                    "recentlyviewed", "setup", "suite", "assignment"]
# The regex pattern used to match the object name to be skipped or not
BANNED_PATTERN = f'{"|".join(BANNED_KEYWORDS)}'

SOURCE_ORG = ""
DESTINATION_ORG = ""

# The list of object names to be migrated
OBJECT_LIST = []

# A dictionary containing all the objects and there fields with their metadata
# Example: 
# {
#   Account: {
#       Name: {
#           type: "Text",
#           createable: True
#       }
#   }
# }
OBJECTS_DICT = dict({})

# Dictionaries containing all the objects and their records in the SOURCE/DESTINATION Org respectively
# Example: 
# {
#   Account: {
#       "SOME_ID": {
#           Name: "Account"
#       }
#   }
# }
RECORDS_DICT = dict({})
NEW_RECORDS_DICT = dict({})

# A list of object names that are migrated
INSERTED_OBJECTS = []

# A Dictionary that maps old IDs (IDs from source org) to new IDs (IDs of the same record in the destination org)
OLD_IDS_TO_NEW_IDS = dict({})

# A Dictionary that maps a serialized (stringified) version of the record values to its ID in the source org
VALUES_TO_OLD_IDS = dict({})

# Used for printing the progress bar
LAST_PRINTED_LINE = ""

def red_text(text):
    red_color = "\033[1;31m"
    reset_color = "\033[0m"
    return f"{red_color}{text}{reset_color}"

def green_text(text):
    green_color = "\033[1;32m"
    reset_color = "\033[0m"
    return f"{green_color}{text}{reset_color}"

def yellow_text(text):
    yellow_color = "\033[1;33m"
    reset_color = "\033[0m"
    return f"{yellow_color}{text}{reset_color}"

# Clear the files inside a given directory
def delete_files_in_directory(directory_path):
    try:
        files = os.listdir(directory_path)
        for file in files:
            file_path = os.path.join(directory_path, file)
            if os.path.isfile(file_path):
                os.remove(file_path)
        print(f"All files deleted successfully from {directory_path}.")
    except OSError:
        print(f"Error occurred while deleting files from {directory_path}.")

# Make sure a given directory exists, if not create it
def ensure_directory_exists(directory_path):
    path = Path(directory_path)
    if not path.exists():
        path.mkdir(parents=True, exist_ok=True)

# Make sure directories are ready before running the script
def organize_folders():
    # Ensure directories exist
    for folder_path in FOLDERS:
        ensure_directory_exists(folder_path)
    
    # Delete files in directories
    for folder_path in FOLDERS:
        delete_files_in_directory(folder_path)

def log_error_in_file(error, file_name):
    with open(f"errors/{file_name}.txt", 'a') as f:
        f.write(error + "\n")

def log_debug_in_file(content, file_name):
    with open(f"debug/{file_name}.json", 'w') as f:
        f.write(content + "\n")

# Used to print the progress bar
def clear_lines(n):
    for _ in range(n):
        print("\033[F\033[K", end='')

# Used to print the progress bar
def print_progress_bar(iteration, total, prefix = '', suffix = ''):
    global LAST_PRINTED_LINE
    terminal_width = shutil.get_terminal_size().columns
    number_of_lines_to_clear = (len(LAST_PRINTED_LINE) // terminal_width)
    clear_lines(number_of_lines_to_clear)

    length = 50
    fill = '█'
    decimals = 1
    percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
    filledLength = int(length * iteration // total)
    bar = fill * filledLength + '-' * (length - filledLength)
    LAST_PRINTED_LINE = f"{prefix} |{bar} {percent}%| {suffix}"
    print(LAST_PRINTED_LINE)

# Runs a given command
def run_command(command):
    try:
        command_output = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, shell=True)
        return command_output
    except:
        return None

# Converts an array to map with the key and value defined by the "key_name" and "value_name" attributes
# if no "value_name" was specified, the value field of the given dict entry will be the object itself
def array_to_map(arr, key_name, value_name=None):
    ids_map = dict({})
    for item in arr:
        ids_map[item.get(key_name)] = (item.get(value_name) if value_name else item)
    return ids_map

# Check if a given field contains a value in any of the given records
def has_value_in_records_array(field_name, records_array):
    for record in records_array:
        if record.get(field_name):
            return True
    return False

# A function used to formulate the key to use in the VALUES_TO_OLD_IDS dict
def formulate_key(obj, object_name, isOld):
    key_arr = []
    for field in OBJECTS_DICT.get(object_name).keys():
        field_value = obj.get(field)
        # Make sure the field if valid and is "filterable" (meaning it can be used in a SOQL query)
        if(
            field_value == "" 
            or field_value is None 
            or not OBJECTS_DICT.get(object_name).get(field).get("filterable")
        ):
            continue
        # Special Case: If the field type is reference (relationship), we use the OLD_IDS_TO_NEW_IDS 
        # to get the new ID of the referenced record
        if(OBJECTS_DICT.get(object_name).get(field).get("type") == "reference" and isOld):
            new_id = OLD_IDS_TO_NEW_IDS.get(field_value)
            if new_id:
                key_arr.append(f"{field}='{new_id}'")
            continue
        if(OBJECTS_DICT.get(object_name).get(field).get("type") == "datetime"):
            key_arr.append(f"{field}='{field_value.split('.')[0]}'")
            continue
        try:
            if isinstance(field_value, bool):
                key_arr.append(f"{field}='{field_value}'")
            else:
                key_arr.append(f"{field}='{float(field_value)}'")
        except:
            key_arr.append(f"{field}='{field_value}'")
    return " ".join(key_arr).lower()

# Formulate the query used to find records in the source org
def formulate_query(object_name):
    query_arr = []
    for field in OBJECTS_DICT.get(object_name).keys():
        if not OBJECTS_DICT.get(object_name).get(field).get("filterable"):
            continue
        query_arr.append(field)
    return f"SELECT Id, {', '.join(query_arr)} FROM {object_name}"

# Check if a given record is found inside an array of records
def get_record_from_array(records_arr, obj):
    for record in records_arr:
        match = True
        for field in record.keys():
            if field == "Id":
                continue
            if record.get(field) != obj.get(field):
                match = False
                break
        if match:
            return record
    return None

# Used to insert a bulk of records at once
def insert_or_get_records(object_name, record_id = None):
    # Use upsert bulk command to upsert the data into the destination org using a CSV file
    bulk_upsert_result = run_command(f'sf data upsert bulk --sobject {object_name} --file destinationorg/data/{object_name}.csv --external-id Id --target-org {DESTINATION_ORG} --json --wait 30')
    if not bulk_upsert_result:
        return
    bulk_upsert_result_json = json.loads(bulk_upsert_result.stdout)
    if(not bulk_upsert_result_json.get("result")
        or not bulk_upsert_result_json.get("result").get("records")):
        return
    successfulResults = bulk_upsert_result_json.get("result").get("records").get("successfulResults")
    failedResults = bulk_upsert_result_json.get("result").get("records").get("failedResults")
    for result in successfulResults:
        old_id = record_id if record_id else VALUES_TO_OLD_IDS.get(formulate_key(result, object_name, False))
        # Update the OLD_IDS_TO_NEW_IDS to including the mapping of old to new ID of this record
        if old_id:
            OLD_IDS_TO_NEW_IDS[old_id] = result.get("sf__Id")

    for result in failedResults:
        destination_records = NEW_RECORDS_DICT.get(object_name)
        if not destination_records:
            return
        
        # Get the record that matches the same values of the result from the destination_records 
        destination_record = get_record_from_array(destination_records, result)
        if not destination_record:
            continue
        
        # Update the OLD_IDS_TO_NEW_IDS to including the mapping of old to new ID of this record
        old_id = record_id if record_id else VALUES_TO_OLD_IDS.get(formulate_key(result, object_name, False))
        if old_id:
            OLD_IDS_TO_NEW_IDS[old_id] = destination_record.get("Id")

# Used to insert a single record, this is needed to handle the case where a record has
# a "hierarchy" relationship field (a field that references a record of the same SObject)
# like a Case that references another Case
def insert_one_record(object_name, record_id):
    record = RECORDS_DICT.get(object_name).get(record_id)
    fields = OBJECTS_DICT.get(object_name).values()

    if not record or not fields:
        return
    
    field_row = []
    values_to_insert = []
    for field in fields:
        field_name = field.get("name")
        if field_name == "Name" and record.get(field_name) and record.get(field_name) in record.get("Id"):
            continue
        field_row.append(field_name)
        if field.get("type") != "reference":
            values_to_insert.append(record.get(field_name))
            continue
        if object_name in field.get("referenceTo") and record.get(field_name) and not OLD_IDS_TO_NEW_IDS.get(record.get(field_name)):
            insert_one_record(object_name, record.get(field_name))
        new_id = OLD_IDS_TO_NEW_IDS.get(record.get(field_name))
        if new_id or not record.get(field_name):
            values_to_insert.append(new_id)
        
    with open(f'destinationorg/data/{object_name}.csv', 'w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file, dialect='unix')
        writer.writerow(field_row)
        writer.writerow(values_to_insert)
        file.close()
    insert_or_get_records(object_name, record_id)

def insert_records(object_name):
    if object_name in INSERTED_OBJECTS:
        return

    references = set(())
    fields = OBJECTS_DICT.get(object_name)
    if not fields:
        INSERTED_OBJECTS.append(object_name)
        return
    
    # Query the records that already exist in the destination org
    query_records_query = formulate_query(object_name)
    query_records_result = run_command(f'sf data query --query "{query_records_query}" --target-org {DESTINATION_ORG} --bulk --json --wait 5')
    if query_records_result:
        query_records_result_json = json.loads(query_records_result.stdout)
        if query_records_result_json.get("status") == 0:
            NEW_RECORDS_DICT[object_name] = query_records_result_json.get("result").get("records")

    field_row = []
    for field in fields.keys():
        field_row.append(field)
        # If the field is a reference, then we need to make sure these references are inserted first
        if (
            fields.get(field).get("type") == "reference" 
            and has_value_in_records_array(field, RECORDS_DICT.get(object_name).values())
        ):
            references = references.union(set(fields.get(field).get("referenceTo")))
            
    for reference in references:
        # If the reference wasn't migrated before, then we need to insert its records first (recursion)
        if reference != object_name and reference not in INSERTED_OBJECTS:
            insert_records(reference)

    record_rows = {}
    for record in RECORDS_DICT.get(object_name).values():
        record_row = []
        if OLD_IDS_TO_NEW_IDS.get(record.get("Id")):
            continue
        for field in fields.keys():
            # If the field is a Name field and is configured to look like the ID
            if field == "Name" and record.get(field) and record.get(field) in record.get("Id"):
                continue
            if fields.get(field).get("type") != "reference":
                record_row.append(record.get(field))
                continue
            # If the field is a reference to the same SObject, insert it separately first then continue
            if object_name in fields.get(field).get("referenceTo") and record.get(field):
                insert_one_record(object_name, record.get(field))
            # Change the ID in this field to be the new ID of the record in the destination org
            new_id = OLD_IDS_TO_NEW_IDS.get(record.get(field))
            record_row.append(new_id)
        
        values_key = formulate_key(record, object_name, True)
        already_existing_record_id = VALUES_TO_OLD_IDS.get(values_key)
        # If exists in the VALUES_TO_OLD_IDS but wasn't yet inserted, insert it separately
        if already_existing_record_id and not OLD_IDS_TO_NEW_IDS.get(already_existing_record_id):
            insert_one_record(object_name, already_existing_record_id)
            record_rows.pop(already_existing_record_id)

        VALUES_TO_OLD_IDS[values_key] = record.get("Id")
        record_rows[record.get("Id")] = record_row
    
    # Write the CSV file of the records to be inserted in the destination org
    with open(f'destinationorg/data/{object_name}.csv', 'w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file, dialect='unix')
        writer.writerow(field_row)
        writer.writerows(record_rows.values())
        file.close()

    if len(record_rows.values()) > 0:
        insert_or_get_records(object_name)
        
    INSERTED_OBJECTS.append(object_name)
    
    num_of_inserted_objects = len(INSERTED_OBJECTS)
    print_progress_bar(num_of_inserted_objects + 1, NUM_OF_OBJECTS, f"Migrating data to {green_text(DESTINATION_ORG)}", f"{object_name} {num_of_inserted_objects + 1}/{NUM_OF_OBJECTS}")

    try:
        log_debug_in_file(json.dumps(OLD_IDS_TO_NEW_IDS, indent=4), "OLD_IDS_TO_NEW_IDS")
        log_debug_in_file(json.dumps(VALUES_TO_OLD_IDS, indent=4), "VALUES_TO_OLD_IDS")
    except:
        pass
    
os.chdir("migration")
organize_folders()

if len(sys.argv) > 2:
    SOURCE_ORG = sys.argv[1]
    DESTINATION_ORG = sys.argv[2]

    print(f"Source Org: {yellow_text(SOURCE_ORG)}")
    print(f"Destination Org: {green_text(DESTINATION_ORG)}")
else:
    print(red_text("Please provide the org to get the data from and the org to add the data to!"))
    print(red_text('Example command "python3 ./migration/MigrateData.py sourceorg@username.com destinationorg@username.com"'))
    sys.exit()

print(f"Getting data from {yellow_text(SOURCE_ORG)} and {green_text(DESTINATION_ORG)} 🚀")

# Get the list of SObjects in the source org
result = run_command(f'sf sobject list --target-org {SOURCE_ORG} --json')
if not result:
    print(red_text("Failed to get SObject List => " + str(result)))
    sys.exit()
result_json = json.loads(result.stdout)
if(result_json.get('status') != 0):
    print(red_text("Failed to get SObject List => " + json.dumps(result_json, indent=4)))
    sys.exit()

OBJECT_LIST = result_json.get('result')
# Filter the list to only the objects that should be migrated
OBJECT_LIST = [
    object_name
    for object_name in OBJECT_LIST
    if not re.search(BANNED_PATTERN, object_name.lower())
]
NUM_OF_OBJECTS = len(OBJECT_LIST)

print()
for i, object_name in enumerate(OBJECT_LIST):
    print_progress_bar(i + 1, NUM_OF_OBJECTS, f"Fetching describe from {yellow_text(SOURCE_ORG)}", f"{object_name} {i + 1}/{NUM_OF_OBJECTS}")

    # Get the describe for each object
    # The describe is the metadata of the object, this includes whether the object is createable, 
    # the fields and relationships in this record and their metadata
    source_object_describe_command = run_command(f'sf sobject describe --target-org {SOURCE_ORG} --sobject {object_name} --json >> sourceorg/describe/{object_name}.txt')
    if not source_object_describe_command:
        log_error_in_file(f"Source Org: Failed to execute {object_name} describe => {str(source_object_describe_command)}", "fetch")
        continue 
    fields = []
    try:
        # Save the describe into a file to make it traceable and make debugging easier
        object_describe_file = open(f"sourceorg/describe/{object_name}.txt", "r")
        object_describe = object_describe_file.read()
        object_describe_file.close()

        object_describe_json = json.loads(object_describe)

        if object_describe_json.get('status') != 0 or not object_describe_json.get('result').get('queryable'):
            log_error_in_file(f"Source Org: Failed to get {object_name} Describe or it is not queryable", "fetch")
            continue
        
        fields = object_describe_json.get('result').get('fields')
        if not fields:
            log_error_in_file(f"Source Org: No fields found for {object_name}", "fetch")
            continue
    except Exception as e:
        log_error_in_file(f"Source Org: Unexpected error occurred for {object_name} => {str(e)}", "fetch")
        continue
    
    print_progress_bar(i + 1, NUM_OF_OBJECTS, f"Fetching describe from {green_text(DESTINATION_ORG)}", f"{object_name} {i + 1}/{NUM_OF_OBJECTS}")
    
    # Get the object describe from the destination org (this is to make sure to only migrate the fields 
    # that exist in both orgs)
    destination_object_describe_command = run_command(f'sf sobject describe --target-org {DESTINATION_ORG} --sobject {object_name} --json >> destinationorg/describe/{object_name}.txt')
    if not destination_object_describe_command:
        log_error_in_file(f"Destination Org: Failed to execute {object_name} describe => {str(destination_object_describe_command)}", "fetch")
        continue
    new_fields = []
    try:
        # Save the describe into a file
        new_object_describe_file = open(f"destinationorg/describe/{object_name}.txt", "r")
        new_object_describe = new_object_describe_file.read()
        new_object_describe_file.close()

        new_object_describe_json = json.loads(new_object_describe)

        if new_object_describe_json.get('status') != 0 or not new_object_describe_json.get('result').get('queryable'):
            log_error_in_file(f"Destination Org: Failed to get {object_name} describe => {json.dumps(new_object_describe_json, indent=4)}", "fetch")
            continue

        new_fields = new_object_describe_json.get('result').get('fields')
        if not new_fields:
            log_error_in_file(f"Destination Org: No fields found for {object_name}", "fetch")
            continue
    except Exception as e:
        log_error_in_file(f"Destination Org: Unexpected error occurred for {object_name} => {str(e)}", "fetch")
        continue
    
    # Filter the fields to be valid for migration
    fields = [
        {
            "name": field.get("name"), 
            "type": field.get("type"), 
            "referenceTo": field.get("referenceTo"), 
            "filterable": field.get("filterable")
        }
        for field in fields
        if field.get("createable", False) 
            and field.get("name") != "OwnerId"
            and field in new_fields
    ]

    if len(fields) == 0:
        log_error_in_file(f"No fields to migrate for {object_name}", "fetch")
        continue

    field_names = [
        field["name"]
        for field in fields
    ]

    print_progress_bar(i + 1, NUM_OF_OBJECTS, f"Fetching data from {yellow_text(SOURCE_ORG)}", f"{object_name} {i + 1}/{NUM_OF_OBJECTS}")
    
    # Get the records from the source org and save them into the corresponding file
    object_records_command = run_command(f'sf data query --query "SELECT Id,{",".join(field_names)} FROM {object_name}" --target-org {SOURCE_ORG} --json >> sourceorg/data/{object_name}.txt')
    if not object_records_command:
        log_error_in_file(f"Source Org: Failed to execute {object_name} query => {str(object_records_command)}", "fetch")
        continue

    # Load the source org records from the file we saved the data into
    f = open(f"sourceorg/data/{object_name}.txt", "r")
    object_records = f.read()
    f.close()
    object_records_json = json.loads(object_records)

    if(object_records_json.get('status') != 0 or len(object_records_json.get("result").get("records")) == 0):
        log_error_in_file(f"Source Org: Failed to get {object_name} data or records are empty => {str(object_records_json)}", "fetch")
        continue

    OBJECTS_DICT[object_name] = array_to_map(fields, "name")
    RECORDS_DICT[object_name] = array_to_map(object_records_json.get("result").get("records"), "Id")

print(green_text("✅ Fetching data completed"))

try:
    log_debug_in_file(json.dumps(OBJECTS_DICT, indent=4), "OBJECTS_DICT")
    log_debug_in_file(json.dumps(RECORDS_DICT, indent=4), "RECORDS_DICT")
except:
    pass

print(yellow_text("Starting data migration to destination org 🚀"))
print()

# Insert the records for each object
for object_name in OBJECTS_DICT.keys():
    insert_records(object_name)

print(green_text("✅ Migration completed, check the folders inside the migration folder to see the details"))
