" Длина одного таба (количество пробелов приравниваемое одному символу табуляции).
set tabstop=4

" Количество пробелов в табе при удалении
set softtabstop=4

" При нажатии таба в начале строки добавляет количество пробелов равное shiftwidth 
set shiftwidth=4
set smarttab

" Замена табов на пробелы
set expandtab

" При переходе на новую строку курсор будет стоять на таком же расстоянии как и предыдущая строка. А так же добавляет отступ после символа { и удаляет один отступ перед 
set smartindent

" Включение синтаксиса языков программирования
syntax on

" Включение нумерации строк
" set number

" отступ между левой частью окна
set foldcolumn=2

" Отключение звуковых эффектов
set noerrorbells
set novisualbell

" Включение поддержки мыши
set mouse=a

" Сделать размер истории последних изменений
" для undo/redo равным 1000
set undolevels=1000
set history=1000

" «Умный» поиск:
" - при вводе только маленьких (строчных) букв
"   ищет регистро-независимо
" - а если введена хотя бы одна большая (заглавная/прописная)
"   буква, то будет искать регистро-зависимо
set ignorecase
set smartcase

" Подсвечивать результаты поиска
set hlsearch

" Кодировка файла по умолчанию
set encoding=utf8

" стандарт использования символов переноса строки в файлах
set ffs=unix,dos,mac

call plug#begin()
  Plug 'altercation/solarized'
  Plug 'itchyny/lightline.vim'
call plug#end()
set background=dark

" Цветовая схема
" colorscheme gruvbox

" Включение синтаксиса 
syntax on 

set laststatus=2
set statusline=%f%m%r%h%w\ %y\ enc:%{&enc}\ ff:%{&ff}\ fenc:%{&fenc}%=(ch:%3b\ hex:%2B)\ col:%2c\ line:%2l/%L\ [%2p%%]

" Автообновление, при изменении файла извне
set updatetime=2000
set autoread

" Работа с вводом (INSERT) без переключения раскладки
noremap ш i
noremap Ш I
noremap ф a
noremap Ф A
noremap щ o
noremap Щ O

" Работа с заменой (REPLACE) без переключения раскладки
noremap к r
noremap К R

" Работа с режимом выделения (VISUAL) без переключения раскладки
noremap м v
noremap М V

" Работа с поиском:
" следующее и предыдущее совпадение без переключения раскладки
noremap т n
noremap Т N

" Копировать, удалить и вставить без переключения раскладки
noremap н y
noremap Н Y
noremap в d
noremap В D
noremap ч x
noremap Ч X
noremap з p
noremap З P

" Перемещения к началу/концу слов без переключения раскладки
noremap ц w
noremap Ц W
noremap у e
noremap У E
noremap и b
noremap И B

" Некоторые прочие русские буквы
noremap й q
noremap Й Q
noremap с c
noremap С C
noremap п g
noremap П G

" Ctrl+s для сохранения файла и возврата в нормальный режим (NORMAL)
"   из NORMAL
nnoremap <C-s> :w<CR>
nnoremap <C-ы> :w<CR>
nnoremap <C-і> :w<CR>
nnoremap <F2> :w<CR>

"   из INSERT
inoremap <C-s> <Esc>:w<CR>
inoremap <C-ы> <Esc>:w<CR>
inoremap <C-і> <Esc>:w<CR>
inoremap <F2> <Esc>:w<CR>

"   из VISUAL
vnoremap <C-s> <Esc>:w<CR>
vnoremap <C-ы> <Esc>:w<CR>
vnoremap <C-і> <Esc>:w<CR>
vnoremap <F2> <Esc>:w<CR>

" Ctrl+c для закрытия текущего файла
" nnoremap <C-c> :q<CR>
" nnoremap <C-с> :q<CR>s
" inoremap <C-c> <Esc>:q<CR>
" inoremap <C-с> <Esc>:q<CR>
" vnoremap <C-c> <Esc>:q<CR>
" vnoremap <C-с> <Esc>:q<CR>

" Ctrl+End для закрытия текущего файла
nnoremap <C-End> :q!<CR>
inoremap <C-End> <Esc>:q!<CR>
vnoremap <C-End> <Esc>:q!<CR>


" Ctrl+z для отмены изменений и Ctrl+x для возврата к изменениям
" в режимах NORMAL, VISUAL и INSERT
nnoremap <C-z> :undo<CR>
vnoremap <C-z> <Esc>:undo<CR>
inoremap <C-z> <Esc>:undo<CR>i
nnoremap <C-x> :redo<CR>
vnoremap <C-x> <Esc>:redo<CR>
inoremap <C-x> <Esc>:redo<CR>i

" Отключение бэкапных файлов Vim, ведь скорее всего,
" весь код уже в какой-нибудь VCS: mercury или git
" ЕСЛИ ВЫ РАБОТАЕТЕ ПО SSH, ЛУЧШЕ ЗАКОММЕНТИРОВАТЬ,
" потому что соединение может оборваться и вы потеряете
" все последние изменения
"set nobackup
"set nowb
"set noswapfile
