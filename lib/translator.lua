local M = {}

function M.get_translator(strings)
  local strings = strings or {}
  return function(str)
    return strings[str] or str
  end
end

return M
