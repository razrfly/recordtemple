class Admin::PagesController < Admin::AdminController
  before_action :set_page, only: [:show, :edit, :update, :destroy]

  def index
    @pages = Page.where(user_id: current_user.id).order('position asc')
  end

  def show
  end

  def new
    @page = current_user.pages.build
  end

  def edit
  end

  def create
    @page = Page.new(page_params)
    if @page.save
      redirect_to admin_user_page_path(current_user, @page), notice: 'Page was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @page.update(cover_id: nil) if params[:cover_remove] == 'true'
    if @page.update(page_params)
      redirect_to admin_user_page_path(current_user, @page), notice: 'Page was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @page.destroy
    redirect_to admin_user_pages_url(current_user), notice: 'Page was successfully destroyed.'
  end

  def sort
    params[:page].each_with_index do |id, index|
      Page.find(id).update(position: index+1)
    end
    render nothing: true
  end

  private
    def set_page
      @page = Page.find(params[:id])
    end

    def page_params
      params.require(:page).permit(:title, :content, :user_id, :position, :cover, :slug)
    end
end
