class SnippetsController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :add_comment]
  before_filter :check_administrator_role, :only => [:edit, :update, :destroy]
  helper :sparklines

  # formerly index
  def list
    @snippets = Snippet.paginate(:page => params[:page], :order => 'created_at DESC', :per_page => 25)
    respond_to do |wants|
      wants.html
      wants.xml { render :xml => @snippets.to_xml }
      wants.rss { render :action => 'rss.rxml', :layout => false }
      wants.atom { render :action => 'atom.rxml', :layout => false }
    end
  end

  def single
    @snippets = Snippet.find(:all, :limit => 1)
  end
  
  # formerly random
  def index
    cuantos = rand(Snippet.count)
    @snippet = Snippet.find(:first, :offset => cuantos)
  end

  def random
    cuantos = rand(Snippet.count)
    @snippet = Snippet.find(:first, :offset => cuantos)
  end

  def show
    @snippet = Snippet.find(params[:id])
    # voteable = 'Snippet'
    # @votes = Vote.find(:all, :conditions => ["voteable_id = ? and voteable_type = ?", params[:id], voteable], :order => "created_at DESC")
  end
  
  def show_by_category
    @categoria = Category.find_by_name(params[:name])
    #@snippets = Snippet.paginate_by_sql(["SELECT * FROM snippets, categories WHERE snippets.category_id = categories.id AND categories.name = ?", @categoria], :page => params[:page], :order => 'created_at DESC', :per_page => 25)
    @snippets = Snippet.paginate(:page => params[:page], :conditions => ["category_id =?",@categoria], :order => 'created_at DESC', :per_page => 25)
  end
  
  def show_by_prediction
    @snippets = Snippet.paginate(:page => params[:page], :conditions => ["is_prediction = 1"], :order => 'created_at DESC', :per_page =>25)
  end
  
  def new
    #@snippet = Snippet.new
    @newsnippet = Snippet.new
    #@prediction = Prediction.new
  end
  
  def create
      @newsnippet = Snippet.new(params[:newsnippet])
      @newsnippet.title = @newsnippet.content.first(25)
      @newsnippet.user_id = current_user.id

      return unless request.post?
      if @newsnippet.is_prediction?
          @newsnippet.expiration = Chronic.parse(params[:newsnippet][:expiration])
          unless @newsnippet.expiration.nil?          
              if @newsnippet.save
          		flash[:notice] = "Your post is now saved."
          		redirect_to :action => 'show', :id => @newsnippet.id
          	else
                  flash[:notice] = "Your post could not be saved. Please try again later."
          		render :action => 'new'
          	end
          else
          	flash[:notice] = "The post is a prediction but the expiration date is not valid. Please change it."
          	render :action => 'new'
           end
       else
       	if @newsnippet.save
          	flash[:notice] = "Your post is now saved."
          	redirect_to :action => 'show', :id => @newsnippet.id
          else
              flash[:notice] = "Your post could not be saved. Please try again later."
          	  render :action => 'new'
          end
       end
  end  

def create_old
    @snippet = Snippet.new(params[:snippet])
    @snippet.title = @snippet.content.first(25)
    @snippet.user_id = current_user.id
    
    return unless request.post?
    if @snippet.is_prediction?
        @snippet.expiration = Chronic.parse(params[:snippet][:expiration])
        unless @snippet.expiration.nil?          
            if @snippet.save
        		flash[:notice] = "Your post is now saved."
        		redirect_to :action => 'show', :id => @snippet.id
        	else
                flash[:notice] = "Your post could not be saved. Please try again later."
        		render :action => 'new'
        	end
        else
        	flash[:notice] = "The post is a prediction but the expiration date is not valid. Please change it."
        	render :action => 'new'
         end
     else
     	if @snippet.save
        	flash[:notice] = "Your post is now saved."
        	redirect_to :action => 'show', :id => @snippet.id
        else
            flash[:notice] = "Your post could not be saved. Please try again later."
        	render :action => 'new'
        end
     end
end


  def edit
    @snippet = Snippet.find(params[:id])
    @snippet.attributes = params[:snippet]
    @snippet.save!
    flash[:notice] = "Update completed."
    redirect_to :action => 'index'
    rescue
      render :action => 'edit'
  end

  def update
  end

  def destroy
    @snippet = Snippet.find(params[:id])
    if @snippet.destroy
      flash[:notice] = "Truth deleted."
    else
      flash[:error] = "There was a problem deleting the page."
    end
    redirect_to :action => 'index'
  end
  
# One man, one vote  
  def vote
    return unless logged_in?
      @snippet = Snippet.find(params[:id])
      unless @snippet.voted_by_user?(current_user)
        @vote = Vote.new(:vote => params[:vote] == "for")
        @vote.user_id = current_user.id
        # @snippet.how_truthful = @snippet.votes_for / @snippet.votes_count
        @snippet.votes << @vote
      end
  end
  
  def add_comment
    @snippet = Snippet.find(params[:id])
    
    @comment = Comment.new(params[:comment])
    @comment.created_at = Time.now
    @comment.title = @comment.comment.first(5)
    @comment.user_id = current_user.id
    @snippet.comments << @comment
    
    flash[:notice] = "Comment Added."
    redirect_to :action => 'show', :id => @snippet.id
  end  
  
end
