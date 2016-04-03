" following two functions from Luc Hermitte
function! s:register_command(event, cmd, group)
  let group = a:group.'_once'
  let s:{group} = 0
  exe 'augroup '.group
  au!
  exe 'au ' .a:event. ' ' .expand('%:p').
    \ ' call s:registered_once('.string(a:cmd).','.string(group).')'
  augroup END
endfunction
function! s:registered_once(cmd, group)
  " We can't delete the current  autocommand => increment a counter
  if !exists('s:'.a:group) || s:{a:group} == 0
    let s:{a:group} = 1
    exe a:cmd
  endif
endfunction

" following two functions from Vimscript The Hard Way by Steve Losh
function! tnt#outliner#indent_level(lnum)
  return indent(a:lnum) / &shiftwidth
endfunction
function! tnt#outliner#next_non_blank_line(lnum)
  let numlines = line('$')
  let current = a:lnum + 1
  while current <= numlines
    if getline(current) =~? '\v\S' | return current | endif
    let current += 1
  endwhile
  return -2
endfunction

function! tnt#outliner#fold_text(...)
  if a:0 == 1 | let current = a:1
  else | let current = v:foldstart
  endif
  let line = getline(current)
  " the label will be our final folded text

  if b:tnt_first_fold == -1
    let b:tnt_first_fold = current
    let b:tnt_seq_folds[1] = current
    let b:tnt_count_folds = 1
  " when our current fold is back to our first fold again, that means we
  " completed a lap (i.e. a complete iteration of all our folds.)
  elseif current == b:tnt_first_fold
    let b:tnt_num_folds = b:tnt_count_folds
    let b:tnt_count_folds = 0
    wviminfo
  " if we haven't completed a lap yet and our countFolds has come to 
  " equal our last numFolds, we take it to mean our original fistFold 
  " is gone so we set a new one.
  elseif b:tnt_count_folds == 
    let firstFold = current
    " reset our fold sequence array.
    let b:tnt_seq_folds = [current]
    let b:tnt_count_folds = 1
    wviminfo
  else
    let b:tnt_count_folds += 1
    let b:tnt_seq_folds[b:tnt_count_folds] = current
  endif

  let indexed = ''
  let formatted = ''

  " a thread begins with a quote followed optionally by pairs of quotes.
  if line =~ g:tnt_regex.thread
    let children = len(tnt#outliner#children(current))
    let l = matchstr(getline(current + 1), '\S[^{]*')
    let by = strridx(l, '(:')
    if by != -1
      let pos = by
      let l:by = strpart(l, pos)
      let l:l = strpart(l, 0, pos)
    endif

    let lindent = strpart(matchstr(getline(current + 1), '^\s*'), 2)
    " make it optional for threads to show their content with a special 
    " symbol in front of them, e.g. the double quote or a bang
    "let l:l = substitute(l:l, '\(^\s*\)\@<=\s\S\@=', '!', '')
    "return strpart(l:l, 1)
    if line =~ '^\s*"!\d*'
      " get how many chars we should ensure (padding formatting).
      let chars = strpart(matchstr(line, '"!\d*'), 2)
      " get the whole thread title up until it's timestamp, and add 
      " padding.
      let label = matchstr(line, '"![^{]*') . repeat(' ', chars)
      " extract the actual title and format to the size constraint.
      let l:label = strpart(label, 4, chars) . ' '

      let l:formatted = lindent . label . l:l . '['. children .']'
    else | let l:formatted = lindent . l:l . '['. children .']'
    endif
    let b:tnt_threads[current] = { 'target': current + 1, 'short': l,
      \ 'full': label . l, 'by': by }

  " a randomizer thread begins with a percent sign (whatever else does?)
  elseif line =~ '^\s*%'
    let label = get(b:tnt_fold_cache, current, '')
    if label == ''
      let children = tnt#outliner#children(current)
      let random = system('sh -c "echo -n $RANDOM"') % len(children)
      let child = children[random]

      let label = strpart(tnt#outliner#fold_text(child), 2)
      let b:tnt_fold_cache[current] = label

      let b:tnt_threads[current] = { 'line': child, 'short': label,
        \ 'full': label }
    endif
    let l:formatted = label

  " a note begins with a hash, and we'd like to show it's contents' 
  " word count.
  elseif line =~ '^\s*!\?#'
    let lindent = matchstr(getline(current), '^\s*')
    let label = matchstr(getline(current), '\S[^{]*')

    let l:formatted = lindent . label . '('
      \ . tnt#outliner#word_count_recursive(current) . ' words)'

  else
    let l:formatted = getline(current)
  endif

  return formatted
endfunction

function! tnt#outliner#fold_expr(lnum)
  if getline(a:lnum) =~? '\v^\s*$' | return -1 | endif
  let this_indent = tnt#outliner#indent_level(a:lnum)
  let next_indent = tnt#outliner#indent_level(tnt#outliner#next_non_blank_line(a:lnum))
  if next_indent == this_indent | return this_indent
  elseif next_indent < this_indent | return this_indent
  elseif next_indent > this_indent | return '>' . next_indent
  endif
endfunction

function! tnt#outliner#on_open_file()
  " tnt_fold_cache is built to avoid expensive recomputations (e.g. random
  " threads); tnt_threads keeps the line number of the child representing
  " each thread.
  let b:tnt_fold_cache = {} | let b:tnt_threads = {}
  let b:tnt_thread_headlines = 1

  " buffer local state used in fold@fold_text()
  let b:tnt_first_fold = -1
  let b:tnt_num_folds = 0
  let b:tnt_count_folds = 0
  " we keep track of each fold's position so that we can bust our 
  " fold cache if their position changes.
  let b:tnt_seq_folds = []

  setlocal foldmethod=expr
  setlocal foldexpr=tnt#outliner#fold_expr(v:lnum)
  setlocal foldtext=tnt#outliner#fold_text()
  setlocal foldopen=search,mark,percent,quickfix,tag,undo
  setlocal filetype=markdown
  setlocal nowrap
endfunction

function! tnt#outliner#go_previous_sibling()
  let column = getpos('.')[2]
  let heading = tnt#outliner#indent_level(line('.'))
  execute 'normal! k'
  let prev = line('.')
  if tnt#outliner#indent_level(prev) != heading || foldclosed(prev) == -1
    while tnt#outliner#indent_level(line('.')) > heading
      execute 'normal! [z'
    endwhile
    execute 'normal! '.column.'|'
    "call cursor(line('.'), column)
  endif
endfunction

function! tnt#outliner#go_next_sibling()
  let current = line('.')
  execute 'normal! j'
  let next = line('.')
  if tnt#outliner#indent_level(next) > tnt#outliner#indent_level(current)
    execute 'normal! ]zj'
  endif
endfunction

function! tnt#outliner#go_first_lower(direction)
  let startindent = tnt#outliner#indent_level(line('.'))
  execute 'normal! ' . a:direction
  let current = line('.')
  let currentindent = tnt#outliner#indent_level(current)
  while currentindent <= startindent
    \ || matchstr(getline(current), s:webpage_regex) != ''
    if currentindent < startindent | return | endif
    execute 'normal! ' . a:direction
    let current = line('.')
    let currentindent = tnt#outliner#indent_level(current)
  endwhile
endfunction

function! tnt#outliner#go_summit(upto)
  while tnt#outliner#indent_level(line('.')) > a:upto
    execute 'normal! [z'
  endwhile
endfunction

let s:search_mapping = { 'n': '/', 'N': '?' }
function! tnt#outliner#search(directive, direction, ...)
  let clear_highlight = 1
  " the third optional parameter, if true, tells us not to clear the search
  " highlighting (i.e. a normal search.)
  if a:0 == 3 && a:1 | let l:clear_highlight = 0 | endif

  let restore_pos = getpos('.')[1:]
  let restore_foldopen = 0

  if &foldopen =~ 'search'
    set foldopen-=search
    let restore_foldopen = 1
  endif

  " the :next directive means to just n/N to the next match of previous
  " search.
  if a:directive ==# ':next'
    execute "normal! " a:direction
    call tnt#outliner#search_match(a:direction, restore_foldopen, restore_pos)
  " the :wait directive means we should expect user input to drive the 
  " search, so we setup a one-time autocmd to fire on the next 
  " CursorMoved, then prompt the user for the search input.
  elseif a:directive ==# ':wait'
    let char = getchar()
    let search = ''
    while char != 13 && char != 27
      let search = search . nr2char(l:char)
      let char = getchar()
    endwhile
    let @/ = search
    call tnt#outliner#searchMatch(a:direction, restore_foldopen, restore_pos,
      \ clear_highlight)
    return

    let cmd = "call tnt#outliner#search_match('" . a:direction
      \ . "', " . restore_foldopen . ", ["
      \ . restore_pos[0] .",". restore_pos[1] .",". restore_pos[2] . "])"
    call s:register_command('CursorMoved', cmd, 'visibleSearch')
    execute "normal! " s:search_mapping[a:direction]
  " any other directive is interpreted to be a pattern to search for.
  else 
    execute "normal! " . s:search_mapping[a:direction] . a:directive . "\r"
    call tnt#outliner#search_match(a:direction, restore_foldopen, restore_pos,
      \ clear_highlight)
  endif
endfunction

function! tnt#outliner#search_match(direction, restore_foldopen, restore_pos, clear)
  let current = line('.')
  let initial = current

  let first_non_closed_parent = foldclosed(current)
  let indexed = get(b:tnt_threads, first_non_closed_parent, 0)

  while first_non_closed_parent != -1 && ( (indexed && indexed != current)
    \ || (!indexed && current != first_non_closed_parent) )

    execute "normal! " a:direction
    let current = line('.')
    " to prevent infinite looping, stop when we loop around the search results
    " back to our initial match (meaning no match found.)
    if current == initial
      " restore our original cursor position, since no match was found.
      call cursor(a:restorePos)
      break
    endif

    let first_non_closed_parent = foldclosed(current)
    let indexed = get(b:tnt_threads, first_non_closed_parent, 0)
  endwhile

  if a:clear | nohlsearch | endif
  if a:restore_foldopen
    set foldopen+=search
  endif
endfunction

"syn region FoldFocus start="\(\([^\r\n]*[\r\n]\)\{6}\)\@<=\s*\S" end="\[^\r\n]*[\r\n]\(\([^[\r\n]*[\r\n]\)\{2}\)\@="
"hi FoldFocus gui=bold guifg=LimeGreen cterm=bold ctermfg=Green
"hi def link FoldFocus FoldFocus

function! tnt#outliner#children(...)
  let [lnum, filter] = [0, '']
  if a:0 == 0 | return | endif
  if a:0 == 2 | let filter = a:2 | endif
  let lnum = a:1

  let parent = tnt#outliner#indent_level(lnum)
  let i = 1
  let indent = tnt#outliner#indent_level(lnum + i)
  let children = []
  if l:filter == ''
    while indent > parent
      if indent == parent + 1 | call add(children, lnum + i) | endif
      let i = i + 1
      let l:indent = tnt#outliner#indent_level(lnum + i)
    endwhile

  else
    while indent > parent
      if indent == parent + 1
        if match(getline(l:lnum + i), filter) != -1
          call add(children, lnum + i)
        endif
      endif
      let i = i + 1
      let l:indent = tnt#outliner#indent_level(lnum + i)
    endwhile
  endif
  return children
endfunction

function! tnt#outliner#human_date(line)
  echo a:line
  return
  return substitute(a:line, '{>>\([^<]*\)<<}\s*$', '\=submatch(0)')
endfunction

let s:webpage_regex = '^\s*\((\d\d\d\?%)\)\?'
  \ . '\[[^\]]*\]\[[^\]]*\]'
  \ . '\s*\({>>\d*<<}\)\?\s*$'

function! tnt#outliner#trigger_session(lnum)
  let browser = get(g:, 'TNTWebBrowser', '')
  if !len(browser)
    echom 'Please set your web browser by having e.g."'
      \ . "let g:TNTWebBrowser = 'google-chrome'" . '" in your vimrc.'
    return
  endif
  let webpages = tnt#outliner#children(a:lnum, s:webpage_regex)
  if !len(webpages) | return | endif
  let links = ''
  for page in webpages
    let link = matchstr(getline(page), '\[http\S*\]')
    let l:links = links . ' ' . strpart(link, 1, len(link) - 2)
  endfor
  call system(browser.l:links)
endfunction

function! tnt#outliner#word_count(lnum)
  return len(split(getline(a:lnum), '\s'))
endfunction

function! tnt#outliner#word_count_recursive(lnum)
  let wc = get(b:tnt_fold_cache, a:lnum, 0)
  if wc == 0
    let children = tnt#outliner#children(a:lnum)
    for child in children
      let l:wc += tnt#outliner#word_count_recursive(child)
    endfor
    let l:wc += tnt#outliner#word_count(a:lnum)
    let b:tnt_fold_cache[a:lnum] = wc
  endif
  return wc
endfunction

function! tnt#outliner#create_webpage()
  " get curront column
  let cursor = getpos('.')[2]
  " get text on the character next to current position.
  let next = (getline('.'))[cursor]
  " if we're not at the end of the url.
  let adjust = ''
  if len(next) && !(next =~ '\s') | let l:adjust = 'E' | endif
  execute "normal! " . adjust . "a)\<Esc>yBi["

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
    let raw = system("curl -L '" . url . "'")
    let begin = match(raw, '<\s*title\s*>') + 7
    let end = match(raw, '<\s*.\?\s*title\s*>', begin)
    let title = strpart(raw, begin, end - begin)
    let title = substitute(title, '[\r\n]\|\r\n', '', 'g')
    let title = substitute(title, '^\s*\|\s*$', '', 'g')
    let title = substitute(title, '[`"]', "'", 'g')

    " we're gonna try a few tools to decode the html entities.
    if executable('php')
      let decode = "php -r 'echo html_entity_decode(fgets(STDIN),"
        \ . " ENT_NOQUOTES, " . '"UTF-8"' . ");'"
    elseif executable('recode')
      let decode = "recode HTML_4.0"
    else | let decode = ''
    endif
    if decode != '' | let title = system('echo "'.title.'" | '.decode) | endif
  endif

  " finish the markdown link now that we (hopefully) have the title
  execute "normal! a".title
  execute "normal! kJxha]("
endfunction
