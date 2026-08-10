const fs = require('fs');

function toLua(obj, indent = 0) {
    const pad = '  '.repeat(indent);
    if (obj === null || obj === undefined) return 'nil';
    if (typeof obj === 'boolean') return obj ? 'true' : 'false';
    if (typeof obj === 'number') return obj.toString();
    if (typeof obj === 'string') return '"' + obj.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n') + '"';
    
    if (Array.isArray(obj)) {
        if (obj.length === 0) return '{}';
        let str = '{\n';
        for (let i = 0; i < obj.length; i++) {
            str += pad + '  ' + toLua(obj[i], indent + 1) + ',\n';
        }
        str += pad + '}';
        return str;
    }
    
    if (typeof obj === 'object') {
        const keys = Object.keys(obj);
        if (keys.length === 0) return '{}';
        let str = '{\n';
        for (let k of keys) {
            let keyStr = '';
            if (k.match(/^[a-zA-Z_][a-zA-Z0-9_]*$/)) {
                keyStr = k;
            } else {
                keyStr = '["' + k.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"]';
            }
            str += pad + '  ' + keyStr + ' = ' + toLua(obj[k], indent + 1) + ',\n';
        }
        str += pad + '}';
        return str;
    }
    
    return 'nil';
}

function processFile(jsonPath, luaPath, varName) {
    console.log('Processing ' + jsonPath);
    try {
        const data = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
        const luaStr = varName + ' = ' + toLua(data) + '\n';
        fs.writeFileSync(luaPath, luaStr, 'utf8');
        console.log('Successfully wrote ' + luaPath);
    } catch (e) {
        console.error('Error processing ' + jsonPath + ':', e);
    }
}

processFile('D:\\BASE NOVA\\fdb-clothing\\shared\\albedo_data_dump.json', 'D:\\BASE NOVA\\fdb-clothing\\shared\\albedo_data.lua', 'AlbedoData');
processFile('D:\\BASE NOVA\\fdb-clothing\\shared\\componentsbody_dump.json', 'D:\\BASE NOVA\\fdb-clothing\\shared\\componentsbody.lua', 'ComponentsBody');
processFile('D:\\BASE NOVA\\fdb-clothing\\shared\\wearablestates_dump.json', 'D:\\BASE NOVA\\fdb-clothing\\shared\\wearablestates.lua', 'WearableStates');
