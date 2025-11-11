local Translations = {
    error = {
        not_online 					= 'A játékos nem elérhető',
        wrong_format 				= 'Helytelen formátum',
        missing_args 				= 'Nem minden érték lett megadva (x, y, z)',
        missing_args2 				= 'Az összes értéket meg kell adnod!',
        no_access 					= 'Nem használhatod ezt a parancsot',
        company_too_poor 			= 'A munkáltatód nem tudott kifizetni',
        item_not_exist 				= 'Ez a tárgy nem létezik',
        too_heavy 					= 'A leltárad megtelt',
        location_not_exist          = 'Location does not exist',
        duplicate_license           = '[SZERVER] - Duplikált Rockstar License-t találtunk!',
        no_valid_license            = '[SZERVER] - Nem valós Rockstar License-t találtunk!',
        not_whitelisted             = '[SZERVER] - Nincs engedélyed, hogy csatlakozz a szerverhez!',
        server_already_open         = 'Szerver megnyitva!',
        server_already_closed       = 'Szerver bezárva!',
        no_permission               = 'Nincs engedélyed, hogy ezt tehesd..',
        no_waypoint                 = 'Nem lett uticél megadva.',
        tp_error                    = 'Hiba teleportálás közben.',
        ban_table_not_found         = '[SZERVER] - Ban tábla nem található az adatbázisban. Gyözödj meg róla, hogy helyesen lett importálva.',
        connecting_database_error   = '[SZERVER] - Hiba történt az adatbázis csatlakozása során. Ellenörizd, hogy a server.cfg fájlban minden SQL adat helyesen szerepel.',
        connecting_database_timeout = '[SZERVER] - Adatbázis csatlakozás idötúllépés. Ellenörizd, hogy a server.cfg fájlban minden SQL adat helyesen szerepel.',
    },
    success = {
        server_opened = 'Szerver megnyitva',
        server_closed = 'Szerver bezárva',
        teleported_waypoint = 'Teleportálás az uticélhoz.',
    },
    info = {
        received_paycheck = 'Fizetést kaptál - $%{value}',
        job_info = 'Munka: %{value} | Beosztás: %{value2} | Ügyeletben: %{value3}',
        gang_info = 'Banda: %{value} | Rang: %{value2}',
        on_duty = 'Ügyeletbe léptél!',
        off_duty = 'Befejezted az ügyeletet!',
        checking_ban = 'Üdvözöllek %s. Ellenörizzük a tíltólistát.',
        join_server = 'Üdvözöllek %s a {Server Name} szerveren!.',
        checking_whitelisted = 'Szia %s. Ellenörizzük az engedélyeidet.',
        exploit_banned = 'Csalásért kitíltásra kerültél. További információkért látogass el a Discord csatornánkra - %{discord}',
        exploit_dropped = 'Kirúgtak a szerverröl mert szabályt sértettél!',
    },
    command = {
        tp = {
            help = 'TP játékoshoz vagy koordinátára (Admin Only)',
            params = {
                x = { name = 'id/x', help = 'Játékos id vagy koordináta X' },
                y = { name = 'y', help = 'koordináta Y' },
                z = { name = 'z', help = 'koordináta Z' },
            },
        },
        tpm = { help = 'TP uticélhoz (Admin Only)' },
        noclip = { help = 'No Clip (Admin Only)' },
        togglepvp = { help = 'PVP (Admin Only)' },
        addpermission = {
            help = 'Engedélyek adása (God Only)',
            params = {
                id = { name = 'id', help = 'Játékos ID' },
                permission = { name = 'permission', help = 'Engedély szint' },
            },
        },
        removepermission = {
            help = 'Engedély elvétele játékostól (God Only)',
            params = {
                id = { name = 'id', help = 'Játékos ID' },
                permission = { name = 'permission', help = 'Engedély szint' },
            },
        },
        openserver = { help = 'Szerver megnyitása mindenki számára (Admin Only)' },
        closeserver = {
            help = 'Szerver bezárása az engedély nélküli játékosok számára (Admin Only)',
            params = {
                reason = { name = 'reason', help = 'Bezárás oka (opcionális)' },
            },
        },
        car = {
            help = 'Jármü Spawn (Admin Only)',
            params = {
                model = { name = 'model', help = 'Jármü model' },
            },
        },
        dv = { help = 'Jármü törlés (Admin Only)' },
        dvall = { help = 'Összes jármü törlés (Admin Only)' },
        dvp = { help = 'Összes Ped törlés (Admin Only)' },
        dvo = { help = 'Összes Objekt törlés (Admin Only)' },
        givemoney = {
            help = 'Pénz adás játékosnak (Admin Only)',
            params = {
                id = { name = 'id', help = 'Játékos ID' },
                moneytype = { name = 'moneytype', help = 'Pénztípus (cash, bank, gold, bloodmoney, tbcoin)' },
                amount = { name = 'amount', help = 'Amount of money' },
            },
        },
        setmoney = {
            help = 'Pénz mennyiségének megadása játékosnak (Admin Only)',
            params = {
                id = { name = 'id', help = 'Játékos ID' },
                moneytype = { name = 'moneytype', help = 'Pénztípus (cash, bank, gold, bloodmoney, tbcoin)' },
                amount = { name = 'amount', help = 'Összeg' },
            },
        },
        job = { help = 'Munkád ellenörzése' },
        setjob = {
            help = 'Munka megadás játékosnak (Admin Only)',
            params = {
                id = { name = 'id', help = 'Játékos ID' },
                job = { name = 'job', help = 'Munka neve' },
                grade = { name = 'grade', help = 'Beosztás' },
            },
        },
        gang = { help = 'Bandád ellenörzése' },
        setgang = {
            help = 'Banda megadása játékosnak (Admin Only)',
            params = {
                id = { name = 'id', help = 'Játékos ID' },
                gang = { name = 'gang', help = 'Banda neve' },
                grade = { name = 'grade', help = 'Rang' },
            },
        },
        ooc = { help = 'OOC Chat üzenet' },
        me = {
            help = 'Lokális cselekvés buborék',
            params = {
                message = { name = 'message', help = 'Üzenet elküldve' }
            },
        },
    },
}

if GetConvar('rsg_locale', 'en') == 'hu' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
