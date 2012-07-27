class UsersController < ApplicationController
  before_filter :check_administrator_role, :except => [:show, :edit, :update, :show_by_login, :forgot, :reset]
  before_filter :login_required, :only => [:edit, :update]

  def show
    @user = User.find(params[:id])
  end
  
  def show_by_login
    @user = User.find_by_login(params[:login])
    @snippets = Snippet.paginate(:page => params[:page], :conditions => ["user_id =?", @user.id], :order => 'created_at DESC', :per_page => 25)
    
    #@snippets = Snippet.find(:all, :conditions => ["user_id =?", @user.id])
    #@snippets = Snippet.paginate(:page => params[:page], :conditions => ["category_id =?",@categoria], :order => 'created_at DESC', :per_page => 25)
    #render :action => 'show'
  end

  def index
    @users = User.find(:all)
  end

  def edit
    @user = current_user
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "User updated"
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.update_attribute(:enabled, false)
      flash[:notice] = "User disabled"
    else
      flash[:error] = "There was a problem disabling this user."
    end
    redirect_to :action => 'index'
  end
  
  def enable
    @user = User.find(params[:id])
    if @user.update_attribute(:enabled, true)
      flash[:notice] = "User enabled"
    else
      flash[:error] = "There was a problem enabling this user."
    end
    redirect_to :action => 'index'
  end
  
  def forgot
    if request.post?
      user = User.find_by_email(params[:user][:email])
      if user
        user.create_reset_code
        flash[:notice] = "Reset code sent to #{user.email}
      else
        flash[:notice] = "#{params[:user][:email]} does not exist in the system."
      end
      redirect_back_or_default('/')
    end
  end
  
  def reset
    @user = User.find_by_reset_code(params[:reset_code]) unless params[:reset_code].nil?
    if request.post?
      if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
        self.current_user = @user
        @user.delete_reset_code
        flash[:notice] = "Password reset successfully for #{@user.login}"
        redirect_back_or_default('/')
      else
        render :action => :reset
      end
    end
  end
  
  
  
end
