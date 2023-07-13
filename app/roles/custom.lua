local cartridge = require('cartridge')
local vshard = require('vshard')
local log = require('log')

local function init(opts) -- luacheck: no unused args
    -- if opts.is_master then
    -- end

    local httpd = assert(cartridge.service_get('httpd'), "Failed to get httpd service")
    httpd:route({method = 'GET', path = '/hello'}, function()
        return {body = 'Hello world!'}
    end)

    return true
end

local function stop()
    return true
end

local function validate_config(conf_new, conf_old) -- luacheck: no unused args
    return true
end

local function apply_config(conf, opts) -- luacheck: no unused args
    -- if opts.is_master then
    -- end

    return true
end

--- Создание учётной записи пользователя.
function create_user(user_uuid, login, password_hash, status, groups)
    log.debug('create_user ' .. user_uuid .. '|' .. login .. '|' .. password_hash .. '|' .. status)

    local bucket_id = vshard.router.bucket_id_strcrc32(login);

    local _, err = vshard.router.callrw(bucket_id, 'box.space.users:insert', {
        { bucket_id, user_uuid, login, password_hash, status }
    })

    if err ~= nil then
        log.error(err)
        return nil
    end

    return user_uuid
end

--- Получение информации об учётной записи пользователя по логину пользователя.
function get_user_by_login(login)
    log.debug('get_user_by_login ' .. login)

    local bucket_id = vshard.router.bucket_id_strcrc32(login);

    local users, err = vshard.router.callbro(bucket_id, 'box.space.users:select', { login })

    if err ~= nil then
        log.error(err)
        return nil
    end

    return users[1]
end

return {
    role_name = 'app.roles.custom',
    init = init,
    stop = stop,
    validate_config = validate_config,
    apply_config = apply_config,
    dependencies = {'cartridge.roles.vshard-router'},
}
