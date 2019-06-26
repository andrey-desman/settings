if exists("g:loaded_AltFile")
    finish
endif
if (v:progname == "ex")
   finish
endif
let g:loaded_AltFile = 1

let s:subdirs = [ 'inc', 'src', 'include[s]\?', 'source[s]\?' ]

let g:AltFile_ext_map = { }

let g:AltFile_ext_map['c'] = [ 'h' ]
let g:AltFile_ext_map['cpp'] = [ 'hpp', 'h' ]
let g:AltFile_ext_map['cxx'] = [ 'hpp', 'h' ]
let g:AltFile_ext_map['C'] = [ 'H' ]
let g:AltFile_ext_map['h'] = [ 'cpp', 'cxx', 'c' ]
let g:AltFile_ext_map['hpp'] = [ 'cpp', 'cxx' ]
let g:AltFile_ext_map['H'] = [ 'C' ]

fu! s:CloseLoc()
	call setloclist(0, s:saved_loclist)
	silent! lclose
endf

fu! s:GetAltExt(ext)
	if (exists('b:AltFile_ext_map[a:ext]'))
		return b:AltFile_ext_map[a:ext]
	elseif (exists('g:AltFile_ext_map[a:ext]'))
		return g:AltFile_ext_map[a:ext]
	endif
	return []
endf

fu! s:GetSubdirs()
	if (exists('b:AltFile_subdirs'))
		return s:subdirs + b:AltFile_subdirs
	elseif (exists('g:AltFile_subdirs'))
		return s:subdirs + g:AltFile_subdirs
	endif
	return s:subdirs
endf

fu! s:SplitStopDir(path)
	if (exists('b:AltFile_stop_dirs'))
		let l:stop_dirs = b:AltFile_stop_dirs
	elseif (exists('g:AltFile_stop_dirs'))
		let l:stop_dirs = g:AltFile_stop_dirs
	else
		return { "stop_dir": "", "path": a:path }
	endif

	for l:dir_glob in l:stop_dirs
		let l:stop_dir_list = glob(l:dir_glob, 1, 1)
		for l:sdir in l:stop_dir_list
			if (!isdirectory(l:sdir))
				continue
			endif
			let l:stop_dir = fnamemodify(l:sdir, ':p')
			let l:sdir_len = strlen(l:stop_dir)
			if (strpart(a:path, 0, l:sdir_len) ==# l:stop_dir)
				return { "stop_dir": l:stop_dir, "path": strpart(a:path, l:sdir_len) }
			endif
		endfor
	endfor

	return { "stop_dir": "", "path": a:path }
endf

fu! s:FindAltNames(file_name)
	let l:path = fnamemodify(a:file_name, ':p:h')
	let l:name = fnamemodify(a:file_name, ':p:t:r')
	let l:ext = fnamemodify(a:file_name, ':e')

	let l:alt_ext = s:GetAltExt(l:ext)

	if (empty(l:alt_ext))
		return []
	endif

	let l:saved_sua = &l:sua
	let &l:sua = join(map(copy(l:alt_ext), "'.' . v:val"), ',')

	let l:found_files = findfile(l:name, l:path, -1)

	if (empty(l:found_files))
		let l:split_path = s:SplitStopDir(l:path)
		let l:subdirs_pattern = join(s:GetSubdirs(), '\|')
		let l:search_dir = l:split_path.stop_dir . substitute(l:split_path.path, '.*\%(^\|/\)\zs\%(' . l:subdirs_pattern . '\)\ze\%($\|/\)', "*", "")
		let l:found_files = findfile(l:name, l:search_dir, -1)

		if (empty(l:found_files))
			let l:search_dir = l:split_path.stop_dir . substitute(l:.split_path.path, '.*\%(^\|\/\)\zs\%('. l:subdirs_pattern . '\)\%($\|\/\).*', "**", "")
			let l:found_files = findfile(l:name, l:search_dir, -1)
		endif
	endif
	let &l:sua = l:saved_sua

	return l:found_files
endf

fu! s:OpenLocList(file_list)
	let s:saved_loclist = getloclist(0)
	let l:loclist = map(a:file_list, "{ 'filename': v:val }")
	call setloclist(0, l:loclist)
	lopen
	let w:quickfix_title = 'AltFile'
	setlocal modifiable
	silent! %s/|.*//
	setlocal nomodified
	setlocal nomodifiable
	nnoremap <buffer> <CR> <CR>:call <SID>CloseLoc()<CR>
	nnoremap <buffer> q :call <SID>CloseLoc()<CR>
	autocmd BufDelete <buffer> call <SID>CloseLoc()
endf

fu! s:FindExistingAlt(file_name)
	let l:name = fnamemodify(a:file_name, ':p:t:r')
	let l:ext = fnamemodify(a:file_name, ':e')

	let l:alt_ext = s:GetAltExt(l:ext)

	if (empty(l:alt_ext))
		return []
	endif

	let l:last_buffer = bufnr('$')
	let l:i = 1
	while l:i <= l:last_buffer
		if (buflisted(l:i) && expand('#' . l:i . ':t:r') ==# l:name && index(l:alt_ext, expand('#' . l:i . ':e')) >= 0)
			return l:i
		endif
		let l:i += 1
	endwhile
	return -1
endf

fu! s:AltFile_switch()
	let l:file_name = expand('%')

	let l:buffer = s:FindExistingAlt(l:file_name)

	if (l:buffer != -1)
		execute 'buffer' l:buffer
		return
	endif

	let l:file_list = s:FindAltNames(l:file_name)
	if (empty(l:file_list))
		return
	elseif (len(l:file_list) == 1)
		execute 'edit' l:file_list[0]
	else
		call s:OpenLocList(l:file_list)
	endif
endf

" Debug
fu! ShowFindAltNames(file_name)
	echom join(s:FindAltNames(a:file_name), '; ')
endf

fu! ShowStopDir(path)
	let l:split = s:SplitStopDir( a:path )
	echo l:split.stop_dir . " " . l:split.path
endf

command A call <SID>AltFile_switch()
