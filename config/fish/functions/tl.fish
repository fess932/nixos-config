function tl --wraps='tsh login --auth=passwordless' --wraps='tsh login --proxy tp-cloud.wb.ru' --wraps='tsh login --proxy tp-cloud.wb.ru --auth=passwordless' --description 'alias tl=tsh login --proxy tp-cloud.wb.ru --auth=passwordless'
    tsh login --proxy tp-cloud.wb.ru --auth=passwordless $argv
end
