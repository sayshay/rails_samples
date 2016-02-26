require 'spec_helper'

describe FeedParser, '#parse' do
  let(:count) { 3 }
  let(:news_sources) { create_list(:news_source, count) }
  let(:feeds) { news_sources.map { |news_source| news_source.feed } }
  before {
    news_sources.first.feed.url = 'http://daily-beat.com/feed/'
    news_sources.second.feed.url = 'http://www.dancingastronaut.com/feed/'
    news_sources.third.feed.url = 'http://www.edmtunes.com/feed/'
  }

  it 'successfully parses and updates news sources' do
    # fetch and parse
    FeedParser.parse(news_sources)
    news_sources.each do |news_source|
      # batch size of above feeds
      expect(news_source.articles.count).to eq(10)
    end

    # update
    FeedParser.parse(news_sources)
    news_sources.each do |news_source|
      expect(news_source.articles.count).to eq(10)
    end

  end
end
