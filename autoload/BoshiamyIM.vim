" vim:fdm=marker
" ============================================================================
" File:        BoshiamyIM.vim
" Description: A Boshiamy Chinese input method plugin for vim
" Maintainer:  Pi314 <michael66230@gmail.com>
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
" ============================================================================

function! BoshiamyIM#CharType (c) " {{{
    if a:c =~# "[a-zA-Z0-9]"
        return 1

    elseif a:c == "[" || a:c == "]"
        return 2

    elseif a:c == "," || a:c == "."
        return 3

    elseif a:c == "'"
        return 4

    endif

    return 0
endfunction " }}}

function! BoshiamyIM#ProcessChewing (line, chewing_str) " {{{
    let l:start = strlen(a:line) - strlen(a:chewing_str)
    let l:col  = l:start + 1

    if has_key(g:BoshiamyIM#chewing#table, a:chewing_str)
        call complete(l:col, g:BoshiamyIM#chewing#table[a:chewing_str])
        return 0
    endif

    return 1
endfunction " }}}

function! BoshiamyIM#ProcessKana (line, kana_str) " {{{
    let l:start = strlen(a:line) - strlen(a:kana_str)
    let l:col  = l:start + 1

    let kana_str_length = strlen(a:kana_str)
    if l:kana_str_length == 0
        return ' '
    endif

    if has_key(g:BoshiamyIM#kana#table, a:kana_str)
        call complete(l:col, g:BoshiamyIM#kana#table[ (a:kana_str) ])
        return ''
    endif

    let ret_hiragana = ''
    let ret_katakana = ''
    let i = 0
    let j = 4
    while l:i <= l:j
        let t = a:kana_str[ (l:i) : (l:j) ]
        echom l:t

        if has_key(g:BoshiamyIM#kana#table, l:t)
            let ret_hiragana = l:ret_hiragana . g:BoshiamyIM#kana#table[(l:t)][0]
            if has_key(g:BoshiamyIM#kana#table, l:t .'.')
                let ret_katakana = l:ret_katakana . g:BoshiamyIM#kana#table[(l:t .'.')][0]
            else
                let ret_katakana = l:ret_katakana . g:BoshiamyIM#kana#table[(l:t)][0]
            endif
            let i = l:j + 1
            let j = l:i + 4
        else
            let j = l:j - 1
        endif

    endwhile
    let remain = a:kana_str[(l:j + 1) : ]

    call complete(l:col, [l:ret_hiragana . l:remain, l:ret_katakana . l:remain] )
    return ''
endfunction " }}}

function! BoshiamyIM#ProcessWide (line, wide_str) " {{{
    let l:start = strlen(a:line) - strlen(a:wide_str)
    let l:col  = l:start + 1

    let wide_str_length = strlen(a:wide_str)
    if l:wide_str_length == 0
        return ' '
    endif

    let p = 0
    let ret = ''
    echom a:wide_str
    echom strlen(a:wide_str)
    while l:p < strlen(a:wide_str)
        echom l:p
        echom a:wide_str[(l:p)]
        let l:ret = l:ret . g:BoshiamyIM#wide#table[a:wide_str[(l:p)]]
        let l:p = l:p + 1
    endwhile

    call complete(l:col, [l:ret] )
    return ''
endfunction " }}}

function! BoshiamyIM#ProcessUnicodeEncode (line, unicode_pattern) " {{{
    let l:start = strlen(a:line) - strlen(a:unicode_pattern)
    let l:col  = l:start + 1

    let unicode_codepoint = str2nr(a:unicode_pattern[2:], 16)
    call complete(l:col, [nr2char(l:unicode_codepoint)])

    return 0
endfunction " }}}

function! BoshiamyIM#ProcessUnicodeDecode (line, unicode_pattern) " {{{
    let l:start = strlen(a:line) - strlen(a:unicode_pattern)
    let l:col  = l:start + 1

    let utf8_str = a:unicode_pattern[3:-2]
    let unicode_codepoint = char2nr(l:utf8_str)
    let unicode_codepoint_str = printf('\u%x', unicode_codepoint)
    let html_code_str = printf('&#%d;', unicode_codepoint)
    call complete(l:col, [unicode_codepoint_str, html_code_str])

    return 0
endfunction " }}}

function! BoshiamyIM#ProcessHTMLCode (line, htmlcode_pattern) " {{{
    let l:start = strlen(a:line) - strlen(a:htmlcode_pattern)
    let l:col  = l:start + 1

    if a:htmlcode_pattern[2] == 'x'
        let utf8_str = a:htmlcode_pattern[3:-2]
        let unicode_codepoint = str2nr(l:utf8_str, 16)
    else
        let utf8_str = a:htmlcode_pattern[2:-2]
        let unicode_codepoint = str2nr(l:utf8_str, 10)
    endif
    echom l:unicode_codepoint
    call complete(l:col, [nr2char(l:unicode_codepoint)])

    return 0
endfunction " }}}

function! BoshiamyIM#SendKey () " {{{
    if s:boshiamy_status == s:IM_ENGLISH
        " IM is not ON, just return a space
        return ' '
    endif

    " I need to substract 2 here, because
    " 1.
    "   col  : 1 2 3 4 5 6
    "   index: 0 1 2 3 4 5
    "   line : a b c d e f
    " 2.
    "   string slice is head-tail-including
    "
    " if you want "bcde", and the cursor is on "f",
    " the col=6, the index=5, tail_index=4
    " so you have to use "line[1:col-2]", which is "line[1:4]"
    "
    let l:line = strpart(getline('.'), 0, (col('.')-1) )

    " Switch input mode
    for [switch, switch_type] in items(s:switch_table)
        if l:line =~# switch
            let c = col('.')
            call setline('.', l:line[:(0-strlen(switch))] . getline('.')[ (l:c-1) : ] )
            call cursor(line('.'), l:c-( strlen(switch)-1 ) )
            call BoshiamyIM#UpdateIMStatus(switch_type)
            return ''
        endif
    endfor

    if s:boshiamy_status == s:IM_WIDE
        let wide_str = matchstr(l:line, '\([a-zA-Z0-9]\|[-=,./;:<>?_+\\|!@#$%^&*(){}"]\|\[\|\]\|'."'".'\)\+$')
        return BoshiamyIM#ProcessWide(l:line, l:wide_str)
    endif

    if s:boshiamy_status == s:IM_KANA
        let kana_str = matchstr(l:line, '[.a-z]\+$')
        return BoshiamyIM#ProcessKana(l:line, l:kana_str)
    endif

    " Try chewing
    let chewing_str = matchstr(l:line, ';[^;]*;[346]\?$')
    if l:chewing_str == ''
        let chewing_str = matchstr(l:line, ';[^;]\+$')
    endif

    if l:chewing_str != ''
        " Found chewing pattern
        if BoshiamyIM#ProcessChewing(l:line, l:chewing_str) == 0
            return ''
        endif
    endif

    let unicode_pattern = matchstr(l:line, '\\[Uu][0-9a-fA-F]\+$')
    if l:unicode_pattern != ''
        if BoshiamyIM#ProcessUnicodeEncode(l:line, l:unicode_pattern) == 0
            return ''
        endif
    endif

    let unicode_pattern = matchstr(l:line, '\\[Uu]\[[^]]*\]$')
    if l:unicode_pattern == ''
        let unicode_pattern = matchstr(l:line, '\\[Uu]\[\]\]$')
    endif
    if l:unicode_pattern != ''
        if BoshiamyIM#ProcessUnicodeDecode(l:line, l:unicode_pattern) == 0
            return ''
        endif
    endif

    let htmlcode_pattern = matchstr(l:line, '&#x\?[0-9a-fA-F]\+;$')
    if l:htmlcode_pattern != ''
        if BoshiamyIM#ProcessHTMLCode(l:line, l:htmlcode_pattern) == 0
            return ''
        endif
    endif

    " Locate the start of the boshiamy key sequence
    let start = col('.') - 1
    while l:start > 0 && BoshiamyIM#CharType(l:line[l:start-1])
        let start -= 1
    endwhile

    let l:base = l:line[(l:start): (col('.')-2)]
    let l:col  = l:start + 1

    " Input key start is l:start
    " Input key col is l:col
    " Input key sequence is l:base

    if has_key(g:BoshiamyIM#boshiamy#table, l:base)
        call complete(l:col, g:BoshiamyIM#boshiamy#table[l:base])
        return ''
    endif

    let char_type = BoshiamyIM#CharType(l:base[0])

    while strlen(l:base) > 0
        let new_char_type = BoshiamyIM#CharType(l:base[0])

        " Cut off the string
        if l:new_char_type != l:char_type

            if has_key( g:BoshiamyIM#boshiamy#table, l:base )
                call complete(l:col, g:BoshiamyIM#boshiamy#table[ (l:base) ])
                return ''

            endif

        endif

        " Boshiamy char not found, cut off one char and keep trying
        let l:col = l:col + 1
        let l:base = l:base[1:]

        let l:char_type = l:new_char_type

    endwhile

    " There is nothing I can do, just return a space
    return ' '

endfunction " }}}

" 0: English
" 1: Boshiamy
" 2: Kana (Japanese alphabet)
" 3: Wide characters
let s:IM_ENGLISH = 0
let s:IM_BOSHIAMY = 1
let s:IM_KANA = 2
let s:IM_WIDE = 3

let s:boshiamy_sub_status = s:IM_BOSHIAMY
let s:boshiamy_status = s:IM_ENGLISH

function! BoshiamyIM#Status ()
    if s:boshiamy_status == s:IM_ENGLISH
        return '[英]'
    elseif s:boshiamy_status == s:IM_BOSHIAMY
        return '[嘸]'
    elseif s:boshiamy_status == s:IM_KANA
        return '[あ]'
    elseif s:boshiamy_status == s:IM_WIDE
        return '[Ａ]'
    endif
    return '[？]'
endfunction

function! BoshiamyIM#UpdateIMStatus (new_status)
    let s:boshiamy_status = a:new_status
    if a:new_status != s:IM_ENGLISH
        let s:boshiamy_sub_status = a:new_status
    endif
    redrawstatus!
    redraw!
endfunction

function! BoshiamyIM#ToggleIM ()
    if s:boshiamy_status
        call BoshiamyIM#UpdateIMStatus(s:IM_ENGLISH)

    else
        call BoshiamyIM#UpdateIMStatus(s:boshiamy_sub_status)

    endif
    return ''
endfunction

function! BoshiamyIM#LeaveIM ()
    call BoshiamyIM#UpdateIMStatus(s:IM_ENGLISH)
    return ''
endfunction

function! BoshiamyIM#UnifyType (variable, vname, default)
    if type(a:variable) == type('')
        return [a:variable]
    endif

    if type(a:variable) == type([])
        for i in a:variable
            if type(i) != type('')
                echoerr "'". a:vname ."' should contain only strings."
            endif
        endfor
        return a:variable
    endif
    echoerr "'". a:vname ."' should be in type 'string' or 'list'."
    echoerr "set to default value: ". a:default
    return [a:default]
endfunction

" ==============
" Default Values
" ==============
let s:BOSHIAMY_IM_CANCEL_KEY_DEFAULT = '<C-h>'
let s:BOSHIAMY_IM_SWITCH_BOSHIAMY_DEFAULT = ',t,'
let s:BOSHIAMY_IM_SWITCH_KANA_DEFAULT = ',j,'
let s:BOSHIAMY_IM_SWITCH_WIDE_DEFAULT = ',w,'

if !exists('g:boshiamy_im_cancel_key')
    let g:boshiamy_im_cancel_key = s:BOSHIAMY_IM_CANCEL_KEY_DEFAULT
endif
let s:cancel_key_list = BoshiamyIM#UnifyType(g:boshiamy_im_cancel_key, 'g:boshiamy_im_cancel_key', s:BOSHIAMY_IM_CANCEL_KEY_DEFAULT)

if !exists('g:boshiamy_im_switch_boshiamy')
    let g:boshiamy_im_switch_boshiamy = s:BOSHIAMY_IM_SWITCH_BOSHIAMY_DEFAULT
endif
let s:switch_boshiamy = BoshiamyIM#UnifyType(g:boshiamy_im_switch_boshiamy, 'g:boshiamy_im_switch_boshiamy', s:BOSHIAMY_IM_SWITCH_BOSHIAMY_DEFAULT)

if !exists('g:boshiamy_im_switch_kana')
    let g:boshiamy_im_switch_kana = s:BOSHIAMY_IM_SWITCH_KANA_DEFAULT
endif
let s:switch_kana = BoshiamyIM#UnifyType(g:boshiamy_im_switch_kana, 'g:boshiamy_im_switch_kana', s:BOSHIAMY_IM_SWITCH_KANA_DEFAULT)

if !exists('g:boshiamy_im_switch_wide')
    let g:boshiamy_im_switch_wide = s:BOSHIAMY_IM_SWITCH_WIDE_DEFAULT
endif
let s:switch_wide = BoshiamyIM#UnifyType(g:boshiamy_im_switch_wide, 'g:boshiamy_im_switch_wide', s:BOSHIAMY_IM_SWITCH_WIDE_DEFAULT)
" ==============
" ==============

" I want this option be set because it's related to my 'cancel' feature
set completeopt+=menuone

" ==============
" Apply Settings
" ==============
for i in s:cancel_key_list
    execute 'inoremap <expr> '. i .' pumvisible() ? "<C-e> " : "'. i .'"'
endfor

let s:switch_table = {}
for i in s:switch_boshiamy
    let s:switch_table[i .'$'] = s:IM_BOSHIAMY
endfor

for i in s:switch_kana
    let s:switch_table[i .'$'] = s:IM_KANA
endfor

for i in s:switch_wide
    let s:switch_table[i .'$'] = s:IM_WIDE
endfor

