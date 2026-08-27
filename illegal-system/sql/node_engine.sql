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

-- Seed de teste para o Roubo de Túmulo (Migração Fase 5)
-- ATENÇÃO: O assalto já está ATIVO (active=1), mas propositalmente restrito a 3 modelos para teste.
-- Após testar em jogo, adicione os 50+ modelos no editor para ir pra produção real.
REPLACE INTO `illegal_heists` (`id`, `name`, `graph`, `active`) VALUES (
    'grave_robbery_heist',
    'Roubo de Túmulo',
    '{
        "nodes": {
            "node_trigger": { 
                "type": "trigger_model", 
                "data": { 
                    "models": "p_gravestone01ax, p_gravestone01x, p_gravestone02x", 
                    "distance": 3.5, 
                    "prompt": "Saquear Túmulo" 
                } 
            },
            "node_check": { 
                "type": "check_requirements", 
                "data": { 
                    "item": "shovel", 
                    "amount": 1, 
                    "failMessage": "Você precisa de uma pá." 
                } 
            },
            "node_minigame": { 
                "type": "minigame_action", 
                "data": { 
                    "minigameType": "tierbar", 
                    "minigameDuration": 5000, 
                    "animDict": "amb_work@world_human_gravedig@working@male_b@base", 
                    "animName": "base", 
                    "propModel": "p_shovel02x", 
                    "failMessage": "Você foi interrompido!",
                    "attachOffsetX": 0.0,
                    "attachOffsetY": -0.19,
                    "attachOffsetZ": -0.089,
                    "attachRotX": 274.19,
                    "attachRotY": 483.89,
                    "attachRotZ": 378.40
                } 
            },
            "node_anim": {
                "type": "play_animation",
                "data": {
                    "animDict": "amb_misc@world_human_kneel@kneel@female_b@base",
                    "animName": "base",
                    "durationMs": 3000
                }
            },
            "node_spawn": { 
                "type": "spawn_prop", 
                "data": { 
                    "props": [
                        {
                            "model": "mp005_p_dirtpile_tall_unburied",
                            "coords": null,
                            "offsetForward": 0.6,
                            "offsetX": 0.0,
                            "offsetZ": -1.0,
                            "heading": 0
                        }
                    ]
                } 
            },
            "node_reward": { 
                "type": "crime_reward_and_cooldown", 
                "data": { 
                    "crimeType": "grave_robbery", 
                    "cooldownPrefix": "grave", 
                    "successMessage": "Você revirou o túmulo e encontrou algo!" 
                } 
            }
        },
        "edges": [
            { "source": "node_trigger", "target": "node_check" },
            { "source": "node_check", "target": "node_minigame" },
            { "source": "node_minigame", "target": "node_anim" },
            { "source": "node_anim", "target": "node_spawn" },
            { "source": "node_spawn", "target": "node_reward" }
        ]
    }',
    1
);
