class MissionsController < ApplicationController
  before_action :set_mission, only: %i[ show edit update destroy ]
  # Allow merchants to access new/create so merchants can create missions.
  # mission_admin authentication still required for other management actions.
  before_action :authenticate_mission_admin!, except: [:index, :show, :new, :create, :complete_via_url, :finalize_complete]
  before_action :authenticate_user!, only: [:complete_via_url, :finalize_complete]

  # GET /missions or /missions.json
  def index
    @missions = Mission.all
  end

  # GET /missions/1 or /missions/1.json
  def show
    @mission = Mission.find(params[:id])

    if mission_admin_signed_in? && @mission.mission_admin_id == current_mission_admin.id
      render :show_admin and return
    elsif merchant_signed_in? && @mission.merchant_id == current_merchant.id
      render :show_admin and return
    end

    render :show
  end

  # GET /missions/new
  def new
    if merchant_signed_in?
      @mission = current_merchant.missions.new
    elsif mission_admin_signed_in?
      @mission = current_mission_admin.missions.new
    end
  end

  # GET /missions/1/edit
  def edit
  end

  # POST /missions or /missions.json
  def create
    if merchant_signed_in?
      @mission = current_merchant.missions.new(mission_params)
    elsif mission_admin_signed_in?
      @mission = current_mission_admin.missions.new(mission_params)
    else
      @mission = Mission.new(mission_params)
    end

    respond_to do |format|
      if @mission.save
        format.html { redirect_to @mission, notice: "Mission was successfully created." }
        format.json { render :show, status: :created, location: @mission }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @mission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /missions/1 or /missions/1.json
  def update
    respond_to do |format|
      if @mission.update(mission_params)
        format.html { redirect_to @mission, notice: "Mission was successfully updated." }
        format.json { render :show, status: :ok, location: @mission }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @mission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /missions/1 or /missions/1.json
  def destroy
    @mission.destroy!

    respond_to do |format|
      format.html { redirect_to missions_path, status: :see_other, notice: "Mission was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # GET /missions/complete
  def complete_via_url
    if request.get?
      payload = params[:payload]
      sig = params[:sig]
      if payload.present? && sig.present?
        expected_sig = OpenSSL::HMAC.digest(
          "SHA256",
          Rails.application.credentials.qr_secret,
          payload
        )
        expected_sig_encoded = Base64.urlsafe_encode64(expected_sig)[0, 8]

        if ActiveSupport::SecurityUtils.secure_compare(expected_sig_encoded, sig)
          parts = payload.split(":")
          code = parts[0]
          timestamp = parts[1].to_i
          mission = Mission.find_by(unique_code: code)
          if mission
            if Time.now.to_i - timestamp > 5.minutes.to_i
              redirect_to root_path, alert: "QRコードの有効期限が切れています" and return
            end
            # Pass the original payload and sig so the confirmation form can submit them
            @payload = payload
            @sig = sig
            render :confirm_complete, locals: { mission: mission, code: code }
          else
            redirect_to root_path, alert: "無効なコードです"
          end
        else
          redirect_to root_path, alert: "無効なQRコードです" and return
        end
      else
        render :complete_via_url
      end
    elsif request.post?
      payload = params[:payload]
      parts = payload.split(":")
      code = parts[0]
      mission = Mission.find_by(unique_code: code)
      if mission
        # Generate a fresh signed payload for the finalize step
        ts = Time.now.to_i
        @payload = "#{code}:#{ts}"
        raw_sig = OpenSSL::HMAC.digest("SHA256", Rails.application.credentials.qr_secret, @payload)
        @sig = Base64.urlsafe_encode64(raw_sig)[0,8]

        render :confirm_complete, locals: { mission: mission, code: code } and return
      else
        redirect_to root_path, alert: "無効なコードです"
      end
    end
  end

  def finalize_complete
    payload = params[:payload]
    sig = params[:sig]
    if payload.present? && sig.present?
      expected_sig = OpenSSL::HMAC.digest(
        "SHA256",
        Rails.application.credentials.qr_secret,
        payload
      )
      expected_sig_encoded = Base64.urlsafe_encode64(expected_sig)[0, 8]

      if ActiveSupport::SecurityUtils.secure_compare(expected_sig_encoded, sig)
        parts = payload.split(":")
        code = parts[0]
        mission = Mission.find_by(unique_code: code)

        if mission
          recent = PointTransaction.where(
            user: current_user,
            mission: mission,
            transaction_type: "earn"
          ).where("created_at >= ?", 1.hour.ago).exists?

          if recent
            redirect_to scanqrcode_path, alert: "このミッションは1時間以内にクリア済みです。"
            return
          end

          PointTransaction.create!(
            user: current_user,
            merchant: mission.merchant,
            mission_admin: (defined?(current_mission_admin) ? current_mission_admin : nil),
            mission: mission,
            transaction_type: "earn",
            amount: mission.point,
            description: "ミッションクリア: #{mission.title}"
          )

          redirect_to root_path, notice: "ミッションを完了しました！#{mission.point}ポイントを付与されました！"
        else
          redirect_to root_path, alert: "無効なコードです"
        end
      else
        redirect_to root_path, alert: "無効なQRコードです" and return
        alert("コードを入力してください")
      end
    else
      redirect_to complete_via_url_missions_path
    end
  end

  def kiosk
    @mission = Mission.find(params[:id])
    generate_url

    if mission_admin_signed_in? && @mission.mission_admin_id == current_mission_admin.id
      render :kiosk and return
    elsif merchant_signed_in? && @mission.merchant_id == current_merchant.id
      render :kiosk and return
    else
      redirect_to root_path
    end
  end

  def generate_url
    @mission = Mission.find(params[:id])
    unique_code = @mission.unique_code
    ts = Time.now.to_i
    device_id = params[:device_id]
    @payload = "#{unique_code}:#{ts}:#{device_id}"

    sig = OpenSSL::HMAC.digest(
      "SHA256",
      Rails.application.credentials.qr_secret,
      @payload
    )
    @sig = Base64.urlsafe_encode64(sig)[0, 8]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mission
      @mission = Mission.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def mission_params
      params.require(:mission).permit(:title, :description, :point)
    end
end
