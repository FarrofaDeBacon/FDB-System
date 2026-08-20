-- Tabela principal de armazenamento dos assaltos (Grafos do Node Engine)
CREATE TABLE IF NOT EXISTS `illegal_heists` (
    `id` VARCHAR(64) PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `graph` LONGTEXT NOT NULL,
    `active` TINYINT(1) DEFAULT 1,
    `created_by` VARCHAR(64) NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Seed de teste usando as coordenadas seguras/isoladas (-300, 800) validadas na Fase 1
INSERT IGNORE INTO `illegal_heists` (`id`, `name`, `graph`) VALUES (
    'test_heist_isolated',
    'Assalto de Teste Isolado',
    '{
        "nodes": {
            "node_start": { "type": "start", "data": {} },
            "node_door": { 
                "type": "open_door", 
                "data": { 
                    "coords": {"x": -300.0, "y": 800.0, "z": 118.0}, 
                    "minTime": 5, 
                    "prompt": "Arrombar Porta" 
                } 
            },
            "node_register": { 
                "type": "crack_register", 
                "data": { 
                    "coords": {"x": -298.0, "y": 800.0, "z": 118.0}, 
                    "heading": 101.4, 
                    "minTime": 3, 
                    "reward": "money", 
                    "prompt": "Roubar Caixa" 
                } 
            }
        },
        "edges": [
            { "source": "node_start", "target": "node_door" },
            { "source": "node_door", "target": "node_register" }
        ]
    }'
);
