class Admin::NewspapersController < Admin::BaseController
  before_action :set_newspaper, only: %i[show edit update destroy]

  def index
    @newspapers = Newspaper.alphabetical
  end

  def show
  end

  def new
    @newspaper = Newspaper.new(defaults)
  end

  def create
    @newspaper = Newspaper.new(newspaper_params)
    if @newspaper.save
      record_activity("newspaper.created", @newspaper)
      redirect_to admin_newspaper_path(@newspaper), notice: "Jornal cadastrado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @newspaper.update(newspaper_params)
      record_activity("newspaper.updated", @newspaper)
      redirect_to admin_newspaper_path(@newspaper), notice: "Jornal atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @newspaper.destroy
      record_activity("newspaper.deleted", nil, { name: @newspaper.name })
      redirect_to admin_newspapers_path, notice: "Jornal removido.", status: :see_other
    else
      redirect_to admin_newspaper_path(@newspaper), alert: "O jornal possui capturas e não pode ser removido."
    end
  end

  private
    def set_newspaper
      @newspaper = Newspaper.find(params[:id])
    end

    def newspaper_params
      params.require(:newspaper).permit(:name, :slug, :homepage_url, :category, :country, :time_zone, :capture_time, :desktop_enabled, :mobile_enabled, :active)
    end

    def defaults
      { country: "Brasil", time_zone: "America/Sao_Paulo", capture_time: "08:00", desktop_enabled: true, mobile_enabled: true, active: true }
    end
end
