kt = Kontakt
fs = Filesystem

INSTRUMENT_IDX = 0

local SAMPLES_PATH = fs.preferred("E:/Dropbox/emergence audio - gabriel/From Emergence Audio/Flux Test Samples/Flux Mapping Test Samples")

for i=0, 50 do
    print("\n")
end

local MAPPING_REPORT = false

-- DO NOT CHANGE
local ZONE_GROUP = 2
local ZONE_ROOT  = 3
local ZONE_VELO  = 4
local ZONE_RDRB  = 5

-- data declaration
local samples_to_map = {}
local group_names = {}
local group_data = {}
local first_group = true

function filename_tokens_into_table(file, separator_char)
	separator_char = separator_char or "_"
	if type(separator_char) ~= "string" or #separator_char ~= 1 then
        error("Separator must be a single character string.")
    end
	local tokens_table = {}
	local wav =  fs.filename(file)
	for token in wav:gmatch("[^" .. separator_char .. "]+") do
		table.insert(tokens_table, token)
	end 
	return tokens_table
end

function find_group_index(group_name)
    local group_index = -1
    for i = 0, kt.get_num_groups(INSTRUMENT_IDX) - 1 do
        if kt.get_group_name(INSTRUMENT_IDX, i) == group_name then
            return i
        end
    end
    return -1
end

function read_sample_files_data()
    -- capture all files in the given directory and group names
    for _, p in fs.directory(SAMPLES_PATH) do
        table.insert(samples_to_map, {
            ["path"] = fs.parent_path(p),
            ["filename"] = fs.filename(p),
            ["full_path"] = p,
            ["mapped"] = false
        })
        local tokens     = filename_tokens_into_table(fs.filename(p))
        local group_name = tokens[ZONE_GROUP]
    
        -- only insert if not already present
        local exists = false
        for _, name in ipairs(group_names) do
            if name == group_name then
                exists = true
                break
            end
        end
    
        if not exists then
            table.insert(group_names, group_name)
        end
    end
end

function reset_instrument()
    -- reset groups and zones in Kontakt
    while kt.get_num_groups(INSTRUMENT_IDX) > 1 do
        kt.remove_group(0,0)
    end
    while kt.get_num_zones(0) > 0 do
        kt.remove_zone(0,0)
    end
end

function map_first_layer()
    for index, item in ipairs(samples_to_map) do
        local sample_path = samples_to_map[index]["full_path"]
        local tokens = filename_tokens_into_table(samples_to_map[index]["filename"])
        local zone_root_key   = tonumber(tokens[ZONE_ROOT])
        local zone_velo       = tonumber(tokens[ZONE_VELO])
        local group_name      = tokens[ZONE_GROUP]
        local zone_roundrobin = string.gsub( tokens[ZONE_RDRB], ".wav", "" )

        -- create group if group doesn't exist

        local item_group_index = find_group_index(group_name)

        if item_group_index == -1 then
            if kt.get_num_groups(INSTRUMENT_IDX) == 1 and first_group then
                kt.set_group_name(INSTRUMENT_IDX, 0, group_name)
                first_group = false
                item_group_index = 0
            else
                local new_group_index = kt.add_group(INSTRUMENT_IDX)
                kt.set_group_name(INSTRUMENT_IDX, new_group_index, group_name)
                item_group_index = new_group_index
            end
        end

        if MAPPING_REPORT then
            print("Adding zone to group: " .. group_name .. " | Sample path: " .. sample_path)
            print("\tRoot key: " .. zone_root_key)
            print("\tVelocity: " .. zone_velo)
            print("\tRR: " .. zone_roundrobin)
        end

        local new_zone_index = kt.add_zone(INSTRUMENT_IDX, item_group_index, sample_path)

        local zone_geometry = {
            root_key            = zone_root_key,
            low_key             = zone_root_key,
            high_key            = zone_root_key,
            low_key_fade        = 0,   -- (default: 0, range: 0 ... span),
            high_key_fade       = 0,   -- (default: 0, range: 0 ... span),
            low_velocity        = zone_velo + (zone_roundrobin-1) * 10,
            high_velocity       = zone_velo + (zone_roundrobin-1) * 10,
            low_velocity_fade   = 0,   -- (default: 0, range: 0 ... span),
            high_velocity_fade  = 0    -- (default: 0, range: 0 ... span)
        }

        kt.set_zone_geometry(INSTRUMENT_IDX, new_zone_index, zone_geometry)

        if group_data[group_name] == nil then
            group_data[group_name] = {}
        end
        if group_data[group_name][zone_root_key] == nil then
            group_data[group_name][zone_root_key] = {}
        end
        table.insert(group_data[group_name][zone_root_key], { 
            ["index"] = new_zone_index,
            ["zone_path"] = sample_path,
        })
    end
end

function duplicate_groups()
    for _, group_name in pairs(group_names) do
        -- create group if duplicated group doesn't exist
        local group_duplicated = 0
        local group_index = -1
        for g = 0, kt.get_num_groups(INSTRUMENT_IDX) - 1 do
            if kt.get_group_name(INSTRUMENT_IDX, g) == group_name then
                group_duplicated = group_duplicated + 1
                group_index = g
            end
        end
        if group_duplicated == 1 then
            group_index = kt.add_group(INSTRUMENT_IDX)
            kt.set_group_name(INSTRUMENT_IDX, group_index, group_name)
        end
        -- add all zones to the duplicated group
        for root, zones in pairs(group_data[group_name]) do
            for _, zone_data in pairs(zones) do
                local zone_geometry = kt.get_zone_geometry(INSTRUMENT_IDX, zone_data['index'])
                local new_zone_index = kt.add_zone(INSTRUMENT_IDX, group_index, zone_data['zone_path'])
                kt.set_zone_geometry(INSTRUMENT_IDX, new_zone_index, zone_geometry)
            end

        end
    end
end

function rename_groups()
    local group_count = kt.get_num_groups(INSTRUMENT_IDX)
    for g = 0, group_count - 1 do
        local current_group_name = kt.get_group_name(INSTRUMENT_IDX, g)
        if g < group_count // 2 then
            kt.set_group_name(INSTRUMENT_IDX, g, "LEFT  | " .. current_group_name)
        else
            kt.set_group_name(INSTRUMENT_IDX, g, "RIGHT | " .. current_group_name)
        end
    end
end


-- Run the script
read_sample_files_data()
reset_instrument()
map_first_layer()
duplicate_groups()
rename_groups()

