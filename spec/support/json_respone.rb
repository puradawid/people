module Helpers
  module JSONResponse
    def json_response
      @json ||= JSON.parse(response.body)
    end
  end
end
