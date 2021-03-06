class ApiController < ApplicationController
  JAM = "http://api.thisismyjam.com/1/search/jam.json"
  RANDOM = "http://api.thisismyjam.com/1/explore/chance.json"

  def search
    begin
      response = HTTParty.get(JAM, query: { "by" => "artist", "q" => params[:artist] })
      data = setup_data(response)
      code = data.any? ? :ok : :no_content
    rescue
      data = {}
      code = :no_content
    end

    render json: data.as_json, status: code
  end

  def random
    response = HTTParty.get(RANDOM)
    data = setup_data(response)
    data = cull_data(data, 10)

    render json: data.as_json, code: :ok
  end

  private

  def cull_data(data, number)
    data[0...number]
  end

  def setup_data(response)
    # "Fetches" the contents of the jams key in the HTTParty object/hash.
    jams = response.fetch "jams", {}
    jams.map do |jam|
      {
        via: jam.fetch("via", ""),
        url: jam.fetch("viaUrl", ""),
        title: jam.fetch("title", ""),
        artist: jam.fetch("artist", "")
      }
    end
  end
end
