let s:scriptpath = expand('<sfile>:p:h')

let s:open_command = 'open'

if !executable(s:open_command)
    let s:open_command = 'nohup xdg-open'
endif

function! s:CheckDependency(command) abort
    if !executable(a:command)
        echoerr a:command . ' not available'
    endif
endfunction

function! s:GetFilename() abort
    if bufname('%') ==# ''
        let l:filename = 'No Name.md'
    else
        let l:filename = bufname('%')
    endif

    return l:filename
endfunction

function! s:GenerateFilename(ext) abort
    let l:filename = s:GetFilename()
    return l:filename . '.' . a:ext
endfunction

function! s:GenerateHTML() abort
    call s:CheckDependency('markdown-it')

    let l:markdownitwrapper = s:scriptpath . '/markdown-it-wrapper.js'
    let l:bootstrapcontent = system('cat "' . s:scriptpath . '/node_modules/bootstrap/dist/css/bootstrap.min.css"')
    let l:csscontent = system('cat "' . s:scriptpath . '/markdown-preview.css"')
    let l:htmlcontent = system(l:markdownitwrapper, join(getline(1,'$'),"\n"))

    let l:filename = s:GetFilename()
    let l:html = '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"/>'
                \ . '<meta http-equiv="X-UA-Compatible" content="IE=edge"/>'
                \ . '<style type="text/css">' . l:bootstrapcontent . '</style><title>' . l:filename . '</title></head>'
                \ . '<style type="text/css">' . l:csscontent . '</style><title>' . l:filename . '</title></head>'
                \ . '<body>' . l:htmlcontent . '</body></html>'

    return l:html
endfunction

function! ConvertMarkdownToPDF() abort
    call s:CheckDependency('wkhtmltopdf')

    let l:filename = s:GenerateFilename('pdf')
    let l:html = s:GenerateHTML()
    call system('wkhtmltopdf - ' . l:filename, l:html)
    call system(s:open_command . ' ' . l:filename)
endfunction

function! ConvertMarkdownToDocX() abort
    call s:CheckDependency('pandoc')

    let l:filename = s:GenerateFilename('docx')
    call system('pandoc -o ' . l:filename, join(getline(1,'$'),"\n"))
    call system(s:open_command . ' ' . l:filename)
endfunction

function! ConvertMarkdownToHTML() abort
    let l:filename = s:GenerateFilename('html')
    let l:html = s:GenerateHTML()

    call writefile(split(l:html, "\n", 1), l:filename, 'b')
    call system(s:open_command . ' ' . l:filename)
endfunction
