require 'spec_helper'

describe MoviesController do

  describe 'searching movies' do  
    before :each do
      @fake_results = [mock('movie1'), mock('movie2')]
      @fake_title = "title1"
      @fake_director = "director1"
    end 
    it 'should call the model method that performs director search' do
      Movie.should_receive(:find_by_director).with(@fake_title, @fake_director)
      get :same_director, {:title => @fake_title, :director => @fake_director} 
    end  
    describe 'after valid search' do 
      before :each do
        Movie.stub(:find_by_director).and_return(@fake_results)
        get :same_director, {:title => @fake_title, :director => @fake_director}
      end
      it 'should select the Similar Movies template for rendering' do
        response.should render_template('same_director')
      end 
      it 'should make the director search results available to that template' do
        assigns(:movies).should == @fake_results
      end     
    end
    describe 'after empty director search' do     
      before :each do
        Movie.should_not_receive(:find_by_director)
        get :same_director, {:title => "title1", :director => ""}
      end
      it 'should render the home page' do
        response.should redirect_to(movies_path)
      end     
    end
  end
   
end
