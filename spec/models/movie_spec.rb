require 'spec_helper'

describe Movie do

  before :each do
    @fake_title = "title1"
    @fake_director = "director1"
  end
  describe 'searching movies by director' do
    context 'with valid director' do
      it 'should call movies with director keywords' do
        Movie.should_receive(:find).with(:all, :conditions => ["title != ? and director = ?", @fake_title, @fake_director])
        Movie.find_by_director(@fake_title, @fake_director)
      end
    end
  end
  
  describe 'searching Tmdb by keyword' do
    context 'with valid key' do
      it 'should call Tmdb with title keywords' do
        TmdbMovie.should_receive(:find).with(hash_including :title => @fake_title)
        Movie.find_in_tmdb(@fake_title)
      end
    end
    context 'with invalid key' do
      it 'should raise an InvalidKeyError with no API key' do
        Movie.stub(:api_key).and_return('')
        lambda { Movie.find_in_tmdb(@fake_title) }.
          should raise_error(Movie::InvalidKeyError)
      end
      it 'should raise an InvalidKeyError with invalid API key' do
        TmdbMovie.stub(:find).
          and_raise(RuntimeError.new("API returned status code '404'"))
        lambda { Movie.find_in_tmdb(@fake_title) }.
          should raise_error(Movie::InvalidKeyError)
      end
    end
  end 
    
end
