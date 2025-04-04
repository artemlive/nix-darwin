-- Declare the module
local telescopePickers = {}

-- Store Utilities we'll use frequently
local action_state = require 'telescope.actions.state'
local action_utils = require 'telescope.actions.utils'
local telescopeUtilities = require 'telescope.utils'
local telescopeMakeEntryModule = require 'telescope.make_entry'
local plenaryStrings = require 'plenary.strings'
local devIcons = require 'nvim-web-devicons'
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local telescopeEntryDisplayModule = require 'telescope.pickers.entry_display'
local conf = require('telescope.config').values
-- local kind_icons = require('kind').icons

-- Obtain Filename icon width
-- --------------------------
-- INSIGHT: This width applies to all icons that represent a file type
local fileTypeIconWidth = plenaryStrings.strdisplaywidth(devIcons.get_icon('fname', { default = true }))

---- Helper functions ----

-- Gets the File Path and its Tail (the file name) as a Tuple
function telescopePickers.getPathAndTail(fileName)
  -- Get the Tail
  local bufferNameTail = telescopeUtilities.path_tail(fileName)

  -- Now remove the tail from the Full Path
  local pathWithoutTail = require('plenary.strings').truncate(fileName, #fileName - #bufferNameTail, '')

  -- Apply truncation and other pertaining modifications to the path according to Telescope path rules
  local pathToDisplay = telescopeUtilities.transform_path({
    path_display = { 'truncate' },
  }, pathWithoutTail)

  -- Return as Tuple
  return bufferNameTail, pathToDisplay
end

-- Function to get buffer number by full file path
local function get_buffer_number_by_path(filepath)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == filepath then
      return bufnr
    end
  end
  return nil
end

---- Picker functions ----

-- Generates a Find File picker but beautified
-- -------------------------------------------
-- This is a wrapping function used to modify the appearance of pickers that provide a Find File
-- functionality, mainly because the default one doesn't look good. It does this by changing the 'display()'
-- function that Telescope uses to display each entry in the Picker.
--
-- Adapted from: https://github.com/nvim-telescope/telescope.nvim/issues/2014#issuecomment-1541423345.
--
-- @param (table) pickerAndOptions - A table with the following format:
--                                   {
--                                      picker = '<pickerName>',
--                                      (optional) options = { ... }
--                                   }
function telescopePickers.prettyFilesPicker(pickerAndOptions)
  -- Parameter integrity check
  if type(pickerAndOptions) ~= 'table' or pickerAndOptions.picker == nil then
    print "Incorrect argument format. Correct format is: { picker = 'desiredPicker', (optional) options = { ... } }"

    -- Avoid further computation
    return
  end

  -- Ensure 'options' integrity
  local options = pickerAndOptions.options or {}

  -- Use Telescope's existing function to obtain a default 'entry_maker' function
  -- ----------------------------------------------------------------------------
  -- INSIGHT: Because calling this function effectively returns an 'entry_maker' function that is ready to
  --          handle entry creation, we can later call it to obtain the final entry table, which will
  --          ultimately be used by Telescope to display the entry by executing its 'display' key function.
  --          This reduces our work by only having to replace the 'display' function in said table instead
  --          of having to manipulate the rest of the data too.
  local originalEntryMaker = telescopeMakeEntryModule.gen_from_file(options)

  -- INSIGHT: 'entry_maker' is the hardcoded name of the option Telescope reads to obtain the function that
  --          will generate each entry.
  -- INSIGHT: The paramenter 'line' is the actual data to be displayed by the picker, however, its form is
  --          raw (type 'any) and must be transformed into an entry table.
  options.entry_maker = function(line)
    -- Generate the Original Entry table
    local originalEntryTable = originalEntryMaker(line)

    -- INSIGHT: An "entry display" is an abstract concept that defines the "container" within which data
    --          will be displayed inside the picker, this means that we must define options that define
    --          its dimensions, like, for example, its width.
    local displayer = telescopeEntryDisplayModule.create {
      separator = ' ', -- Telescope will use this separator between each entry item
      items = {
        { width = fileTypeIconWidth },
        { width = nil },
        { remaining = true },
      },
    }

    -- LIFECYCLE: At this point the "displayer" has been created by the create() method, which has in turn
    --            returned a function. This means that we can now call said function by using the
    --            'displayer' variable and pass it actual entry values so that it will, in turn, output
    --            the entry for display.
    --
    -- INSIGHT: We now have to replace the 'display' key in the original entry table to modify the way it
    --          is displayed.
    -- INSIGHT: The 'entry' is the same Original Entry Table but is is passed to the 'display()' function
    --          later on the program execution, most likely when the actual display is made, which could
    --          be deferred to allow lazy loading.
    --
    -- HELP: Read the 'make_entry.lua' file for more info on how all of this works
    originalEntryTable.display = function(entry)
      -- Get the Tail and the Path to display
      local tail, pathToDisplay = telescopePickers.getPathAndTail(entry.value)

      -- Add an extra space to the tail so that it looks nicely separated from the path
      local tailForDisplay = tail .. ' '

      -- Get the Icon with its corresponding Highlight information
      local icon, iconHighlight = telescopeUtilities.get_devicons(tail)

      -- INSIGHT: This return value should be a tuple of 2, where the first value is the actual value
      --          and the second one is the highlight information, this will be done by the displayer
      --          internally and return in the correct format.
      return displayer {
        { icon, iconHighlight },
        tailForDisplay,
        { pathToDisplay, 'TelescopeResultsComment' },
      }
    end

    return originalEntryTable
  end

  -- Finally, check which file picker was requested and open it with its associated options
  if pickerAndOptions.picker == 'find_files' then
    require('telescope.builtin').find_files(options)
  elseif pickerAndOptions.picker == 'git_files' then
    require('telescope.builtin').git_files(options)
  elseif pickerAndOptions.picker == 'oldfiles' then
    require('telescope.builtin').oldfiles(options)
  elseif pickerAndOptions.picker == '' then
    print 'Picker was not specified'
  else
    print 'Picker is not supported by Pretty Find Files'
  end
end

-- Generates a Grep Search picker but beautified
-- ----------------------------------------------
-- This is a wrapping function used to modify the appearance of pickers that provide Grep Search
-- functionality, mainly because the default one doesn't look good. It does this by changing the 'display()'
-- function that Telescope uses to display each entry in the Picker.
--
-- @param (table) pickerAndOptions - A table with the following format:
--                                   {
--                                      picker = '<pickerName>',
--                                      (optional) options = { ... }
--                                   }
function telescopePickers.prettyGrepPicker(pickerAndOptions)
  -- Parameter integrity check
  if type(pickerAndOptions) ~= 'table' or pickerAndOptions.picker == nil then
    print "Incorrect argument format. Correct format is: { picker = 'desiredPicker', (optional) options = { ... } }"
    -- Avoid further computation
    return
  end

  -- Ensure 'options' integrity and setup
  local options = pickerAndOptions.options or {}

  -- If cwd is not set, prompt the user to enter a directory path or use the current directory
  if not options.cwd then
    options.cwd = vim.fn.getcwd()
  end

  options.prompt_title = 'Search in: ' .. options.cwd
  -- Use Telescope's existing function to obtain a default 'entry_maker' function
  local originalEntryMaker = telescopeMakeEntryModule.gen_from_vimgrep(options)

  -- Customize entry display
  options.entry_maker = function(line)
    local originalEntryTable = originalEntryMaker(line)

    local displayer = telescopeEntryDisplayModule.create {
      separator = ' ',
      items = {
        { width = fileTypeIconWidth },
        { width = nil },
        { width = nil }, -- Maximum path size, keep it short
        { remaining = true },
      },
    }

    originalEntryTable.display = function(entry)
      local tail, pathToDisplay = telescopePickers.getPathAndTail(entry.filename)
      local icon, iconHighlight = telescopeUtilities.get_devicons(tail)

      local coordinates = ''
      if not options.disable_coordinates and entry.lnum then
        coordinates = string.format(' -> %s:%s', entry.lnum, entry.col or '')
      end

      tail = tail .. coordinates
      local tailForDisplay = tail .. ' '
      local text = options.file_encoding and vim.iconv(entry.text, options.file_encoding, 'utf8') or entry.text

      return displayer {
        { icon, iconHighlight },
        tailForDisplay,
        { pathToDisplay, 'TelescopeResultsComment' },
        text,
      }
    end

    return originalEntryTable
  end

  -- Check which file picker was requested and open it with its associated options
  if pickerAndOptions.picker == 'live_grep' then
    require('telescope.builtin').live_grep(options)
  elseif pickerAndOptions.picker == 'grep_string' then
    require('telescope.builtin').grep_string(options)
  else
    print 'Picker is not supported by Pretty Grep Picker'
  end
end

function telescopePickers.prettyWorkspaceSymbols(localOptions)
  if localOptions ~= nil and type(localOptions) ~= 'table' then
    print 'Options must be a table.'
    return
  end

  local options = localOptions or {}

  local originalEntryMaker = telescopeMakeEntryModule.gen_from_lsp_symbols(options)

  options.entry_maker = function(line)
    local originalEntryTable = originalEntryMaker(line)

    local displayer = telescopeEntryDisplayModule.create {
      separator = ' ',
      items = {
        { width = fileTypeIconWidth },
        { width = 15 },
        { width = 30 },
        { width = nil },
        { remaining = true },
      },
    }

    originalEntryTable.display = function(entry)
      local tail, _ = telescopePickers.getPathAndTail(entry.filename)
      local tailForDisplay = tail .. ' '
      local pathToDisplay = telescopeUtilities.transform_path({
        path_display = { shorten = { num = 2, exclude = { -2, -1 } }, 'truncate' },
      }, entry.value.filename)

      return displayer {
        string.format('%s', kind_icons[(entry.symbol_type:lower():gsub('^%l', string.upper))]),
        { entry.symbol_type:lower(), 'TelescopeResultsVariable' },
        { entry.symbol_name, 'TelescopeResultsConstant' },
        tailForDisplay,
        { pathToDisplay, 'TelescopeResultsComment' },
      }
    end

    return originalEntryTable
  end

  require('telescope.builtin').lsp_dynamic_workspace_symbols(options)
end

function telescopePickers.prettyLspReferences(localOptions)
  if localOptions ~= nil and type(localOptions) ~= 'table' then
    print 'Options must be a table.'
    return
  end

  local options = localOptions or {}

  local originalEntryMaker = telescopeMakeEntryModule.gen_from_quickfix(options)

  options.entry_maker = function(line)
    local originalEntryTable = originalEntryMaker(line)

    local displayer = telescopeEntryDisplayModule.create {
      separator = ' ', -- Telescope will use this separator between each entry item
      items = {
        { width = fileTypeIconWidth },
        { width = nil },
        { remaining = true },
      },
    }

    originalEntryTable.display = function(entry)
      local tail, pathToDisplay = telescopePickers.getPathAndTail(entry.filename)
      local tailForDisplay = tail .. ' '
      local icon, iconHighlight = telescopeUtilities.get_devicons(tail)
      local coordinates = string.format('  %s:%s ', entry.lnum, entry.col)

      return displayer {
        { icon, iconHighlight },
        tailForDisplay .. coordinates,
        { pathToDisplay, 'TelescopeResultsComment' },
      }
    end

    return originalEntryTable
  end

  require('telescope.builtin').lsp_references(options)
end

function telescopePickers.prettyHarpoonPicker(marks, localOptions)
  if localOptions ~= nil and type(localOptions) ~= 'table' then
    print 'Options must be a table.'
    return
  end

  local options = localOptions or {}

  local originalEntryMaker = telescopeMakeEntryModule.gen_from_file(options)

  local function filter_empty_string(list)
    local next = {}
    for idx = 1, #list do
      if list[idx].value ~= '' then
        table.insert(next, list[idx])
      end
    end

    return next
  end

  local generate_new_finder = function(harpoon_marks)
    local file_paths = {}

    for _, item in ipairs(harpoon_marks.items) do
      table.insert(file_paths, item.value)
    end

    return finders.new_table {
      results = filter_empty_string(file_paths),
      entry_maker = function(line)
        local originalEntryTable = originalEntryMaker(line)

        local displayer = telescopeEntryDisplayModule.create {
          separator = ' ', -- Telescope will use this separator between each entry item
          items = {
            { width = fileTypeIconWidth },
            { width = nil },
            { remaining = true },
          },
        }

        originalEntryTable.display = function(entry)
          local tail, pathToDisplay = telescopePickers.getPathAndTail(entry.value)
          local tailForDisplay = tail .. ' '
          local icon, iconHighlight = telescopeUtilities.get_devicons(tail)

          return displayer {
            { icon, iconHighlight },
            tailForDisplay,
            { pathToDisplay, 'TelescopeResultsComment' },
          }
        end

        return originalEntryTable
      end,
    }
  end

  local delete_harpoon_mark = function(prompt_bufnr)
    local confirmation = vim.fn.input(string.format 'Delete current mark(s)? [y/n]: ')

    if string.len(confirmation) == 0 or string.sub(string.lower(confirmation), 0, 1) ~= 'y' then
      vim.notify "Didn't delete mark"
      return
    end

    local selection = action_state.get_selected_entry()
    marks:removeAt(selection.index)

    local function get_selections()
      local results = {}
      action_utils.map_selections(prompt_bufnr, function(entry)
        table.insert(results, entry)
      end)
      return results
    end

    local selections = get_selections()
    for _, current_selection in ipairs(selections) do
      marks:removeAt(current_selection.index)
    end

    local current_picker = action_state.get_current_picker(prompt_bufnr)
    current_picker:refresh(generate_new_finder(marks), { reset_prompt = true })
  end

  local move_mark_up = function(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    local length = marks:length()

    if selection.index == length then
      return
    end

    local mark_list = marks.items

    table.remove(mark_list, selection.index)
    table.insert(mark_list, selection.index + 1, selection.value)

    local current_picker = action_state.get_current_picker(prompt_bufnr)
    current_picker:refresh(generate_new_finder(marks), { reset_prompt = true })
  end

  local move_mark_down = function(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    if selection.index == 1 then
      return
    end
    local mark_list = marks.items

    table.remove(mark_list, selection.index)
    table.insert(mark_list, selection.index - 1, selection.value)

    local current_picker = action_state.get_current_picker(prompt_bufnr)
    current_picker:refresh(generate_new_finder(marks), { reset_prompt = true })
  end

  pickers
    .new({}, {
      prompt_title = 'Harpoon',
      finder = generate_new_finder(marks),
      sorter = conf.generic_sorter {},
      previewer = conf.file_previewer {},
      attach_mappings = function(_, map)
        map('i', '<c-d>', delete_harpoon_mark)
        map('n', '<c-d>', delete_harpoon_mark)

        map('i', '<c-p>', move_mark_up)
        map('n', '<c-p>', move_mark_up)

        map('i', '<c-n>', move_mark_down)
        map('n', '<c-n>', move_mark_down)
        return true
      end,
    })
    :find()
end

function telescopePickers.prettyBuffersPicker(localOptions)
  if localOptions ~= nil and type(localOptions) ~= 'table' then
    print 'Options must be a table.'
    return
  end

  local options = localOptions or {}

  local originalEntryMaker = telescopeMakeEntryModule.gen_from_buffer(options)

  options.entry_maker = function(line)
    local originalEntryTable = originalEntryMaker(line)

    local displayer = telescopeEntryDisplayModule.create {
      separator = ' ',
      items = {
        { width = fileTypeIconWidth },
        { width = nil },
        { width = nil },
        { remaining = true },
      },
    }

    originalEntryTable.display = function(entry)
      local tail, path = telescopePickers.getPathAndTail(entry.filename)
      local tailForDisplay = tail .. ' '
      local icon, iconHighlight = telescopeUtilities.get_devicons(tail)

      return displayer {
        { icon, iconHighlight },
        tailForDisplay,
        { '(' .. entry.bufnr .. ')', 'TelescopeResultsNumber' },
        { path, 'TelescopeResultsComment' },
      }
    end

    return originalEntryTable
  end

  require('telescope.builtin').buffers(options)
end

function telescopePickers.prettyGrapplePicker(localOptions)
  local Grapple = require 'grapple'

  if localOptions ~= nil and type(localOptions) ~= 'table' then
    print 'Options must be a table.'
    return
  end

  local options = localOptions or {}

  local generate_finder = function()
    local tags, err = Grapple.tags()

    if not tags then
      ---@diagnostic disable-next-line: param-type-mismatch
      return vim.notify(err, vim.log.levels.ERROR)
    end

    local results = {}
    for i, tag in ipairs(tags) do
      ---@class grapple.telescope.result
      local result = {
        i,
        tag.path,
        tag.cursor and tag.cursor[1],
        tag.cursor and tag.cursor[2],
      }

      table.insert(results, result)
    end

    local displayer = telescopeEntryDisplayModule.create {
      separator = ' ',
      items = {
        { width = fileTypeIconWidth },
        { width = nil },
        { remaining = true },
      },
    }

    return finders.new_table {
      results = results,

      ---@param result grapple.telescope.result
      entry_maker = function(result)
        local filename = result[2]
        local lnum = result[3]

        local entry = {
          value = result,
          ordinal = filename,
          filename = filename,
          lnum = lnum,
          display = function(entry)
            local tail, pathToDisplay = telescopePickers.getPathAndTail(entry.value[2])
            local icon, iconHighlight = telescopeUtilities.get_devicons(tail)
            local tailForDisplay = string.len(tail) > 0 and tail or 'window'
            local bufnr = get_buffer_number_by_path(filename)
            local modified = vim.api.nvim_get_option_value('modified', { buf = bufnr })

            return displayer {
              { icon, iconHighlight },
              { tailForDisplay .. ' ', bufnr and modified and 'TelescopeResultsNumber' or '' },
              { pathToDisplay, 'TelescopeResultsComment' },
            }
          end,
        }

        return entry
      end,
    }
  end

  local function delete_tag(prompt_bufnr)
    local selection = action_state.get_selected_entry()

    Grapple.untag { path = selection.filename }

    local current_picker = action_state.get_current_picker(prompt_bufnr)
    current_picker:refresh(generate_finder(), { reset_prompt = true })
  end

  pickers
    .new(options, {
      prompt_title = 'Grapple',
      finder = generate_finder(),
      sorter = conf.generic_sorter {},
      previewer = conf.file_previewer {},
      results_title = 'Grapple Tags',
      attach_mappings = function(_, map)
        map('i', '<C-X>', delete_tag)
        map('n', '<C-X>', delete_tag)
        return true
      end,
    })
    :find()
end

-- Return the module for use
return telescopePickers
