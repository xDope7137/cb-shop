fx_version 'cerulean'

game 'gta5'
lua54 'yes'

author 'sobing, xdope'
decription 'cb-shop'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/index.js',
    'html/style.css',
    'html/*otf',
    'html/*png',
    'fonts/*.ttf',
    'fonts/*.otf'
}

client_scripts{
    'client/*.lua',
}

shared_scripts {
	'shared/cores.lua',
    'shared/config.lua'
}

server_scripts {
    'server/*.lua',
}

dependency 'cb_lib'