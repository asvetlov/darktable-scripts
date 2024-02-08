--[[

    sync_group_rate.lua - sync all rates for all images in the group

    Copyright (C) 2024 Andrew Svetlov <andrew.svetlov@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]
--[[
    sync_group_rate - sync all rates for all images in the group

    sync_group_rate does it's job

    cycle_group_leader changes the group leader to the next
    image in the group.  If the end of the group is reached
    then the next image is wrapped around to the first image.

    ADDITIONAL SOFTWARE NEEDED FOR THIS SCRIPT
    None

    USAGE
    * enable with script_manager
    * assign a key to the shortcut

    BUGS, COMMENTS, SUGGESTIONS
    Bill Ferguson <wpferguson@gmail.com>

    CHANGES
]]

local dt = require "darktable"
local du = require "lib/dtutils"
local df = require "lib/dtutils.file"

-- - - - - - - - - - - - - - - - - - - - - - - -
-- C O N S T A N T S
-- - - - - - - - - - - - - - - - - - - - - - - -

local MODULE = "sync_group_rate"

-- - - - - - - - - - - - - - - - - - - - - - - -
-- A P I  C H E C K
-- - - - - - - - - - - - - - - - - - - - - - - -

du.check_min_api_version("7.0.0", MODULE)


-- - - - - - - - - - - - - - - - - - - - - - - - - -
-- S C R I P T  M A N A G E R  I N T E G R A T I O N
-- - - - - - - - - - - - - - - - - - - - - - - - - -

local script_data = {}

script_data.destroy = nil -- function to destory the script
script_data.destroy_method = nil -- set to hide for libs since we can't destroy them commpletely yet
script_data.restart = nil -- how to restart the (lib) script after it's been hidden - i.e. make it visible again
script_data.show = nil -- only required for libs since the destroy_method only hides them

-- - - - - - - - - - - - - - - - - - - - - - - -
-- M A I N  P R O G R A M
-- - - - - - - - - - - - - - - - - - - - - - - -

local function sync_group_rate(image)
  local group_images = image:get_group_members()
  local has_rejected = false
  for i, img in ipairs(group_images) do
    if img.rating == -1 then
      has_rejected = true
    end
  end
  if has_rejected then
    for i, img in ipairs(group_images) do
      img.rating = -1
    end
  end
end

-- - - - - - - - - - - - - - - - - - - - - - - -
-- D A R K T A B L E  I N T E G R A T I O N
-- - - - - - - - - - - - - - - - - - - - - - - -

local function destroy()
  -- put things to destroy (events, storages, etc) here
  dt.destroy_event(MODULE, "shortcut")
end

script_data.destroy = destroy

-- - - - - - - - - - - - - - - - - - - - - - - -
-- E V E N T S
-- - - - - - - - - - - - - - - - - - - - - - - -

dt.register_event(MODULE, "shortcut",
  function(event, shortcut)
    -- ignore the film roll, it contains all the images, not just the imported
    local images = dt.gui.selection()
    for i, img in ipairs(images) do
      sync_group_rate(img)
    end
  end,
  "sync group rate"
)

return script_data
