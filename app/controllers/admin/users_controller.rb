class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: %i[edit update]

  def index
    @users = User.order(:name)
  end

  def new
    @user = User.new(role: :member, active: true)
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    if @user.save
      record_activity("user.created", @user)
      redirect_to admin_users_path, notice: "Usuário criado. Compartilhe a senha inicial de forma segura."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user == current_user && params.dig(:user, :active) == "0"
      redirect_to admin_users_path, alert: "Você não pode desativar a própria conta."
    elsif @user.update(update_params)
      record_activity("user.updated", @user)
      redirect_to admin_users_path, notice: "Usuário atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email_address, :role, :active, :password, :password_confirmation)
    end

    def update_params
      user_params.tap do |attributes|
        if attributes[:password].blank?
          attributes.delete(:password)
          attributes.delete(:password_confirmation)
        end
      end
    end
end
