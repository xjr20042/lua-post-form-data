local http = require 'resty.http'
local cjson = require("cjson")

local _M = {}
function _M.generate_payload(args_table, boundary)
    local line_end_str = '\r\n'
    local payload_end_str = '--' .. boundary .. '--' .. line_end_str .. ''
    local payload = ''
    for k, v in pairs(args_table) do
        local param = {
            '--' .. boundary,
            'Content-Disposition: form-data; name="' .. k .. '"',
            --'Content-Type: text/plain',
            '',
            type(v) == "table" and cjson.encode(v) or v,
        }
        payload = payload .. table.concat(param, line_end_str) .. line_end_str
    end
    payload = payload .. payload_end_str
    return payload
end

function _M.http_post(url, args, boundary)
    local httpc = http.new()
    httpc:set_timeout(2*1000)

    if not boundary then
        boundary = 'wL36Yn8afVp8Ag7AmP8qZ0SA4n1v9T'
    end
    --local res, err =
    return httpc:request_uri(
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
end

return _M

