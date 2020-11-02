-- Copyright (c) 2016 Martin Ridgers
-- License: http://opensource.org/licenses/MIT

--------------------------------------------------------------------------------
clink = clink or {}
local prompt_filters = {}
local prompt_filters_unsorted = false



--------------------------------------------------------------------------------
function clink._filter_prompt(prompt)
    -- Sort by priority if required.
    if prompt_filters_unsorted then
        local lambda = function(a, b) return a._priority < b._priority end
        table.sort(prompt_filters, lambda)

        prompt_filters_unsorted = false
    end

    -- Protected call to prompt filters.
    local impl = function(prompt)
        for _, filter in ipairs(prompt_filters) do
            local filtered, onwards = filter:filter(prompt)
            if filtered ~= nil then
                if onwards == false then return filtered end
                prompt = filtered
            end
        end

        return prompt
    end

    local ok, ret = pcall(impl, prompt)
    if not ok then
        print("")
        print(ret)
        print(debug.traceback())
        return false
    end

    return ret
end

--------------------------------------------------------------------------------
--- -name:  clink.promptfilter
--- -arg:   [priority:integer]
--- -ret:   table
function clink.promptfilter(priority)
    if priority == nil then priority = 999 end

    local ret = { _priority = priority }
    table.insert(prompt_filters, ret)

    prompt_filters_unsorted = true
    return ret
end

--------------------------------------------------------------------------------
--- -name:  clink.prompt.register_filter
--- -arg:   filter_func
--- -arg:   [priority:integer]
--- -ret:   table
--- Old API shim, for backward compatibility.
clink.prompt = clink.prompt or {}
function clink.prompt.register_filter(filter, priority)
    if priority == nil then
        priority = 999
    end

    local o = clink.promptfilter(priority)
    function o:filter(the_prompt)
        clink.prompt.value = the_prompt
        local stop = filter(the_prompt)
        return clink.prompt.value, not stop
    end
end