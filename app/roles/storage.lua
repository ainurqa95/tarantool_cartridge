local function init(opts)
    if opts.is_master then

        -- Список учётных записей пользователей.
        -- Для данного списка будет применяться шардирование.
        -- bucket_id необходимо привязать к логину пользователя.
        local users = box.schema.space.create('users',
            { if_not_exists = true, is_sync = true, engine = 'vinyl' }
        )

        users:format({
            { 'bucket_id', 'unsigned' },
            { 'uuid', 'string' },
            { 'login', 'string' },
            { 'password', 'string' },
            { 'status', 'string' }
        })

        users:create_index('user_login_index', {
            parts = { { field = "login", type = "string" } },
            if_not_exists = true
        })

        users:create_index('user_uuid_index', {
            parts = { { field = "uuid", type = "string" } },
            if_not_exists = true
        })
    end
end

local role_name = "storage"

return {
    dependencies = { 'cartridge.roles.vshard-storage' },
    role_name = role_name,
    init = init
}
