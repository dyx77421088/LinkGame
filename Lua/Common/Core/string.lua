--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:对字符串进行处理
--     创建时间:2021/09/24 
--------------------------------------------------------------------------------
--string扩展

string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

--非正则替换
function string.replace(s, pat, repl, n)
    local list = {"(", ")", ".", "%", "+", "-", "*", "?", "[", "^", "$"}
    for k, v in ipairs(list) do
        pat = string.gsub(pat, "%"..v, "%%"..v)
    end
    return string.gsub(s, pat, repl, n)
end

function string.startwith(s, starts)
    if #starts > #s then
        return false
    end
    for i = 1, #starts do
        if string.byte(s, i) ~= string.byte(starts, i) then
            return false
        end
    end
    return true
end

function string.endwith(s, ends)
    local lenS = #s
    local lenEnds = #ends
    if lenEnds > lenS then
        return false
    end
    local offset = lenS - lenEnds
    for i = 1, lenEnds do
        if string.byte(s, offset+i) ~= string.byte(ends, i) then
            return false
        end
    end
    return true
end

--[[--

将特殊字符转为 HTML 转义符

~~~ lua

print(string.htmlspecialchars("<ABC>"))
-- 输出 &lt;ABC&gt;

~~~

@param string input 输入字符串

@return string 转换结果

]]
function string.htmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, k, v)
    end
    return input
end

--[[--

将 HTML 转义符还原为特殊字符，功能与 string.htmlspecialchars() 正好相反

~~~ lua

print(string.restorehtmlspecialchars("&lt;ABC&gt;"))
-- 输出 <ABC>

~~~

@param string input 输入字符串

@return string 转换结果

]]
function string.restorehtmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, v, k)
    end
    return input
end

--[[--

将字符串中的 \n 换行符转换为 HTML 标记

~~~ lua

print(string.nl2br("Hello\nWorld"))
-- 输出
-- Hello<br />World

~~~

@param string input 输入字符串

@return string 转换结果

]]
function string.nl2br(input)
    return string.gsub(input, "\n", "<br />")
end

--[[--

将字符串中的特殊字符和 \n 换行符转换为 HTML 转移符和标记

~~~ lua

print(string.nl2br("<Hello>\nWorld"))
-- 输出
-- &lt;Hello&gt;<br />World

~~~

@param string input 输入字符串

@return string 转换结果

]]
function string.text2html(input)
    input = string.gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string.gsub(input, " ", "&nbsp;")
    input = string.nl2br(input)
    return input
end

--[[--

用指定字符或字符串分割输入字符串，返回包含分割结果的数组

~~~ lua

local input = "Hello,World"
local res = string.split(input, ",")
-- res = {"Hello", "World"}

local input = "Hello-+-World-+-Quick"
local res = string.split(input, "-+-")
-- res = {"Hello", "World", "Quick"}

~~~

@param string input 输入字符串
@param string delimiter 分割标记字符或字符串

@return array 包含分割结果的数组

]]
function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

--[[--

去除输入字符串头部的空白字符，返回结果

~~~ lua

local input = "  ABC"
print(string.ltrim(input))
-- 输出 ABC，输入字符串前面的两个空格被去掉了

~~~

空白字符包括：

-   空格
-   制表符 \t
-   换行符 \n
-   回到行首符 \r

@param string input 输入字符串

@return string 结果

@see string.rtrim, string.trim

]]
function string.ltrim(input)
    return string.gsub(input, "^[ \t\n\r]+", "")
end

--[[--

去除输入字符串尾部的空白字符，返回结果

~~~ lua

local input = "ABC  "
print(string.ltrim(input))
-- 输出 ABC，输入字符串最后的两个空格被去掉了

~~~

@param string input 输入字符串

@return string 结果

@see string.ltrim, string.trim

]]
function string.rtrim(input)
    return string.gsub(input, "[ \t\n\r]+$", "")
end

--[[--

去掉字符串首尾的空白字符，返回结果

@param string input 输入字符串

@return string 结果

@see string.ltrim, string.rtrim

]]
function string.trim(input)
    input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end

--[[--

将字符串的第一个字符转为大写，返回结果

~~~ lua

local input = "hello"
print(string.ucfirst(input))
-- 输出 Hello

~~~

@param string input 输入字符串

@return string 结果

]]
function string.ucfirst(input)
    return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
end

local function urlencodechar(char)
    return "%" .. string.format("%02X", string.byte(char))
end

--[[--

将字符串转换为符合 URL 传递要求的格式，并返回转换结果

~~~ lua

local input = "hello world"
print(string.urlencode(input))
-- 输出
-- hello%20world

~~~

@param string input 输入字符串

@return string 转换后的结果

@see string.urldecode

]]
function string.urlencode(input)
    -- convert line endings
    input = string.gsub(tostring(input), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    input = string.gsub(input, "([^%w%.%- ])", urlencodechar)
    -- convert spaces to "+" symbols
    return string.gsub(input, " ", "+")
end

function string.isblankchar(input, i)
    local c = string.byte(input, i)
    -- 32:" ", 9:"\t", 10:"\n", 13:"\r"
    return c == 32 or c == 9 or c == 10 or c == 13
end

--判定是否是空白字符串
function string.isBlank( input )
    if input == nil then return true end

    for i = 1, #input do
        if (not string.isblankchar(input, i)) then
            return false
        end
    end
    return true
end

function string.isNotBlank( input )
    return not string.isBlank(input)
end

function string.isNullOrEmpty(str)
    return (not str) or (#str == 0)
end

--[[--

将 URL 中的特殊字符还原，并返回结果

~~~ lua

local input = "hello%20world"
print(string.urldecode(input))
-- 输出
-- hello world

~~~

@param string input 输入字符串

@return string 转换后的结果

@see string.urlencode

]]
function string.urldecode(input)
    input = string.gsub (input, "+", " ")
    input = string.gsub (input, "%%(%x%x)", function(h) return string.char(checknumber(h,16)) end)
    input = string.gsub (input, "\r\n", "\n")
    return input
end

--[[--

计算 UTF8 字符串的长度，每一个中文算一个字符

~~~ lua

local input = "你好World"
print(string.utf8len(input))
-- 输出 7

~~~

@param string input 输入字符串

@return integer 长度

]]
function string.utf8len(input)
    local len  = string.len(input)
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end


-- 截取utf8 字符串
-- str:            要截取的字符串
-- startChar:    开始字符下标,从1开始
-- numChars:    要截取的字符长度
function string.utf8sub(str, startChar, numChars)

    local chsize = function(ch)
        if not ch then return 0
        elseif ch >=252 then return 6
        elseif ch >= 248 and ch < 252 then return 5
        elseif ch >= 240 and ch < 248 then return 4
        elseif ch >= 224 and ch < 240 then return 3
        elseif ch >= 192 and ch < 224 then return 2
        elseif ch < 192 then return 1
        end
    end

    local startIndex = 1
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + chsize(char)
        startChar = startChar - 1
    end

    local currentIndex = startIndex

    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        numChars = numChars -1
    end
    return str:sub(startIndex, currentIndex - 1)
end

--[[--

将数值格式化为包含千分位分隔符的字符串

~~~ lua

print(string.formatnumberthousands(1924235))
-- 输出 1,924,235

~~~

@param number num 数值

@return string 格式化结果

]]
function string.formatnumberthousands(num)
    local formatted = tostring(checknumber(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

--return HH:MM:SS
function string.ConvertNumToHMSStr(num)
    -- body
    local h = math.floor(num / 3600)
    local m = math.floor((num % 3600) / 60) 
    local s = math.floor((num % 3600) % 60)
    return string.format("%02d : %02d : %02d", h, m, s)
end

--str1<str2 ret: -1,
--str1=str2 ret: 0,
--str1>str2 ret: 1,
function string.compare(str1, str2)
    str1 = string.lower(str1)
    str2 = string.lower(str2)
    local i = 1
    local lenStr1 = string.len(str1)
    while i <= lenStr1 do
        local char1 = string.byte(str1, i, i)
        local char2 = string.byte(str2, i, i)
        if not char2 then
            return 1
        end
        if char1 > char2 then
           return 1
        elseif char1 < char2 then
           return -1
        else
            i = i + 1
        end
    end
    return 0
end

function string.hex2number(str)
    if str then
        return tonumber("0x"..str)
    end
end

--由传入的数字 获得固定长度的字符串
function string.GetFixedCntNumString(num, cnt)
    local temp = 10 ^ cnt
    local v = num % temp / temp
    local formatStr = "%."..tostring(cnt)..'f'
    local s = string.format(formatStr, v)
    return s:gsub("^0%.", "")
end


-- 拆分汉字与英文
-- chars: 字的列表
-- lens: 每个字对应的byte长度列表
function string.SplitString(str)
	if str == nil then
		return nil
	end

	local lenInByte = #str
	local chars = {}
	local lens = {}
	
	local i = 1
	while i <= lenInByte do
		local curByte = string.byte(str, i)
		local byteCount = 1
		if curByte>0 and curByte<=127 then
			byteCount = 1
		elseif curByte>=192 and curByte<223 then
			byteCount = 2
		elseif curByte>=224 and curByte<=239 then
			byteCount = 3
		elseif curByte>=240 and curByte<=247 then
			byteCount = 4
		end
		
		local c = string.sub(str, i, i+byteCount-1)
		chars[#chars + 1] = c
		lens[#chars + 1] = byteCount
		
		i = i + byteCount
	end

	return chars, lens
end


function string.FormatString(s)
	-- s = string.gsub(s, ' ', '　')
	s = string.gsub(s, '#n', '\n')
	return s
end

--字符串插入 
--(*)需要注意pos<=0 或者大于#str2的情况
--@str1: 源字符串
--@str2: 插入的字符串
--@pos: 插入位置
--@return 插入后完整的字符串 
function string.insert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end

--有中文字符串插入用这个
function string.utf8Insert(str1, str2, pos)
    local len = string.len(str1)
    local front = string.utf8sub(str1, 1, pos)
    local back = string.utf8sub(str1, pos+1, len-pos)
    return  front .. str2 .. back
end


function string.lastIndexOf(haystack, needle)
    local i, j
    local k = 0
    repeat
        i = j
        j, k = string.find(haystack, needle, k + 1, true)
    until j == nil

    return i
end

--输出向下取整百分比字符串:0.9999=>99%
--@value: 数值
function string.ToPercentString(value)
    value = math.floorVec(value, 100)
    return string.format("%.0f%%", value * 100)
end

function string.contains(str, key)
    local zva = string.find(str,key)
    if not zva then
        return false 
    else
        return true
    end
end

function string.tonumber(str, default)
	if not str or str == "" then
		return default
	end
	return tonumber(str)
end
