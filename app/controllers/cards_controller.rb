class CardsController < ApplicationController
  def new
    @card = Card.new
    @users = User.all
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
    params.expect(card: [:card_number, :user_id])
  end
end
