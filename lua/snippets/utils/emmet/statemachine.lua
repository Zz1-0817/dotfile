local cnt = 0
local transitions = {
    start = { ["letter"] = "tag", ["."] = "class", ["#"] = "id", ["("] = "group_start" },
    tag = {
        ["."] = "class",
        ["#"] = "id",
        ["["] = "attribute",
        ["{"] = "text",
        ["("] = "group_start",
        [">"] = "child_op",
        ["+"] = "sibling_op",
        ["*"] = "multiply_op",
        ["letter"] = "tag"
    },
    class = {
        ["."] = "class",
        ["#"] = "id",
        ["["] = "attribute",
        ["{"] = "text",
        ["("] = "group_start",
        [">"] = "child_op",
        ["+"] = "sibling_op",
        ["*"] = "multiply_op",
        ["letter"] = "class"
    },
    id = {
        ["."] = "class",
        ["#"] = "id",
        ["["] = "attribute",
        ["{"] = "text",
        ["("] = "group_start",
        [">"] = "child_op",
        ["+"] = "sibling_op",
        ["*"] = "multiply_op",
        ["letter"] = "id"
    },
    attribute = {
        ["="] = "attribute_value",
        ["]"] = "tag",
        ["letter"] = "attribute"
    },
    attribute_value = {
        ["]"] = "tag",
        ["letter"] = "attribute_value",
        ["digit"] = "attribute_value",
        ["$"] = "numbering"
    },
    numbering = {
        ["["] = "attribute",
        ["]"] = "tag",
        ["{"] = "text",
        ["letter"] = "numbering",
        ["digit"] = "numbering",
        ["#"] = "id",
        ["."] = "class"
    },
    text = {
        ["}"] = "tag",
        ["letter"] = "text",
        ["$"] = "numbering"
    },
    multiply_op = {
        ["digit"] = "multiply_count"
    },
    multiply_count = {
        ["digit"] = "multiply_count",
        ["."] = "class",
        ["#"] = "id",
        ["["] = "attribute",
        ["{"] = "text",
        [">"] = "child_op",
        ["+"] = "sibling_op",
        ["("] = "group_start"
    },
    child_op = {
        ["letter"] = "tag",
        ["."] = "class",
        ["#"] = "id",
        ["("] = "group_start"
    },
    sibling_op = {
        ["letter"] = "tag",
        ["."] = "class",
        ["#"] = "id",
        ["("] = "group_start"
    },
    group_start = {
        ["letter"] = "tag",
        ["."] = "class",
        ["#"] = "id",
        ["("] = "group_start"
    },
    group_end = {
        ["."] = "class",
        ["#"] = "id",
        ["["] = "attribute",
        ["{"] = "text",
        [">"] = "child_op",
        ["+"] = "sibling_op",
        ["*"] = "multiply_op"
    },
}

-- 辅助函数：检查字符类型
local function get_char_type(char)
    if char:match("%a") then return "letter" end
    if char:match("%d") then return "digit" end
    return char
end

-- 验证单个元素
local function validate_element(element_str)
    local state = "start"
    local group_level = 0
    local idx = 0

    for char in string.gmatch(element_str, '.') do
        idx = idx + 1
        local char_type = get_char_type(char)

        -- 分组处理
        if char == "(" then
            group_level = group_level + 1
            goto continue
        elseif char == ")" then
            if group_level <= 0 then
                print("错误：未匹配的 ')'")
                return false
            end
            group_level = group_level - 1
            state = "group_end"
            goto continue
        -- 状态转移检查
        elseif not transitions[state] then
            print("错误: 没有匹配的状态")
            return false
        -- 特殊情况处理
        elseif not transitions[state][char_type] then
            if state == "attribute_value" and string.gmatch(char, "%p") then
                goto continue
            end
            return false
        else
            state = transitions[state][char_type]
        end
        ::continue::
    end

    -- 结束状态检查
    local valid_end_states = {
        tag = true,
        class = true,
        id = true,
        group_end = true,
        multiply_count = true
    }

    if not valid_end_states[state] then
        print("错误：元素未正确结束，当前状态 '" .. state .. "'")
        return false
    end

    if group_level > 0 then
        print("错误：未闭合的分组")
        return false
    end

    return true
end

-- 完整Emmet验证
local function validate_emmet(input)
    cnt = cnt + 1
    print(cnt)
    if input:match("[>+]$") then
        print("错误：操作符不能出现在表达式末尾")
        return false
    end

    if input:match("[>+][>+]") then
        print("错误：连续的操作符")
        return false
    end

    -- 分组语法检查
    local open_count = select(2, input:gsub("%(", ""))
    local close_count = select(2, input:gsub("%)", ""))
    if open_count ~= close_count then
        print("错误：括号不匹配")
        return false
    end

    -- 拆分表达式为多个元素
    local elements = {}
    local current = ""
    local group_level = 0

    for i = 1, #input do
        local char = input:sub(i, i)

        if char == "(" then
            group_level = group_level + 1
            current = current .. char
        elseif char == ")" then
            group_level = group_level - 1
            current = current .. char
        elseif group_level == 0 and (char == ">" or char == "+") then
            if current ~= "" then
                table.insert(elements, current)
            end
            table.insert(elements, char)
            current = ""
        else
            current = current .. char
        end
    end

    if current ~= "" then
        table.insert(elements, current)
    end

    -- 验证每个元素
    for i, element in ipairs(elements) do
        if element == ">" or element == "+" then
            -- 检查操作符位置
            if i == 1 or i == #elements then
                print("错误：操作符位置无效")
                return false
            end
            if elements[i - 1] == ">" or elements[i - 1] == "+" or
                elements[i + 1] == ">" or elements[i + 1] == "+" then
                print("错误：操作符连续使用")
                return false
            end
        else
            if not validate_element(element) then
                return false
            end
        end
    end

    print("输入有效: " .. input)
    return true
end

-- 测试用例
validate_emmet("div>span")              -- ✅ 子节点
validate_emmet("div+p")                 -- ✅ 兄弟节点
validate_emmet("ul>li*3")               -- ✅ 乘法
validate_emmet("(div>span)+p")          -- ✅ 分组
validate_emmet("div.item")              -- ✅ 类名
validate_emmet("div#main")              -- ✅ ID
validate_emmet("a[href=#]")             -- ✅ 属性
validate_emmet("div{Click $}")          -- ✅ 文本带编号
validate_emmet("ul>li[data-index=$]*3") -- ✅ 属性编号
validate_emmet("div..container")        -- ❌ 空类名
validate_emmet("div>")                  -- ❌ 无效操作符
validate_emmet("*5")                    -- ❌ 缺少元素
validate_emmet("div+>p")                -- ❌ 连续操作符
validate_emmet("(div")                  -- ❌ 未闭合分组
validate_emmet("li.item$*3")            -- ✅ 带编号的乘法
validate_emmet("div>(span+em)>strong")  -- ✅ 复杂嵌套

-- 目前至少 attribute, attribute_value 部分是有 bug 的, 需要处理符号
-- 而且由于luasnip读字符串的方式, 两个属性应该要两个方括号, 应该不能直接加空格
-- 现在难处理的问题变成了花括号的处理{}
