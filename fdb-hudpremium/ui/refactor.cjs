const fs = require('fs');
const path = 'D:/STEEL/Server/resources/[framework]/fdb-hudpremium/ui/src/components/StatusCores.svelte';
let code = fs.readFileSync(path, 'utf-8');

code = code.replace(/<DraggableModule id="[^"]+">\s*<div class="([^"]+)">/g, '<div class="$1">');
code = code.replace(/<\/div>\s*<\/DraggableModule>/g, '</div>');

code = code.replace(/(<HUDItem[^>]+itemId="([^"]+)"[\s\S]*?\/>)/g, '<DraggableModule id="$2">\n            \n        </DraggableModule>');

fs.writeFileSync(path, code);
console.log('StatusCores refactored!');
