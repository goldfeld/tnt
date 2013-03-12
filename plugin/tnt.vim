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
  autocmd BufRead,BufNewFile *.tnt.* call outliner#autocmds()
  " temporarily switch to manual folding when entering insert mode,
  " so that adjacent folds won't inaverdtently open when we create new folds.
  autocmd InsertEnter *.tnt.* let w:last_fm=&foldmethod
    \ | setlocal foldmethod=manual
  autocmd InsertLeave *.tnt.* let &l:foldmethod=w:last_fm
augroup END

nnoremap <silent> <Space>w :TNTTriggerSession<CR>
nnoremap <silent> <Space>W :TNTCreateWebpage<CR>
nnoremap <silent> <Space>mt :execute "normal! a{>>". outliner#timestamp() ."<<}"<CR>
nnoremap <silent> <Space>t :echo 'cmd-t for folds'<CR>

" go to current heading's next sibling.
noremap <silent> <Space>j :call outliner#goNextSibling()<CR>
" go to current heading's previous sibling.
noremap <silent> <Space>k :call outliner#goPreviousSibling()<CR>
" go to current subtree's heading.
noremap <silent> <Space>h [z
" go to next subtree's heading.
noremap <silent> <Space>n ]zj

" go to first heading of a lower level than the current.
noremap <silent> <Space>l :call outliner#goFirstLower('j')<CR>
" go to current subtree's last open item.
noremap <silent> <Space>e ]z
" go to current tree's (whole tree from root) last open item.
"noremap <silent> <Space>E

" go to 0th-level heading of current fold, or nth-level with a count.
noremap <silent> <Space>H :<C-U>call outliner#goTopLevelHeading(v:count)<CR>
" go back to find the first heading of a lower level than the current.
noremap <silent> <Space>L :call outliner#goFirstLower('k')<CR>

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

" demote current heading.
nnoremap <silent> <Space>>> zc>>zo
" promote current heading.
nnoremap <silent> <Space><< zc<<zo
" move current fold down one position.
nnoremap <silent> <Space>mj zcddpzo
" move current fold up one position.
nnoremap <silent> <Space>mk zcddkPzo
