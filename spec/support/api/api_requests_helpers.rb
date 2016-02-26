module ApiRequestsHelpers
  module JsonHelpers
    def json
      @json ||= JSON.parse last_response.body
    end

    def refresh_json
      @json = JSON.parse last_response.body
    end

    def print_json
      puts JSON.pretty_generate(json)
    end

    def json_has_key(key)
      item_has_key(json, key)
    end

    def json_has_keys(keys)
      item_has_keys(json, keys)
    end

    def json_has_no_key(key)
      item_has_no_key(json, key)
    end

    def item_has_key(item, key)
      expect(item).to have_key(key.to_s)
    end

    def item_has_no_key(item, key)
      expect(item).not_to have_key(key.to_s)
    end

    def item_has_keys(item, keys)
      keys.each { |key| item_has_key(item, key) }
    end

  end

  module ResponseHelpers
    def should_respond_ok
      response_status 200
    end

    def should_respond_created
      response_status 201
    end

    def should_respond_with_no_content
      response_status 204
    end

    def should_respond_not_authenticated
      response_status 401
    end

    def should_respond_not_authorized
      response_status 403
    end

    def should_respond_not_found
      response_status 404
    end

    def response_status(status)
      expect(last_response.status).to eq(status)
    end

    def should_respond_with_error_for(field)
      response_status 422
      expect(json["errors"]).to have_key(field.to_s)
    end

    def should_respond_with_errors_for(fields)
      fields.each { |field| should_respond_with_error_for(field) }
    end
  end

  module RequestHelpers
    def basic_auth_header
      login = 'admin'
      password = 'festivals'
      { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(login, password) }
    end

    def auth_header options
      options[:auth_header] || {}
    end

    def default_options
      { auth_header: basic_auth_header }
    end

    def guest_options
      {}
    end
  end
end

RSpec.configure do |c|
  c.include ApiRequestsHelpers::JsonHelpers, type: :api
  c.include ApiRequestsHelpers::ResponseHelpers, type: :api
  c.include ApiRequestsHelpers::RequestHelpers, type: :api
end
