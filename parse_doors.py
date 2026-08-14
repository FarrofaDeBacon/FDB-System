import re, json

with open(r'D:\DUST-RP\DUST-RP\server-data\resources\rsd_doorlock\config.lua', 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

doors_match = re.search(r'Config\.Doors\s*=\s*\{(.*)', content, re.MULTILINE | re.DOTALL)
if not doors_match: exit()
doors_str = doors_match.group(1)

# We will split by lines to track the headers
lines = doors_str.split('\n')
door_blocks = []
brace_level = 0
current_block = ""
current_category = "Door"
current_subcategory = ""

for line in lines:
    # Check for header comments like --SHERIFF-- or --BANK or ---- taxidermiste
    header_match = re.match(r'^(\s*)-+\s*([a-zA-Z0-9\s]+)-*\s*$', line)
    if header_match:
        indent = len(header_match.group(1).replace('\t', '    '))
        text = header_match.group(2).strip().upper()
        if text == "NE RIEN RAJOUTER EN PREMIER":
            continue
            
        if brace_level == 0 and text:
            if indent <= 4:
                current_category = text
                current_subcategory = ""
            else:
                current_subcategory = text
    
    for char in line:
        if char == '{':
            if brace_level > 0: current_block += char
            brace_level += 1
        elif char == '}':
            brace_level -= 1
            if brace_level == 0:
                # Store block with its current context
                door_blocks.append({
                    "block": current_block,
                    "category": current_category,
                    "subcategory": current_subcategory
                })
                current_block = ""
            else:
                current_block += char
        elif brace_level > 0:
            current_block += char
            
    if brace_level > 0:
        current_block += '\n'

sql_inserts = []

def extract_vec3(text, key):
    m = re.search(key + r'\s*=\s*vector3\(([^,]+),\s*([^,]+),\s*([^)]+)\)', text)
    if m:
        return float(m.group(1)), float(m.group(2)), float(m.group(3))
    return None

def extract_val(text, key, is_string=False):
    if is_string:
        m = re.search(key + r'\s*=\s*[\'"]([^\'"]+)[\'"]', text)
        return m.group(1) if m else None
    else:
        m = re.search(key + r'\s*=\s*([^,\n]+)', text)
        return m.group(1).strip() if m else None

def extract_list(text, key):
    m = re.search(key + r'\s*=\s*\{([^}]+)\}', text)
    if not m: return []
    items = m.group(1).split(',')
    res = []
    for i in items:
        clean = i.strip().strip('"').strip("'")
        if clean: res.append(clean)
    return res

door_count = 1
for item in door_blocks:
    block = item["block"]
    
    hash1_str = extract_val(block, 'door')
    if not hash1_str: continue
    
    # Check if there is an inline comment on the door = line
    door_line_comment = ""
    comment_match = re.search(r'door\s*=\s*[^,]+,\s*-+\s*(.+)', block)
    if comment_match:
        door_line_comment = comment_match.group(1).strip()
    
    try:
        hash1 = int(re.search(r'^\d+', hash1_str).group(0) if re.search(r'^\d+', hash1_str) else hash1_str)
    except:
        continue
    
    hash2_str = extract_val(block, 'door2')
    hash2 = int(hash2_str) if hash2_str and hash2_str.lower() != 'nil' else 0
    
    locked_str = extract_val(block, 'locked')
    locked = True if locked_str == 'true' else False
    
    jobs = extract_list(block, 'jobs')
    jobs = [j for j in jobs if j != '']
    
    open_coord = extract_vec3(block, 'OpenCoord')
    door_coord = extract_vec3(block, 'DoorCoord')
    door_coord2 = extract_vec3(block, 'DoorCoord2')
    
    prompt_coord = open_coord or door_coord or (0,0,0)
    
    panels = []
    p1 = {
        'hash': hash1,
        'x': door_coord[0] if door_coord else prompt_coord[0],
        'y': door_coord[1] if door_coord else prompt_coord[1],
        'z': door_coord[2] if door_coord else prompt_coord[2],
        'heading': 0.0
    }
    panels.append(p1)
    
    if hash2 != 0:
        p2 = {
            'hash': hash2,
            'x': door_coord2[0] if door_coord2 else prompt_coord[0],
            'y': door_coord2[1] if door_coord2 else prompt_coord[1],
            'z': door_coord2[2] if door_coord2 else prompt_coord[2],
            'heading': 0.0
        }
        panels.append(p2)
        
    # Translate French words to Portuguese
    translations = {
        "Banque": "Banco",
        "Bank": "Banco",
        "Sheriff": "Delegacia",
        "Poste": "Delegacia",
        "Grille": "Grade",
        "Dynamite": "Dinamite",
        "Door Hash": "Porta",
        "Ecurie": "Estabulo",
        "Alambic": "Alambique",
        "Disitllerie": "Destilaria",
        "Tabac": "Tabaco",
        "Taxidermiste": "Taxidermista",
        "Appart": "Apartamento",
        "Chinois": "Chines",
        "Baraque": "Cabana",
        "Contrebande": "Contrabando",
        "Opium": "Opio",
        "Mine": "Mina",
        "Ferme": "Fazenda",
        "Armurier": "Armeiro",
        "Gunsmith": "Armeiro",
        "Presse": "Jornal",
        "Doctor": "Medico",
        "Forge": "Forja",
        "General Store": "Mercado",
        "Store": "Mercado",
        "Jail": "Prisao",
    }
    
    cat = item['category'].title()
    if cat == "Door" or not cat:
        # Fallback to job-based categories if the developer forgot to put a header
        cmt = door_line_comment.lower()
        if "banque" in cmt or "bank" in cmt or "banco" in cmt: cat = 'Banco'
        elif "poste" in cmt or "delegacia" in cmt: cat = 'Delegacia'
        elif any('sheriff' in j.lower() for j in jobs): cat = 'Sheriff'
        elif any('doctor' in j.lower() for j in jobs): cat = 'Doctor'
        elif any('saloon' in j.lower() for j in jobs): cat = 'Saloon'
    
    for fr, pt in translations.items():
        pattern = re.compile(re.escape(fr), re.IGNORECASE)
        cat = pattern.sub(pt, cat)
    
    # Construct name
    final_name = f"{item['category'].title()} {item['subcategory'].title()}".strip()
    if door_line_comment:
        final_name = door_line_comment.title()
        
    for fr, pt in translations.items():
        # Case insensitive replace but keeping title case
        pattern = re.compile(re.escape(fr), re.IGNORECASE)
        final_name = pattern.sub(pt, final_name)
    
    # Prettier names: "Banco Rhodes" -> "Banco de Rhodes"
    if final_name.startswith("Banco ") and not final_name.startswith("Banco de "):
        final_name = final_name.replace("Banco ", "Banco de ", 1)
    elif final_name.startswith("Delegacia ") and not final_name.startswith("Delegacia de "):
        final_name = final_name.replace("Delegacia ", "Delegacia de ", 1)
    elif final_name.startswith("Sheriff "):
        final_name = final_name.replace("Sheriff ", "Delegacia de ", 1)
    elif final_name.startswith("Estábulo ") and not final_name.startswith("Estábulo de "):
        final_name = final_name.replace("Estábulo ", "Estábulo de ", 1)
        
    if not final_name or final_name == "Door":
        final_name = f"{cat} Door {door_count}"
        
    data = {
        'name': final_name,
        'category': cat,
        'locked': locked,
        'lockedOnStart': locked,
        'showPrompt': True,
        'show3d': False,
        'canLockpick': True,
        'lockpickItem': 'lockpick',
        'accessItem': False,
        'jobAccess': jobs,
        'charAccess': [],
        'closedRatio': 0.0,
        'promptRadius': 2.5,
        'prompt': { 'x': prompt_coord[0], 'y': prompt_coord[1], 'z': prompt_coord[2] },
        'double': len(panels) > 1,
        'panels': panels
    }
    
    json_str = json.dumps(data, ensure_ascii=False)
    
    # Escape single quotes for SQL
    json_str = json_str.replace("'", "''")
    sql = f"INSERT INTO `wasvendel_doorlocks` (`name`, `data`) VALUES ('{data['name']}', '{json_str}');"
    sql_inserts.append(sql)
    door_count += 1

out_file = r'D:\BASE NOVA\import_rsd_doorlocks.sql'
with open(out_file, 'w', encoding='utf-8') as out:
    for sql in sql_inserts:
        out.write(sql + '\n')

print(f"Wrote {len(sql_inserts)} inserts to {out_file}")
