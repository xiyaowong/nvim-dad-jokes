local config = {
  enable_interval = false,
  interval = 10 * 60 * 1000,
  display_timeout = 5000,
}
local running = false
local should_stop = false

---@param lines table/string
local function notify(lines)
  lines = type(lines) == 'string' and { lines } or lines
  lines = vim.tbl_flatten(vim.tbl_map(function(line)
    return vim.split(line, '\n')
  end, lines))

  local width
  for idx, line in ipairs(lines) do
    line = '  ' .. line .. '  '
    lines[idx] = line
    local length = #line
    if not width or width < length then
      width = length
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local prev
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if
      vim.bo[vim.api.nvim_win_get_buf(w)].filetype == 'dad-joke-notify'
      and vim.api.nvim_win_is_valid(w)
    then
      prev = vim.api.nvim_win_get_config(w)
      break
    end
  end

  local win = vim.api.nvim_open_win(buf, false, {
    relative = 'editor',
    width = width,
    height = #lines,
    col = vim.o.columns,
    row = prev and prev.row[false] - prev.height - 2 or vim.o.lines - vim.o.cmdheight - 3,
    anchor = 'SE',
    style = 'minimal',
    focusable = false,
    border = 'single',
  })

  vim.bo[buf].filetype = 'dad-joke-notify'
  vim.wo[win].winhighlight = [[NormalFloat:Normal]]
  vim.wo[win].wrap = true
  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, config.display_timeout)
end

local function fetch()
  vim.fn.jobstart([[curl 'https://icanhazdadjoke.com/' --connect-timeout 10]], {
    stdout_buffered = true,
    on_stdout = function(_, data, _)
      if data and #data > 0 then
        notify(data)
      end
    end,
  })
end

local function start()
  if running then
    return
  end
  running = true
  should_stop = false
  notify '🎉Hurray!!! Dad Jokes is active🎉'
  vim.schedule(fetch)
  local timer
  timer = vim.fn.timer_start(config.interval, function()
    if should_stop then
      running = false
      vim.fn.timer_stop(timer)
      return
    end
    fetch()
  end, {
    ['repeat'] = -1,
  })
end

local function stop()
  if not running then
    return
  end
  notify 'Dad Jokes is deactive!'
  should_stop = true
end

local function setup(opts)
  config = vim.tbl_extend('force', config, opts or {})
  if config.enable_interval then
    start()
  end
end

return { fetch = fetch, setup = setup, start = start, stop = stop }
