-----------------------------------------------------------------------------------------------
--                                    OBS TEXT FLASHER                                       --
--                          CREATED BY JOSIAH ANYINSAH-BONDZIE                               --
-----------------------------------------------------------------------------------------------

obs = obslua

-- USER SETTINGS
local source_name    = ""
local flash_interval = 500
local col1, col2     = 0xFFFFFFFF, 0xFF0000FF  -- default white & red (AABBGGRR)

-- INTERNAL STATE
local hotkey_id     = obs.OBS_INVALID_HOTKEY_ID
local is_flashing   = false
local flash_src     = nil
local orig_color    = 0
local toggle_state  = false  -- false→col1, true→col2

-- CACHE API FUNCTIONS LOCALLY
local timer_add        = obs.timer_add
local timer_remove     = obs.timer_remove
local get_source       = obs.obs_get_source_by_name
local source_update    = obs.obs_source_update
local source_get_data  = obs.obs_source_get_settings
local data_set_int     = obs.obs_data_set_int
local data_get_int     = obs.obs_data_get_int
local data_release     = obs.obs_data_release
local source_release   = obs.obs_source_release

-- FLASH CALLBACK: swap between col1/col2 on each tick
local function flash_callback()
  if not flash_src then return end
  local settings = source_get_data(flash_src)
  data_set_int(settings, "color", toggle_state and col2 or col1)
  source_update(flash_src, settings)
  data_release(settings)
  toggle_state = not toggle_state
end

-- HOTKEY HANDLER: start/stop flashing
local function on_hotkey(pressed)
  if not pressed then return end

  if not is_flashing then
    flash_src = get_source(source_name)
    if not flash_src then return end

    -- save original color
    local settings = source_get_data(flash_src)
    orig_color = data_get_int(settings, "color")
    data_release(settings)

    toggle_state = false
    timer_add(flash_callback, flash_interval)
    is_flashing = true
  else
    timer_remove(flash_callback)
    if flash_src then
      -- restore original color
      local settings = source_get_data(flash_src)
      data_set_int(settings, "color", orig_color)
      source_update(flash_src, settings)
      data_release(settings)

      source_release(flash_src)
      flash_src = nil
    end

    is_flashing = false
  end
end

-- BUILD PROPERTIES UI
function script_properties()
  local props = obs.obs_properties_create()

  -- editable dropdown of text sources
  local p = obs.obs_properties_add_list(props, "source", "Text Source",
                obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
  -- populate once at load
  local sources = obs.obs_enum_sources()
  if sources then
    for _, src in ipairs(sources) do
      local id = obs.obs_source_get_id(src)
      if id == "text_gdiplus_v3" then
        local name = obs.obs_source_get_name(src)
        obs.obs_property_list_add_string(p, name, name)
      end
    end
    obs.source_list_release(sources)
  end

  obs.obs_properties_add_int(props,   "interval", "Flash Interval (ms)", 50, 2000, 50)
  obs.obs_properties_add_color(props, "col1",     "First Colour")
  obs.obs_properties_add_color(props, "col2",     "Second Colour")

  return props
end

-- UPDATE SETTINGS
function script_update(settings)
  source_name    = obs.obs_data_get_string(settings, "source")
  flash_interval = obs.obs_data_get_int(settings, "interval")
  col1           = obs.obs_data_get_int(settings, "col1")
  col2           = obs.obs_data_get_int(settings, "col2")
end

-- REGISTER HOTKEY
function script_load(settings)
  hotkey_id = obs.obs_hotkey_register_frontend("flash.toggle", "Toggle Flashing", on_hotkey)
  local hotkey_array = obs.obs_data_get_array(settings, "flash.hotkey")
  obs.obs_hotkey_load(hotkey_id, hotkey_array)
  obs.obs_data_array_release(hotkey_array)
end

function script_save(settings)
  local hotkey_array = obs.obs_hotkey_save(hotkey_id)
  obs.obs_data_set_array(settings, "flash.hotkey", hotkey_array)
  obs.obs_data_array_release(hotkey_array)
end

-- CLEANUP ON UNLOAD
function script_unload()
  if is_flashing and flash_src then
    local settings = obs.obs_source_get_settings(flash_src)
    data_set_int(settings, "color", orig_color)
    source_update(flash_src, settings)
    data_release(settings)
    source_release(flash_src)
  end
end

function script_description()
  return [[
Toggle a flashing effect on a text source with minimal overhead.

1. Select your text source (dropdown + editable).  
2. Pick your interval and two colours.  
3. Bind “Toggle Flashing” in Settings → Hotkeys.  
4. Press your hotkey to start/stop.
]]
end
