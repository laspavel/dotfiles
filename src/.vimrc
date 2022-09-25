" замена табов на пробелы
set expandtab

" при нажатии таба в начале строки добавляет количество пробелов равное shiftwidth
set smarttab
set shiftwidth=4

" количество пробелов в одном обычном табе
set tabstop=4

" количество пробелов в табе при удалении
set softtabstop=4

" Включение нумерации строк
" set number

" отступ между левой частью окна
set foldcolumn=2

" Отключение звуковых эффектов
set noerrorbells
set novisualbell

" Включение поддержки мыши
set mouse=a

" Игнорировать регистр при поиске
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
