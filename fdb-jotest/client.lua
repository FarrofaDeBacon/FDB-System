RegisterCommand('jotest', function()
    print('Framework detectado:', jo.framework:getFrameworkDetected())

    local menu = jo.menu.create("jotest_menu", { title = "Teste FDB", subtitle = "Slider" })
    menu:addItem({
        title = "Cor de Cabelo",
        sliders = {
            { type = "palette", value = 1, max = 10 }
        },
        onChange = function(currentData)
            print("Slider mudou pra:", currentData.item.sliders[1].value)
        end
    })
    menu:open()
end, false)
