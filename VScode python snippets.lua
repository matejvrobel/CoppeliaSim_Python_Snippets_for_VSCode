sim = require 'sim'

function sysCall_info()
    return {autoStart=false, menu='Exporters\nVSCode Python snippets'}
end

function sysCall_init()
    local funcs = sim.getApiFunc(-1, '+')
    table.sort(funcs)
    local consts = sim.getApiFunc(-1, '-')
    table.sort(consts)

    local finalTxt = "{\n"

    for i=1,#funcs do
        local funcName = funcs[i]
        --keep only functions with "sim" in it
        if not string.find(funcName, "sim") then
            goto continue
        end
        local s = sim.getApiInfo(-1, funcName)
        if s and not string.find(string.lower(s), "deprecated") then
            s = string.gsub(s, "\n","")
            local ep = string.find(s, ")")
            if ep then
                s = string.sub(s,1,ep-1)
                ep = string.find(s,"%(")
                if ep then
                    local args = string.sub(s,ep+1)
                    local params = {}
                    local params_dec = {}
                    local idx = 1
                    for param in string.gmatch(args,"([^,]+)") do
                        if not string.find(param, "=") then
                            table.insert(params,"$"..idx)
                            idx = idx + 1
                        end
                        param = string.gsub(param,"^%s*(.-)%s*$","%1")
                        param = string.gsub(param, "float%[%d+%]", "list")
                        param = string.gsub(param, "int%[%d+%]", "list")
                        param = string.gsub(param, "map", "dict")
                        param = string.gsub(param, "string", "str")
                        param = string.gsub(param, "nil", "None")
                        param = string.gsub(param, '"', '\\"')
                        table.insert(params_dec, param)
                    end
                    local bodyStr = funcName.."("..table.concat(params,", ")..")"
                    finalTxt = finalTxt..'  "'..funcName..'": {\n'
                    finalTxt = finalTxt..'    "prefix": "'..funcName..'",\n'
                    finalTxt = finalTxt..'    "body": ["'..bodyStr..'"],\n'
                    finalTxt = finalTxt..'    "description": "'..funcName..'('..table.concat(params_dec,", ")..')"\n'
                    finalTxt = finalTxt..'  }'
                    if i<#funcs then finalTxt = finalTxt..',' end
                    finalTxt = finalTxt..'\n'
                end
            end
        end
        ::continue::
    end

    for i, const in ipairs(consts) do
        --keep only constants with "sim" in it
        if string.find(const, "sim") then
            finalTxt = finalTxt..'  "'..const..'": {\n'
            finalTxt = finalTxt..'    "prefix": "'..const..'",\n'
            finalTxt = finalTxt..'    "body": ["'..const..'"],\n'
            finalTxt = finalTxt..'  }'
            if i<#funcs then finalTxt = finalTxt..',' end
            finalTxt = finalTxt..'\n'
        end
    end

    finalTxt = finalTxt.."}\n"

    local file = io.open("coppeliasim_snippets.code-snippets","w")
    file:write(finalTxt)
    io.close(file)
    sim.addLog(sim.verbosity_msgs,"Wrote 'coppeliasim_snippets.code-snippets'")

    return {cmd='cleanup'}
end
