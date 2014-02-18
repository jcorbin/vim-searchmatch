" searchmatch.vim - easy search highlight pinning in Vim with :match
" Maintainer: Joshua T Corbin
" URL:        https://github.com/jcorbin/vim-searchmatch
" Version:    0.9.2

if exists("g:loaded_searchmatch") || &cp
  finish
endif
let g:loaded_searchmatch = 1

function! s:cased_regex(regex)
  return (&ignorecase ? '\c' : '\C') . a:regex
endfunction

if !exists("s:disabled_matchparen")
  let s:disabled_matchparen = 0
endif

function! s:setup_highlight_defaults()
  highlight default link Match1 ErrorMsg
  highlight default link Match2 DiffDelete
  highlight default link Match3 DiffAdd
endfunction

augroup searchmatch
autocmd ColorScheme * call <SID>setup_highlight_defaults()
augroup END

call <SID>setup_highlight_defaults()

function! s:show_1match()
  execute "1match Match1 " . w:searchmatch_matches[1]
endfunction

function! s:show_2match()
  execute "2match Match2 " . w:searchmatch_matches[2]
endfunction

function! s:show_3match()
  execute "3match Match3 " . w:searchmatch_matches[3]
  if exists("g:loaded_matchparen")
    let s:disabled_matchparen = 1
    NoMatchParen
  endif
endfunction

function! s:hide_1match()
  1match none
endfunction

function! s:hide_2match()
  2match none
endfunction

function! s:hide_3match()
  3match none
  if s:disabled_matchparen
    if !exists("g:loaded_matchparen")
      DoMatchParen
    endif
    let s:disabled_matchparen = 0
  endif
endfunction

function! s:set_match(n, regex)
  let pattern = <SID>cased_regex(a:regex)
  let pattern = '/' . substitute(pattern, '/', '\/', 'g') . '/'
  if !exists("w:searchmatch_matches")
    let w:searchmatch_matches = {}
  endif
  let w:searchmatch_matches[a:n] = a:regex
  if a:n == 1
    call <SID>show_1match()
  elseif a:n == 2
    call <SID>show_2match()
  elseif a:n == 3
    call <SID>show_3match()
  endif
endfunction

function! s:rotate_match(regex)
  if exists("w:searchmatch_matches") && has_key(w:searchmatch_matches, 1)
    if has_key(w:searchmatch_matches, 2)
      call <SID>set_3match(w:searchmatch_matches[2])
    endif
    call <SID>set_2match(w:searchmatch_matches[1])
  endif
  call <SID>set_match(1, a:regex)
endfunction

function! s:reset_match()
  if !exists("w:searchmatch_matches")
    return
  endif

  if has_key(w:searchmatch_matches, 1)
    call <SID>hide_1match()
    unlet w:searchmatch_matches[1]
  endif

  if has_key(w:searchmatch_matches, 2)
    call <SID>hide_2match()
    unlet w:searchmatch_matches[2]
  endif

  if has_key(w:searchmatch_matches, 3)
    call <SID>hide_3match()
    unlet w:searchmatch_matches[3]
  endif
endfunction

function! s:operator(type, ...)
    let reg_save = @@
    let sel_save = &selection
    let &selection = "inclusive"

    if a:0 " Invoked from Visual mode, use '< and '> marks.
        silent execute "normal! `<" . a:type . "`>y"
    elseif a:type ==# 'line'
        silent execute "normal! `[V`]y"
    elseif a:type ==# 'block'
        silent execute "normal! `[<C-V>`]y"
    else
        silent execute "normal! `[v`]y"
    endif

    let patterns = split(@@, '\r\?\n')
    let patterns = filter(patterns, 'strlen(v:val) > 0')
    let patterns = map(patterns, 'substitute(v:val, ''^\s*'', "", "g")')
    let patterns = map(patterns, 'substitute(v:val, ''\s*$'', "", "g")')
    let patterns = map(patterns, 'substitute(v:val, ''\\'', ''\\\\'', "g")')
    let pattern = '\V' . join(patterns, '\|')
    call <SID>rotate_match(pattern)

    let &selection = sel_save
    let @@ = reg_save
endfunction

command! Searchmatch1     :call <SID>set_match(1, @/)
command! Searchmatch2     :call <SID>set_match(2, @/)
command! Searchmatch3     :call <SID>set_match(3, @/)
command! SearchmatchReset :call <SID>reset_match()

nmap <Plug>Searchmatch1     :Searchmatch1<CR>
nmap <Plug>Searchmatch2     :Searchmatch2<CR>
nmap <Plug>Searchmatch3     :Searchmatch3<CR>
nmap <Plug>SearchmatchReset :SearchmatchReset<CR>
nmap <Plug>SearchmatchOp    :set operatorfunc=<SID>operator<cr>g@
vmap <Plug>SearchmatchOp    :<c-u>call <SID>operator(visualmode(), 1)<cr>

if !exists("g:searchmatch_nomap") && mapcheck("<leader>/", "n") == ""
  nmap <leader>/1 <Plug>Searchmatch1
  nmap <leader>/2 <Plug>Searchmatch2
  nmap <leader>/3 <Plug>Searchmatch3
  nmap <leader>/- <Plug>SearchmatchReset
  nmap <leader>/  <Plug>SearchmatchOp
  vmap <leader>/  <Plug>SearchmatchOp
  nmap <leader>// V<Plug>SearchmatchOp
  nmap <leader>/* <Plug>SearchmatchOpiw
endif
