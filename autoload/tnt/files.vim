function! tnt#files#remove_trailing_slash(path)
  if a:path[len(a:path) - 1] == '/' | return a:path[:-2]
  else | return a:path
  endif
endfunction

function! tnt#files#get_apex(folderpath)
  let path = tnt#files#remove_trailing_slash(a:folderpath)
  let folder = fnamemodify(path, ':t')
  return path . '/' . folder . '.tnt'
endfunction

function! tnt#files#letter2global_var_name(letter)
  return 'tnt_' . g:tnt_prefix_dict[a:letter] . '_folder'
endfunction

function! tnt#files#letter2folder_path(letter)
  return g:[tnt#files#letter2global_var_name(a:letter)]
endfunction

function! tnt#files#title2slug(title)
  return substitute(a:title, ' ', '_', 'g')
endfunction

function! tnt#files#open_session_link(line, col)
  let link = matchstr(a:line, '\v^\s*\"?\/\zs[a-z]\/(.*)')
  if len(link)
    let [letter, title] = [link[0], link[2:]]   
    let slug = tnt#files#title2slug(title)
    let path = tnt#files#letter2folder_path(letter) . '/' . slug
    if !isdirectory(path)
      call mkdir(fnamemodify(path, ':p'), 'p')
    endif

    exe 'edit ' . path . '/' . slug . '.tnt'
  endif
endfunction
