local Translations = {
    error = {
        not_online                  = 'Gracz nie jest online',
        wrong_format                = 'Niepoprawny format',
        missing_args                = 'Nie wszystkie argumenty zostały podane (x, y, z)',
        missing_args2               = 'Wszystkie argumenty muszą być wypełnione!',
        no_access                   = 'Brak dostępu do tej komendy',
        company_too_poor            = 'Twój pracodawca jest spłukany',
        item_not_exist              = 'Przedmiot nie istnieje',
        too_heavy                   = 'Ekwipunek jest zbyt pełny',
        location_not_exist          = 'Lokalizacja nie istnieje',
        duplicate_license           = '[RSGCORE] - Znaleziono duplikat licencji Rockstar',
        no_valid_license            = '[RSGCORE] - Nie znaleziono ważnej licencji Rockstar',
        not_whitelisted             = '[RSGCORE] - Nie jesteś na whitelist tego serwera',
        server_already_open         = 'Serwer jest już otwarty',
        server_already_closed       = 'Serwer jest już zamknięty',
        no_permission               = 'Nie masz do tego uprawnień',
        no_waypoint                 = 'Nie ustawiono waypointu',
        tp_error                    = 'Błąd podczas teleportacji',
        ban_table_not_found         = '[RSGCORE] - Nie znaleziono tabeli banów w bazie danych. Upewnij się, że poprawnie zaimportowałeś plik SQL.',
        connecting_database_error   = '[RSGCORE] - Wystąpił błąd podczas łączenia z bazą danych. Upewnij się, że serwer SQL działa i że dane w server.cfg są poprawne.',
        connecting_database_timeout = '[RSGCORE] - Połączenie z bazą danych wygasło. Upewnij się, że serwer SQL działa i że dane w server.cfg są poprawne.',
    },
    success = {
        server_opened = 'Serwer został otwarty',
        server_closed = 'Serwer został zamknięty',
        teleported_waypoint = 'Zteleportowano do waypointu',
    },
    info = {
        received_paycheck = 'Otrzymałeś wypłatę w wysokości $%{value}',
        job_info = 'Praca: %{value} | Stopień: %{value2} | Na służbie: %{value3}',
        gang_info = 'Gangi: %{value} | Stopień: %{value2}',
        on_duty = 'Jesteś teraz na służbie!',
        off_duty = 'Jesteś teraz poza służbą!',
        checking_ban = 'Witaj %s. Sprawdzamy, czy jesteś zbanowany.',
        join_server = 'Witaj %s na {Server Name}.',
        checking_whitelisted = 'Witaj %s. Sprawdzamy twój dostęp.',
        exploit_banned = 'Zostałeś zbanowany za oszustwo. Sprawdź naszego Discorda po więcej informacji: %{discord}',
        exploit_dropped = 'Zostałeś wyrzucony za wykorzystywanie exploitów',
    },
    command = {
        tp = {
            help = 'Teleport do gracza lub współrzędnych (tylko Admin)',
            params = {
                x = { name = 'id/x', help = 'ID gracza lub pozycja X' },
                y = { name = 'y', help = 'Pozycja Y' },
                z = { name = 'z', help = 'Pozycja Z' },
            },
        },
        tpm = { help = 'Teleport do markera (tylko Admin)' },
        noclip = { help = 'Przelot przez obiekty (tylko Admin)' },
        togglepvp = { help = 'Włącz/Wyłącz PVP na serwerze (tylko Admin)' },
        addpermission = {
            help = 'Nadaj graczowi uprawnienia (tylko Bóg)',
            params = {
                id = { name = 'id', help = 'ID gracza' },
                permission = { name = 'permission', help = 'Poziom uprawnień' },
            },
        },
        removepermission = {
            help = 'Odbierz graczowi uprawnienia (tylko Bóg)',
            params = {
                id = { name = 'id', help = 'ID gracza' },
                permission = { name = 'permission', help = 'Poziom uprawnień' },
            },
        },
        openserver = { help = 'Otwórz serwer dla wszystkich (tylko Admin)' },
        closeserver = {
            help = 'Zamknij serwer dla osób bez uprawnień (tylko Admin)',
            params = {
                reason = { name = 'reason', help = 'Powód zamknięcia (opcjonalnie)' },
            },
        },
        car = {
            help = 'Spawn pojazdu (tylko Admin)',
            params = {
                model = { name = 'model', help = 'Nazwa modelu pojazdu' },
            },
        },
        dv = { help = 'Usuń pojazd (tylko Admin)' },
        dvall = { help = 'Usuń wszystkie pojazdy (tylko Admin)' },
        dvp = { help = 'Usuń wszystkie postacie (tylko Admin)' },
        dvo = { help = 'Usuń wszystkie obiekty (tylko Admin)' },
        givemoney = {
            help = 'Daj graczowi pieniądze (tylko Admin)',
            params = {
                id = { name = 'id', help = 'ID gracza' },
                moneytype = { name = 'moneytype', help = 'Rodzaj pieniędzy (cash, bank, bloodmoney)' },
                amount = { name = 'amount', help = 'Kwota pieniędzy' },
            },
        },
        setmoney = {
            help = 'Ustaw kwotę pieniędzy gracza (tylko Admin)',
            params = {
                id = { name = 'id', help = 'ID gracza' },
                moneytype = { name = 'moneytype', help = 'Rodzaj pieniędzy (cash, bank, bloodmoney)' },
                amount = { name = 'amount', help = 'Kwota pieniędzy' },
            },
        },
        job = { help = 'Sprawdź swoją pracę' },
        setjob = {
            help = 'Ustaw pracę gracza (tylko Admin)',
            params = {
                id = { name = 'id', help = 'ID gracza' },
                job = { name = 'job', help = 'Nazwa pracy' },
                grade = { name = 'grade', help = 'Stopień pracy' },
            },
        },
        gang = { help = 'Sprawdź swój gang' },
        setgang = {
            help = 'Ustaw gang gracza (tylko Admin)',
            params = {
                id = { name = 'id', help = 'ID gracza' },
                gang = { name = 'gang', help = 'Nazwa gangu' },
                grade = { name = 'grade', help = 'Stopień w gangu' },
            },
        },
        ooc = { help = 'Wiadomość czatu OOC' },
        me = {
            help = 'Pokaż lokalną wiadomość',
            params = {
                message = { name = 'message', help = 'Wiadomość do wysłania' }
            },
        },
    },
}

if GetConvar('qb_locale', 'en') == 'pl' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
