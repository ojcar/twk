class CategoriesController < ApplicationController
  before_filter :check_administrator_role, :except => [:index, :show, :list]
  
  def list
    categoria = @params[:name]
    @snippets = Snippet.find(:all, :conditions => ["snippets.category.name = ?", categoria])
  end
  
  def index
    @categories = Category.find(:all)
  end

  def show
    @category = Category.find(params[:id])
    redirect_to category_snippets_url(:category_id => @category.id)
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.create(params[:category])
    redirect_to admin_categories_url
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    @category.update_attributes(params[:category])
    redirect_to admin_categories_url
  end

  def destroy
    @category = Category.find(params[:id])
    @category.find(params[:id]).destroy
    redirect_to admin_categories_url
  end

  def admin
    @categories = Category.find(:all)
  end
end
