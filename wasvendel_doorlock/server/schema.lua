local db = exports.oxmysql
local schemaReady = false

local function parseSqlStatements(sql)
    local statements = {}
    if not sql or sql == "" then return statements end
    sql = sql:gsub("\r\n", "\n"):gsub("\r", "\n")
    for statement in sql:gmatch("([^;]+);") do
        local trimmed = statement:match("^%s*(.-)%s*$")
        if trimmed and trimmed ~= "" and not trimmed:match("^%-%-") then
            statements[#statements + 1] = trimmed
        end
    end
    return statements
end

local function runSequential(statements, index, onReady)
    if index > #statements then
        schemaReady = true
        if onReady then onReady() end
        return
    end
    db:query(statements[index], {}, function()
        runSequential(statements, index + 1, onReady)
    end)
end

local function runSchema(onReady)
    local sql = LoadResourceFile(GetCurrentResourceName(), "wasvendel_doorlock.sql")
    local statements = parseSqlStatements(sql)
    if #statements == 0 then
        statements = {
            [[CREATE TABLE IF NOT EXISTS `wasvendel_doorlocks` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `name` VARCHAR(128) NOT NULL,
                `data` LONGTEXT NOT NULL,
                `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]],
        }
    end
    runSequential(statements, 1, onReady)
end

CreateThread(function()
    while GetResourceState("oxmysql") ~= "started" do Wait(100) end
    Wait(500)
    runSchema()
end)

function WVDL_SchemaReady()
    return schemaReady
end
