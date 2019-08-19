let s:scriptpath = expand('<sfile>:p:h')

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
    let l:csscontent = system('cat "' . s:scriptpath . '/markdown-preview.css"')
    let l:htmlcontent = system(l:markdownitwrapper, join(getline(1,'$'),"\n"))

    let l:filename = s:GetFilename()
    let l:html = '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"/>'
                \ . '<meta http-equiv="X-UA-Compatible" content="IE=edge"/>'
                \ . '<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">'
                \ . '<script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>'
                \ . '<style type="text/css">' . l:csscontent . '</style><title>' . l:filename . '</title></head>'
                \ . '<body>' . l:htmlcontent . '<script>$("table").addClass("table");</script>'
                \ . '</div></body></html>'

    return l:html
endfunction

function! ConvertMarkdownToPDF() abort
    call s:CheckDependency('wkhtmltopdf')

    let l:filename = s:GenerateFilename('pdf')
    let l:html = s:GenerateHTML()
    call system('wkhtmltopdf - ' . l:filename, l:html)
    call system('open ' . l:filename)
endfunction

function! ConvertMarkdownToDocX() abort
    call s:CheckDependency('pandoc')

    let l:filename = s:GenerateFilename('docx')
    call system('pandoc -o ' . l:filename, join(getline(1,'$'),"\n"))
    call system('open ' . l:filename)
endfunction

function! ConvertMarkdownToHTML() abort
    let l:filename = s:GenerateFilename('html')
    let l:html = s:GenerateHTML()

    call writefile(split(l:html, "\n", 1), l:filename, 'b')
    call system('open ' . l:filename)
endfunction
