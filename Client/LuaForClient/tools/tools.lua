Trace = function(msg)
	local int,digit = math.modf(socket.gettime());
	digit = string.format("%.2f", digit);
	local _date = lua_to_db_time(int).."."..(digit*100);
	--print(os.date("%Y-%m-%d %X ", os.time())..msg);

	print(_date.." "..msg);
end
TraceError = Trace;

check_file_exist = function(file)
	local exist = false;
	local tag_file = io.open(file);
	if tag_file ~= nil then
		exist = true;
		io.close(tag_file);
	end
	return exist;
end

toutf8 = function(tag_file)
	OS_EXEC("mv "..tag_file.." "..tag_file..".cv");
	OS_EXEC("iconv --from-code=CP936 --to-code=UTF-8 "..tag_file..".cv".." -o "..tag_file);
	--OS_EXEC("rm "..tag_file..".cv");
end

--lua ±ÔøΩÔøΩ◊™ÔøΩÔøΩŒ™ÔøΩÔøΩÔøΩ›øÔøΩ ±ÔøΩÔøΩÔøΩ Ω
function lua_to_db_time(lua_time)
	if type(lua_time) ~= "number" then
		error("lua_to_db_timeÔøΩÔøΩÔøΩÔøΩÔøΩÀ¥ÔøΩÔøΩÔøΩÔøΩ ±ÔøΩÔøΩÔøΩ Ω")
		return "1970-1-1 0:0:0"
	end
    return os.date("%Y-%m-%d %X", lua_time)
end

--ÔøΩÔøΩÔøΩ›øÔøΩ ±ÔøΩÔøΩ◊™ÔøΩÔøΩŒ™lua ±ÔøΩÔøΩÔøΩ Ω
function db_to_lua_time(db_time)
	local time = {}
	for i in string.gmatch(db_time, "%d+") do
		table.insert(time, i)
	end
	if #time == 0 then
		return 0
	end
	local lua_time = os.time{year = time[1], month = time[2], day = time[3], hour = time[4], min = time[5], sec = time[6]}
	return lua_time
end

function getdayfromto(daytime)
	local std = db_to_lua_time("2013-01-01 00:00:00");
	local day_start = daytime - math.mod(daytime - std, 24*3600);
	local day_end = day_start + 24*3600;
	return day_start, day_end
end

function is_endmonth(timeparam)
	local timenext = timeparam + 24*3600;
	if os.date("%Y-%m", timeparam) ~= os.date("%Y-%m", timenext) then
		return true;
	end
	return false;
end

function split(s, delim)
	if s == nil or delim == nil then
		TraceError(debug.traceback());
	end

	assert (type (delim) == "string" and string.len (delim) > 0,"bad delimiter")
	local start = 1  local t = {}
	while true do
		local pos = string.find (s, delim, start, true) -- plain find
		if not pos then
			break
		end
		table.insert (t, string.sub (s, start, pos - 1))
		start = pos + string.len (delim)
	end
	table.insert (t, string.sub (s, start))
	return t
end

function tostringex(v, len, strsize)
	if len == nil then len = 0 end
    if strsize == nil then strsize = 0 end
	local pre = string.rep('\t', len)
	local ret = ""

	if type(v) == "table" then
		if len > 10 then return "\t{ ... }" end
		local t = ""
		local keys = {}
		for k, v1 in pairs(v) do
			table.insert(keys, k)
		end
		--table.sort(keys)
        --ÔøΩÔøΩ–°ÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩ›πÈ£¨3kÔøΩÔøΩ–°ÔøΩÔøΩŒ™ÔøΩÔøΩÔøΩÔøΩ
		for k, v1 in pairs(keys) do
			k = v1
			v1 = v[k]
			t = t .. "\n\t" .. pre .. tostring(k) .. ":"
			t = t .. tostringex(v1, len + 1, strsize + string.len(t));
		end
		if t == "" then
			ret = ret .. pre .. "{ }\t(" .. tostring(v) .. ")"
		else
			if len > 0 then
				ret = ret .. "\t(" .. tostring(v) .. ")\n"
			end
			ret = ret .. pre .. "{" .. t .. "\n" .. pre .. "}"
		end
	else
		ret = ret .. pre .. tostring(v) .. "\t(" .. type(v) .. ")"
	end
	return ret
end

_readTxtFile = function(fileName)
	local fileIsExit = cc.FileUtils:getInstance():isFileExist(fileName)
    if fileIsExit == false then
		TraceError("Êâæ‰∏çÂà∞ËØ•Êñá‰ª∂" .. tostring(fileName))
		return
	end

    local fileData = cc.FileUtils:getInstance():getStringFromFile(fileName);
    if fileData == "" then
        TraceError(fileName.." empty file,please check out");
    end

	if (string.byte(fileData, 1, 1) == 0xEF) then
		fileData = string.sub(fileData, 4);
	else
		TraceError("∑«UTF-8¥¯BOMÕ∑µƒŒƒº˛:"..fileName);
	end

	local rows = split(fileData, "\r\n");
	local tab = {};
	for k,v in pairs(rows) do
		local subtab = StringToTable(v);
		if subtab then
			table.insert(tab, #tab+1, subtab);
		end
	end

	return tab;
end

_readTabFile = function(fileName)
	--assert(fileName)
    local fileIsExit = cc.FileUtils:getInstance():isFileExist(fileName)
    if fileIsExit == false then
		TraceError("≤ª¥Ê‘⁄" .. tostring(fileName))
		return
	end

    local fileData = cc.FileUtils:getInstance():getStringFromFile(fileName);

    if fileData == "" then
        TraceError(fileName.." empty file,please check out");
    end

	if (string.byte(fileData, 1, 1) == 0xEF) then
		fileData = string.sub(fileData, 4);
	else
		TraceError("∑«UTF-8¥¯BOMÕ∑µƒŒƒº˛:"..fileName);
	end

	--print("rows:"..fileData);
	local rows = split(fileData, "\r\n")
	local ret = {}
	local colNames = nil
	local cltCol = nil
	for i = 1, #rows do
		local row = rows[i]
		if row and row ~= "" then
			if string.sub(row, 1, 1) ~= "#" then
				local col = split(row, "\t");
				if not colNames then
					colNames = col
				else
					local item = {}
					local itemId = tonumber(col[1])
					if itemId == nil then
						TraceError("\n\tread "..fileName.." wrongly error code row:"..i);
					end

					assert(itemId);
					for i = 1, #col do
						if colNames[i] ~= "" and (cltCol == nil or tonumber(cltCol[i]) ~= 1 ) then
							local value = col[i]
							if string.char(1) == '"' and string.char() == '"' then
								-- ÷ßÔøΩÔøΩÀ´ÔøΩÔøΩÔøΩ≈µÔøΩÔøΩÔøΩÔøΩ›£ÔøΩÔøΩÔøΩÔøΩÔøΩExcel
								value = string.sub(value, 2, string.len() - 1);
							end

							if string.sub(colNames[i], 1, 2) == "sz" then
								if col[i] == "" then
									value = nil;
								else
									value = col[i];
								end
								--assert(col[i] == "" or value, colNames[i])
							elseif string.sub(colNames[i], 1, 2) == "b_" then
								if tonumber(col[i]) == 1 then
									value = true;
								else
									value = false;
								end
							elseif string.sub(colNames[i], 1, 2) == "tb" then
								value = StringToTable(col[i]);
							else
								--value = _U(col[i]);
								value = tonumber(col[i]) or 0
							end

							--if value and string.find(value, "\"") then
								--assert(false, fileName .. " ÔøΩÔøΩÔøΩ‹∞ÔøΩÔøΩÔøΩÀ´ÔøΩÔøΩÔøΩÔøΩ" .. value)
							--end
							item[colNames[i]] = value
						end
					end
					if ret[itemId] then
						assert(false, fileName .. " ÔøΩÔøΩÔøΩÿ∏ÔøΩ id:" .. itemId .. tostringex(colNames))
					end
					--TraceError(itemId);
					ret[itemId] = item
				end
			elseif string.sub(row, 1, 7) == "#CLIENT" then
				--cltCol = split(row, "\t");
			end
		end
    end
	return ret
end

local g_tabConf = {};
readTabFile = function(fileName)
	if not fileName then
		return nil;
	end

	if not g_tabConf[fileName] then
		if string.find(fileName, ".tab") then
			g_tabConf[fileName] = _readTabFile(fileName);
		elseif string.find(fileName, ".txt") then
			g_tabConf[fileName] = _readTxtFile(fileName);
		end
	end

	return g_tabConf[fileName];
end

OS_EXEC = function(cmd)
	Trace(cmd);
	os.execute(cmd);
end

StringToTable = function(str)
	if not str then
		return nil;
	end

    local _str = "return "..str
    local func = loadstring(_str)

	if not func then
		print("StringToTable error str:".._str);
	end

    return func();
end

