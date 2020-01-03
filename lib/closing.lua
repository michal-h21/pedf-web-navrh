local date = require "date"

local currentyear = tonumber(os.date("%Y", os.time()))

local function get_date(dateobj)
  return date(dateobj.year or currentyear, dateobj.month, dateobj.day)
end

local function make_date(year, month, day)
  return {day=tonumber(day), month = tonumber(month), year = tonumber(year) }
end

local function make_range(t,first, second)
  -- we must use years for ranges, use the current year as default
  local first_date = get_date(first)
  local second_date = get_date(second)
  local diff = date.diff( second_date, first_date)
  t[#t+1] = first_date:copy()
  for i=1,  diff:spandays()-1, 1 do
    t[#t+1] = first_date:adddays(1):copy()
  end
  return t
end

local function get_date_ranges(calendar, dates, comment)
  -- step over dates and
  local t = {}
  for i = 1, #dates do
    local current = dates[i]
    if current.modifier == "-" then
      local next_date = dates[i+1] 
      t = make_range(t, current, next_date)
      i=i+1
    else
      t[#t+1] = get_date(current)
    end
  end
  for _, v in ipairs(t) do 
    local day = v:fmt("%G-%m-%d")
    calendar[day] = comment
  end
  return calendar
end

local function parse_dates(calendar, dates,comment)
  local t = {}
  for day, month, year, modifier in dates:gmatch("(%d+)%.%s*(%d+)%.%s*(%d*)%.?%s*([%,%-]?)") do
    local date_obj = make_date(year, month, day)
    date_obj.modifier = modifier
    t[#t+1] = date_obj
    -- print(day, month,year, modifier)
  end
  return t, get_date_ranges(calendar,t,comment)
end

local function load_closing(lines)
  local entries = {}
  local calendar = {}
  for line in lines do
    local comment, dates = line:match("(.+)%s*:%s*(.+)%s*")
    if comment then
      local closing = dates 
      if closing:match("^%s*%d") then
        closing, calendar = parse_dates(calendar,dates, comment)
      end
      entries[#entries+1] = {closing = closing, comment = comment}
    end
  end
  return entries, calendar
end


return load_closing
-- local  x,y = load_closing(io.lines("data/closing.csv"))

-- for _,v in ipairs(x) do
--   print("closing",v.comment, v.closing)
-- end

-- for k,v in pairs(y) do
--   print(k,v)
-- end



