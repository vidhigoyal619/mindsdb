import bson

def is_true(val):
    # Converts val to a boolean and checks if it is True
    return bool(val) is True

def is_false(val):
    # Converts val to a boolean and checks if it is False
    return bool(val) is False

def int_to_objectid(n):
    # Convert the integer to a string
    s = str(n)
    # Pad the string with leading zeros to make it 24 characters long
    s = '0' * (24 - len(s)) + s
    # Convert the padded string to a MongoDB ObjectId
    return bson.ObjectId(s)

def objectid_to_int(obj):
    # Convert the ObjectId to a string and then to an integer
    return int(str(obj))
