"" =============================================================================
"" File:          autoload/outliner.vim
"" License:       see /plugin/tnt.vim
"" =============================================================================

function! outliner#goPreviousSibling()
  let column = getpos('.')[2]
  let heading = IndentLevel(line('.'))
  execute 'normal! k'
  let prev = line('.')
  if IndentLevel(prev) != heading || foldclosed(prev) == -1
    while IndentLevel(line('.')) > heading
      execute 'normal! [z'
    endwhile
    execute 'normal! '.column.'|'
    "call cursor(line('.'), column)
  endif
endfunction

function! outliner#goNextSibling()
  let current = line('.')
  execute 'normal! j'
  let next = line('.')
  if IndentLevel(next) > IndentLevel(current)
    execute 'normal! ]zj'
  endif
endfunction

function! outliner#goFirstLower(direction)
  let startindent = IndentLevel(line('.'))
  execute 'normal! ' . a:direction
  let current = line('.')
  let currentindent = IndentLevel(current)
  while currentindent <= startindent
    \ || matchstr(getline(current), g:tntWebpageRegex) != ''
    if currentindent < startindent | return | endif
    execute 'normal! ' . a:direction
    let l:current = line('.')
    let l:currentindent = IndentLevel(current)
  endwhile
endfunction

function! outliner#goTopLevelHeading(upto)
  echo a:upto
  while IndentLevel(line('.')) > a:upto
    execute 'normal! [z'
  endwhile
endfunction

"syn region FoldFocus start="\(\([^\r\n]*[\r\n]\)\{6}\)\@<=\s*\S" end="\[^\r\n]*[\r\n]\(\([^[\r\n]*[\r\n]\)\{2}\)\@="
"hi FoldFocus gui=bold guifg=LimeGreen cterm=bold ctermfg=Green
"hi def link FoldFocus FoldFocus

function! outliner#timestamp()
  if outliner#checkBashUtility('ruby')
    let date = system("ruby -e 'puts Time.now.to_f'")
    return strpart(substitute(l:date, '\.', '', 'g'), 0, 13)
  else
    let date = system('date +%s%N | cut -b1-13')
    return strpart(l:date, 0, len(l:date) - 1)
  endif
endfunction

function! outliner#timestampN(cmd)
  let date = outliner#timestamp()
  let lnum = line('.')
  execute "normal! ".a:cmd

  execute "s/$/ {>>". l:date ."<<}/"
  execute "normal! 0"
  startinsert
endfunction

function! outliner#timestampI(cmd)
  let date = outliner#timestamp()
  call feedkeys(a:cmd.l:date)
  execute 'normal! '.cmd.l:date
endfunction

" code from Vim The Hard Way
function! IndentLevel(lnum)
  return indent(a:lnum) / &shiftwidth
endfunction
function! NextNonBlankLine(lnum)
  let numlines = line('$')
  let current = a:lnum + 1
  while current <= numlines
    if getline(current) =~? '\v\S' | return current | endif
    let current += 1
  endwhile
  return -2
endfunction

function! outliner#foldExpr(lnum)
  if getline(a:lnum) =~? '\v^\s*$' | return -1 | endif
  let this_indent = IndentLevel(a:lnum)
  let next_indent = IndentLevel(NextNonBlankLine(a:lnum))
  if next_indent == this_indent | return this_indent
  elseif next_indent < this_indent | return this_indent
  elseif next_indent > this_indent | return '>' . next_indent
  endif
endfunction

function! outliner#children(...)
  let [lnum, filter] = [0, '']
  if a:0 == 0 | return | endif
  if a:0 == 2 | let l:filter = a:2 | endif
  let l:lnum = a:1

  let parent = IndentLevel(l:lnum)
  let i = 1
  let indent = IndentLevel(l:lnum + i)
  let children = []
  if l:filter == ''
    while indent > parent
      if indent == parent + 1 | call add(children, l:lnum + i) | endif
      let i = i + 1
      let indent = IndentLevel(l:lnum + i)
    endwhile

  else
    while indent > parent
      if indent == parent + 1
        if match(getline(l:lnum + i), l:filter) != -1
          call add(children, l:lnum + i)
        endif
      endif
      let i = i + 1
      let indent = IndentLevel(l:lnum + i)
    endwhile
  endif
  return l:children
endfunction

function! outliner#humanDate(line)
  echo a:line
  return
  return substitute(a:line, '{>>\([^<]*\)<<}\s*$', '\=submatch(0)')
endfunction

" go to the function name from within a function
let expr = '\(^fun\S* \)\@<=[^f][^u][^n]\w\+\<Bar>^\w\+'
execute "nnoremap <Leader>f ?".expr."<CR>"

let g:tntWebpageRegex = '^\s*\((\d\d\d\?%)\)\?'
  \ . '\[[^\]]*\]\[[^\]]*\]'
  \ . '\s*\({>>\d*<<}\)\?\s*$'

command! -nargs=0 TNTTriggerSession call outliner#triggerSession(line('.'))
function! outliner#triggerSession(lnum)
  let browser = get(g:, 'TNTWebBrowser', '')
  if !len(browser)
    echom 'Please set your web browser by having e.g."'
      \ . "let g:TNTWebBrowser = 'google-chrome'" . '" in your vimrc.'
    return
  endif
  let webpages = outliner#children(a:lnum, g:tntWebpageRegex)
  if !len(webpages) | return | endif
  let links = ''
  for page in webpages
    let link = matchstr(getline(page), '\[http\S*\]')
    let l:links = l:links . ' ' . strpart(link, 1, len(link) - 2)
  endfor
  call system(browser.l:links)
endfunction

let g:TNTFoldCache = {}
function! outliner#foldText(...)
  if a:0 == 1 | let current = a:1
  else | let current = v:foldstart
  endif
  let line = getline(l:current)
  " the label will be our final folded text

  " a thread begins with a quote followed optionally by pairs of quotes.
  if l:line =~? '^\s*"\([^"]*"[^"]*"\)*[^"]*$'
    let children = len(outliner#children(l:current))
    let l = matchstr(getline(l:current + 1), '\S[^{]*')
    let lindent = strpart(matchstr(getline(l:current + 1), '^\s*'), 2)
    " make it optional for threads to show their content with a special symbol
    " in front of them, e.g. the double quote or a bang
    "let l:l = substitute(l:l, '\(^\s*\)\@<=\s\S\@=', '!', '')
    "return strpart(l:l, 1)
    if l:line =~ '^\s*"!\d*'
      " get how many chars we should ensure (padding formatting).
      let chars = strpart(matchstr(l:line, '"!\d*'), 2)
      " get the whole thread title up until it's timestamp, and add padding,
      " and add padding.
      let l:label = matchstr(l:line, '"![^{]*') . repeat(' ', chars)
      " extract the actual title and format to the size constraint.
      let l:label = strpart(l:label, 4, chars) . ' '
      return l:lindent . l:label . l:l . '['.children.']'
    endif
    return l:lindent . l:l . '['.children.']'

  " a randomizer thread begins with a percent sign (whatever else does?)
  elseif l:line =~? '^\s*%'
    let label = get(g:outliner#foldCache, l:current, '')
    if l:label == ''
      let children = outliner#children(l:current)
      let number = strpart(outliner#timestamp(), 5)
        \ + system('sh -c "echo -n $RANDOM"')
      let random = l:number % len(l:children)
      let child = l:children[random]

      let label = strpart(outliner#foldText(child), 2)
      let g:TNTFoldCache[l:current] = l:label
    endif
    return l:label
  
  " a note begins with a hash, and we'd like to show it's contents' word count.
  elseif l:line =~? '^\s*!\?#'
    let lindent = matchstr(getline(l:current), '^\s*')
    return lindent . matchstr(getline(l:current), '\S[^{]*') . '('
      \ . outliner#wordCountRecursive(l:current) . ' words)'
  endif

  return getline(l:current)
endfunction

function! outliner#wordCount(lnum)
  " remove one to account for tnt timestamp.
  return len(split(getline(a:lnum), '\s')) - 1
endfunction

function! outliner#wordCountRecursive(lnum)
  let wc = get(g:TNTFoldCache, a:lnum, 0)
  if l:wc == 0
    let children = outliner#children(a:lnum)
    for child in children
      let l:wc += outliner#wordCountRecursive(child)
    endfor
    let l:wc += outliner#wordCount(a:lnum)
    let g:TNTFoldCache[a:lnum] = l:wc
  endif
  return l:wc
endfunction

augroup TNT
  autocmd!
  autocmd BufRead,BufNewFile *.tnt.* call outliner#autocmds()
  " temporarily switch to manual folding when entering insert mode,
  " so that adjacent folds won't inaverdtently open when we create new folds.
  autocmd InsertEnter *.tnt.* let w:last_fm=&foldmethod
    \ | setlocal foldmethod=manual
  autocmd InsertLeave *.tnt.* let &l:foldmethod=w:last_fm
augroup END

function! outliner#autocmds()
  setlocal foldmethod=expr
  setlocal foldexpr=outliner#foldExpr(v:lnum)
  setlocal foldtext=outliner#foldText()
  setlocal foldopen=search,mark,percent,quickfix,tag,undo
  nnoremap <silent> <buffer> o :call outliner#timestampN('o')<CR>
  nnoremap <silent> <buffer> O :call outliner#timestampN('O')<CR>
  "inoremap <silent> <buffer> <CR> :call outliner#timestampI("\<CR>")<CR>
endfunction

command! -nargs=0 TNTCreateWebpage call outliner#createWebpage()
function! outliner#createWebpage()
  " get curront column
  let cursor = getpos('.')[2]
  " get text on the character next to current position.
  let next = (getline('.'))[cursor]
  " if we're not at the end of the url.
  let adjust = ''
  if len(next) && !(next =~ '\s') | let l:adjust = 'E' | endif
  execute "normal! " . adjust . "a]\<Esc>yBi["

  " our normal call above used the y operator to capture the url.
  let url = @"

  let engines = { 'google': '\v(google\.com(\....?)?\/search\?q\=)@<=(\S*)' }
  let engine = ''
  let query = ''
  " if our url is a query in one of the listed engines, we treat it differently.
  for pattern in items(engines)
    let query = matchstr(url, pattern[1])
    let engine = pattern[0] . ':'
  endfor

  if query != ''
    " we simply url-decode the query and prepend the engine's name, and we
    " have our title.
    let title = engine . system('echo "' . query . '"'
    \ . ' | echo -e "$(sed ' . "'s/%/\\\\x/g'" . ')"')
  else
    " grab the title and make sure we guard against some evil saboteur putting
    " backticks instead of single quotes on his webpage's title.
    let raw = system("curl '" . url . "'")
    let begin = match(raw, '<\s*title\s*>') + 7
    let end = match(raw, '<\s*.\?\s*title\s*>', begin)
    let title = strpart(raw, begin, end - begin)
    let title = substitute(title, '[\r\n]\|\r\n', '', 'g')
    let title = substitute(title, '^\s*\|\s*$', '', 'g')
    let title = substitute(title, '[`"]', "'", 'g')

    " we're gonna try a few tools to decode the html entities.
    if outliner#checkBashUtility('php')
      let decode = "php -r 'echo html_entity_decode(fgets(STDIN),"
        \ . " ENT_NOQUOTES, " . '"UTF-8"' . ");'"
    elseif outliner#checkBashUtility('recode')
      let decode = "recode HTML_4.0"
    else | let decode = ''
    endif
    if decode != '' | let title = system('echo "'.title.'" | '.decode) | endif
  endif

  " finish the markdown link now that we (hopefully) have the title
  execute "normal! a".title
  execute "normal! kJxha]["
endfunction

function! outliner#checkBashUtility(name)
  let result = system('hash '.a:name.' 2>/dev/null'
    \ . ' || { echo >&1 "not available"; exit 1; }')
  if result =~ 'not available' | return 0
  else | return 1
  endif
endfunction