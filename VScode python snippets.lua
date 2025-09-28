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
                --float[], float[3], float[3..9], float[3..*] -> list
                s = string.gsub(s, "float%[[^%]]*%]", "list")
                s = string.gsub(s, "int%[[^%]]*%]", "list")
                s = string.gsub(s, "any%[[^%]]*%]", "list")
                s = string.gsub(s, "string%[[^%]]*%]", "list")
                s = string.gsub(s, "map%[[^%]]*%]", "list")

                s = string.gsub(s, "map", "dict")
                s = string.gsub(s, "string", "str")
                s = string.gsub(s, "nil", "None")
                s = string.gsub(s, "true", "True")
                s = string.gsub(s, "false", "False")
                s = string.gsub(s, '"', '\\"')

                s = string.sub(s,1,ep-1)
                ep = string.find(s,"%(")
                if ep then
                    local args = string.sub(s,ep+1)
                    local params = {}
                    local params_dec = {}
                    local idx = 1

                    local pres = ""
                    if ep then pres = string.sub(s, 0, ep - 1) end
                    
                    for param in string.gmatch(args,"([^,]+)") do
                        if not string.find(param, "=") then
                            table.insert(params,"$"..idx)
                            idx = idx + 1
                        end
                        param = string.gsub(param,"^%s*(.-)%s*$","%1")
                        table.insert(params_dec, param)
                    end
                    local bodyStr = funcName.."("..table.concat(params,", ")..")"
                    finalTxt = finalTxt..'  "'..funcName..'": {\n'
                    finalTxt = finalTxt..'    "prefix": "'..funcName..'",\n'
                    finalTxt = finalTxt..'    "body": ["'..bodyStr..'"],\n'
                    finalTxt = finalTxt..'    "description": "'..pres..'('..table.concat(params_dec,", ")..')"\n'
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

    local file = io.open("coppeliasim_py.code-snippets","w")
    file:write(finalTxt)
    io.close(file)
    sim.addLog(sim.verbosity_msgs,"Wrote 'coppeliasim_py.code-snippets'")

    return {cmd='cleanup'}
end
