class CardsController < ApplicationController
  before_action :set_card, only: [:show, :edit, :update]

  def new
    @card = Card.new
    @users = User.all
  end

  def show

  end

  def edit
    @users = User.all
  end

  def update
    if @card.update(card_params)
      redirect_to @card, notice: 'Card was updated'
    else
      @users = User.all
      render :edit
    end
  end

  def create
    @card = Card.new(card_params)
    if @card.save
      redirect_to @card, notice: 'Card was saved'
    else
      @users = User.all
      render :new
    end
  end

  private

  def card_params
    params.expect(card: [:card_number, :user_id, :image])
  end

  def set_card
    @card = Card.find(params[:id])
  end
end
