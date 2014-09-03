class Admin::SessionsController < Admin::AdminController
  make_resourceful do
    actions :index, :edit, :new
  end

  def update
    load_object
    if current_object.update_attributes(params[:session], :without_protection => true)
      redirect_to admin_sessions_path

    else
      render :edit
    end
  end

  def create
    # find exact match by name
    presenter = Participant.where(:name => params[:session][:name]).first

    unless presenter
      presenter = Participant.new(:name => params[:session][:name]).tap do |p|
        p.save(validate: false)
      end
    end

    @session = Event.current_event.sessions.new(params[:session], :without_protection => true)
    @session.participant = presenter
    @session.timeslot_id = params[:session][:timeslot_id]
    @session.room_id = params[:session][:room_id]

    if @session.save
      flash[:notice] = "Presentation added"
      redirect_to admin_sessions_path
    else
      render :new
    end
  end

  def current_objects
    @current_objects ||= Event.current_event.sessions.sort_by{ |s| -s.created_at.to_i}
  end
end
