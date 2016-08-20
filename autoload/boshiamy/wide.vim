echom "Loading wide table..."
let boshiamy#wide#table = {}
let boshiamy#wide#table["a"] = "ａ"
let boshiamy#wide#table["b"] = "ｂ"
let boshiamy#wide#table["c"] = "ｃ"
let boshiamy#wide#table["d"] = "ｄ"
let boshiamy#wide#table["e"] = "ｅ"
let boshiamy#wide#table["f"] = "ｆ"
let boshiamy#wide#table["g"] = "ｇ"
let boshiamy#wide#table["h"] = "ｈ"
let boshiamy#wide#table["i"] = "ｉ"
let boshiamy#wide#table["j"] = "ｊ"
let boshiamy#wide#table["k"] = "ｋ"
let boshiamy#wide#table["l"] = "ｌ"
let boshiamy#wide#table["m"] = "ｍ"
let boshiamy#wide#table["n"] = "ｎ"
let boshiamy#wide#table["o"] = "ｏ"
let boshiamy#wide#table["p"] = "ｐ"
let boshiamy#wide#table["q"] = "ｑ"
let boshiamy#wide#table["r"] = "ｒ"
let boshiamy#wide#table["s"] = "ｓ"
let boshiamy#wide#table["t"] = "ｔ"
let boshiamy#wide#table["u"] = "ｕ"
let boshiamy#wide#table["v"] = "ｖ"
let boshiamy#wide#table["w"] = "ｗ"
let boshiamy#wide#table["x"] = "ｘ"
let boshiamy#wide#table["y"] = "ｙ"
let boshiamy#wide#table["z"] = "ｚ"
let boshiamy#wide#table["A"] = "Ａ"
let boshiamy#wide#table["B"] = "Ｂ"
let boshiamy#wide#table["C"] = "Ｃ"
let boshiamy#wide#table["D"] = "Ｄ"
let boshiamy#wide#table["E"] = "Ｅ"
let boshiamy#wide#table["F"] = "Ｆ"
let boshiamy#wide#table["G"] = "Ｇ"
let boshiamy#wide#table["H"] = "Ｈ"
let boshiamy#wide#table["I"] = "Ｉ"
let boshiamy#wide#table["J"] = "Ｊ"
let boshiamy#wide#table["K"] = "Ｋ"
let boshiamy#wide#table["L"] = "Ｌ"
let boshiamy#wide#table["M"] = "Ｍ"
let boshiamy#wide#table["N"] = "Ｎ"
let boshiamy#wide#table["O"] = "Ｏ"
let boshiamy#wide#table["P"] = "Ｐ"
let boshiamy#wide#table["Q"] = "Ｑ"
let boshiamy#wide#table["R"] = "Ｒ"
let boshiamy#wide#table["S"] = "Ｓ"
let boshiamy#wide#table["T"] = "Ｔ"
let boshiamy#wide#table["U"] = "Ｕ"
let boshiamy#wide#table["V"] = "Ｖ"
let boshiamy#wide#table["W"] = "Ｗ"
let boshiamy#wide#table["X"] = "Ｘ"
let boshiamy#wide#table["Y"] = "Ｙ"
let boshiamy#wide#table["Z"] = "Ｚ"
let boshiamy#wide#table["0"] = "０"
let boshiamy#wide#table["1"] = "１"
let boshiamy#wide#table["2"] = "２"
let boshiamy#wide#table["3"] = "３"
let boshiamy#wide#table["4"] = "４"
let boshiamy#wide#table["5"] = "５"
let boshiamy#wide#table["6"] = "６"
let boshiamy#wide#table["7"] = "７"
let boshiamy#wide#table["8"] = "８"
let boshiamy#wide#table["9"] = "９"
let boshiamy#wide#table["-"] = "ー"
let boshiamy#wide#table["="] = "＝"
let boshiamy#wide#table["!"] = "！"
let boshiamy#wide#table["@"] = "＠"
let boshiamy#wide#table["#"] = "＃"
let boshiamy#wide#table["$"] = "＄"
let boshiamy#wide#table["%"] = "％"
let boshiamy#wide#table["^"] = "︿"
let boshiamy#wide#table["&"] = "＆"
let boshiamy#wide#table["*"] = "＊"
let boshiamy#wide#table["("] = "（"
let boshiamy#wide#table[")"] = "）"
let boshiamy#wide#table["_"] = "＿"
let boshiamy#wide#table["+"] = "﹢"
let boshiamy#wide#table["["] = "〔"
let boshiamy#wide#table["]"] = "〕"
let boshiamy#wide#table["\\"] = "＼"
let boshiamy#wide#table['{'] = "｛"
let boshiamy#wide#table['}'] = "｝"
let boshiamy#wide#table['|'] = "│"
let boshiamy#wide#table[";"] = "；"
let boshiamy#wide#table["'"] = "、"
let boshiamy#wide#table[","] = "，"
let boshiamy#wide#table["."] = "。"
let boshiamy#wide#table["/"] = "／"
let boshiamy#wide#table[":"] = "："
let boshiamy#wide#table['"'] = "〝"
let boshiamy#wide#table["<"] = "＜"
let boshiamy#wide#table[">"] = "＞"
let boshiamy#wide#table["?"] = "？"
let boshiamy#wide#table[" "] = "　"
echom "Done"

function! boshiamy#wide#handler (line, wide_str)
    if strlen(a:wide_str) == 0
        return '　'
    endif

    let l:idx = strlen(a:line) - strlen(a:wide_str)
    let l:col  = l:idx + 1

    let p = 0
    let ret = ''
    echom a:wide_str
    echom strlen(a:wide_str)
    while l:p < strlen(a:wide_str)
        echom l:p
        echom a:wide_str[(l:p)]
        let l:ret = l:ret . g:boshiamy#wide#table[a:wide_str[(l:p)]]
        let l:p = l:p + 1
    endwhile

    call complete(l:col, [l:ret] )
    return ''
endfunction
