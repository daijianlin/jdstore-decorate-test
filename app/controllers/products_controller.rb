class ProductsController < ApplicationController
  before_action :validate_search_key, only: [:search]
  # before_action :authenticate_user!, only: [:upvote, :downvote]
  def home
    @products = Product.all
  end
  def index
    # if params[:category].blank?
    #   @products = Product
    # else
    #   @category_id = Category.find_by(name:params[:category]).id
    #   @products = Product.where(:category_id => @category_id).order("created_at DESC")
    # end
    @products = Product.all
  end
  def show
    @product = Product.find(params[:id])
  end
  def add_to_cart
    @product = Product.find(params[:id])
    if !current_cart.products.include?(@product)
      current_cart.add_product_to_cart(@product)

      flash[:notice] = "你已成功将#{@product.title}加入购物车"
    else
      flash[:notice] = "你的购物车内已有此物品"
    end
    redirect_to :back
  end

  def search
    if @query_string.present?
      search_result = Product.ransack(@search_criteria).result(:distinct => true)
      @products = search_result.paginate(:page => params[:page], :per_page => 6 )
    end
  end

  def upvote
    @product = Product.find(params[:id])
    @product.upvote_by current_user
    redirect_to :back
  end

  def downvote
    @product = Product.find(params[:id])
    @product.downvote_by current_user
    redirect_to :back
  end


  protected

  def validate_search_key
    @query_string = params[:q].gsub(/\\|\'|\/|\?/, "") if params[:q].present?
    @search_criteria = search_criteria(@query_string)
  end


  def search_criteria(query_string)
    { :title_cont => query_string }
  end
end
