class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: %i[update]

  def index
    @users = User.order(:name)
  end

  def new
    @user = User.new(role: :member, active: true)
  end

  def create
    @user = User.new(user_params.merge(password: SecureRandom.base58(32), invited_at: Time.current))
    if @user.save
      PasswordsMailer.reset(@user).deliver_later
      record_activity("user.invited", @user)
      redirect_to admin_users_path, notice: "Convite enviado para #{@user.email_address}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user == current_user && params.dig(:user, :active) == "0"
      redirect_to admin_users_path, alert: "Você não pode desativar a própria conta."
    elsif @user.update(user_params.slice(:role, :active))
      record_activity("user.updated", @user)
      redirect_to admin_users_path, notice: "Usuário atualizado."
    else
      redirect_to admin_users_path, alert: @user.errors.full_messages.to_sentence
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email_address, :role, :active)
    end
end
