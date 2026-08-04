import os
import subprocess

for item in os.listdir('.'):
    if os.path.isdir(item) and item.startswith('rsg-'):
        new_name = item.replace('rsg-', 'fdb-', 1)
        print(f"Renaming {item} to {new_name}")
        subprocess.run(['git', 'mv', item, new_name])
