class MoviesController < ApplicationController

  before_filter :login, :except => [:index, :show, :same_director, :search_tmdb]

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    sort = params[:sort] || session[:sort]
    case sort
    when 'title'
      ordering,@title_header = {:order => :title}, 'hilite'
    when 'release_date'
      ordering,@date_header = {:order => :release_date}, 'hilite'
    end
    @all_ratings = Movie.all_ratings
    @selected_ratings = params[:ratings] || session[:ratings] || {}
    
    if @selected_ratings == {}
      @selected_ratings = Hash[@all_ratings.map {|rating| [rating, rating]}]
    end
    
    if params[:sort] != session[:sort]
      session[:sort] = sort
      flash.keep
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end

    if params[:ratings] != session[:ratings] and @selected_ratings != {}
      session[:sort] = sort
      session[:ratings] = @selected_ratings
      flash.keep
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end
    @movies = Movie.find_all_by_rating(@selected_ratings.keys, ordering)
  end

  def new
    # default: render 'new' template
  end

  def create
    if params[:commit] == "Cancel"
      redirect_to movies_path
    else
      @movie = Movie.create!(params[:movie])
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    if params[:commit] == "Cancel"
      redirect_to movie_path(@movie)
    else
      @movie.update_attributes!(params[:movie])
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  def same_director
    if params[:director].nil? || params[:director] == ""
      flash[:notice] = "'#{params[:title]}' has no director info."
      redirect_to movies_path
      return
    end 
    @movies = Movie.find_by_director(params[:title], params[:director])
    if !@movies.nil? and @movies.size == 0
      flash[:notice] = "Not found any movies with the same director that '#{params[:title]}'."
      redirect_to movies_path
    end
  end
  
  def search_tmdb
    begin
      @movie = Movie.find_in_tmdb(params[:search_terms])
      if @movie.nil? || @movie.empty?
        flash[:warning] = "'#{params[:search_terms]}' was not found in TMDb."
        redirect_to movies_path
      end
    rescue Movie::InvalidKeyError
      flash[:warning] = "Search not available."
      redirect_to movies_path
    end 
  end
  
end
