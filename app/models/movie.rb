class Movie < ActiveRecord::Base
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end

  def search_tmdb
  end

  def self.find_in_tmdb(search_params, api_key = ENV['TMDB_API_KEY'])
    url = 'https://api.themoviedb.org/3/search/movie'

    params = {
      api_key: api_key,
      query: search_params[:title],
      language: search_params[:language] == 'en' ? 'en-US' : nil
    }

    if search_params[:release_year].present?
      params[:year] = search_params[:release_year]
    end

    response = Faraday.get(url, params)
    raise 'TMDb API request failed' unless response.success?

    results = JSON.parse(response.body)['results'] || []

    results.map do |movie|
      Movie.new(
        title: movie['title'],
        description: movie['overview'],
        release_date: movie['release_date'].present? ? Date.parse(movie['release_date']) : nil,
        rating: 'R'
      )
    end
  end
end

