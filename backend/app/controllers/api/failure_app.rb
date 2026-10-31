module API
  class FailureApp
    def self.call(_env)
      [ 401, { "content-type" => "application/json" }, [ { error: "Unauthorized" }.to_json ] ]
    end
  end
end
