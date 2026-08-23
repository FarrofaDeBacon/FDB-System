# Regra: Deploy Obrigatório

Após **qualquer** alteração em arquivos do projeto `illegal-system` (ou qualquer recurso do servidor):

1. **Commitar no GitHub** com mensagem descritiva em português.
2. **Copiar os arquivos alterados** de `D:\BASE NOVA\` para `D:\SERVIDOR\server\resources\[framework]\`.

Nunca considerar uma tarefa como "concluída" sem ter feito ambos os passos.

## Caminhos

| Origem (dev) | Destino (servidor) |
|---|---|
| `D:\BASE NOVA\illegal-system\` | `D:\SERVIDOR\server\resources\[framework]\illegal-system\` |
| `D:\BASE NOVA\fdb-libs\` | `D:\SERVIDOR\server\resources\[framework]\fdb-libs\` |

## Comandos de Cópia Padrão

```powershell
# Lua (arquivo individual)
xcopy "D:\BASE NOVA\illegal-system\<caminho>\<arquivo>.lua" "D:\SERVIDOR\server\resources\[framework]\illegal-system\<caminho>\" /Y

# UI (após npm run build)
xcopy "D:\BASE NOVA\illegal-system\ui\dist\*" "D:\SERVIDOR\server\resources\[framework]\illegal-system\ui\dist\" /S /Y
```

## Commit Padrão

```powershell
cd "D:\BASE NOVA\illegal-system"
git add -A
git commit -m "<mensagem descritiva>"
git push
```
