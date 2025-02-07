class CompaniesController < InheritedResources::Base
  respond_to :html, :json

  def destroy
    destroy! { contacts_path }
  end

  def autocomplete
    @companies = Company.order(:name).where("name like ?", "%#{params[:term]}%")
    render :json => @companies.map(&:name)
  end

  def full_display?(company)
    company == @company
  end
  helper_method :full_display?
end
