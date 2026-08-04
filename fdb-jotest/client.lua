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
    jo.menu.send("jotest_menu")
    jo.menu.setCurrentMenu("jotest_menu")
    jo.menu.show(true)
end, false)
