class Movie < ActiveRecord::Base

  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
  def self.find_by_director(title, director)
    Movie.find(:all, :conditions => ["title != ? and director = ?", title, director])
  end
  
end
