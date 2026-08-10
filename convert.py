import json
import sys
import re

def dict_to_lua(d, indent=1):
    lua_str = "{\n"
    for k, v in d.items():
        # Handle string keys
        key_str = f'["{k}"]' if isinstance(k, str) else f'[{k}]'
        
        if isinstance(v, dict):
            lua_str += "  " * indent + f"{key_str} = " + dict_to_lua(v, indent + 1) + ",\n"
        elif isinstance(v, list):
            lua_str += "  " * indent + f"{key_str} = " + list_to_lua(v, indent + 1) + ",\n"
        elif isinstance(v, str):
            v_escaped = v.replace('\"', '\\\"').replace('\n', '\\n')
            lua_str += "  " * indent + f'{key_str} = "{v_escaped}",\n'
        elif isinstance(v, bool):
            lua_str += "  " * indent + f"{key_str} = " + ("true" if v else "false") + ",\n"
        elif isinstance(v, (int, float)):
            lua_str += "  " * indent + f"{key_str} = {v},\n"
        elif v is None:
            lua_str += "  " * indent + f"{key_str} = nil,\n"
    lua_str += "  " * (indent - 1) + "}"
    return lua_str

def list_to_lua(lst, indent=1):
    lua_str = "{\n"
    for i, v in enumerate(lst):
        if isinstance(v, dict):
            lua_str += "  " * indent + dict_to_lua(v, indent + 1) + ",\n"
        elif isinstance(v, list):
            lua_str += "  " * indent + list_to_lua(v, indent + 1) + ",\n"
        elif isinstance(v, str):
            v_escaped = v.replace('\"', '\\\"').replace('\n', '\\n')
            lua_str += "  " * indent + f'"{v_escaped}",\n'
        elif isinstance(v, bool):
            lua_str += "  " * indent + ("true" if v else "false") + ",\n"
        elif isinstance(v, (int, float)):
            lua_str += "  " * indent + f"{v},\n"
        elif v is None:
            lua_str += "  " * indent + "nil,\n"
    lua_str += "  " * (indent - 1) + "}"
    return lua_str

def convert_file(filepath, var_name):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract json string from between [[ ]]
    match = re.search(r'local jsonData = \[\[(.*?)\]\]', content, re.DOTALL)
    if not match:
        return
    
    json_str = match.group(1)
    data = json.loads(json_str)
    
    lua_str = dict_to_lua(data) if isinstance(data, dict) else list_to_lua(data)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(f"{var_name} = {lua_str}\n")

try:
    convert_file(r'D:\BASE NOVA\fdb-clothing\shared\albedo_data.lua', 'AlbedoData')
    convert_file(r'D:\BASE NOVA\fdb-clothing\shared\wearablestates.lua', 'WearableStates')
    convert_file(r'D:\BASE NOVA\fdb-clothing\shared\componentsbody.lua', 'ComponentsBody')
    print("Conversion successful.")
except Exception as e:
    print("Error:", e)
