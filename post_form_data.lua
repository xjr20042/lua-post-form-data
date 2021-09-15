local http = require 'resty.http'
local _M = {}
function _M.generate_payload(args_table, boundary)
    local line_end_str = '\r\n'
    local payload_end_str = '--' .. boundary .. '--' .. line_end_str .. ''
    local payload = ''
    for k, v in pairs(args_table) do
        local param = {
            '--' .. boundary,
            'Content-Disposition: form-data; name=' .. k .. ';',
            'Content-Type: text/plain',
            '',
            v
        }
        payload = payload .. table.concat(param, line_end_str) .. line_end_str
    end
    payload = payload .. payload_end_str
    return payload
end

function _M.http_post(url, args, boundary)
    local httpc = http.new()
    httpc:set_timeout(20 * 60 * 1000)

    if not boundary then
        boundary = 'wL36Yn8afVp8Ag7AmP8qZ0SA4n1v9T' --分割符
    end

    local res, err =
        httpc:request_uri(
        url,
        {
            method = 'POST',
            body = _M.generate_payload(args, boundary),
            headers = {
                ['Content-Type'] = 'multipart/form-data; boundary=' .. boundary
            },
            ssl_verify = false,
            keepalive_pool = 30
        }
    )
    if err then
        local msg = 'url:' .. url .. '\nerr:' .. err
        error(msg)
    end
    return res
end

return _M
