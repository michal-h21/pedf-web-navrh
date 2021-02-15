-- počet sekund za den
local day = 24 * 60 * 60
-- dnešní den
local first = os.time {year = 2021, month = 2, day = 15}

local function get_date(x)
  return os.date("%d. %m",x)
end

-- jeden krok je tyden
local result = {}
for week = 0, 20 do
  local first_day = first + week * 7 * day
  local tuesday = first_day + day
  local thursday = first_day + 3 * day
  local sunday = first_day + 6 * day
  -- print(get_date(tuesday), get_date(thursday), get_date(sunday))
  -- zavreno je v utery a od ctvrtka do nedele
  result[#result + 1] = get_date(tuesday)
  result[#result + 1] = get_date(thursday) .. " - " .. get_date(sunday)
end

print(table.concat(result, ", "))
