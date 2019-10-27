class PostsController < ApplicationController
  skip_before_action :authenticate_user!
  add_breadcrumb "Posts", :posts_path

  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    #@posts = Post.where("published_on >= ?", Time.now.utc.to_date)
    @featured_posts = Post.where(is_featured: true).order(:position)
    @posts = Post.where(is_featured: false).order(:published_on).reverse
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    add_breadcrumb @post.title, post_path(@post), :title => "Back to the Index"
  end

  # GET /posts/new
  def new
    redirect_to posts_path unless current_user && current_user.is_admin
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
    redirect_to posts_path(@post) unless current_user && current_user.is_admin
  end

  # POST /posts
  # POST /posts.json
  def create
    render "errors/unacceptable", status: :unprocessable_entity unless current_user.is_admin

    params[:post][:published_on] = params[:post][:published_on].to_date
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }

        if @post.is_featured
          featured_posts = Post.where(is_featured: true).order(:published_on)
          
          if featured_posts.length > 4
            featured_posts[4..-1].each do |fp|
              fp.is_featured = false
              fp.save
            end
          end

        end

      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    render "errors/unacceptable", status: :unprocessable_entity unless current_user.is_admin
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    render "errors/unacceptable", status: :unprocessable_entity unless current_user.is_admin
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.friendly.find(params[:id]).decorate
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :body, :thumbnail, :published_on, :tags, :is_featured, :description)
    end
end
