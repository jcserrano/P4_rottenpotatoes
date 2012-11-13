require 'spec_helper'

describe MoviesController do

  describe 'show movie controller' do 
    before :each do
      @fake_movie = mock('movie1', :id => '1', :title => 'movie1title')
    end
    it 'should call find()' do
      Movie.should_receive(:find).with(@fake_movie.id)
      get :show, {:id => @fake_movie.id}
    end  
  end
  
  describe 'index movie controller' do
    it "sort movies by title" do
      get :index, {:sort => 'title'}        
      response.should be_redirect
    end
    it "sort movies by release date" do
      get :index, {:sort => 'release_date'}        
      response.should be_redirect
    end
    it "keep ordering movies by release date" do
      session[:sort] = 'release_date'
      get :index
      response.should be_redirect
    end
    it "keep ordering movies by title" do
      session[:sort] = 'title'
      get :index
      response.should be_redirect
    end
    it "keep selecting movies ratings" do
      session[:ratings] = 'PG', 'G'
      get :index
      response.should be_redirect
    end
  end

  describe 'create movie' do
    before :each do
      m = mock('movie1', :title => 'movie1title')
      Movie.should_receive(:create!).and_return(m)
    end 
    it 'should call create!()' do
      post :create, :movie => mock('movie1')
    end
    it 'should render the main page' do
      post :create, :movie => mock('movie1')
      response.should redirect_to(movies_path)
    end
  end
  
  describe 'edit movie' do
    before :each do
      @fake_movie = mock('movie1', :id => '1', :title => 'movie1title')
    end
    it 'should call find()' do
      Movie.should_receive(:find).with(@fake_movie.id)
      get :edit, {:id => @fake_movie.id}
    end  
  end
  
  describe 'update movie' do
    before :each do
      @fake_movie = mock('movie1', :id => '1', :title => 'movie1title')
      @fake_rating = 'PG-15'
      Movie.stub(:find).and_return(@fake_movie)
      @fake_movie.should_receive(:update_attributes!).with("rating" => @fake_rating)
    end 
    it 'should call update_attributes!()' do
      put :update, :id => @fake_movie.id, :movie => {:rating => @fake_rating}
    end
    it 'should render the Details page' do
      put :update, :id => @fake_movie.id, :movie => {:rating => @fake_rating}
      response.should redirect_to(movie_path(@fake_movie))
    end 
  end 
  
  describe 'delete movie' do
    before :each do
      @fake_movie = mock('movie1', :id => '1', :title => 'movie1title')
      Movie.stub(:find).and_return(@fake_movie)
      @fake_movie.should_receive(:destroy)
    end 
    it 'should call destroy()' do
      delete :destroy, :id => @fake_movie.id
    end
    it 'should render the home page' do
      delete :destroy, :id => @fake_movie.id
      response.should redirect_to(movies_path)
    end  
  end

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
  
  describe 'searching TMDb' do
    before :each do
      @fake_title = "title1"
      @fake_results = [mock('movie1')]
    end
    it 'should call the model method that performs TMDb search' do
      Movie.should_receive(:find_in_tmdb).with(@fake_title).
        and_return(@fake_results)
      post :search_tmdb, {:search_terms => @fake_title}
    end
    describe 'after valid search' do
      before :each do
        Movie.stub(:find_in_tmdb).and_return(@fake_results)
        post :search_tmdb, {:search_terms => @fake_title}
      end
      it 'should select the Search Results template for rendering' do
        response.should render_template('search_tmdb')
      end
      it 'should make the TMDb search results available to that template' do
        assigns(:movie).should == @fake_results
      end
    end
    describe 'after no valid search' do     
      before :each do
        Movie.stub(:find_in_tmdb)
        post :search_tmdb, {:search_terms => @fake_title}
      end
      it 'should render the home page' do
        response.should redirect_to(movies_path)
      end     
    end
    describe 'raise Movie::InvalidKeyError' do
      before :each do
        Movie.stub(:find_in_tmdb).and_raise(Movie::InvalidKeyError)
        post :search_tmdb, {:search_terms => @fake_title}
      end
      it 'should render the home page' do
        response.should redirect_to(movies_path)
      end  
    end
  end
   
end
