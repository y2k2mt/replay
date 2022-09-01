module Recorder
  def self.record(io : IO, requests : Requests, datasource : Datasource) : RequestError | ProxyError | Record?
    case maybe_request = requests.from(io)
    when RequestError
      maybe_request
    when Request
      case maybe_record = maybe_request.proxy
      when Record
        datasource.persist(maybe_request, maybe_record)
      when ProxyError
        maybe_record
      end
    else
      ProxyError.new
    end
  end
end
