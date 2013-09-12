"" =============================================================================
"" File:          plugin/tnt.vim
"" Description:   An outliner and system for hackers, writers and artists.
"" Author:        Vic Goldfeld <vic@longstorm.org>
"" Version:       0.0
"" ReleaseDate:   2013-01-31
"" License:       MIT License (see below)
""
"" Copyright (C) 2013 Vic Goldfeld under the MIT License.
""
"" Permission is hereby granted, free of charge, to any person obtaining a 
"" copy of this software and associated documentation files (the "Software"), 
"" to deal in the Software without restriction, including without limitation 
"" the rights to use, copy, modify, merge, publish, distribute, sublicense, 
"" and/or sell copies of the Software, and to permit persons to whom the 
"" Software is furnished to do so, subject to the following conditions:
""
"" The above copyright notice and this permission notice shall be included in 
"" all copies or substantial portions of the Software.
""
"" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
"" OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
"" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
"" THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR 
"" OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
"" ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR 
"" OTHER DEALINGS IN THE SOFTWARE.
"" =============================================================================

if exists('g:loaded_tnt') || &cp
	finish
endif
let g:loaded_tnt = 1

augroup TNT
  autocmd!
  autocmd BufRead,BufNewFile *.tnt*,*.ana* call outliner#autocmds()
  " temporarily switch to manual folding when entering insert mode,
  " so that adjacent folds won't inaverdtently open when we create new folds.
  autocmd InsertEnter *.tnt*,*.ana* let w:last_fm=&foldmethod
    \ | setlocal foldmethod=manual
  autocmd InsertLeave *.tnt*,*.ana* let &l:foldmethod=w:last_fm
augroup END

let g:TNTRegex = {
  \ 'thread': '^\s*"\([^"]*"[^"]*"\)*[^"]*$'
  \ }

nnoremap <silent> <Space>w :TNTTriggerSession<CR>
command! -nargs=0 TNTTriggerSession call outliner#triggerSession(line('.'))

nnoremap <silent> <Space>W :TNTCreateWebpage<CR>
command! -nargs=0 TNTCreateWebpage call outliner#createWebpage()

nnoremap <silent> <Space>m. :execute "normal! a{>>". outliner#timestamp() ."<<}"<CR>
nnoremap <silent> <Space>t :echo 'cmd-t for folds'<CR>

" go to current heading's next sibling.
nnoremap <silent> <Space>j :call outliner#goNextSibling()<CR>
" go to current heading's previous sibling.
nnoremap <silent> <Space>k :call outliner#goPreviousSibling()<CR>
" go to current subtree's heading.
nnoremap <silent> <Space>h @=(outliner#indentLevel('.')?'[z':'')<CR>
" go to next subtree's heading.
nnoremap <silent> <Space>n ]zj

" go to first heading of a lower level than the current.
nnoremap <silent> <Space>l :call outliner#goFirstLower('j')<CR>
" go to current subtree's last open item.
nnoremap <silent> <Space>e ]z
" go to current tree's (whole tree from root) last open item.
"nnoremap <silent> <Space>E

" go back to find the first heading of a lower level than the current.
nnoremap <silent> <Space>gl :call outliner#goFirstLower('k')<CR>

" go to 0th-level heading of current fold, or nth-level with a count.
nnoremap <silent> <Space>H :<C-U>call outliner#goSummit(v:count)<CR>
" go to 0th-level next heading
nnoremap <silent> <Space>L :<C-U>call outliner#goSummit(0)<CR>
  \ :call outliner#goNextSibling()<CR>

" close current subtree's heading
nnoremap <silent> <Space>c @=(outliner#indentLevel('.')?'[z':'')<CR>zc
" close 0th-level heading of current fold, or nth-level with a count.
nnoremap <silent> <Space>C :<C-U>call outliner#goSummit(v:count)<CR>zc

" insert a new parent for the current item. 
"nnoremap <silent> <Space>i
" insert a new absolute parent for the current item, given a count.
" by default, if you don't supply a count, 1 is used, meaning it will insert
" a parent at the level below root--this is more useful in tnt, where you'll
" want to add a new top-level trigger when priorities change--but you can
" change it to another number such as 0 by using `let g:TNTIDefaultCount = 0`.
"nnoremap <silent> <Space>I

" add a new child to the current fold, prepending it to the list. 
"nnoremap <silent> <Space>a
" append a new child to the current fold.
"nnoremap <silent> <Space>A
" prepend a new sibling to the current fold's parent.
"nnoremap <silent> <Space>o
" append a new sibling to the current fold's parent.
"nnoremap <silent> <Space>O

" capital B should operate always on top level block.
" b should be aware of the current indentation's block.

" open all folds on current block.
nnoremap <silent> <Space>bo {v}zo
" close all folds on current block.
nnoremap <silent> <Space>bc {v}zc
" minimize all folds on current block.
nnoremap <silent> <Space>bm {v}zmzc
" open all threads on current block.
nnoremap <silent> <Space>bt {v}zmzo

" move down to next block
"nnoremap <silent> <Space>bj
" move up to previous block
"nnoremap <silent> <Space>bk

" search only visible text
nnoremap <silent> <Space>/ :<C-U>call outliner#search('!WAIT!', 'n', 1)<CR>
nnoremap <silent> <Space>? :<C-U>call outliner#search('!WAIT!', 'N', 1)<CR>
" go to next visible match
nnoremap <silent> <Space>n :<C-U>call outliner#search('!NEXT!', 'n', 1)<CR>
" go to previous visible match
nnoremap <silent> <Space>N :<C-U>call outliner#search('!NEXT!', 'N', 1)<CR>

" search for next/prev visible markdown heading
command! -nargs=0 TNTVisibleHeadingNext call outliner#search("^\s*#", 'n')
nnoremap <silent> <Space>mh :TNTVisibleHeadingNext<CR>
command! -nargs=0 TNTVisibleHeadingPrev call outliner#search("^\s*#", 'N')
nnoremap <silent> <Space>ml :TNTVisibleHeadingPrev<CR>
" search for next/prev markdown heading
command! -nargs=0 TNTVisibleHeadingNext call outliner#search("^\s*#", 'n')
nnoremap <silent> <Space>mh :TNTVisibleHeadingNext<CR>
command! -nargs=0 TNTVisibleHeadingPrev call outliner#search("^\s*#", 'N')
nnoremap <silent> <Space>ml :TNTVisibleHeadingPrev<CR>

command! -nargs=0 TNTVisibleSectionNext call outliner#search('^$', 'n')
nnoremap <silent> <Space>} :TNTVisibleSectionNext<CR>
command! -nargs=0 TNTVisibleSectionPrev call outliner#search('^$', 'N')
nnoremap <silent> <Space>{ :TNTVisibleSectionPrev<CR>

" search for next/prev visible thread
com! -nargs=0 TNTVisibleThreadNext call outliner#search(g:TNTRegex.thread, 'n')
nnoremap <silent> <Space>m' :TNTVisibleThreadNext<CR>
com! -nargs=0 TNTVisibleThreadPrev call outliner#search(g:TNTRegex.thread, 'N')
nnoremap <silent> <Space>m" :TNTVisibleThreadPrev<CR>
" search for next/prev thread
com! -nargs=0 TNTThreadNext execute "normal! /" . g:TNTRegex.thread . "\<CR>"
nnoremap <silent> <Space>M' :TNTThreadNext<CR>
com! -nargs=0 TNTThreadPrev execute "normal! ?" . g:TNTRegex.thread . "\<CR>"
nnoremap <silent> <Space>M" :TNTThreadPrev<CR>

" demote current heading.
nnoremap <silent> <Space>>> zc>>zo
" promote current heading.
nnoremap <silent> <Space><< zc<<zo
" move current fold down one position.
nnoremap <silent> <Space>mj zcddpzo
" move current fold up one position.
nnoremap <silent> <Space>mk zcddkPzo

" ----------------
" TNT-API COMMANDS
" ----------------

" DELETION COMMANDS
"
" mutinying a line promotes the first child to take it's place.
command! -nargs=+ TNTMutinyLine call api#mutinyLine(<f-args>)
" exploding a line eclodes it's children, i.e. it promotes each of them.
command! -nargs=+ TNTExplodeLine echo "TNTExplodeLine is not implemented."
" killing a line orphans it's children, sending them to the nearest inbox.
command! -nargs=+ TNTKillLine echo "TNTKillLine is not implemented."
" killing a fold deletes the heading and all it's children, recursively.
command! -nargs=+ TNTKillFold echo "TNTKillFold is not implemented."
