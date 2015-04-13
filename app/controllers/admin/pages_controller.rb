class Admin::PagesController < Admin::AdminController
  authorize_resource
  before_action :set_user, only: [:index]
  before_action :set_page, only: [:show, :edit, :update, :destroy]

  def index
    @pages = current_user.pages.order('position asc')
  end

  def show
  end

  def new
    @page = current_user.pages.build
  end

  def edit
  end

  def create
    @page = Page.new(page_params.merge(user_id: current_user.id))
    if @page.save
      redirect_to [:admin, @page], notice: 'Page was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @page.update(cover_id: nil) if params[:cover_remove] == 'true'
    if @page.update(page_params)
      redirect_to [:admin, @page], notice: 'Page was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @page.destroy
    redirect_to admin_pages_url notice: 'Page was successfully destroyed.'
  end

  def sort
    params[:page].each_with_index do |id, index|
      Page.find(id).update(position: index+1)
    end
    render nothing: true
  end

  private
    def set_user
      @user = User.find(params[:user_id]) if params[:user_id].present?
    end

    def set_page
      @page = Page.find(params[:id])
    end

    def page_params
      params.require(:page).permit(:title, :content, :position, :cover, :slug)
    end
end
