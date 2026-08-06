Config = {}

Config.ActiveTheme = "western_gold" -- opções: "western_gold", "dark_coal", "blood_red", "custom"
Config.Debug = true -- Habilita logs de rastreamento no F8 console do cliente

Config.ThemePresets = {
    western_gold = {
        fontBody = "'RDR Lino Regular', 'Roboto Condensed', serif",
        fontDisplay = "'RDR Lino Regular', 'Playfair Display', serif",
        textPrimary = '#d4c5b0',
        textSecondary = '#a89878',
        textOnPaper = '#2b1d14',
        accentColor = '#c9a15a',
        accentColorDark = '#8a6a35',
        backgroundColor = 'rgba(10, 10, 10, 0.88)',
        backgroundPaper = '#d8c9a3',
        backgroundWood = '#2b1d14',
        borderColor = 'rgba(255, 255, 255, 0.1)',
        borderColorWood = '#4a2e1a',
        borderRadius = '4px',
        statusGood = '#27ae60',
        statusWarning = '#c98a3a',
        statusCritical = '#c0392b',
        statusInfo = '#2980b9',
    },
    dark_coal = {
        fontBody = "'RDR Lino Regular', 'Roboto Condensed', serif",
        fontDisplay = "'RDR Lino Regular', 'Playfair Display', serif",
        textPrimary = '#e0e0e0',
        textSecondary = '#888888',
        textOnPaper = '#ffffff',
        accentColor = '#555555',
        accentColorDark = '#333333',
        backgroundColor = 'rgba(15, 15, 15, 0.95)',
        backgroundPaper = '#222222',
        backgroundWood = '#111111',
        borderColor = 'rgba(255, 255, 255, 0.05)',
        borderColorWood = '#222222',
        borderRadius = '4px',
        statusGood = '#2e7d32',
        statusWarning = '#ef6c00',
        statusCritical = '#c62828',
        statusInfo = '#1565c0',
    },
    blood_red = {
        fontBody = "'RDR Lino Regular', 'Roboto Condensed', serif",
        fontDisplay = "'RDR Lino Regular', 'Playfair Display', serif",
        textPrimary = '#ffcccc',
        textSecondary = '#aa6666',
        textOnPaper = '#ffebeb',
        accentColor = '#8a2020',
        accentColorDark = '#5a1010',
        backgroundColor = 'rgba(10, 5, 5, 0.93)',
        backgroundPaper = '#261212',
        backgroundWood = '#150808',
        borderColor = 'rgba(255, 0, 0, 0.1)',
        borderColorWood = '#351010',
        borderRadius = '4px',
        statusGood = '#27ae60',
        statusWarning = '#c98a3a',
        statusCritical = '#ff3333',
        statusInfo = '#2980b9',
    },
    -- Custom Theme (se Config.ActiveTheme for "custom")
    custom = {
        fontBody = "'RDR Lino Regular', 'Roboto Condensed', serif",
        fontDisplay = "'RDR Lino Regular', 'Playfair Display', serif",
        textPrimary = '#d4c5b0',
        textSecondary = '#a89878',
        textOnPaper = '#2b1d14',
        accentColor = '#c9a15a',
        accentColorDark = '#8a6a35',
        backgroundColor = 'rgba(10, 10, 10, 0.88)',
        backgroundPaper = '#d8c9a3',
        backgroundWood = '#2b1d14',
        borderColor = 'rgba(255, 255, 255, 0.1)',
        borderColorWood = '#4a2e1a',
        borderRadius = '4px',
        statusGood = '#27ae60',
        statusWarning = '#c98a3a',
        statusCritical = '#c0392b',
        statusInfo = '#2980b9',
    }
}

-- CONFIGURAÇÕES PADRÃO PARA ZONAS (GEOFENCES)
Config.DefaultZoneSettings = {
    drawMarker = true,                                     -- Se desenha marcador no chão por padrão nas zonas
    markerType = 1,                                        -- 1 = cilindro padrão
    markerColor = { r = 201, g = 161, b = 90, a = 60 },    -- Cor padrão do marcador (ouro translúcido)
    promptKey = 0xE30CD707,                                -- Tecla padrão para prompts (E / Context)
}

