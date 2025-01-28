fx_version 'cerulean'
game 'gta5'

name 'Blackmarket'
author 'Nicky'
description 'A Simple, Configurable Blackmarket Script by Nicky'
version '1.1.1'

lua54 'yes'

shared_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua'
}

server_scripts {
    'server/main.lua'
}

client_scripts {
    'client/main.lua',
}
