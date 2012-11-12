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
    
end
