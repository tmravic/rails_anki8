class MoviesController < ApplicationController
  # This one line does magic:
  # - loads @movie / @movies automatically
  # - checks authorization using current_ability
  # - raises AccessDenied (caught in ApplicationController) if not allowed
  load_and_authorize_resource

  def index
    # @movies is already filtered to what the user can :read
  end

  def show
    # @movie was loaded & authorized for :read or :show
  end

  def new
    # @movie = Movie.new  ← already done by load_and_authorize_resource
    # and it passed :new / :create check
  end

  def edit
    # @movie loaded and authorized for :edit / :update
  end

  def create
    # @movie already built from params[:movie] by load_and_authorize_resource
    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: "Movie was successfully created." }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: "Movie was successfully updated." }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @movie.destroy!

    respond_to do |format|
      format.html { redirect_to movies_url, notice: "Movie was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def movie_params
    params.expect(movie: [:title, :year, :actress_id])
  end
end