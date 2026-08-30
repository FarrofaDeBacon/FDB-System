function GetGameMinutes()
    local t = exports.weathersync:getTime()
    return (t.day * 1440) + (t.hour * 60) + t.minute
end
