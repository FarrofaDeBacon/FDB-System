Config = {}

--[[ Command ]]--
Config.Command = "medicmdt"

Config.Jobs = {"medic"}

--[[ Offices ]]--
Config.UseOffice = true
Config.Open = { 
	['key'] = 0xCEFD9220, -- E
	['text'] = "Presiona ~e~[E] ~q~ para abrir el Archivo",
	} 
Config.Office = {
    [1] = {
        coords={-289.46, 806.82, 119.31}, 
    },
}

--[[ Notifys ]]--
Config.Notify = {  
	['1'] = "As alterações foram salvas.",
	['2'] = "As alterações no relatório foram salvas.",
	['3'] = "O relatório foi excluído com sucesso.",
	['4'] = "Um novo relatório foi registrado.",
	['5'] = "Novo registro adicionado.",
	['6'] = "Registro removido.",
	['7'] = "Não foi possível encontrar este relatório.",
	['8'] = "Nota salva.",
	['9'] = "Nota excluída.",	
	} 
